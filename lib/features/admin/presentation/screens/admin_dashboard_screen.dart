import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../shared/providers/supabase_provider.dart';

enum InscriptionFilter { tous, nonVus, prioritaire, aRappeler, doublon, vip }

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  InscriptionFilter _currentFilter = InscriptionFilter.tous;
  List<Map<String, dynamic>> _inscriptions = [];
  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadInscriptions();
  }

  Future<void> _loadInscriptions() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(supabaseClientProvider)
          .from('inscriptions')
          .select()
          .order('created_at', ascending: false);

      final inscriptions = List<Map<String, dynamic>>.from(response);

      // Calculer les stats
      _stats = {
        'total': inscriptions.length,
        'nonVus': inscriptions.where((i) => i['admin_viewed'] != true).length,
        'prioritaire': inscriptions.where((i) => i['tag_admin'] == 'prioritaire').length,
      };

      setState(() {
        _inscriptions = inscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredInscriptions {
    switch (_currentFilter) {
      case InscriptionFilter.tous:
        return _inscriptions;
      case InscriptionFilter.nonVus:
        return _inscriptions.where((i) => i['admin_viewed'] != true).toList();
      case InscriptionFilter.prioritaire:
        return _inscriptions.where((i) => i['tag_admin'] == 'prioritaire').toList();
      case InscriptionFilter.aRappeler:
        return _inscriptions.where((i) => i['tag_admin'] == 'a_rappeler').toList();
      case InscriptionFilter.doublon:
        return _inscriptions.where((i) => i['tag_admin'] == 'doublon').toList();
      case InscriptionFilter.vip:
        return _inscriptions.where((i) => i['tag_admin'] == 'vip').toList();
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      context.go('/splash');
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'il y a ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return 'il y a ${diff.inHours}h';
    } else {
      return 'il y a ${diff.inDays}j';
    }
  }

  Color _getTagColor(String? tag) {
    switch (tag) {
      case 'prioritaire':
        return AppColors.warning;
      case 'a_rappeler':
        return AppColors.secondary;
      case 'doublon':
        return AppColors.error;
      case 'vip':
        return AppColors.tertiary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTagLabel(String? tag) {
    switch (tag) {
      case 'prioritaire':
        return 'Prioritaire';
      case 'a_rappeler':
        return 'À rappeler';
      case 'doublon':
        return 'Doublon';
      case 'vip':
        return 'VIP';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.adminTitle,
          style: GoogleFonts.shareTechMono(
            color: AppColors.error,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.signOut(), color: AppColors.error),
            onPressed: _logout,
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      body: CyberBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: _loadInscriptions,
                child: CustomScrollView(
                  slivers: [
                    // Stats
                    SliverToBoxAdapter(
                      child: _buildStatsRow(),
                    ),
                    // Filtres
                    SliverToBoxAdapter(
                      child: _buildFiltersRow(),
                    ),
                    // Liste des inscrits
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final inscription = _filteredInscriptions[index];
                          return _buildInscriptionCard(inscription);
                        },
                        childCount: _filteredInscriptions.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingScreen),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              _stats['total']?.toString() ?? '0',
              AppStrings.adminInscrits,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              _stats['nonVus']?.toString() ?? '0',
              AppStrings.adminNonVus,
              AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              _stats['prioritaire']?.toString() ?? '0',
              AppStrings.adminPrioritaire,
              AppColors.warning,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
        children: InscriptionFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _currentFilter = filter;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  String _getFilterLabel(InscriptionFilter filter) {
    switch (filter) {
      case InscriptionFilter.tous:
        return 'Tous';
      case InscriptionFilter.nonVus:
        return 'Non vus';
      case InscriptionFilter.prioritaire:
        return 'Prioritaire';
      case InscriptionFilter.aRappeler:
        return 'À rappeler';
      case InscriptionFilter.doublon:
        return 'Doublon';
      case InscriptionFilter.vip:
        return 'VIP';
    }
  }

  Widget _buildInscriptionCard(Map<String, dynamic> inscription) {
    final createdAt = DateTime.parse(inscription['created_at'] as String);
    final tag = inscription['tag_admin'] as String?;
    final isViewed = inscription['admin_viewed'] == true;

    return GestureDetector(
      onTap: () {
        context.push('/admin/dossier/${inscription['id']}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingScreen,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isViewed ? AppColors.surfaceVariant : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isViewed ? AppColors.border : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Photo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: inscription['photo_participant_url'] as String,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: Icon(
                      PhosphorIcons.user(),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: Icon(
                      PhosphorIcons.user(),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${inscription['prenom']} ${inscription['nom']}',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTagColor(tag).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getTagColor(tag).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _getTagLabel(tag),
                            style: GoogleFonts.inter(
                              color: _getTagColor(tag),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inscription['telephone'] as String,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${inscription['ville']} • ${inscription['situation_actuelle']}',
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Temps et flèche
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeAgo(createdAt),
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                PhosphorIcons.caretRight(),
                color: AppColors.textSecondary,
                size: 16,
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
