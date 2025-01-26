import 'package:flexx/features/auth/domain/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser(
      {required this.bio,
      required this.profileImageUrl,
      required super.uid,
      required super.email,
      required super.name,
      required this.followers,
      required this.following});

  // method to update profile user
  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
    required String bio,
    List<String>? newFollowers,
    List<String>? newFollowing,
  }) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
    );
  }

  //  converting profile user ->json
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
    };
  }

  // convert json-> profile user
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      bio: json['bio'] ?? "",
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'] ?? "",
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
    );
  }
}
