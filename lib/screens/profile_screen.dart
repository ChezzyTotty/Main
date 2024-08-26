import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<DocumentSnapshot> _userProfileStream;
  bool _showWebsite = false;
  bool _showBiography = false;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _userProfileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profil',
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_uwR49r.json',
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('Bir hata oluştu: ${snapshot.error}',
                      style: GoogleFonts.roboto(color: Colors.white)));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                  child: Text('Kullanıcı bulunamadı.',
                      style: GoogleFonts.roboto(color: Colors.white)));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return _buildProfileContent(userData);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    String biography = userData['biography'] ?? 'Biyografi mevcut değil.';
    String website = userData['website'] ?? 'Web sitesi mevcut değil.';

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height:
                        MediaQuery.of(context).padding.top + kToolbarHeight),
                _buildProfileImage(),
                const SizedBox(height: 16),
                _buildUserName(),
                const SizedBox(height: 8),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildContentSection('Web Sitesi', website, _showWebsite),
                const SizedBox(height: 8),
                _buildContentSection('Biyografi', biography, _showBiography),
                const SizedBox(height: 16),
                _buildStatistics(userData),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return FutureBuilder<String>(
      future: _getProfileImageUrlFromFirebase(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassmorphicContainer(
            width: 160,
            height: 160,
            borderRadius: 80,
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
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        String imageUrl = snapshot.data ??
            'https://i.pinimg.com/736x/8b/16/7a/8b167af653c2399dd93b952a48740620.jpg';

        return GlassmorphicContainer(
          width: 160,
          height: 160,
          borderRadius: 80,
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
            borderRadius: BorderRadius.circular(78),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 156,
              height: 156,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getProfileImageUrlFromFirebase(String userId) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$userId');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return '';
    }
  }

  Widget _buildUserName() {
    return Text(
      FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı Adı',
      style: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildActionButton('Web Sitesi', () => _toggleVisibility('website')),
        const SizedBox(width: 16),
        _buildActionButton('Biyografi', () => _toggleVisibility('biography')),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.roboto(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContentSection(String title, String content, bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: content.length > 100 ? 200 : 100,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> userData) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Takipçiler', userData['followers'] ?? 0),
          _buildStatItem('Takip Edilenler', userData['following'] ?? 0),
          _buildStatItem('Gönderiler', userData['posts'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  void _toggleVisibility(String type) {
    setState(() {
      if (type == 'website') {
        _showWebsite = !_showWebsite;
        if (_showWebsite) _showBiography = false;
      } else if (type == 'biography') {
        _showBiography = !_showBiography;
        if (_showBiography) _showWebsite = false;
      }
    });
  }
}
