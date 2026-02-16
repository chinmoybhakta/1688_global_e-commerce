import 'package:ecommece_site_1688/core/const/app_colors.dart';
import 'package:ecommece_site_1688/core/data/riverpod/search_notifier.dart';
import 'package:ecommece_site_1688/core/route/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    Future.microtask(() async {
      await ref.read(searchProvider.notifier).fetchSearchItems(" ", 1);

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset('assets/logo.png', width: 200, height: 200),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Wholesale Marketplace',
                style: TextStyle(fontSize: 16, color: AppColors.semiPrimaryColor),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
