class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
    return isValid ? null : 'Enter a valid email address.';
  }
}
