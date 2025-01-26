import 'package:flutter/material.dart';

class CustomDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const CustomDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 8.0), // Add spacing between tiles
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              offset: const Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
          ),
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            semanticLabel: title, // Added for better accessibility
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 16), // Adjust padding
        ),
      ),
    );
  }
}
