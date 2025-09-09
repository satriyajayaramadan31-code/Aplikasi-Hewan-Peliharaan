import 'package:flutter/material.dart';
import '../data/pets_data.dart';
import '../models/pet.dart';
import '../widgets/pet_list_tile.dart';
import 'pet_detail_page.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({Key? key}) : super(key: key);

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  List<Pet> displayed = petsData;
  String query = '';

  void updateSearch(String q) {
    setState(() {
      query = q;
      if (q.isEmpty) {
        displayed = petsData;
      } else {
        displayed = petsData
            .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Hewan Peliharaan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari hewan berdasarkan nama...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => updateSearch(''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: displayed.isEmpty
                ? Center(child: Text('Tidak ditemukan: "$query"'))
                : ListView.builder(
                    itemCount: displayed.length,
                    itemBuilder: (context, index) {
                      final pet = displayed[index];
                      return PetListTile(
                        pet: pet,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetDetailPage(pet: pet),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
