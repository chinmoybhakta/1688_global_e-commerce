import 'package:ecommece_site_1688/feature/onboarding/widgets/features_section.dart';
import 'package:ecommece_site_1688/feature/onboarding/widgets/footer_section.dart';
import 'package:ecommece_site_1688/feature/onboarding/widgets/hero_section.dart';
import 'package:ecommece_site_1688/feature/onboarding/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: const [
                    Navbar(),
                    HeroSection(),
                    FeaturesSection(),

                    Spacer(), // ⬅ pushes footer to bottom

                    FooterSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
