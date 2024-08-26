import 'package:flutter/material.dart';

class ViewProfileScreen extends StatelessWidget {
  final String userId;

  ViewProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Profili'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Kullanıcı Bilgileri Burada Olacak'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to user profile details
              },
              child: Text('Profili Görüntüle'),
            ),
          ],
        ),
      ),
    );
  }
}
