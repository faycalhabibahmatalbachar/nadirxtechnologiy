import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../shared/providers/supabase_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  List<Map<String, dynamic>> _inscriptions = [];
  bool _isLoading = true;
  String _nameQuery = '';
  String _phoneQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInscriptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadInscriptions() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(supabaseClientProvider)
          .from('inscriptions')
          .select()
          .order('created_at', ascending: false);

      final inscriptions = List<Map<String, dynamic>>.from(response);

      setState(() {
        _inscriptions = inscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredInscriptions {
    final name = _nameQuery.trim().toLowerCase();
    final phoneDigits = _phoneQuery.replaceAll(RegExp(r'[^0-9]'), '');

    return _inscriptions.where((i) {
      final prenom = (i['prenom'] ?? '').toString().toLowerCase();
      final nom = (i['nom'] ?? '').toString().toLowerCase();
      final fullName = '$prenom $nom'.trim();
      final tel = (i['telephone'] ?? '')
          .toString()
          .replaceAll(RegExp(r'[^0-9]'), '');

      final matchesName = name.isEmpty ||
          prenom.contains(name) ||
          nom.contains(name) ||
          fullName.contains(name);
      final matchesPhone = phoneDigits.isEmpty || tel.contains(phoneDigits);

      return matchesName && matchesPhone;
    }).toList();
  }

  Future<void> _logout() async {
    await LocalStorage.logoutAdmin();
    if (mounted) {
      context.go('/admin/login');
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
                    // Recherche
                    SliverToBoxAdapter(child: _buildSearchRow()),
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

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingScreen),
      child: CyberCard(
        child: Column(
          children: [
            CyberTextField(
              label: 'Nom / prénom',
              prefixIcon: PhosphorIcons.magnifyingGlass(),
              controller: _nameController,
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _nameQuery = v),
            ),
            const SizedBox(height: 12),
            CyberTextField(
              label: 'Téléphone',
              prefixIcon: PhosphorIcons.phone(),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onChanged: (v) => setState(() => _phoneQuery = v),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
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
            color: isViewed ? AppColors.border : AppColors.primary.withAlpha(77),
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
                            color: _getTagColor(tag).withAlpha(38),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getTagColor(tag).withAlpha(128),
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
