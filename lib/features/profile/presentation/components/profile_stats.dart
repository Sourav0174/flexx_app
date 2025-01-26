// profile state no. of -post, -followers, -followings

import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final VoidCallback? onTap;
  const ProfileStats(
      {super.key,
      required this.postCount,
      required this.followerCount,
      required this.followingCount,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    // text style for count
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary);

    // text style for text
    var textStyleFortext =
        TextStyle(color: Theme.of(context).colorScheme.primary);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  postCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Posts",
                  style: textStyleFortext,
                )
              ],
            ),
          ),

          // followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followerCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Followers",
                  style: textStyleFortext,
                )
              ],
            ),
          ),

          // following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Following",
                  style: textStyleFortext,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
