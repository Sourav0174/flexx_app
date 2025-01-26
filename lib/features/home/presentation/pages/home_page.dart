import 'package:flexx/features/home/presentation/components/custom_drawer.dart';
import 'package:flexx/features/post/presentation/components/post_tile.dart';
import 'package:flexx/features/home/presentation/pages/upload_post_page.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flexx/features/post/presentation/cubits/post_states.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PostCubit postCubit;

  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
    _fetchAllPosts();
  }

  void _fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void _deletePost(String postId) {
    postCubit.deletePost(postId);
    _fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        // foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 5,
        shadowColor: Theme.of(context).colorScheme.secondary,
        actions: [
          // Add Post button with Neugraphism effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadPostPage()),
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostsUploading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No posts available"),
              );
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  // Neugraphism effect for each post tile
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.5),
                        Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(6, 6),
                        blurRadius: 20,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        offset: const Offset(-6, -6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: PostTile(
                    post: post,
                    onDeletePressed: () => _deletePost(post.id),
                  ),
                );
              },
            );
          } else if (state is PostsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 16),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
