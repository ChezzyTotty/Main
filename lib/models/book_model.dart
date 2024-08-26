import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String id;
  String title;
  String authorId;
  String genre;
  String coverImageUrl;
  List<Chapter> chapters;
  double rating;

  Book({
    required this.id,
    required this.title,
    required this.authorId,
    required this.genre,
    required this.coverImageUrl,
    required this.chapters,
    required this.rating,
  });

  factory Book.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'],
      authorId: data['authorId'],
      genre: data['genre'],
      coverImageUrl: data['coverImageUrl'],
      chapters: (data['chapters'] as List)
          .map((chapterData) => Chapter.fromMap(chapterData))
          .toList(),
      rating: data['rating'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authorId': authorId,
      'genre': genre,
      'coverImageUrl': coverImageUrl,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'rating': rating,
    };
  }
}

class Chapter {
  String title;
  String content;

  Chapter({
    required this.title,
    required this.content,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      title: map['title'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }
}
