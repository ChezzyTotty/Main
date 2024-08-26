import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            setState(() {
              _nameController.text = userData['name'] ?? '';
              _biographyController.text = userData['biography'] ?? '';
              _websiteController.text = userData['website'] ?? '';
            });
          }
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      String? profileImageUrl;
      if (_profileImage != null) {
        if (user.photoURL != null) {
          try {
            final oldImageRef =
                FirebaseStorage.instance.refFromURL(user.photoURL!);
            await oldImageRef.delete();
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }

        profileImageUrl = await _uploadImage(_profileImage!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': _nameController.text,
        'biography': _biographyController.text,
        'website': _websiteController.text,
        if (profileImageUrl != null) 'photoURL': profileImageUrl,
      });

      if (profileImageUrl != null) {
        await user.updatePhotoURL(profileImageUrl);
      }
      if (_nameController.text.isNotEmpty) {
        await user.updateDisplayName(_nameController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil güncellendi!',
              style: GoogleFonts.roboto(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 95, 92, 92),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil güncellenirken bir hata oluştu.',
              style: GoogleFonts.roboto(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/${widget.userId}');
      final uploadTask = imageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() => {});

      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (downloadUrl.startsWith('https://') ||
          downloadUrl.startsWith('gs://')) {
        return downloadUrl;
      } else {
        throw Exception('Geçersiz URL formatı: $downloadUrl');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Image upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profil Düzenle',
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildProfileImage(),
                          const SizedBox(height: 16),
                          _buildTextField(_nameController, 'Kullanıcı Adı'),
                          const SizedBox(height: 8),
                          _buildTextField(_biographyController, 'Biyografi',
                              maxLines: 4),
                          const SizedBox(height: 8),
                          _buildTextField(_websiteController, 'Web Sitesi'),
                          const SizedBox(height: 16),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: GlassmorphicContainer(
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
          child: Container(
            width: 156,
            height: 156,
            child: _profileImage != null
                ? Image.file(_profileImage!, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: FirebaseAuth.instance.currentUser?.photoURL ??
                        'https://i.pinimg.com/736x/8b/16/7a/8b167af653c2399dd93b952a48740620.jpg',
                    fit: BoxFit.cover,
                    width: 156,
                    height: 156,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: maxLines > 1 ? 120 : 60,
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.roboto(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.roboto(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GlassmorphicContainer(
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
        onPressed: _saveProfile,
        child: Text('Kaydet',
            style: GoogleFonts.roboto(
                color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
