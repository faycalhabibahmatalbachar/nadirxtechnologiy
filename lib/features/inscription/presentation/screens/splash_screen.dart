import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/nadirx_logo.dart';
import '../../../../core/widgets/terminal_loader.dart';
import '../../../../core/painters/matrix_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  bool _showInit = false;
  Timer? _progressTimer;
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _navigateAfterDelay();
  }

  void _startAnimations() {
    // Afficher le texte d'initialisation après 1.5s
    _initTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showInit = true;
        });
      }
    });

    // Animation de progression
    _progressTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (_progress < 1) {
        setState(() {
          _progress += 0.01;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));  // Réduit de 9s à 2s ⚡

    if (!mounted) return;

    // Vérifier si l'utilisateur a déjà une inscription
    final hasInscription = await LocalStorage.hasInscriptionId();

    if (hasInscription) {
      context.go('/mon-espace');
    } else {
      context.go('/inscription');
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CyberBackground(
        showScanlines: false,
        child: Stack(
          children: [
            // Matrix rain en arrière-plan
            const Positioned.fill(
              child: MatrixRainPainter(opacity: 0.04),
            ),
            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo NADIRX animé
                  const NadirxLogo(animate: true),
                  const SizedBox(height: 40),
                  // Texte d'initialisation
                  AnimatedOpacity(
                    opacity: _showInit ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      AppStrings.splashInit,
                      style: GoogleFonts.sourceCodePro(
                        color: AppColors.primary,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Barre de progression style terminal
                  TerminalLoader(
                    progress: _progress,
                    message: '',
                  ),
                ],
              ),
            ),
            // Footer
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.shieldCheck(),
                        color: AppColors.primary.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NADIRX TECHNOLOGIE',
                        style: GoogleFonts.shareTechMono(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '+23568881226 - 91912191',
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
