/// Validateurs centralisés pour tous les formulaires de l'application
/// Assure la cohérence et la réutilisabilité de la validation
class FormValidators {
  FormValidators._();

  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }

  /// Valide un mot de passe
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }
    
    // Vérifier au moins une majuscule
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    
    // Vérifier au moins un chiffre
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    return null;
  }

  /// Valide un nom (prénom, nom de famille)
  static String? name(String? value, {String fieldName = 'Nom'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return '$fieldName ne peut pas dépasser 50 caractères';
    }
    
    // Vérifier que ce n'est pas que des espaces
    if (value.trim().isEmpty) {
      return '$fieldName ne peut pas être vide';
    }
    
    return null;
  }

  /// Valide un numéro de téléphone
  static String? phone(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le numéro de téléphone est requis' : null;
    }
    
    // Format canadien: (XXX) XXX-XXXX ou XXX-XXX-XXXX ou XXXXXXXXXX
    final phoneRegex = RegExp(
      r'^(\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})$',
    );
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Format de téléphone invalide';
    }
    
    return null;
  }

  /// Valide un prix
  static String? price(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le prix est requis';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Prix invalide';
    }
    
    if (price < 0) {
      return 'Le prix ne peut pas être négatif';
    }
    
    if (min != null && price < min) {
      return 'Le prix minimum est \$${min.toStringAsFixed(2)}';
    }
    
    if (max != null && price > max) {
      return 'Le prix maximum est \$${max.toStringAsFixed(2)}';
    }
    
    return null;
  }

  /// Valide une date
  static String? date(DateTime? value, {DateTime? min, DateTime? max}) {
    if (value == null) {
      return 'La date est requise';
    }
    
    if (min != null && value.isBefore(min)) {
      return 'La date ne peut pas être antérieure au ${_formatDate(min)}';
    }
    
    if (max != null && value.isAfter(max)) {
      return 'La date ne peut pas être postérieure au ${_formatDate(max)}';
    }
    
    return null;
  }

  /// Valide une plage de dates (check-in < check-out)
  static String? dateRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return null; // La validation individuelle s'en chargera
    }
    
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      return 'La date de départ doit être postérieure à la date d\'arrivée';
    }
    
    final difference = checkOut.difference(checkIn).inDays;
    if (difference < 1) {
      return 'La durée minimale est de 1 nuit';
    }
    
    if (difference > 365) {
      return 'La durée maximale est de 365 nuits';
    }
    
    return null;
  }

  /// Valide un nombre de personnes
  static String? guests(int? value, {int min = 1, int max = 20}) {
    if (value == null) {
      return 'Le nombre de personnes est requis';
    }
    
    if (value < min) {
      return 'Le nombre minimum de personnes est $min';
    }
    
    if (value > max) {
      return 'Le nombre maximum de personnes est $max';
    }
    
    return null;
  }

  /// Valide un code postal canadien
  static String? postalCode(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Le code postal est requis' : null;
    }
    
    // Format canadien: A1A 1A1
    final postalRegex = RegExp(r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$');
    
    if (!postalRegex.hasMatch(value)) {
      return 'Format de code postal invalide (ex: A1A 1A1)';
    }
    
    return null;
  }

  /// Valide une description
  static String? description(String? value, {int minLength = 10, int maxLength = 5000}) {
    if (value == null || value.isEmpty) {
      return 'La description est requise';
    }
    
    if (value.length < minLength) {
      return 'La description doit contenir au moins $minLength caractères';
    }
    
    if (value.length > maxLength) {
      return 'La description ne peut pas dépasser $maxLength caractères';
    }
    
    return null;
  }

  /// Valide un champ requis
  static String? required(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Valide une URL
  static String? url(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'L\'URL est requise' : null;
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'L\'URL doit commencer par http:// ou https://';
      }
      return null;
    } catch (e) {
      return 'Format d\'URL invalide';
    }
  }

  /// Valide un nombre positif
  static String? positiveNumber(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }
    
    if (number < 0) {
      return '$fieldName ne peut pas être négatif';
    }
    
    return null;
  }

  /// Valide un nombre décimal positif
  static String? positiveDecimal(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }
    
    if (number < 0) {
      return '$fieldName ne peut pas être négatif';
    }
    
    return null;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

