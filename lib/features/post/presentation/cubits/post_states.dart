import 'package:flexx/features/post/domain/entities/post.dart';

abstract class PostState {}

class PostsInitial extends PostState {}

class PostsLoading extends PostState {}

class PostsUploading extends PostState {}

class PostsUploadingImage
    extends PostState {} // Optional state for image uploading

class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

class PostsLoaded extends PostState {
  final List<Post> posts;

  PostsLoaded(this.posts);
}

class PostsCreated extends PostState {
  final Post post;

  PostsCreated(this.post);
}
