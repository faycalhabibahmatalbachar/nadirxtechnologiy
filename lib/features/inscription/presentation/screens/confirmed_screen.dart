import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final AudioPlayer _successPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDimensions.durationPulse,
    )..repeat(reverse: true);

    _playSuccessSoundOncePerDossier();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSoundOncePerDossier() async {
    try {
      final id = widget.inscription.id.trim();
      if (id.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final key = 'success_sound_played_$id';
      final alreadyPlayed = prefs.getBool(key) == true;
      if (alreadyPlayed) return;

      await _successPlayer.play(AssetSource('audio/success.mp3'));
      await prefs.setBool(key, true);
    } catch (_) {
      // ignore
    }
  }

  Future<Uint8List?> _tryDownloadBytes(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      final client = HttpClient();
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      return await consolidateHttpClientResponseBytes(res);
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image?> _decodeImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _composeQrWithAvatar({
    required Uint8List qrPngBytes,
    required Uint8List avatarBytes,
  }) async {
    final qrImg = await _decodeImage(qrPngBytes);
    final avatarImg = await _decodeImage(avatarBytes);
    if (qrImg == null || avatarImg == null) return null;

    final width = qrImg.width.toDouble();
    final height = qrImg.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);

    canvas.drawImage(qrImg, Offset.zero, Paint());

    final center = Offset(width / 2, height / 2);
    final avatarRadius = width * 0.15;
    final borderRadius = avatarRadius + (width * 0.012);

    // White border circle
    canvas.drawCircle(
      center,
      borderRadius,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // Clip avatar in circle
    final avatarRect = Rect.fromCircle(center: center, radius: avatarRadius);
    canvas.save();
    canvas.clipPath(Path()..addOval(avatarRect));
    canvas.drawImageRect(
      avatarImg,
      Rect.fromLTWH(
        0,
        0,
        avatarImg.width.toDouble(),
        avatarImg.height.toDouble(),
      ),
      avatarRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    final picture = recorder.endRecording();
    final outImg = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await outImg.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _share() async {
    final dossier = widget.inscription.shortId;
    final fullName = widget.inscription.nomComplet;

    final shareText = [
      'Inscription confirmée — NADIRX TECHNOLOGY',
      '$fullName',
      'N° dossier: $dossier',
      'Formation: ${widget.session.titre}',
      'Dates: ${widget.session.datesFormatted}',
      'Lieu: ${widget.session.lieu}',
      'Contact: +235 68 88 12 26',
      if (AppStrings.apkDownloadUrl.trim().isNotEmpty)
        'Télécharger l\'application: ${AppStrings.apkDownloadUrl}',
      'Formulaire alternatif (si besoin): ${AppStrings.googleFormUrl}',
      '#NADIRXTechnology #LalekouInformatique',
    ].join('\n');

    try {
      final qrData = AppStrings.googleFormUrl;
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );
      final byteData = await painter.toImageData(
        768,
        format: ui.ImageByteFormat.png,
      );

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) {
        await Share.share(shareText);
        return;
      }

      Uint8List finalQrBytes = bytes;
      final photoUrl = widget.inscription.photoParticipantUrl.trim();
      if (photoUrl.isNotEmpty) {
        final avatarBytes = await _tryDownloadBytes(photoUrl);
        if (avatarBytes != null && avatarBytes.isNotEmpty) {
          final composed = await _composeQrWithAvatar(
            qrPngBytes: bytes,
            avatarBytes: avatarBytes,
          );
          if (composed != null && composed.isNotEmpty) {
            finalQrBytes = composed;
          }
        }
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/nadirx_dossier_$dossier.png');
      await file.writeAsBytes(finalQrBytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
      );
    } catch (_) {
      await Share.share(shareText);
    }
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
          '${widget.inscription.nomComplet} !',
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
            icon: PhosphorIcons.certificate(),
            label: 'Attestation',
            value: AppStrings.formationAttestation,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 800.ms);
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
