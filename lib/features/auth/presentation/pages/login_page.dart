import 'package:flexx/features/auth/presentation/components/custom_button.dart';
import 'package:flexx/features/auth/presentation/components/custom_text.dart';
import 'package:flexx/features/auth/presentation/components/custom_textfield.dart';
import 'package:flexx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flexx/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method to handle login
  void _login() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show snackbar for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid email and password")),
      );
      return;
    }

    // Trigger login through the AuthCubit
    context.read<AuthCubit>().login(email, password);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Make the content scrollable
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  "assets/images/1.png",
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 40),
                CustomText(
                  text: "Welcome back!",
                  color: Theme.of(context).colorScheme.primary,
                  fontsize: 20,
                ),
                const SizedBox(height: 25),
                _buildNeumorphicContainer(
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 25),
                _buildNeumorphicContainer(
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 25),
                _buildNeumorphicContainer(
                  child: CustomButton(
                    onTap: _login,
                    text: "Login",
                  ),
                ),
                const SizedBox(height: 50),
                _buildRegisterRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper methods for UI components
  Widget _buildNeumorphicContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(15),
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

  Widget _buildRegisterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => RegisterPage())),
            child: Text(
              "Register now",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
