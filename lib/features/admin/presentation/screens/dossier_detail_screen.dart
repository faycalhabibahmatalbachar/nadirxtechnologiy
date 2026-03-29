import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
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
    {'value': 'normal', 'label': '—'},
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
    final dbValue = tag == 'normal' ? null : tag;
    await ref.read(supabaseClientProvider)
        .from('inscriptions')
        .update({'tag_admin': dbValue})
        .eq('id', widget.inscriptionId);
    
    setState(() {
      _selectedTag = tag;
      _inscription = {...?_inscription, 'tag_admin': dbValue};
    });
  }

  Future<void> _setViewed(bool viewed) async {
    await ref.read(supabaseClientProvider)
        .from('inscriptions')
        .update({'admin_viewed': viewed})
        .eq('id', widget.inscriptionId);

    setState(() {
      _inscription = {...?_inscription, 'admin_viewed': viewed};
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
        return 'Normal';
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
            // Identité + ID
            _buildIdentitySection(),
            const SizedBox(height: 24),
            // Contact
            _buildContactSection(),
            const SizedBox(height: 24),
            // Photo participant (cadre 4x4)
            _buildPhotoSection(),
            const SizedBox(height: 24),
            // Administration / notes
            _buildAdminSection(),
            const SizedBox(height: 24),
            // Informations personnelles
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            // Profil professionnel
            _buildProfessionSection(),
            const SizedBox(height: 24),
            // Documents (CV)
            _buildDocumentsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_inscription!['prenom']} ${_inscription!['nom']}',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${_inscription!['id']}',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoBadge(
            _getTagLabel(_inscription!['tag_admin'] as String?),
            PhosphorIcons.tag(),
            color: _getTagColor(_inscription!['tag_admin'] as String?),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildPhotoSection() {
    final photoUrl = _inscription!['photo_participant_url'] as String;

    Future<void> download() async {
      final url = Uri.parse(photoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PHOTO PARTICIPANT', PhosphorIcons.image()),
          const Divider(color: AppColors.border, height: 24),
          Row(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withAlpha(128)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.contain, // 4x4 sans couper l'image
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: _showFullPhoto,
                      icon: Icon(PhosphorIcons.eye(), size: 18),
                      label: const Text('Voir'),
                    ),
                    TextButton.icon(
                      onPressed: download,
                      icon: Icon(PhosphorIcons.downloadSimple(), size: 18),
                      label: const Text('Télécharger'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildPersonalInfoSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('INFORMATIONS PERSONNELLES', PhosphorIcons.user()),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            PhosphorIcons.calendar(),
            'Date de Naissance',
            _formatDate(_inscription!['date_naissance'] as String),
          ),
          _buildInfoRow(
            PhosphorIcons.genderIntersex(),
            'Genre',
            (_inscription!['genre'] as String?) ?? '-',
          ),
          _buildInfoRow(
            PhosphorIcons.phone(),
            'Téléphone',
            _inscription!['telephone'] as String,
          ),
          _buildInfoRow(
            PhosphorIcons.mapPin(),
            'Ville',
            _inscription!['ville'] as String,
          ),
          _buildInfoRow(
            PhosphorIcons.globe(),
            'Nationalité',
            (_inscription!['nationalite'] as String?) ?? 'Tchadienne',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildInfoBadge(String text, PhosphorIconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: (color ?? AppColors.border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: color ?? AppColors.textPrimary,
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
          // Email supprimé (inscription sans email)
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
          _buildSectionHeader('PROFIL PROFESSIONNEL', PhosphorIcons.briefcase()),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            PhosphorIcons.userFocus(),
            'Situation',
            _formatSituation(_inscription!['situation_actuelle'] as String),
          ),
          _buildInfoRow(
            PhosphorIcons.chartBar(),
            'Niveau IT',
            _formatNiveau(_inscription!['niveau_informatique'] as String),
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
          if (cvUrl != null) ...[
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
          ] else
            Text(
              'Aucun CV',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildAdminSection() {
    final statut = (_inscription!['statut'] as String?) ?? 'confirme';
    final statutLower = statut.toLowerCase();
    final statutLabel = (statutLower == 'confirme' ||
            statutLower == 'confirmé' ||
            statutLower == 'confirmee')
        ? 'Confirmé ✓'
        : statut;

    final isViewed = _inscription!['admin_viewed'] == true;
    final rgpdAccepted = _inscription!['consentement_rgpd'] == true;

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ADMINISTRATION', PhosphorIcons.wrench()),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            PhosphorIcons.shieldCheck(),
            'Statut',
            statutLabel,
          ),
          const SizedBox(height: 8),
          Text(
            'Catégorie',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTag,
            items: _tagOptions
                .map((o) => DropdownMenuItem<String>(
                      value: o['value'],
                      child: Text(o['label']!),
                    ))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              _updateTag(v);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            dropdownColor: AppColors.surface,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            iconEnabledColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examiné',
                      style: GoogleFonts.inter(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isViewed ? '✓ Oui' : '✗ Non',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isViewed,
                activeColor: AppColors.primary,
                onChanged: _setViewed,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Note
          Text(
            'NOTES INTERNES',
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
              hintText: '(Aucune note)',
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Inscrit: ${_formatDate(_inscription!['created_at'] as String)}',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'RGPD: ${rgpdAccepted ? '✓ Accepté' : '✗ Refusé'}',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
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
