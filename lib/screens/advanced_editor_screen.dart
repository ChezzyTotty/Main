import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AdvancedEditorScreen extends StatefulWidget {
  final String bookId;

  const AdvancedEditorScreen({Key? key, required this.bookId})
      : super(key: key);

  @override
  _AdvancedEditorScreenState createState() => _AdvancedEditorScreenState();
}

class _AdvancedEditorScreenState extends State<AdvancedEditorScreen> {
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController _contentController;
  late String _bookId;
  String _bookTitle = '';

  @override
  void initState() {
    super.initState();
    _bookId = widget.bookId;
    _contentController = TextEditingController();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('books').doc(_bookId).get();
      if (doc.exists) {
        setState(() {
          _contentController.text = doc['content'] ?? '';
          _bookTitle = doc['title'] ?? 'Kitap';
        });
      }
    } catch (e) {
      print('Error loading book content: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      await _firestore.collection('books').doc(_bookId).update({
        'content': _contentController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik kaydedildi.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating book content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İçerik kaydedilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('$_bookTitle - Düzenle',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [],
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
              children: [
                Expanded(
                  child: GlassmorphicContainer(
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
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Kitabın içeriğini buraya girin veya düzenleyin...',
                        hintStyle: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.5)),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      style:
                          GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GlassmorphicContainer(
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
                  child: TextButton(
                    onPressed: _saveChanges,
                    child: Text(
                      'Kaydet',
                      style:
                          GoogleFonts.roboto(color: Colors.white, fontSize: 18),
                    ),
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
