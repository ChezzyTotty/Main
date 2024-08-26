import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';

class AuthorProfileScreen extends StatelessWidget {
  final String userId;
  final AuthService _authService = AuthService();

  AuthorProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Yazar Profili',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueGrey.shade900, Colors.cyan.shade800],
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _authService.getUserData(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}',
                          style: GoogleFonts.roboto(color: Colors.white)));
                }
                if (!snapshot.hasData) {
                  return Center(
                      child: Text('Yazar bulunamadı.',
                          style: GoogleFonts.roboto(color: Colors.white)));
                }

                final userData = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GlassmorphicContainer(
                            width: 200,
                            height: 200,
                            borderRadius: 100,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: userData['photoURL'] != null &&
                                      userData['photoURL'].isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: userData['photoURL'],
                                      fit: BoxFit.cover,
                                      width: 200,
                                      height: 200,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(
                                              color: Colors.white),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error,
                                              color: Colors.white, size: 100),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          userData['name'] ?? 'İsim yok',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          userData['biography'] ?? 'Biyografi yok',
                          style: GoogleFonts.roboto(
                              fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Website: ${userData['website'] ?? 'Belirtilmemiş'}',
                          style: GoogleFonts.roboto(
                              fontSize: 14, color: Colors.white60),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        Center(
                          child: GlassmorphicContainer(
                            width: 200,
                            height: 50,
                            borderRadius: 25,
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/user-books',
                                  arguments: userId,
                                );
                              },
                              child: Text('Yazarın Kitapları',
                                  style:
                                      GoogleFonts.roboto(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
