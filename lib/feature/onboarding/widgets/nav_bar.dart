import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '1688 global Shop',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          (width <= 460) ? const SizedBox() : Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Home')),
              TextButton(onPressed: () {}, child: const Text('Products')),
              TextButton(onPressed: () {}, child: const Text('Login')),
            ],
          ),
        ],
      ),
    );
  }
}
