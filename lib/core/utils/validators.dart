class Validators {
  const Validators._();

  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Ce champ est requis';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.trim().length < min) {
      return message ?? 'Minimum $min caractères requis';
    }
    return null;
  }

  static String? prenom(String? value) {
    final error = required(value, 'Prénom requis');
    if (error != null) return error;
    return minLength(value, 2, 'Prénom trop court (min. 2 caractères)');
  }

  static String? nom(String? value) {
    final error = required(value, 'Nom requis');
    if (error != null) return error;
    return minLength(value, 2, 'Nom trop court (min. 2 caractères)');
  }

  static String? dateNaissance(DateTime? value) {
    if (value == null) {
      return 'Date de naissance requise';
    }
    final now = DateTime.now();
    final age = now.year - value.year;
    if (age < 16 || age > 65) {
      return 'Âge doit être entre 16 et 65 ans';
    }
    return null;
  }

  static String? telephone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Téléphone requis';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 8) {
      return 'Téléphone invalide (8 chiffres)';
    }
    final firstDigit = digits[0];
    if (!['6', '8', '9', '3'].contains(firstDigit)) {
      return 'Le numéro doit commencer par 6, 8, 9 ou 3';
    }
    return null;
  }

  static String? ville(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ville requise';
    }
    return null;
  }

  static String? niveauInformatique(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Niveau requis';
    }
    return null;
  }

  static String? photo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Photo obligatoire';
    }
    return null;
  }

  static String? rgpd(bool? value) {
    if (value != true) {
      return 'Veuillez accepter les conditions';
    }
    return null;
  }
}
