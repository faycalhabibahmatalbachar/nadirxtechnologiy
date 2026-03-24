import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../core/widgets/nadirx_logo.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/inscription_entity.dart';
import '../../domain/entities/session_formation_entity.dart';

class MonEspaceScreen extends ConsumerStatefulWidget {
  const MonEspaceScreen({super.key});

  @override
  ConsumerState<MonEspaceScreen> createState() => _MonEspaceScreenState();
}

class _MonEspaceScreenState extends ConsumerState<MonEspaceScreen> {
  InscriptionEntity? _inscription;
  SessionFormationEntity? _session;
  bool _isLoading = true;
  int _logoTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final inscriptionId = await LocalStorage.getInscriptionId();
    if (inscriptionId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final inscriptionData = await ref.read(inscriptionByIdProvider(inscriptionId).future);
      final sessionData = await ref.read(activeSessionProvider.future);

      if (inscriptionData != null && mounted) {
        setState(() {
          _inscription = InscriptionEntity.fromJson(inscriptionData);
          _session = sessionData != null ? SessionFormationEntity.fromJson(sessionData) : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 10) {
      _logoTapCount = 0;
      // Easter egg: accès admin après 10 taps
      Navigator.of(context).pushNamed('/admin/login');
    }
  }

  Future<void> _openWhatsapp() async {
    final url = Uri.parse('https://wa.me/23568663737');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall() async {
    final url = Uri.parse('tel:+23568881226');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail() async {
    final url = Uri.parse('mailto:nadirxtechnology@gmail.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: _handleLogoTap,
          onLongPress: () {
            // Easter egg: long press pour admin
            Navigator.of(context).pushNamed('/admin/login');
          },
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: NadirxLogo(compact: true),
          ),
        ),
        title: Text(
          AppStrings.monEspaceTitle,
          style: GoogleFonts.shareTechMono(
            color: AppColors.primary,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_inscription != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: CachedNetworkImageProvider(_inscription!.photoParticipantUrl),
              ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              color: AppColors.warning,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune inscription trouvée',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
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
            // Badge statut
            _buildStatusBadge(),
            const SizedBox(height: 24),
            // Profil participant
            _buildProfileCard(),
            const SizedBox(height: 24),
            // Détails formation
            _buildFormationCard(),
            const SizedBox(height: 24),
            // Programme
            if (_session != null) _buildProgrammeSection(),
            const SizedBox(height: 24),
            // Matériel requis
            _buildMaterielCard(),
            const SizedBox(height: 24),
            // Contact
            _buildContactSection(),
            const SizedBox(height: 40),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.shieldCheck(),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Text(
              AppStrings.monEspaceStatut,
              style: GoogleFonts.shareTechMono(
                color: AppColors.primary,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProfileCard() {
    return CyberCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.primaryGlow, blurRadius: 12),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: _inscription!.photoParticipantUrl,
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
                Text(
                  _inscription!.nomComplet,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${AppStrings.confirmedDossier} ',
                      style: GoogleFonts.sourceCodePro(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _inscription!.shortId,
                      style: GoogleFonts.sourceCodePro(
                        color: AppColors.primary,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildFormationCard() {
    if (_session == null) return const SizedBox.shrink();

    final joursRestants = _session!.joursRestants;

    return CyberCard(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppStrings.monEspaceFormation, PhosphorIcons.graduationCap()),
          const Divider(color: AppColors.border, height: 24),
          CyberInfoRow(
            icon: PhosphorIcons.calendarCheck(),
            label: 'Dates',
            value: _session!.datesFormatted,
          ),
          CyberInfoRow(
            icon: PhosphorIcons.clockCountdown(),
            label: 'Horaire',
            value: _session!.horaire,
          ),
          CyberInfoRow(
            icon: PhosphorIcons.mapPin(),
            label: 'Lieu',
            value: _session!.lieu,
          ),
          if (joursRestants > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.timer(),
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dans J-$joursRestants jours',
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.primary,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildProgrammeSection() {
    if (_session!.programme.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.monEspaceProgramme),
        const SizedBox(height: 12),
        ...List.generate(_session!.programme.length, (index) {
          final jour = _session!.programme[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Text(
                      'J${jour.jour}',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  jour.titre,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: jour.modules.map((m) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                PhosphorIcons.faders(),
                                color: AppColors.secondary,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildMaterielCard() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppStrings.monEspaceMateriel, PhosphorIcons.backpack()),
          const Divider(color: AppColors.border, height: 24),
          _buildMaterielItem(AppStrings.materielOrdi, PhosphorIcons.desktopTower()),
          _buildMaterielItem(AppStrings.materielNotes, PhosphorIcons.notePencil()),
          _buildMaterielItem(AppStrings.materielId, PhosphorIcons.identificationCard()),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }

  Widget _buildMaterielItem(String text, PhosphorIconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.monEspaceContact),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactButton(
                'WhatsApp',
                PhosphorIcons.whatsappLogo(),
                _openWhatsapp,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactButton(
                'Appeler',
                PhosphorIcons.phone(),
                _makeCall,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactButton(
                'Email',
                PhosphorIcons.envelope(),
                _sendEmail,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 500.ms);
  }

  Widget _buildContactButton(String label, PhosphorIconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        AppStrings.footer,
        style: GoogleFonts.shareTechMono(
          color: AppColors.textTertiary,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '[  $title  ]',
            style: GoogleFonts.shareTechMono(
              color: AppColors.primary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}
