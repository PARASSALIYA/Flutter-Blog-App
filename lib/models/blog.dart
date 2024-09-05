import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final String author;
  final String imageUrl;
  int views;
  int comments;
  final int readingTime;
  final List<String> viewedBy; // List of user IDs who have viewed the blog

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.imageUrl,
    this.views = 0,
    this.comments = 0,
    required this.readingTime,
    this.viewedBy = const [], // Initialize viewedBy as an empty list
  });

  // Factory method to create a Blog from a Firestore document
  factory Blog.fromDocument(DocumentSnapshot doc) {
    return Blog(
      id: doc.id,
      title: doc['title'] ?? 'Untitled',
      content: doc['content'] ?? 'No content available',
      author: doc['author'] ?? 'Unknown author',
      imageUrl: doc['imageUrl'] ?? '',
      views: doc['views'] ?? 0,
      comments: doc['comments'] ?? 0,
      readingTime: doc['readingTime'] ?? 5,
      viewedBy: List<String>.from(
          doc['viewedBy'] ?? []), // Convert Firestore array to List<String>
    );
  }

  // Method to convert Blog object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'imageUrl': imageUrl,
      'views': views,
      'comments': comments,
      'readingTime': readingTime,
      'viewedBy': viewedBy, // Save the list of users who have viewed the blog
    };
  }
}
