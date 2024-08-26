class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresinizi girin';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifrenizi girin';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Şifrenizi tekrar girin';
    }
    if (password != confirmPassword) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
}
