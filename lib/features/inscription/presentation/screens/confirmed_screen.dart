import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/entities/inscription_entity.dart';
import '../../domain/entities/session_formation_entity.dart';

class ConfirmedScreen extends StatefulWidget {
  final InscriptionEntity inscription;
  final SessionFormationEntity session;

  const ConfirmedScreen({
    super.key,
    required this.inscription,
    required this.session,
  });

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDimensions.durationPulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _share() {
    Share.share(AppStrings.shareText);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CyberBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingScreen,
                vertical: 24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Animation succès
                  _buildSuccessAnimation(),
                  const SizedBox(height: 40),
                  // Texte principal
                  _buildMainText(),
                  const SizedBox(height: 24),
                  // Photo du participant
                  _buildParticipantPhoto(),
                  const SizedBox(height: 32),
                  // Card détails formation
                  _buildFormationCard(),
                  const SizedBox(height: 20),
                  // Message notification
                  _buildNotificationMessage(),
                  const SizedBox(height: 20),
                  // Numéro de dossier
                  _buildDossierNumber(),
                  const SizedBox(height: 32),
                  // Boutons
                  _buildButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercles concentriques qui pulsent
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08 * _pulseController.value),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15 * _pulseController.value),
              ),
            );
          },
        ),
        // Shield principal
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGlow,
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            PhosphorIcons.shieldCheck(),
            color: AppColors.background,
            size: 32,
          ),
        ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1.2, 1.2),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ).then().scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: 200.ms,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildMainText() {
    return Column(
      children: [
        Text(
          AppStrings.confirmedTitle,
          style: GoogleFonts.shareTechMono(
            color: AppColors.primary,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          AppStrings.confirmedFelicitations,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
        const SizedBox(height: 4),
        Text(
          '${widget.inscription.prenom} !',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
        const SizedBox(height: 16),
        Text(
          AppStrings.confirmedPlace,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.6,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildParticipantPhoto() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.primaryGlow, blurRadius: 16),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.inscription.photoParticipantUrl,
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
        ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
        const SizedBox(height: 12),
        Text(
          AppStrings.confirmedParticipant,
          style: GoogleFonts.shareTechMono(
            color: AppColors.primary,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
      ],
    );
  }

  Widget _buildFormationCard() {
    return CyberCard(
      withGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.shieldStar(),
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.session.titre,
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          CyberInfoRow(
            icon: PhosphorIcons.calendarCheck(),
            label: 'Dates',
            value: widget.session.datesFormatted,
          ),
          CyberInfoRow(
            icon: PhosphorIcons.clockCountdown(),
            label: 'Horaire',
            value: widget.session.horaire,
          ),
          CyberInfoRow(
            icon: PhosphorIcons.mapPin(),
            label: 'Lieu',
            value: widget.session.lieu,
          ),
          CyberInfoRow(
            icon: PhosphorIcons.users(),
            label: 'Promotion',
            value: 'Mai 2026 • ${widget.session.placesMax} participants max',
          ),
          CyberInfoRow(
            icon: PhosphorIcons.certificate(),
            label: 'Attestation',
            value: AppStrings.formationAttestation,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 800.ms);
  }

  Widget _buildNotificationMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.bellRinging(),
            color: AppColors.secondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.confirmedNotif,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 900.ms);
  }

  Widget _buildDossierNumber() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.confirmedDossier,
            style: GoogleFonts.sourceCodePro(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.inscription.shortId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Numéro copié !')),
              );
            },
            child: Row(
              children: [
                Text(
                  widget.inscription.shortId,
                  style: GoogleFonts.sourceCodePro(
                    color: AppColors.primary,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  PhosphorIcons.copy(),
                  color: AppColors.textSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 1000.ms);
  }

  Widget _buildButtons() {
    return Column(
      children: [
        CyberButton(
          label: AppStrings.btnMonEspace,
          icon: PhosphorIcons.terminal(),
          onPressed: () {
            context.go('/mon-espace');
          },
        ).animate().fadeIn(duration: 300.ms, delay: 1100.ms),
        const SizedBox(height: 12),
        CyberButton(
          label: AppStrings.btnPartager,
          icon: PhosphorIcons.shareNetwork(),
          isOutlined: true,
          onPressed: _share,
        ).animate().fadeIn(duration: 300.ms, delay: 1200.ms),
      ],
    );
  }
}
