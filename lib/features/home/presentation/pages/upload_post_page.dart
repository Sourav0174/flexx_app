import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flexx/features/auth/domain/app_user.dart';
import 'package:flexx/features/auth/presentation/components/custom_textfield.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/home/presentation/pages/home_page.dart';
import 'package:flexx/features/post/domain/entities/post.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flexx/features/post/presentation/cubits/post_states.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? _imagePickedFile;
  Uint8List? _webImage;
  final _textController = TextEditingController();
  late final AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final authCubit = context.read<AuthCubit>();
    _currentUser = authCubit.currentUser;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        _imagePickedFile = result.files.first;
        if (kIsWeb) {
          _webImage = _imagePickedFile?.bytes;
        }
      });
    }
  }

  void _uploadPost() {
    if (_imagePickedFile == null || _textController.text.isEmpty) {
      _showSnackBar("Both image and caption are required");
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.uid,
      userName: _currentUser!.name,
      text: _textController.text,
      imageUrl: "",
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    final postCubit = context.read<PostCubit>();

    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: _imagePickedFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: _imagePickedFile?.path);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
    );
  }

  Widget _buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: _uploadPost,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (kIsWeb && _webImage != null)
                _neumorphicContainer(child: Image.memory(_webImage!)),
              if (!kIsWeb && _imagePickedFile != null)
                _neumorphicContainer(
                    child: Image.file(File(_imagePickedFile!.path!))),
              const SizedBox(height: 16),
              _neumorphicButton(
                onTap: _pickImage,
                child: const Text("Pick Image",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              _neumorphicContainer(
                child: CustomTextField(
                  controller: _textController,
                  hintText: "Caption",
                  obscureText: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Neumorphic container for images and buttons
  Widget _neumorphicContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
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
      child: child,
    );
  }

  // Neumorphic button for Pick Image button
  Widget _neumorphicButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        child: child,
      ),
    );
  }
}
