import 'package:flexx/features/auth/presentation/pages/login_page.dart';
import 'package:flexx/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Private state variable to toggle between login and register pages
  bool _showLoginPage = true;

  // Method to toggle between pages
  void _togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginPage ? LoginPage() : RegisterPage();
  }
}
