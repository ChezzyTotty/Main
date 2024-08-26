import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String selectedGenre = 'Tümü';
  String searchQuery = '';

  final List<String> genres = [
    'Tümü',
    'Bilim Kurgu',
    'Fantastik',
    'Gizemli',
    'Romantik',
    'Gerilim',
    'Gerçekçi',
    'Tarihi',
    'Yabancı',
    'Edebiyat',
    'Hikaye',
    'Polisiye',
    'Kişisel Gelişim',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kütüphane',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BookSearchDelegate(),
              );
            },
          ),
        ],
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
          child: Column(
            children: [
              buildFilterSection(),
              Expanded(
                child: buildBookGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedGenre,
                dropdownColor: Colors.blueGrey.shade800,
                style: GoogleFonts.roboto(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: genres.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGenre = newValue ?? 'Tümü';
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                style: GoogleFonts.roboto(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Kitap Ara',
                  labelStyle: GoogleFonts.roboto(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    searchQuery = text;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBookGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('published', isEqualTo: true)
          .snapshots(),
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
              child: Text('Bir hata oluştu.',
                  style: GoogleFonts.roboto(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('Kütüphanede kitap bulunamadı.',
                  style: GoogleFonts.roboto(color: Colors.white)));
        }

        final allBooks = snapshot.data!.docs;
        final filteredBooks = allBooks.where((book) {
          final bookData = book.data() as Map<String, dynamic>;
          final title = bookData['title']?.toString().toLowerCase() ?? '';
          final genre = bookData['genre']?.toString().toLowerCase() ?? '';
          final queryLower = searchQuery.toLowerCase();
          final genreFilter =
              selectedGenre == 'Tümü' || genre == selectedGenre.toLowerCase();
          return (title.contains(queryLower) || searchQuery.isEmpty) &&
              genreFilter;
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            return buildBookCard(filteredBooks[index]);
          },
        );
      },
    );
  }

  Widget buildBookCard(DocumentSnapshot book) {
    final bookData = book.data() as Map<String, dynamic>;

    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
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
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/book-details', arguments: book.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: bookData['coverImage'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        bookData['coverImage'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookData['title'] ?? 'Başlıksız',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(bookData['userId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Yükleniyor...',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 12.0));
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Bilinmeyen Yazar',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 12.0));
                      }
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        userData['name'] ?? 'Bilinmeyen Yazar',
                        style: GoogleFonts.roboto(
                            color: Colors.white70, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BookSearchDelegate sınıfı değişmedi, bu yüzden buraya eklemedim.
class BookSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchBookTitles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu.'));
        }

        final bookTitles = snapshot.data ?? [];
        final filteredTitles = bookTitles
            .where((title) => title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filteredTitles.length,
          itemBuilder: (context, index) {
            final title = filteredTitles[index];
            return ListTile(
              title: Text(title),
              onTap: () {
                Navigator.pushNamed(context, '/book-details', arguments: title);
              },
            );
          },
        );
      },
    );
  }

  Future<List<String>> _fetchBookTitles() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('published', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['title'] as String;
      }).toList();
    } catch (e) {
      print('Error fetching book titles: $e');
      return [];
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchBookTitles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu.'));
        }

        final bookTitles = snapshot.data ?? [];
        final filteredTitles = bookTitles
            .where((title) => title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filteredTitles.length,
          itemBuilder: (context, index) {
            final title = filteredTitles[index];
            return ListTile(
              title: Text(title),
              onTap: () {
                Navigator.pushNamed(context, '/book-details', arguments: title);
              },
            );
          },
        );
      },
    );
  }
}
