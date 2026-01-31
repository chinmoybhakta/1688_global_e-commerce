import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.black87,
      child: const Center(
        child: Text(
          '© 2026 e-commerce 1688 global',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
