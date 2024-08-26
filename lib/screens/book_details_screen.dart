import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  BookDetailsScreen({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kitap Detayları',
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
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('books').doc(bookId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Bir hata oluştu.',
                      style: GoogleFonts.roboto(color: Colors.white)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                  child: Text('Kitap bulunamadı.',
                      style: GoogleFonts.roboto(color: Colors.white)));
            }

            final bookData = snapshot.data!.data() as Map<String, dynamic>;

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverImage(bookData),
                      SizedBox(height: 16),
                      _buildTitle(context, bookData),
                      SizedBox(height: 16),
                      _buildDescription(context, bookData),
                      SizedBox(height: 16),
                      _buildButtons(context, bookData),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoverImage(Map<String, dynamic> bookData) {
    return Center(
      child: GlassmorphicContainer(
        width: 200,
        height: 300,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: bookData['coverImage'] != null
              ? CachedNetworkImage(
                  imageUrl: bookData['coverImage'],
                  fit: BoxFit.cover,
                  width: 200,
                  height: 300,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(color: Colors.white),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: Colors.white),
                )
              : Container(
                  width: 200,
                  height: 300,
                  color: Colors.grey.withOpacity(0.3),
                  child: Icon(
                    Icons.book,
                    size: 150,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Map<String, dynamic> bookData) {
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
      child: Center(
        child: Text(
          bookData['title'] ?? 'Başlık yok',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, Map<String, dynamic> bookData) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
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
              'Açıklama:',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              bookData['description'] ?? 'Açıklama yok.',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, Map<String, dynamic> bookData) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildButton(context, 'Oku', () {
          Navigator.pushNamed(context, '/book-read', arguments: bookId);
        }),
        _buildButton(context, 'Yorum Yap', () {
          Navigator.pushNamed(context, '/book-review', arguments: bookId);
        }),
        _buildButton(context, 'Yazarı Görüntüle', () {
          if (bookData['userId'] != null && bookData['userId'].isNotEmpty) {
            Navigator.pushNamed(context, '/author-profile',
                arguments: bookData['userId']);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Yazar bilgisi bulunamadı.',
                      style: GoogleFonts.roboto())),
            );
          }
        }),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return GlassmorphicContainer(
      width: 150,
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
        onPressed: onPressed,
        child: Text(text,
            style: GoogleFonts.roboto(
                color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}
