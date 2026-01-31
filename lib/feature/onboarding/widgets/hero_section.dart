import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      width: double.infinity,
      color: Colors.deepPurple,
      child: Flex(
        direction: width > 800 ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build Your Shopping Experience',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A modern e-commerce platform built with Flutter Web & Firebase Firestore.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Text('Get Started'),
                ),
              ),
            ],
          ),

          (width <= 870) ? const SizedBox() : Image.network(
            'https://img.alicdn.com/imgextra/i1/O1CN01FLiUvb1K4szSnB9fw_!!6000000001111-2-tps-176-68.png',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
