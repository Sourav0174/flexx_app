import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexx/features/auth/domain/app_user.dart';
import 'package:flexx/features/auth/presentation/components/custom_textfield.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/post/domain/entities/comment.dart';
import 'package:flexx/features/post/domain/entities/post.dart';
import 'package:flexx/features/post/presentation/components/comment_tile.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flexx/features/post/presentation/cubits/post_states.dart';
import 'package:flexx/features/profile/domain/entities/profile_user.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flexx/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  ProfileUser? postUser;
  AppUser? currentUser;

  final commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
        isOwnPost = widget.post.userId == user.uid;
      });
    }
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (mounted && fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    if (mounted) {
      setState(() {
        if (isLiked) {
          widget.post.likes.remove(currentUser!.uid);
        } else {
          widget.post.likes.add(currentUser!.uid);
        }
      });
    }
    postCubit
        .toggleLikesPost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      if (mounted) {
        setState(() {
          if (isLiked) {
            widget.post.likes.add(currentUser!.uid);
          } else {
            widget.post.likes.remove(currentUser!.uid);
          }
        });
      }
    });
  }

  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add a new comment"),
        content: CustomTextField(
            controller: commentTextController,
            hintText: "Type a comment",
            obscureText: false),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => {
              addComment(),
              Navigator.of(context).pop(),
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void addComment() {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed();
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(10, 10),
            blurRadius: 15,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            offset: Offset(-10, -10),
            blurRadius: 15,
          ),
        ],
        color: Theme.of(context).colorScheme.background.withOpacity(0.6),
      ),
      child: Column(
        children: [
          // Top section: profile pic / name / delete button
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: widget.post.userId))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover)),
                          ),
                        )
                      : Icon(Icons.person),
                  SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(Icons.delete),
                    ),
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => SizedBox(height: 430),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          // Buttons with Neumorphism
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Like button
                neumorphicButton(
                  onTap: toggleLikePost,
                  child: Icon(
                    widget.post.likes.contains(currentUser!.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.likes.contains(currentUser!.uid)
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 5),
                Text(widget.post.likes.length.toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                // Comment button
                neumorphicButton(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(widget.post.comments.length.toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                Spacer(),
                // Timestamp
                Text(widget.post.timestamp.toString())
              ],
            ),
          ),
          // Caption
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              children: [
                Text(widget.post.userName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text(widget.post.text)
              ],
            ),
          ),
          // Comment Section
          BlocBuilder<PostCubit, PostState>(builder: (context, state) {
            if (state is PostsLoaded) {
              final post =
                  state.posts.firstWhere((p) => p.id == widget.post.id);
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: post.comments.length,
                  itemBuilder: (context, index) {
                    final comment = post.comments[index];
                    return CommentTile(comment: comment);
                  });
            }
            if (state is PostsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostsError) {
              return Center(child: Text(state.message));
            } else {
              return SizedBox();
            }
          }),
        ],
      ),
    );
  }

  // Custom neumorphic button for the like and comment icons
  Widget neumorphicButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(6, 6),
              blurRadius: 20,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              offset: Offset(-6, -6),
              blurRadius: 20,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
