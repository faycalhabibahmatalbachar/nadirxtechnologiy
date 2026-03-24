import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/cyber_background.dart';
import '../../../../core/widgets/nadirx_logo.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../../../core/widgets/terminal_loader.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/fcm_provider.dart';
import '../controllers/inscription_form_controller.dart';
import '../controllers/photo_upload_controller.dart';

class InscriptionFormScreen extends ConsumerStatefulWidget {
  const InscriptionFormScreen({super.key});

  @override
  ConsumerState<InscriptionFormScreen> createState() => _InscriptionFormScreenState();
}

class _InscriptionFormScreenState extends ConsumerState<InscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _quartierController = TextEditingController();
  final _domaineActiviteController = TextEditingController();
  final _objectifController = TextEditingController();

  DateTime? _dateNaissance;
  String? _genre;
  String? _ville;
  String _niveauInformatique = 'debutant';
  String _situationActuelle = 'etudiant';
  String? _commentConnu;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _quartierController.dispose();
    _domaineActiviteController.dispose();
    _objectifController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner votre date de naissance')),
      );
      return;
    }
    final photoState = ref.read(photoUploadControllerProvider);
    if (photoState.photoPath == null && photoState.photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo obligatoire')),
      );
      return;
    }
    final photoPath = photoState.photoPath;

    final formData = InscriptionFormData()
      ..prenom = _prenomController.text.trim()
      ..nom = _nomController.text.trim()
      ..dateNaissance = _dateNaissance
      ..genre = _genre
      ..telephone = '+235${_telephoneController.text.replaceAll(' ', '')}'
      ..ville = _ville ?? ''
      ..quartier = _quartierController.text.trim()
      ..situationActuelle = _situationActuelle
      ..domaineActivite = _domaineActiviteController.text.trim()
      ..niveauInformatique = _niveauInformatique
      ..objectifFormation = _objectifController.text.trim()
      ..photoPath = photoPath
      ..photoBytes = photoState.photoBytes
      ..commentConnu = _commentConnu
      ..consentementRgpd = true;

    ref.read(inscriptionFormControllerProvider.notifier).updateFormData(formData);
    ref.read(inscriptionFormControllerProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(inscriptionFormControllerProvider);
    final photoState = ref.watch(photoUploadControllerProvider);

    ref.listen<InscriptionFormState>(inscriptionFormControllerProvider, (prev, next) {
      if (next.status == InscriptionStatus.success && next.inscription != null && next.session != null) {
        showLocalNotification(
          title: 'Bienvenue, ${next.inscription!.prenom} ! 🛡️',
          body: 'Votre place est confirmée. NADIRX TECHNOLOGIE vous attend.',
        );
        context.go('/confirmed', extra: {
          'inscription': next.inscription,
          'session': next.session,
        });
      } else if (next.status == InscriptionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Erreur')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const NadirxLogo(compact: true),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      body: Stack(
        children: [
          const CyberBackground(child: SizedBox.expand()),
          // Formulaire
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // Section Identité
                  _buildSectionTitle(AppStrings.sectionIdentite),
                  const SizedBox(height: 16),
                  _buildIdentiteSection(),
                  const SizedBox(height: 24),
                  // Section Contact
                  _buildSectionTitle(AppStrings.sectionContact),
                  const SizedBox(height: 16),
                  _buildContactSection(),
                  const SizedBox(height: 24),
                  // Section Niveau
                  _buildSectionTitle(AppStrings.sectionNiveau),
                  const SizedBox(height: 16),
                  _buildNiveauSection(),
                  const SizedBox(height: 24),
                  // Section Photo
                  _buildSectionTitle(AppStrings.sectionPhoto),
                  const SizedBox(height: 16),
                  _buildPhotoSection(photoState),
                  const SizedBox(height: 32),
                  // Bouton de soumission
                  _buildSubmitButton(formState),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Overlay de chargement
          if (formState.status == InscriptionStatus.loading)
            TerminalProgressOverlay(
              isVisible: true,
              messages: [
                AppStrings.loadingSecurisation,
                AppStrings.loadingUpload,
                AppStrings.loadingEnregistrement,
                AppStrings.loadingConfirmation,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Divider(color: AppColors.border, height: 16);
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
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
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentiteSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CyberTextField(
                label: AppStrings.labelPrenom,
                hint: AppStrings.hintPrenom,
                prefixIcon: PhosphorIcons.userCircle(),
                controller: _prenomController,
                validator: Validators.prenom,
                inputFormatters: [NameInputFormatter()],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CyberTextField(
                label: AppStrings.labelNom,
                hint: AppStrings.hintNom,
                prefixIcon: PhosphorIcons.identificationCard(),
                controller: _nomController,
                validator: Validators.nom,
                inputFormatters: [NameInputFormatter()],
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CyberDatePicker(
          label: AppStrings.labelDateNaissance,
          prefixIcon: PhosphorIcons.calendarBlank(),
          value: _dateNaissance,
          firstDate: DateTime(1950),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
          onChanged: (date) {
            setState(() {
              _dateNaissance = date;
            });
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.labelGenre,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  _buildGenreChip(AppStrings.genreHomme, 'homme'),
                  _buildGenreChip(AppStrings.genreFemme, 'femme'),
                  _buildGenreChip(AppStrings.genreAutre, 'autre'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreChip(String label, String value) {
    final isSelected = _genre == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _genre = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? AppColors.background : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final villes = [
      "N'Djaména", 'Moundou', 'Sarh', 'Abéché', 'Bongor', 'Doba', 'Kélo', 'Autre'
    ];

    return Column(
      children: [
        CyberTextField(
          label: AppStrings.labelTelephone,
          hint: AppStrings.hintTelephone,
          prefixIcon: PhosphorIcons.phone(),
          controller: _telephoneController,
          validator: Validators.telephone,
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneInputFormatter()],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CyberDropdown<String>(
          label: AppStrings.labelVille,
          hint: AppStrings.hintVille,
          prefixIcon: PhosphorIcons.mapPin(),
          value: _ville,
          items: villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) {
            setState(() {
              _ville = v;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNiveauSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNiveauCard(
                AppStrings.niveauDebutant,
                'debutant',
                PhosphorIcons.seal(),
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNiveauCard(
                AppStrings.niveauIntermediaire,
                'intermediaire',
                PhosphorIcons.sealCheck(),
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNiveauCard(
                AppStrings.niveauAvance,
                'avance',
                PhosphorIcons.sealPercent(),
                AppColors.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNiveauCard(String label, String value, PhosphorIconData icon, Color color) {
    final isSelected = _niveauInformatique == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _niveauInformatique = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? color : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(PhotoUploadState photoState) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (photoState.photoPath == null && photoState.photoBytes == null) ...[
            // Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Icon(
                PhosphorIcons.camera(),
                color: AppColors.textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.photoAjouter,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.photoPortrait,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CyberButton(
                    label: AppStrings.photoPrendre,
                    icon: PhosphorIcons.camera(),
                    isOutlined: true,
                    onPressed: () {
                      ref.read(photoUploadControllerProvider.notifier).pickFromCamera();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberButton(
                    label: AppStrings.photoGalerie,
                    icon: PhosphorIcons.image(),
                    isOutlined: true,
                    onPressed: () {
                      ref.read(photoUploadControllerProvider.notifier).pickFromGallery();
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            // Photo sélectionnée
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGlow, blurRadius: 16),
                      ],
                      image: DecorationImage(
                        image: photoState.photoBytes != null
                            ? MemoryImage(photoState.photoBytes!)
                            : ((photoState.photoPath ?? '').startsWith('blob:') ||
                                    (photoState.photoPath ?? '').startsWith('data:'))
                                ? NetworkImage(photoState.photoPath!)
                                : FileImage(File(photoState.photoPath!)) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(photoUploadControllerProvider.notifier).pickFromGallery();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.pencilSimple(),
                          color: AppColors.background,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '[ PHOTO AJOUTÉE ]',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.primary,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text(
                        'Supprimer la photo ?',
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                      ),
                      content: Text(
                        'Cette action est irréversible.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Annuler',
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ref.read(photoUploadControllerProvider.notifier).clear();
                          },
                          child: Text(
                            'Supprimer',
                            style: GoogleFonts.inter(color: AppColors.error),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(PhosphorIcons.trash(), size: 16),
              label: Text(
                'Supprimer',
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ref.read(photoUploadControllerProvider.notifier).pickFromGallery();
              },
              icon: Icon(PhosphorIcons.pencilSimple(), size: 16),
              label: Text(
                AppStrings.photoModifier,
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(InscriptionFormState formState) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CyberButton(
        label: AppStrings.btnValider,
        icon: PhosphorIcons.shieldCheck(),
        isLoading: formState.status == InscriptionStatus.loading,
        onPressed: _submitForm,
      ),
    );
  }
}
