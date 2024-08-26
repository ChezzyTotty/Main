import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BookAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add a new book to Firestore
  Future<void> addBook({
    required String title,
    required String genre,
    required String authorName,
    required File coverImage,
    required String userId,
    required String description,
  }) async {
    try {
      String coverImageUrl = await _uploadCoverImage(coverImage);
      await _firestore.collection('books').add({
        'title': title,
        'genre': genre,
        'authorName': authorName,
        'coverImage': coverImageUrl,
        'description': description,
        'createdAt': Timestamp.now(),
        'published': false,
        'userId': userId,
        'content': '', // İçerik alanı ekleniyor, başlangıçta boş
      });
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // Fetch book details
  Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    try {
      DocumentSnapshot bookSnapshot =
          await _firestore.collection('books').doc(bookId).get();
      if (!bookSnapshot.exists) {
        throw Exception('Book not found');
      }
      return bookSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching book details: $e');
      rethrow;
    }
  }

  // Upload the cover image to Firebase Storage and return the download URL
  Future<String> _uploadCoverImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('book_covers/$fileName');
      await ref.putFile(image);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading cover image: $e');
      rethrow;
    }
  }

  // Update book details
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String genre,
    required String authorName,
    required String description,
    File? coverImage,
    String? content,
  }) async {
    try {
      // Önce mevcut kitap verilerini al
      DocumentSnapshot bookSnapshot =
          await _firestore.collection('books').doc(bookId).get();
      Map<String, dynamic> existingData =
          bookSnapshot.data() as Map<String, dynamic>;

      Map<String, dynamic> updateData = {
        'title': title,
        'genre': genre,
        'authorName': authorName,
        'description': description,
        // Eğer yeni içerik sağlanmışsa onu kullan, yoksa mevcut içeriği koru
        'content': content ?? existingData['content'] ?? '',
      };

      if (coverImage != null) {
        String coverImageUrl = await _uploadCoverImage(coverImage);
        updateData['coverImage'] = coverImageUrl;
      }

      await _firestore.collection('books').doc(bookId).update(updateData);
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  // Add a review to a book
  Future<void> addReview({
    required String bookId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String review,
  }) async {
    try {
      if (bookId.isEmpty || userId.isEmpty || review.isEmpty) {
        print('Hata: Kitap ID, kullanıcı ID veya yorum boş olamaz.');
        return;
      }

      // Review koleksiyonuna yorum ekle
      await _firestore
          .collection('books')
          .doc(bookId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'review': review,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  // Fetch the list of predefined genres
  List<String> getGenres() {
    return [
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
      // Add more genres as needed
    ];
  }

  // Fetch books created by a specific user
  Stream<QuerySnapshot> fetchUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Fetch only published books
  Stream<QuerySnapshot> fetchPublishedBooks() {
    return _firestore
        .collection('books')
        .where('published', isEqualTo: true)
        .snapshots();
  }

  // Update the published status of a book
  Future<void> updateBookPublishStatus(String bookId, bool isPublished) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'published': isPublished,
      });
    } catch (e) {
      print('Error updating book publish status: $e');
    }
  }
}
