import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> setUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).set({'role': role});
    } catch (e) {
      print('Error setting user role: $e');
    }
  }

  Future<void> createBook(
      String title, String author, String genre, String imageUrl) async {
    try {
      await _db.collection('books').add({
        'title': title,
        'author': author,
        'genre': genre,
        'imageUrl': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating book: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getBooksByAuthor(String authorId) async {
    try {
      final querySnapshot = await _db
          .collection('books')
          .where('author_id', isEqualTo: authorId)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting books by author: $e');
      return []; // Return an empty list on error
    }
  }

  Future<List<QueryDocumentSnapshot>> getBooks() async {
    try {
      final querySnapshot = await _db.collection('books').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting books: $e');
      return []; // Return an empty list on error
    }
  }
}
