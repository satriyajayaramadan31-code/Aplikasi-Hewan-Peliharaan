import '../models/pet.dart';
import 'pets_data.dart';

// Hapus seluruh class PetDetailPage di file ini!

final List<String> petCategories = [
  'Kucing',
  'Anjing',
  'Burung',
  'Ikan',
  // Tambahkan kategori lain sesuai kebutuhan
];

List<Pet> getPetsByCategory(String category) {
  return petsData.where((pet) => pet.type.toLowerCase() == category.toLowerCase()).toList();
}
