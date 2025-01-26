import 'dart:typed_data';

import 'package:flexx/features/post/domain/entities/comment.dart';
import 'package:flexx/features/post/domain/entities/post.dart';
import 'package:flexx/features/post/domain/repo/post_repo.dart';
import 'package:flexx/features/post/presentation/cubits/post_states.dart';
import 'package:flexx/features/storage/data/firebase_storage_repo.dart';
import 'package:flexx/features/storage/domain/storage_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // Create a new post
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;
    try {
      emit(PostsUploading());

      // Handle image upload for mobile platforms(using file path)
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }
      // Handle image upload for web platform(using file bytes)
      else if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // If the image upload succeeds, create the post
      final newPost = post.copyWith(imageUrl: imageUrl);

      // Create the post in the backend
      await postRepo.createPost(newPost);

      emit(PostsCreated(newPost)); // Emit a successful post creation state

      // Re-fetch all posts (optional if you're handling real-time updates)
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to create post: $e"));
    }
  }

  // Fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }

  // Toggle likes on a post
  Future<void> toggleLikesPost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError("Failed to toggle likes: $e"));
    }
  }

  // Add a comment to a post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  // Delete a comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }
}
