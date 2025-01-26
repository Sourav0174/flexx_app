import 'package:flexx/core/themes/dark_mode.dart';
import 'package:flexx/core/themes/light_mode.dart';
import 'package:flexx/core/themes/theme_cubit.dart';
import 'package:flexx/features/auth/data/firebase_auth_repo.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_states.dart';
import 'package:flexx/features/auth/presentation/pages/auth_page.dart';
import 'package:flexx/features/home/presentation/pages/home_page.dart';
import 'package:flexx/features/post/data/firebase_post_repo.dart';
import 'package:flexx/features/post/presentation/cubits/post_cubit.dart';
import 'package:flexx/features/profile/data/firebase_profile_repo.dart';
import 'package:flexx/features/profile/domain/repos/profile_repo.dart';
import 'package:flexx/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flexx/features/search/data/firebase_search_repo.dart';
import 'package:flexx/features/search/presentation/cubits/search_cubit.dart';
import 'package:flexx/features/storage/data/firebase_storage_repo.dart';
import 'package:flexx/features/storage/domain/storage_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();
  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();
  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();
  // post repo
  final firebasePostRepo = FirebasePostRepo();
  // search repo
  final firebaseSearchRepo = FirebaseSearchRepo();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          // auth cubit
          BlocProvider<AuthCubit>(
              create: (context) =>
                  AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()),
          // profile cubit
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                  profileRepo: firebaseProfileRepo,
                  storageRepo: firebaseStorageRepo)),
          // post cubit
          BlocProvider<PostCubit>(
              create: (context) => PostCubit(
                    postRepo: firebasePostRepo,
                    storageRepo: firebaseStorageRepo,
                  )),
          // search cubit
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
          ),
          // theme cubit
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, currentTheme) => MaterialApp(
            debugShowMaterialGrid: false,
            title: 'Flexx',
            theme: currentTheme,
            debugShowCheckedModeBanner: false,
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, AuthState) {
                if (AuthState is Unauthenticated) {
                  return const AuthPage();
                } else if (AuthState is Authenticated) {
                  return const HomePage();
                } else {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ),
        ));
  }
}
