import 'package:ecommece_site_1688/core/resource/theme_manager.dart';
import 'package:ecommece_site_1688/core/route/route_config.dart';
import 'package:ecommece_site_1688/core/route/route_name.dart';
import 'package:ecommece_site_1688/core/service/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyService.initialize();
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Agency',
      theme: getApplicationTheme(),
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.splashScreen,
    );
  }
}
