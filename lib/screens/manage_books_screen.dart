import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/book_auth.dart';
import 'editor_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageBooksScreen extends StatelessWidget {
  final ValueNotifier<int> _hoverIndex = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('Giriş yapmamış kullanıcı yok.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kitapları Yönet',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the title text color to white
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.blueGrey[800],
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: BookAuthService().fetchUserBooks(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Kitaplar yüklenirken hata oluştu.'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Kitap bulunamadı.'));
              }

              final books = snapshot.data!.docs;
              return BookGrid(
                books: books,
                hoverNotifier: _hoverIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}

class BookGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot> books;
  final ValueNotifier<int> hoverNotifier;

  const BookGrid({
    Key? key,
    required this.books,
    required this.hoverNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => BookCard(
        book: books[index],
        index: index,
        hoverNotifier: hoverNotifier,
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final QueryDocumentSnapshot book;
  final int index;
  final ValueNotifier<int> hoverNotifier;

  const BookCard({
    Key? key,
    required this.book,
    required this.index,
    required this.hoverNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookData = book.data() as Map<String, dynamic>;

    return MouseRegion(
      onEnter: (_) => hoverNotifier.value = index,
      onExit: (_) => hoverNotifier.value = -1,
      child: ValueListenableBuilder<int>(
        valueListenable: hoverNotifier,
        builder: (context, hoverIndex, child) {
          return Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: BookCover(imageUrl: bookData['coverImage']),
                ),
                Expanded(
                  flex: 2,
                  child: BookInfo(
                      title: bookData['title'], genre: bookData['genre']),
                ),
                BookOptions(
                  bookId: book.id,
                  bookData: bookData,
                  isHovered: index == hoverIndex,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String? imageUrl;

  const BookCover({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(Icons.book, size: 100, color: Colors.grey.shade700),
    );
  }
}

class BookInfo extends StatelessWidget {
  final String? title;
  final String? genre;

  const BookInfo({Key? key, this.title, this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              title ?? 'Başlıksız',
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4),
          Flexible(
            child: Text(
              genre ?? 'Bilinmeyen tür',
              style: GoogleFonts.roboto(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class BookOptions extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> bookData;
  final bool isHovered;

  const BookOptions({
    Key? key,
    required this.bookId,
    required this.bookData,
    required this.isHovered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isHovered ? 1.0 : 0.0,
      duration: Duration(milliseconds: 200),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: TextButton.icon(
                icon: Icon(Icons.edit, color: Colors.blue),
                label: Text('Düzenle',
                    style: GoogleFonts.roboto(color: Colors.white)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditBookScreen(bookId: bookId, bookData: bookData)),
                ),
              ),
            ),
            Flexible(
              child: TextButton.icon(
                icon: Icon(
                  bookData['published'] == true
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: bookData['published'] == true
                      ? Colors.green
                      : Colors.grey,
                ),
                label: Text(
                  bookData['published'] == true ? 'Yayınlandı' : 'Yayınla',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
                onPressed: () => BookAuthService()
                    .updateBookPublishStatus(bookId, !bookData['published']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
