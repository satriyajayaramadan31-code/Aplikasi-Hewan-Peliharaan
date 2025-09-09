class Pet {
  final int id;
  final String name;        // Nama spesies/ras (misal: Persia, Golden Retriever)
  final String type;        // Jenis utama (Kucing, Anjing, Kelinci, dll)
  final String imagePath;   // Path asset lokal, bukan URL
  final String traits;      // Karakteristik singkat
  final String careTips;    // Tips perawatan singkat

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.traits,
    required this.careTips,
  });
}
