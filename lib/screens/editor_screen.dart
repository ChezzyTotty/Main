import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/book_auth.dart';

class EditBookScreen extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  EditBookScreen({required this.bookId, required this.bookData});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late String _selectedGenre;
  File? _coverImage;
  final BookAuthService _bookAuthService = BookAuthService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookData['title']);
    _descriptionController =
        TextEditingController(text: widget.bookData['description'] ?? '');
    _authorController =
        TextEditingController(text: widget.bookData['authorName']);
    _selectedGenre =
        widget.bookData['genre'] ?? _bookAuthService.getGenres().first;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _bookAuthService.updateBook(
          bookId: widget.bookId,
          title: _titleController.text,
          genre: _selectedGenre,
          authorName: _authorController.text,
          description: _descriptionController.text,
          coverImage: _coverImage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kitap güncellendi.')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kitap güncellenemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> genres = _bookAuthService.getGenres();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey.shade900, Colors.cyan.shade800],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Kitap Düzenle',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 80), // AppBar için ekstra boşluk
                  _buildGlassmorphicTextField(
                    controller: _titleController,
                    labelText: 'Kitap Başlığı',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kitap adını girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGlassmorphicTextField(
                    controller: _descriptionController,
                    labelText: 'Açıklama',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen açıklama girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGlassmorphicTextField(
                    controller: _authorController,
                    labelText: 'Yazar Adı',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen yazar adını girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGlassmorphicDropdown(
                    value: _selectedGenre,
                    items: genres,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGenre = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  _coverImage == null
                      ? Text('Resim seçilmedi',
                          style: GoogleFonts.roboto(color: Colors.white))
                      : Image.file(_coverImage!, height: 150),
                  SizedBox(height: 20),
                  _buildGlassmorphicButton(
                    onPressed: _pickImage,
                    child: Text('Resim seç',
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                  _buildGlassmorphicButton(
                    onPressed: _submitUpdate,
                    child: Text('Güncelle',
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: maxLines > 1 ? 120 : 60,
      borderRadius: 10,
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
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.roboto(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.roboto(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildGlassmorphicDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 10,
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
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.blueGrey.shade900,
        style: GoogleFonts.roboto(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Kitap Türü',
          labelStyle: GoogleFonts.roboto(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
        ),
        value: value,
        items: items.map((String genre) {
          return DropdownMenuItem<String>(
            value: genre,
            child: Text(genre),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Lütfen tür seçin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGlassmorphicButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
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
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
