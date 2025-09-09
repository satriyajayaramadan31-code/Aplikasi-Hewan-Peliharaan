import 'package:flutter/material.dart';
import 'pages/pet_list_page.dart';

void main() {
  runApp(const PetCatalogApp());
}

class PetCatalogApp extends StatelessWidget {
  const PetCatalogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Hewan Peliharaan',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const PetListPage(),
    );
  }
}
