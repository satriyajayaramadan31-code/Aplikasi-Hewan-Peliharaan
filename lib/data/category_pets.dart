import 'package:flutter/material.dart';
import '../data/pets_data.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';

class CategoryPage extends StatelessWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // ambil data sesuai tipe (case-insensitive)
    final List<Pet> items = petsData
        .where((p) => p.type.toLowerCase() == category.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: AppColors.tealDark,
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Belum ada data untuk "$category"',
                style: TextStyle(color: AppColors.darkGray),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = items[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        p.imagePath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: AppColors.limeLight.withValues(alpha: 0.3),
                          alignment: Alignment.center,
                          child: const Icon(Icons.pets),
                        ),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      p.traits,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: AppColors.darkGray),
                    onTap: () {
                      // TODO: navigasi ke detail pet
                    },
                  ),
                );
              },
            ),
    );
  }
}
