import '../models/pet.dart';

final List<Pet> petsData = [
  Pet(
    id: 1,
    name: 'Kiki',
    type: 'Kucing',
    imageUrl: 'https://placekitten.com/400/300',
    characteristics: 'Pemalu, suka tidur, pembersih diri.',
    careTips: 'Bersihkan litter box setiap hari. Sikat bulu seminggu 2-3x.',
  ),
  Pet(
    id: 2,
    name: 'Bimo',
    type: 'Anjing (Beagle)',
    imageUrl: 'https://placedog.net/400/300?id=1',
    characteristics: 'Ramah, aktif, suka berjalan.',
    careTips: 'Jalan minimal 30 menit/hari. Periksa telinga rutin.',
  ),
  Pet(
    id: 3,
    name: 'Mochi',
    type: 'Kelinci',
    imageUrl: 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=60',
    characteristics: 'Tenang, pemalu, suka mengunyah.',
    careTips: 'Sediakan jerami dan mainan kunyah. Bersihkan kandang tiap minggu.',
  ),
  Pet(
    id: 4,
    name: 'Pipin',
    type: 'Hamster',
    imageUrl: 'https://images.unsplash.com/photo-1556228720-9d6b3f6f0d9d?auto=format&fit=crop&w=400&q=60',
    characteristics: 'Aktif di malam hari, kecil.',
    careTips: 'Sediakan roda yang aman, cuci kandang tiap 2 minggu.',
  ),
  Pet(
    id: 5,
    name: 'Koko',
    type: 'Burung (Kakatua)',
    imageUrl: 'https://images.unsplash.com/photo-1501703979959-797917eb21c8?auto=format&fit=crop&w=400&q=60',
    characteristics: 'Cerdas, suka meniru suara.',
    careTips: 'Berikan stimulasi mental, bersihkan sangkar rutin.',
  ),
];
