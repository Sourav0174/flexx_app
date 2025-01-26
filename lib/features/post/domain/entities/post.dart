import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexx/features/post/domain/entities/comment.dart';
import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.likes,
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  /// Convert post to JSON for Firebase storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  /// Convert JSON to Post entity with null safety.
  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments
    final List<Comment> comments = (json["comments"] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];

    return Post(
      id: json['id'] ?? '', // Default to empty string if null
      userId: json['userId'] ?? '', // Default to empty string if null
      userName: json['userName'] ?? 'Unknown', // Default name if missing
      text: json['text'] ?? 'No text', // Default text if missing
      imageUrl: json['imageUrl'] ?? '', // Default to empty string if null
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
      // If timestamp is null, default to the current date and time
    );
  }
}
