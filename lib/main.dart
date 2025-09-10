import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/pet_list_page.dart';
import 'pages/splash_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Hewan Peliharaan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.greenFresh),
        useMaterial3: false,
        textTheme: const TextTheme().apply(bodyColor: Colors.black87),
      ),
      // start from splash screen
      home: const SplashScreen(),
      // still keep PetListPage import available for navigation after splash
      routes: {
        '/home': (_) => const PetListPage(),
      },
    );
  }
}
