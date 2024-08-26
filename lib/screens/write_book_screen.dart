import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'advanced_editor_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth eklendi

class WriteBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mevcut kullanıcının ID'sini al
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kitaplarım',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
          child: StreamBuilder<QuerySnapshot>(
            // Sorguyu sadece kullanıcının kitaplarını getirecek şekilde güncelle
            stream: FirebaseFirestore.instance
                .collection('books')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: GoogleFonts.roboto(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text('Henüz kitap eklenmemiş.',
                        style: GoogleFonts.roboto(color: Colors.white)));
              }

              final books = snapshot.data!.docs;

              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final bookId = book.id;
                  final title = book['title'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 80,
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
                          title,
                          style: GoogleFonts.roboto(
                              color: Colors.white, fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdvancedEditorScreen(bookId: bookId),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
