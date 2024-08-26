import 'package:flutter/material.dart';

class SupportRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destek Talebi'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Burada gerçek bir e-posta gönderim işlemi yapmanız gerekebilir.
            // Aşağıda sadece bilgi mesajı gösteriliyor.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Yazar rolü talep formunuz canlı destek ekibine gönderildi.')),
            );
          },
          child: Text('Destek Talebinizi Gönderin'),
        ),
      ),
    );
  }
}
