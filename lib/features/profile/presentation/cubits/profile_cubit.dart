import 'dart:typed_data';

import 'package:flexx/features/post/domain/repo/post_repo.dart';
import 'package:flexx/features/profile/domain/entities/profile_user.dart';
import 'package:flexx/features/profile/domain/repos/profile_repo.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_state.dart';
import 'package:flexx/features/storage/domain/storage_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.storageRepo, required this.profileRepo})
      : super(ProfileInitial());

  // fetch user profile using repo - >useful for loading ingle profile pages
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // return user profile given uid -> useful for loading many profile for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio and profile picture
  Future<void> updateProfile(
      {required String uid,
      String? newBio,
      Uint8List? imageWebBytes,
      String? imageMobilePath}) async {
    emit(ProfileLoading()); // Indicate that the update process has started
    try {
      // Fetch the current profile
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return; // Exit early if the user is not found
      }

      // profile picture update
      String? imageDownloadUrl;

      // ensure there is an image
      if (imageWebBytes != null || imageMobilePath != null) {
        // for mobile
        if (imageMobilePath != null) {
          // upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }
        // for web
        else if (imageWebBytes != null) {
          // upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }
      }

      if (imageDownloadUrl == null) {
        emit(ProfileError("Failed to upload image"));
      }

      // Create the updated profile object
      final updatedProfile = currentUser.copyWith(
          bio: newBio ?? currentUser.bio,
          newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl);

      // Update the profile in the repository
      await profileRepo.updateProfile(updatedProfile);

      // Re-fetch the updated profile to ensure state is up-to-date
      final updatedUser = await profileRepo.fetchUserProfile(uid);
      if (updatedUser != null) {
        emit(ProfileLoaded(updatedUser));
      } else {
        emit(ProfileError("Failed to fetch updated profile"));
      }
    } catch (e) {
      // Emit an error state if something goes wrong
      emit(ProfileError("Error updating profile: ${e.toString()}"));
    }
  }

  // toggle follow method
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow : $e"));
    }
  }
}
