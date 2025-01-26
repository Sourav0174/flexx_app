import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flexx/features/auth/presentation/components/custom_textfield.dart';
import 'package:flexx/features/profile/domain/entities/profile_user.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // bio text controller
  final bioTextController = TextEditingController();

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // update profile
  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    // prepare images
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    // only update profile if there is something to update
    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading state
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Uploading...")],
              ),
            ),
          );
        }
        // edit form
        return buildEditPage();
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // show a confirmation and go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
        if (state is ProfileError) {
          // show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: updateProfile, icon: Icon(Icons.upload))
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          // Profile picture (neumorphic effect with smaller size)
          Center(
            child: Container(
              height: 120, // Smaller height
              width: 120, // Smaller width
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(-3, -3), // Light shadow for "pushed" effect
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(3, 3), // Shadow for "extruded" effect
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  // display selected image for mobile
                  (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        )
                      // display selected image for web
                      : (kIsWeb && webImage != null)
                          ? Image.memory(webImage!)
                          :
                          // No image selected -> display existing profile pic
                          CachedNetworkImage(
                              imageUrl: widget.user.profileImageUrl,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              imageBuilder: (context, ImageProvider) => Image(
                                image: ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          // Pick image button (neumorphic style)
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Theme.of(context).colorScheme.primary,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                "Pick Image",
                style: TextStyle(color: Colors.white),
              ),
              textColor: Theme.of(context).colorScheme.inversePrimary,
              // shadowColor: Colors.grey.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 20),
          // Bio section (neumorphic effect)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bio", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                CustomTextField(
                  controller: bioTextController,
                  hintText: widget.user.bio,
                  obscureText: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
