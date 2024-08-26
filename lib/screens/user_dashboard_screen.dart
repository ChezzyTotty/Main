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
import 'about_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kullanıcı Paneli',
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
        child: Center(
          child: Text(
            'İlk kayıt işlemi ise lütfen ayarlardan profil bilgilerini ekleyin',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: UserDrawer(),
    );
  }
}

class UserDrawer extends StatelessWidget {
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
            FutureBuilder<String?>(
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
                        width: 100,
                        height: 100,
                        borderRadius: 50,
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
                        child: ClipOval(
                          child: profileImageUrl != null &&
                                  profileImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(
                                          color: Colors.white),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error, color: Colors.white),
                                )
                              : Image.asset(
                                  'assets/default_profile.png',
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        user?.displayName ?? 'Kullanıcı Adı',
                        style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                final userId = user?.uid ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: userId),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.library_books,
              title: 'Kütüphane',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LibraryScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Ayarlar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
