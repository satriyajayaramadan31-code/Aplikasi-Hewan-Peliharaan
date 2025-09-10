import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';

class PetDetailPage extends StatelessWidget {
  final Pet pet;
  const PetDetailPage({super.key, required this.pet});

  Widget sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.orangeBright, AppColors.tealLight],
          ).createShader(bounds),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1.1,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      );

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Hero(
            tag: 'pet-${pet.id}',
            child: InteractiveViewer(
              child: Image.asset(
                pet.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.tealLight.withAlpha(80),
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, size: 120, color: AppColors.orangeBright),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.tealLight, AppColors.orangeBright],
          ).createShader(bounds),
          child: Text(
            pet.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background gradient & neon blobs
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.tealLight.withAlpha(180),
                    AppColors.darkBg,
                    AppColors.orangeBright.withAlpha(120),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Neon blob
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orangeBright.withAlpha(90),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tealLight.withAlpha(80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar dengan animasi dan glass
                GestureDetector(
                  onTap: () => _showFullImage(context),
                  child: Hero(
                    tag: 'pet-${pet.id}',
                    child: Container(
                      width: width,
                      height: width * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orangeBright.withAlpha(60),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              pet.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.tealLight.withAlpha(80),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.pets, size: 80, color: AppColors.orangeBright),
                                );
                              },
                            ),
                            // Glass overlay
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha(80),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tealLight.withAlpha(30),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.orangeBright.withAlpha(60),
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama & tipe
                          Row(
                            children: [
                              Icon(Icons.pets, color: AppColors.orangeBright, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight.withAlpha(180),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  pet.type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(
                            color: AppColors.orangeBright.withAlpha(120),
                            thickness: 1.2,
                            endIndent: 60,
                          ),
                          sectionTitle('Karakteristik'),
                          Text(
                            pet.traits,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          sectionTitle('Tips Perawatan Singkat'),
                          Text(
                            pet.careTips,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.tealLight.withAlpha(220),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
