class ValidationUtils {
  static final List<String> _commonPasswords = [
    '123456',
    'password',
    'j3h4h4j',
    '989898',
    'absd456',
    'qwerty',
    'abc123',
    // Add more common passwords as needed
  ];

  /// Validate email format, domain, and non-empty
  static bool validateEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return false;

    // Domain whitelist (adjust as needed)
    final allowedDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'example.com'];
    final domain = email.split('@').last.toLowerCase();
    if (!allowedDomains.contains(domain)) return false;

    return true;
  }

  /// Validate password strength:
  /// Minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number, 1 special char,
  /// and not in common passwords list
  static bool validatePassword(String password) {
    if (password.length < 8) return false;

    final upperCaseRegex = RegExp(r'[A-Z]');
    final lowerCaseRegex = RegExp(r'[a-z]');
    final numberRegex = RegExp(r'\d');
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    if (!upperCaseRegex.hasMatch(password)) return false;
    if (!lowerCaseRegex.hasMatch(password)) return false;
    if (!numberRegex.hasMatch(password)) return false;
    if (!specialCharRegex.hasMatch(password)) return false;

    if (_commonPasswords.contains(password.toLowerCase())) return false;

    return true;
  }

  /// Validate name:
  /// Minimum 2 characters, no numbers or special characters allowed
  static bool validateName(String name) {
    if (name.length < 2) return false;
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// Validate phone number format (optional field):
  /// Accepts digits, +, -, spaces, and parentheses
  static bool validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return true; // optional
    final phoneRegex = RegExp(r'^[\d+\-\s\(\)]+$');
    return phoneRegex.hasMatch(phone);
  }

  /// Validate age based on birth date:
  /// User must be at least [minAge] years old (default 18)
  static bool validateAge(DateTime birthDate, {int minAge = 18}) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }

    return age >= minAge;
  }
}
