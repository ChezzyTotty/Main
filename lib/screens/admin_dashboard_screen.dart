import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli'),
      ),
      body: Center(
        child: Text(
            'Admin paneline hoş geldiniz! Buradan tüm yönetim işlerini yapabilirsiniz.'),
      ),
    );
  }
}
