import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';

class BookReadScreen extends StatelessWidget {
  final String bookId;

  const BookReadScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Kitap Okuma',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('books')
                .doc(bookId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.network(
                    'https://assets2.lottiefiles.com/packages/lf20_uwR49r.json',
                    width: 100,
                    height: 100,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Bir hata oluştu: ${snapshot.error}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text(
                    'Kitap bulunamadı.',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                );
              }

              final bookData = snapshot.data!.data() as Map<String, dynamic>;
              final content = bookData['content'] as String? ?? '';
              final title = bookData['title'] as String? ?? 'Başlıksız Kitap';

              return content.isEmpty
                  ? Center(
                      child: Text(
                        'Bu kitap için içerik bulunmamaktadır.',
                        style: GoogleFonts.roboto(color: Colors.white),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              GlassmorphicContainer(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height - 150,
                                borderRadius: 20,
                                blur: 20,
                                alignment: Alignment.topLeft,
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
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      content,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
