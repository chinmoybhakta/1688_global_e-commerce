// lib/feature/home/widgets/minimal_carousel.dart
import 'dart:async';

import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class MinimalCarousel extends StatefulWidget {
  final Function(int)? onPageChanged;
  final Function(int)? onTap;

  const MinimalCarousel({super.key, this.onPageChanged, this.onTap});

  @override
  State<MinimalCarousel> createState() => _MinimalCarouselState();
}

class _MinimalCarouselState extends State<MinimalCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> slides = const [
    {'image': 'slider_img_01.jpg'},
    {'image': 'slider_img_02.jpg'},
    {'image': 'slider_img_03.jpg'},
    {'image': 'slider_img_04.jpg'},
    {'image': 'slider_img_05.jpg'},
  ];

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: isMobile ? 150 : 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onTap?.call(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image (if available)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        slides[index]['image']!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: AppColors.primaryColor);
                        },
                      ),
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primaryColor
                      : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
