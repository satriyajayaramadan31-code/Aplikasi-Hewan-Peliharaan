import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';

class PetDetailPage extends StatelessWidget {
  final Pet pet;
  const PetDetailPage({super.key, required this.pet});

  Widget sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: AppColors.tealDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  pet.imagePath,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 220,
                      color: AppColors.limeLight.withValues(alpha: 0.3),
                      alignment: Alignment.center,
                      child: const Icon(Icons.pets, size: 80),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(pet.type, style: const TextStyle(color: Colors.black54)),
            sectionTitle('Karakteristik'),
            Text(pet.traits),
            sectionTitle('Tips Perawatan Singkat'),
            Text(pet.careTips),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealDark,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} ditandai sementara!'),
                      backgroundColor: AppColors.tealDark,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Tandai / Simpan (sementara)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
