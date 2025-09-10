import 'package:flutter/material.dart';
import 'pages/pet_list_page.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFF181A20),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF5AA9A3),
          secondary: const Color(0xFFF4743B),
        ),
      ),
      home: const PetListPage(),
    );
  }
}
