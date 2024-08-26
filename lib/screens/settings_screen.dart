import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Ayarlar',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade900, Colors.cyan.shade800],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsItem(
                  context,
                  'Profil Güncelle',
                  () {
                    Navigator.pushNamed(context, '/update-profile');
                  },
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  'Lisanslandırma',
                  () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  'Çıkış Yap',
                  () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, String text, VoidCallback onTap) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.2),
        ],
      ),
      child: ListTile(
        title: Text(
          text,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      ),
    );
  }
}
