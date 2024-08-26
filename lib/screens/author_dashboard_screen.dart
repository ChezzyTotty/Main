import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'book_creation_screen.dart';
import 'manage_books_screen.dart';
import 'write_book_screen.dart';

class AuthorDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Yazar Paneli',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AuthorDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade900, Colors.cyan.shade800],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'İlk kayıt işlemi ise lütfen ayarlardan profil bilgilerini ekleyin',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthorDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade900, Colors.cyan.shade800],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(context, user),
            _buildDrawerItem(context, Icons.person, 'Profil', () {
              final userId = user?.uid ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: userId),
                ),
              );
            }),
            _buildDrawerItem(context, Icons.add, 'Kitap Ekle', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookCreationScreen()),
              );
            }),
            _buildDrawerItem(context, Icons.edit, 'Kitapları Yönet', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageBooksScreen()),
              );
            }),
            _buildDrawerItem(context, Icons.create, 'Kitap Yaz', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteBookScreen()),
              );
            }),
            _buildDrawerItem(context, Icons.library_books, 'Kütüphane', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryScreen()),
              );
            }),
            _buildDrawerItem(context, Icons.settings, 'Ayarlar', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    return FutureBuilder<String?>(
      future: _getProfileImageUrl(user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        String? profileImageUrl = snapshot.data;
        return DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GlassmorphicContainer(
                width: 80,
                height: 80,
                borderRadius: 40,
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
                child: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(color: Colors.white),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.white),
                          )
                        : Icon(Icons.account_circle,
                            size: 60, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                user?.displayName ?? 'Yazar Adı',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.center,
      border: 0,
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
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 16)),
        onTap: onTap,
      ),
    );
  }

  Future<String?> _getProfileImageUrl(String userId) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$userId');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }
}
