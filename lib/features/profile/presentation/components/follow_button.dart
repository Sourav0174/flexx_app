import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isFollowing;

  const FollowButton(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.all(18),
        color:
            isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
        child: Text(
          isFollowing ? "Unfollow" : "Follow",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
