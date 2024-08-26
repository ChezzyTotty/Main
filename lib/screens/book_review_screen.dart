import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glassmorphism/glassmorphism.dart';

class BookReviewScreen extends StatefulWidget {
  final String bookId;

  BookReviewScreen({required this.bookId});

  @override
  _BookReviewScreenState createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitReview() async {
    if (_formKey.currentState?.validate() ?? false) {
      final review = _reviewController.text;

      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final userName = user?.displayName ?? 'Bilinmeyen Kullanıcı';
      final userPhotoUrl = user?.photoURL;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı kimliği alınamadı.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .collection('reviews')
            .add({
          'userId': userId,
          'userName': userName,
          'userPhotoUrl': userPhotoUrl,
          'review': review,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _reviewController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorumunuz başarıyla gönderildi!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .collection('reviews')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum başarıyla silindi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum silinirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kitap Yorumları',
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 150,
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
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _reviewController,
                            style: GoogleFonts.roboto(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Yorumunuzu yazın',
                              labelStyle:
                                  GoogleFonts.roboto(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir yorum girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitReview,
                        child: Text('Yorum Gönder',
                            style: GoogleFonts.roboto(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('books')
                        .doc(widget.bookId)
                        .collection('reviews')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Bir hata oluştu: ${snapshot.error}',
                                style:
                                    GoogleFonts.roboto(color: Colors.white)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text('Henüz yorum yok.',
                                style:
                                    GoogleFonts.roboto(color: Colors.white)));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final reviewData = doc.data() as Map<String, dynamic>;
                          final userName =
                              reviewData['userName'] ?? 'Bilinmeyen Kullanıcı';
                          final userPhotoUrl = reviewData['userPhotoUrl'];
                          final review = reviewData['review'];
                          final userId = reviewData['userId'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GlassmorphicContainer(
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: userPhotoUrl != null
                                      ? NetworkImage(userPhotoUrl)
                                      : null,
                                  child: userPhotoUrl == null
                                      ? Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                                title: Text(userName,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white)),
                                subtitle: Text(review,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white70)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                trailing: userId ==
                                        FirebaseAuth.instance.currentUser?.uid
                                    ? IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.white),
                                        onPressed: () => _deleteReview(doc.id),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
