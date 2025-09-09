import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetListTile extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const PetListTile({required this.pet, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            pet.imagePath,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                width: 64,
                height: 64,
                alignment: Alignment.center,
                child: const Icon(Icons.pets),
              );
            },
          ),
        ),
        title: Text(pet.name),
        subtitle: Text(pet.type),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
