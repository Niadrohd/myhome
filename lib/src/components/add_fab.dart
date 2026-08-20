import 'package:flutter/material.dart';

class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.onPressed, this.icon = Icons.add});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
