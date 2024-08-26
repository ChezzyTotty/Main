import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen e-posta adresinizi girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Giriş Yap'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text('Hesabınız yok mu? Kayıt Olun'),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text('Şifremi Unuttum'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        final user = _authService.currentUser;
        if (user != null) {
          if (!user.emailVerified) {
            _showVerificationDialog();
          } else {
            final role = await _authService.getUserRole(user.uid);
            _navigateBasedOnRole(context, role);
          }
        }
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        _showErrorDialog(errorMessage);
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('user-not-found') ||
        error.toString().contains('wrong-password')) {
      return 'E-posta adresi veya şifre hatalı.';
    } else if (error.toString().contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    } else if (error.toString().contains('user-disabled')) {
      return 'Bu hesap devre dışı bırakılmış.';
    } else if (error.toString().contains('too-many-requests')) {
      return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
    } else {
      return 'Giriş yapılamadı. Lütfen bilgilerinizi kontrol edip tekrar deneyin.';
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('E-posta Doğrulama'),
          content: Text(
              'E-posta adresinizi doğrulamanız gerekiyor. Lütfen e-posta adresinizi kontrol edin ve doğrulama işlemini tamamlayın.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _navigateBasedOnRole(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'author':
        Navigator.pushReplacementNamed(context, '/author-dashboard');
        break;
      case 'user':
      default:
        Navigator.pushReplacementNamed(context, '/user-dashboard');
        break;
    }
  }
}
