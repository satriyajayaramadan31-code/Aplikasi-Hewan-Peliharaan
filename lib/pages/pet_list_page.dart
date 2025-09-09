import 'package:flutter/material.dart';
import '../data/pets_data.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';
import '../data/category_pets.dart';
import 'pet_detail_page.dart';

class PetListPage extends StatefulWidget {
  // jangan const di sini
  PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final List<Category> categories = const [
    Category('Kucing', 'assets/types/cat.png'),
    Category('Anjing', 'assets/types/dog.png'),
    Category('Kelinci', 'assets/types/rabbit.png'),
    Category('Hamster', 'assets/types/hamster.png'),
    Category('Burung', 'assets/types/bird.png'),
  ];

  String query = '';
  List<Pet> results = [];

  void _onSearchChanged(String v) {
    setState(() {
      query = v.trim();
      if (query.isEmpty) {
        results = [];
      } else {
        results = petsData
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() => _onSearchChanged('');

  @override
  Widget build(BuildContext context) {
    final bool searching = query.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.limeLight.withValues(alpha: 20),
      appBar: AppBar(
        backgroundColor: AppColors.tealDark,
        title: const Text('Katalog Hewan Peliharaan'),
        centerTitle: true,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildSearchField(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                searching ? 'Hasil Pencarian' : 'Pilih Jenis Hewan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                searching
                    ? 'Menampilkan ${results.length} hasil untuk "$query"'
                    : 'Ketuk salah satu jenis di bawah untuk melihat daftar spesies / nama hewan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGray.withValues(alpha: 204),
                    ),
              ),
              const SizedBox(height: 16),

              // Jika sedang mencari -> tampilkan list hasil / pesan tidak ditemukan
              if (searching) ...[
                Expanded(child: _buildSearchResults()),
              ] else ...[
                // Grid kategori
                Expanded(
                  child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.12,
                    ),
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      return CategoryCard(
                        category: c,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPage(category: c.name),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: _onSearchChanged,
        controller: TextEditingController(text: query),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Cari nama hewan (mis. Persia, Golden Retriever)...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchChanged,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 72, color: AppColors.darkGray.withValues(alpha: 153)),
            const SizedBox(height: 12),
            Text('Tidak ditemukan', style: TextStyle(fontSize: 18, color: AppColors.darkGray)),
            const SizedBox(height: 6),
            Text('"$query"', style: TextStyle(color: AppColors.darkGray.withValues(alpha: 150))),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _clearSearch,
              child: const Text('Bersihkan Pencarian'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = results[index];
        return _SearchResultTile(
          pet: p,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PetDetailPage(pet: p)),
            );
          },
        );
      },
      padding: const EdgeInsets.only(top: 8, bottom: 12),
    );
  }
}

class Category {
  final String name;
  final String assetPath;
  const Category(this.name, this.assetPath);
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  const CategoryCard({required this.category, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          children: [
            // gambar background (asset)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  category.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.limeLight.withValues(alpha: 90),
                  ),
                ),
              ),
            ),
            // gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 115),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // label
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.tealDark.withValues(alpha: 230),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _SearchResultTile({required this.pet, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            pet.imagePath,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              color: AppColors.limeLight.withValues(alpha: 77),
              alignment: Alignment.center,
              child: const Icon(Icons.pets),
            ),
          ),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(pet.type),
        trailing: Icon(Icons.chevron_right, color: AppColors.darkGray),
        onTap: onTap,
      ),
    );
  }
}
