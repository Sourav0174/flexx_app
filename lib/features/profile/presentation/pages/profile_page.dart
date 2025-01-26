import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexx/features/auth/domain/app_user.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/post/presentation/components/post_tile.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flexx/features/post/presentation/cubits/post_states.dart';
import 'package:flexx/features/profile/domain/entities/profile_user.dart';
import 'package:flexx/features/profile/presentation/components/bio_box.dart';
import 'package:flexx/features/profile/presentation/components/follow_button.dart';
import 'package:flexx/features/profile/presentation/components/profile_stats.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_state.dart';
import 'package:flexx/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flexx/features/profile/presentation/pages/follower_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AppUser? currentUser;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    currentUser = authCubit.currentUser;
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed(ProfileUser user) {
    final isFollowing = user.followers.contains(currentUser!.uid);
    setState(() {
      if (isFollowing) {
        user.followers.remove(currentUser!.uid);
      } else {
        user.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      setState(() {
        if (isFollowing) {
          user.followers.add(currentUser!.uid);
        } else {
          user.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = widget.uid == currentUser!.uid;

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) {
        return current is ProfileLoaded || current is ProfileLoading;
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(user.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 5,
              shadowColor: Theme.of(context).colorScheme.secondary,
              actions: [
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: Icon(Icons.settings),
                  ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                  // Using the colors from the light theme
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Theme.of(context).colorScheme.surface,
                  //     Theme.of(context).colorScheme.secondary,
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildProfileHeader(user),
                  _buildProfileStats(user),
                  SizedBox(
                    height: 25,
                  ),
                  if (!isOwnPost) _buildFollowButton(user),
                  SizedBox(
                    height: 25,
                  ),
                  _buildBio(user),
                  _buildPostsSection(user),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return _buildLoadingState();
        } else {
          return _buildErrorState();
        }
      },
    );
  }

  Widget _buildProfileHeader(ProfileUser user) {
    return Column(
      children: [
        Text(
          user.email,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(height: 25),
        CachedNetworkImage(
          imageUrl: user.profileImageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          imageBuilder: (context, ImageProvider) => Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: ImageProvider, fit: BoxFit.cover),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(3, 3)),
              ],
            ),
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildProfileStats(ProfileUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 15,
            offset: Offset(5, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(-5, -5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ProfileStats(
        postCount: postCount,
        followerCount: user.followers.length,
        followingCount: user.following.length,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FollowerPage(
              followers: user.followers,
              following: user.following,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(ProfileUser user) {
    return FollowButton(
      isFollowing: user.followers.contains(currentUser!.uid),
      onPressed: () => followButtonPressed(user),
    );
  }

  Widget _buildBio(ProfileUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bio",
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        SizedBox(height: 10),
        BioBox(text: user.bio),
      ],
    );
  }

  Widget _buildPostsSection(ProfileUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 25),
          child: Text("Posts",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(height: 10),
        BlocBuilder<PostCubit, PostState>(
          buildWhen: (previous, current) {
            return current is PostsLoaded || current is PostsLoading;
          },
          builder: (context, state) {
            if (state is PostsLoaded) {
              final userPosts = state.posts
                  .where((post) => post.userId == widget.uid)
                  .toList();
              postCount = userPosts.length;
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: postCount,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      PostTile(
                        post: post,
                        onDeletePressed: () =>
                            context.read<PostCubit>().deletePost(post.id),
                      ),
                    ],
                  );
                },
              );
            } else if (state is PostsLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text("No posts.."));
            }
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(child: Text("No profile found..")),
    );
  }
}
