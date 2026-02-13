import 'package:ecommece_site_1688/core/route/route_name.dart';
// import 'package:ecommece_site_1688/feature/contact/contact_screen.dart';
import 'package:ecommece_site_1688/feature/home/home_screen.dart';
// import 'package:ecommece_site_1688/feature/product/product_screen.dart';
import 'package:ecommece_site_1688/feature/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      // case RouteNames.productScreen:
      //   return MaterialPageRoute(builder: (_) => const ProductScreen());
      // case RouteNames.contactScreen:
      //   return MaterialPageRoute(builder: (_) => const ContactScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
