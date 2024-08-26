import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/book_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:glassmorphism/glassmorphism.dart';

class BookCreationScreen extends HookWidget {
  final BookAuthService _bookAuthService = BookAuthService();

  @override
  Widget build(BuildContext context) {
    final formKey = useState(GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final authorController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final selectedGenre = useState<String?>(null);
    final coverImage = useState<File?>(null);
    final genres = useState<List<String>>([]);
    final isLoading = useState(false);

    useEffect(() {
      Future<void> loadGenres() async {
        final loadedGenres = await _bookAuthService.getGenres();
        genres.value = loadedGenres;
        if (loadedGenres.isNotEmpty) {
          selectedGenre.value = loadedGenres.first;
        }
      }

      loadGenres();
      return null;
    }, []);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        coverImage.value = File(pickedFile.path);
      }
    }

    Future<void> submitBook() async {
      if (formKey.value.currentState?.validate() ?? false) {
        if (coverImage.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lütfen bir kapak resmi seçin.')));
          return;
        }

        if (selectedGenre.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lütfen bir kitap türü seçin.')));
          return;
        }

        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Kullanıcı bulunamadı.')));
          return;
        }

        isLoading.value = true;

        try {
          await _bookAuthService.addBook(
            title: titleController.text,
            authorName: authorController.text,
            coverImage: coverImage.value!,
            userId: user.uid,
            genre: selectedGenre.value!,
            description: descriptionController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kitap başarıyla eklendi.')));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kitap eklenirken bir hata oluştu.')));
        } finally {
          isLoading.value = false;
        }
      }
    }

    Widget buildTextField(
        TextEditingController controller, String label, IconData icon,
        {int maxLines = 1}) {
      return TextFormField(
        controller: controller,
        style: GoogleFonts.roboto(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen $label girin';
          }
          return null;
        },
      );
    }

    Widget buildDropdown(
        ValueNotifier<String?> selectedGenre, List<String> genres) {
      return DropdownButtonFormField<String>(
        dropdownColor: const Color.fromARGB(255, 6, 95, 110),
        style: GoogleFonts.roboto(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Kitap Türü',
          labelStyle: GoogleFonts.roboto(color: Colors.white70),
          prefixIcon: Icon(Icons.category, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
        ),
        value: selectedGenre.value,
        items: genres.map((String genre) {
          return DropdownMenuItem<String>(
            value: genre,
            child: Text(genre),
          );
        }).toList(),
        onChanged: (String? newValue) {
          selectedGenre.value = newValue;
        },
        validator: (value) {
          if (value == null) {
            return 'Lütfen kitap türünü seçin';
          }
          return null;
        },
      );
    }

    Widget buildCoverImageSection(
        ValueNotifier<File?> coverImage, VoidCallback pickImage) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            coverImage.value == null
                ? Icon(Icons.image, size: 100, color: Colors.white70)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(coverImage.value!,
                        height: 150, fit: BoxFit.cover),
                  ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Resim Seç', style: GoogleFonts.roboto()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSubmitButton(
        VoidCallback onPressed, ValueNotifier<bool> isLoading) {
      return AnimatedButton(
        height: 50,
        width: 200,
        text: 'Kitap Ekle',
        isReverse: true,
        selectedTextColor: Colors.black,
        transitionType: TransitionType.LEFT_TO_RIGHT,
        textStyle: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        borderColor: Colors.cyan,
        borderRadius: 50,
        borderWidth: 2,
        onPress: () {
          if (!isLoading.value) {
            onPressed();
          }
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Yeni Kitap Ekle',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Colors.white), // Geri butonunu beyaz yapar
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
          child: genres.value.isEmpty
              ? Center(
                  child: Lottie.network(
                      'https://assets2.lottiefiles.com/packages/lf20_uwR49r.json'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: formKey.value,
                      child: Column(
                        children: [
                          GlassmorphicContainer(
                            width: double.infinity,
                            height: 350,
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
                                children: [
                                  buildTextField(titleController,
                                      'Kitap Başlığı', Icons.title),
                                  SizedBox(height: 16),
                                  buildTextField(authorController, 'Yazar Adı',
                                      Icons.person),
                                  SizedBox(height: 16),
                                  buildDropdown(selectedGenre, genres.value),
                                  SizedBox(height: 16),
                                  buildTextField(descriptionController,
                                      'Açıklama', Icons.description,
                                      maxLines: 4),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          buildCoverImageSection(coverImage, pickImage),
                          SizedBox(height: 16),
                          isLoading.value
                              ? CircularProgressIndicator()
                              : buildSubmitButton(submitBook, isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
