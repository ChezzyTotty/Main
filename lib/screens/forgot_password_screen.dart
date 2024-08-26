// forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;

  void _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen e-posta adresinizi girin.';
      });
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('E-posta gönderildi'),
          content: Text(
              'Şifre sıfırlama e-postası gönderildi. Lütfen e-posta adresinizi kontrol edin.'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Geriye döner
              },
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Sıfırlama'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta adresi',
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: Text('Şifre Sıfırlama E-postası Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
