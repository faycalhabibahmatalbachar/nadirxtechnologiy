import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../shared/providers/supabase_provider.dart';

class DossierDetailScreen extends ConsumerStatefulWidget {
  final String inscriptionId;

  const DossierDetailScreen({
    super.key,
    required this.inscriptionId,
  });

  @override
  ConsumerState<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends ConsumerState<DossierDetailScreen> {
  Map<String, dynamic>? _inscription;
  bool _isLoading = true;
  final _noteController = TextEditingController();
  String _selectedTag = 'normal';

  final List<Map<String, String>> _tagOptions = [
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'prioritaire', 'label': 'Prioritaire'},
    {'value': 'a_rappeler', 'label': 'À rappeler'},
    {'value': 'doublon', 'label': 'Doublon'},
    {'value': 'vip', 'label': 'VIP'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDossier();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDossier() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(supabaseClientProvider)
          .from('inscriptions')
          .select()
          .eq('id', widget.inscriptionId)
          .single();

      // Marquer comme vu
      await ref.read(supabaseClientProvider)
          .from('inscriptions')
          .update({'admin_viewed': true})
          .eq('id', widget.inscriptionId);

      setState(() {
        _inscription = response;
        _selectedTag = response['tag_admin'] as String? ?? 'normal';
        _noteController.text = response['note_admin'] as String? ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTag(String tag) async {
    await ref.read(supabaseClientProvider)
        .from('inscriptions')
        .update({'tag_admin': tag})
        .eq('id', widget.inscriptionId);
    
    setState(() {
      _selectedTag = tag;
    });
  }

  Future<void> _saveNote() async {
    await ref.read(supabaseClientProvider)
        .from('inscriptions')
        .update({'note_admin': _noteController.text})
        .eq('id', widget.inscriptionId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note sauvegardée')),
      );
    }
  }

  Future<void> _openWhatsapp() async {
    final phone = _inscription?['telephone'] as String?;
    if (phone == null) return;
    
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall() async {
    final phone = _inscription?['telephone'] as String?;
    if (phone == null) return;
    
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'DOSSIER',
          style: GoogleFonts.shareTechMono(
            color: AppColors.primary,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.whatsappLogo(), color: AppColors.secondary),
            onPressed: _openWhatsapp,
          ),
          IconButton(
            icon: Icon(PhosphorIcons.phone(), color: AppColors.primary),
            onPressed: _makeCall,
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _inscription == null
              ? _buildNoData()
              : _buildContent(),
    );
  }

  Widget _buildNoData() {
    return CyberBackground(
      child: Center(
        child: Text(
          'Dossier non trouvé',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CyberBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo et identité
            _buildIdentitySection(),
            const SizedBox(height: 24),
            // Contact
            _buildContactSection(),
            const SizedBox(height: 24),
            // Profession
            _buildProfessionSection(),
            const SizedBox(height: 24),
            // Documents
            _buildDocumentsSection(),
            const SizedBox(height: 24),
            // Admin section
            _buildAdminSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return CyberCard(
      child: Column(
        children: [
          // Photo
          Center(
            child: GestureDetector(
              onTap: () => _showFullPhoto(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryGlow, blurRadius: 16),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _inscription!['photo_participant_url'] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: Icon(
                        PhosphorIcons.user(),
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nom complet
          Text(
            '${_inscription!['prenom']} ${_inscription!['nom']}',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              'CONFIRMÉ',
              style: GoogleFonts.shareTechMono(
                color: AppColors.primary,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Infos identité
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoBadge(
                _inscription!['genre'] ?? '-',
                PhosphorIcons.genderIntersex(),
              ),
              const SizedBox(width: 12),
              _buildInfoBadge(
                _inscription!['nationalite'] ?? 'Tchadienne',
                PhosphorIcons.globe(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Né(e) le ${_formatDate(_inscription!['date_naissance'] as String)}',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInfoBadge(String text, PhosphorIconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CONTACT', PhosphorIcons.addressBook()),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            PhosphorIcons.phone(),
            'Téléphone',
            _inscription!['telephone'] as String,
          ),
          _buildInfoRow(
            PhosphorIcons.envelope(),
            'Email',
            _inscription!['email'] as String,
          ),
          _buildInfoRow(
            PhosphorIcons.mapPin(),
            'Ville',
            _inscription!['ville'] as String,
          ),
          if (_inscription!['quartier'] != null)
            _buildInfoRow(
              PhosphorIcons.house(),
              'Quartier',
              _inscription!['quartier'] as String,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildProfessionSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PROFESSION', PhosphorIcons.briefcase()),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            PhosphorIcons.userFocus(),
            'Situation',
            _formatSituation(_inscription!['situation_actuelle'] as String),
          ),
          if (_inscription!['domaine_activite'] != null)
            _buildInfoRow(
              PhosphorIcons.folders(),
              'Domaine',
              _inscription!['domaine_activite'] as String,
            ),
          _buildInfoRow(
            PhosphorIcons.chartBar(),
            'Niveau informatique',
            _formatNiveau(_inscription!['niveau_informatique'] as String),
          ),
          const SizedBox(height: 12),
          Text(
            'Objectif de formation',
            style: GoogleFonts.inter(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _inscription!['objectif_formation'] as String,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildDocumentsSection() {
    final cvUrl = _inscription!['cv_url'] as String?;
    
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('DOCUMENTS', PhosphorIcons.files()),
          const Divider(color: AppColors.border, height: 24),
          Row(
            children: [
              Icon(
                PhosphorIcons.image(),
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Photo participant',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: _showFullPhoto,
                child: const Text('Voir'),
              ),
            ],
          ),
          if (cvUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  PhosphorIcons.filePdf(),
                  color: AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'CV (optionnel)',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse(cvUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Voir'),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildAdminSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ADMINISTRATION', PhosphorIcons.wrench()),
          const Divider(color: AppColors.border, height: 24),
          // Tag
          Text(
            'Tag',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tagOptions.map((option) {
              final isSelected = _selectedTag == option['value'];
              return GestureDetector(
                onTap: () => _updateTag(option['value']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getTagColor(option['value']).withOpacity(0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? _getTagColor(option['value'])
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    option['label']!,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? _getTagColor(option['value'])
                          : AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Note
          Text(
            'Note interne',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Ajouter une note...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _saveNote,
              icon: Icon(PhosphorIcons.floppyDisk(), size: 18),
              label: const Text('Sauvegarder'),
            ),
          ),
          const SizedBox(height: 16),
          // Métadonnées
          Text(
            'Inscrit le ${_formatDate(_inscription!['created_at'] as String)}',
            style: GoogleFonts.inter(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }

  Widget _buildSectionHeader(String title, PhosphorIconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          '[  $title  ]',
          style: GoogleFonts.shareTechMono(
            color: AppColors.primary,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(PhosphorIconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPhoto() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _inscription!['photo_participant_url'] as String,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    PhosphorIcons.x(),
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatSituation(String situation) {
    switch (situation) {
      case 'etudiant':
        return 'Étudiant';
      case 'salarie_prive':
        return 'Salarié (secteur privé)';
      case 'salarie_public':
        return 'Salarié (secteur public)';
      case 'freelance':
        return 'Freelance';
      case 'entrepreneur':
        return 'Entrepreneur';
      case 'sans_emploi':
        return 'Sans emploi';
      default:
        return situation;
    }
  }

  String _formatNiveau(String niveau) {
    switch (niveau) {
      case 'debutant':
        return 'Débutant';
      case 'intermediaire':
        return 'Intermédiaire';
      case 'avance':
        return 'Avancé';
      default:
        return niveau;
    }
  }
}
