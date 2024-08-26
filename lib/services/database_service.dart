import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBook(Book book) async {
    await _db.collection('books').add(book.toMap());
  }

  Future<List<Book>> getBooks() async {
    QuerySnapshot snapshot = await _db.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromDocument(doc)).toList();
  }

  Future<Book> getBookById(String bookId) async {
    DocumentSnapshot doc = await _db.collection('books').doc(bookId).get();
    return Book.fromDocument(doc);
  }

  Future<void> updateBookRating(String bookId, double rating) async {
    await _db.collection('books').doc(bookId).update({
      'rating': rating,
    });
  }
}
