import 'package:flexx/features/auth/domain/app_user.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_states.dart';
import 'package:flexx/features/post/domain/entities/comment.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  // Move this to a helper function for clarity
  void _showOptions(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          // Delete button
          TextButton(
            onPressed: () {
              context
                  .read<PostCubit>()
                  .deleteComment(comment.postId, comment.id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final currentUser = state is Authenticated ? state.user : null;
        final isOwnPost =
            currentUser != null && comment.userId == currentUser.uid;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Profile Picture (Placeholder for now)
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 18,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Comment Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // More button (visible only if it's the current user's comment)
                if (isOwnPost)
                  GestureDetector(
                    onTap: () => _showOptions(context, comment),
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
