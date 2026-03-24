import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../../../../core/widgets/cyber_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Vérifier si l'utilisateur est admin
        final isAdmin = response.user!.userMetadata?['role'] == 'admin';
        
        if (isAdmin) {
          if (mounted) {
            context.go('/admin/dashboard');
          }
        } else {
          await Supabase.instance.client.auth.signOut();
          setState(() {
            _errorMessage = 'Accès non autorisé';
            _isLoading = false;
          });
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CyberBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône cadenas
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.error, width: 1),
                    ),
                    child: Icon(
                      PhosphorIcons.lockKey(),
                      color: AppColors.error,
                      size: 28,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 24),
                  // Titre
                  Text(
                    AppStrings.adminLogin,
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.error,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 32),
                  // Formulaire
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CyberTextField(
                          label: AppStrings.adminEmail,
                          prefixIcon: PhosphorIcons.envelopeSimple(),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CyberTextField(
                          label: AppStrings.adminPassword,
                          prefixIcon: PhosphorIcons.key(),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? PhosphorIcons.eye()
                                  : PhosphorIcons.eyeSlash(),
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.warningCircle(),
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.inter(
                                      color: AppColors.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        CyberButton(
                          label: AppStrings.adminConnexion,
                          icon: PhosphorIcons.shieldCheck(),
                          isLoading: _isLoading,
                          onPressed: _login,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: 24),
                  // Retour
                  TextButton.icon(
                    onPressed: () {
                      context.go('/splash');
                    },
                    icon: Icon(
                      PhosphorIcons.arrowLeft(),
                      size: 18,
                    ),
                    label: Text(
                      'Retour',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
