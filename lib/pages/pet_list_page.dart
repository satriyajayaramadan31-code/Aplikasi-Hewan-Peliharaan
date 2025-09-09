import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_hewan_peliharaan/pages/pet_detail_page.dart';
import '../data/pets_data.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';

/// Improved PetListPage: full pet grid, nicer gradients, glass cards, animated blobs.

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> with TickerProviderStateMixin {
  // categories kept as const so the list can be const
  static const List<_Category> categories = [
    _Category('Kucing', 'images/types/cat.png'),
    _Category('Anjing', 'images/types/dog.png'),
    _Category('Kelinci', 'images/types/rabbit.png'),
    _Category('Hamster', 'images/types/hamster.png'),
    _Category('Burung', 'images/types/bird.png'),
  ];

  final TextEditingController _controller = TextEditingController();
  String query = '';
  List<Pet> results = [];

  late final AnimationController _bgController; // for animated blobs
  late final AnimationController _listController; // for staggered cards

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _listController.forward();

    // optional auto-open: keep but check mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (petsData.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        // Navigator.of(context).push(_fadeRoute(PetDetailPage(pet: petsData[0])));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() {
      query = v.trim();
      if (query.isEmpty) {
        results = [];
      } else {
        results = petsData.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
        _listController.forward(from: 0);
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: ScaleTransition(scale: Tween<double>(begin: 0.99, end: 1.0).animate(anim), child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = query.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      // base gradient background created by a CustomPaint (animated blobs) + subtle overlay
      body: Stack(
        children: [
          Positioned.fill(child: _AnimatedBlobs(controller: _bgController)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.tealDark.withAlpha(28),
                    AppColors.greenFresh.withAlpha(18),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Top bar with title and search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _TopBar(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                ),
                const SizedBox(height: 12),

                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          searching ? 'Hasil Pencarian' : 'Cari & Jelajahi Hewan',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if (!searching)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.limeLight.withAlpha(220), AppColors.greenFresh.withAlpha(200)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.darkGray.withAlpha(30), blurRadius: 8, offset: const Offset(0, 6))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('Futuristic', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      searching ? 'Menampilkan ${results.length} hasil untuk "$query"' : 'Kategori populer & semua hewan tersedia di bawah',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkGray.withAlpha(150)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Category chips (compact) + "show all" control
                SizedBox(
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1, // +1 for "All"
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          return _AllCategoryChip(onTap: () {
                            // reset search to show all
                            _clearSearch();
                            // animate grid
                            _listController.forward(from: 0);
                          });
                        }
                        final c = categories[idx - 1];
                        return _CategoryChip(category: c, onTap: () {
                          final filtered = petsData.where((p) => p.type == c.name).toList();
                          Navigator.of(context).push(_fadeRoute(_CategoryPetsPage(category: c.name, pets: filtered)));
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Content area (grid or list)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: searching ? _buildSearchList() : _buildFullGrid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => HapticFeedback.lightImpact(),
        backgroundColor: AppColors.orangeBright,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchList() {
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 88, color: AppColors.darkGray.withAlpha(60)),
          const SizedBox(height: 10),
          Text('Tidak ada hasil', style: TextStyle(color: AppColors.darkGray)),
          const SizedBox(height: 12),
          Text('"$query"', style: TextStyle(color: AppColors.darkGray.withAlpha(160))),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = results[i];
        return _LargeResultTile(pet: p, onTap: () => Navigator.of(context).push(_fadeRoute(PetDetailPage(pet: p))));
      },
    );
  }

  Widget _buildFullGrid(BuildContext context) {
    final list = petsData;
    final width = MediaQuery.of(context).size.width;
    final cross = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final pet = list[idx];
        final start = (idx * 0.02).clamp(0.0, 0.8);
        final end = (start + 0.6).clamp(0.0, 1.0);
        final anim = CurvedAnimation(parent: _listController, curve: Interval(start, end, curve: Curves.easeOutQuad));
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            final t = anim.value;
            return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, (1 - t) * 10), child: child));
          },
          child: _FancyPetCard(
            pet: pet,
            onTap: () => Navigator.of(context).push(_fadeRoute(PetDetailPage(pet: pet))),
          ),
        );
      },
    );
  }
}

/// -------------------- Widgets used by page --------------------

class _CategoryChip extends StatelessWidget {
  final _Category category;
  final VoidCallback onTap;
  const _CategoryChip({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: [Colors.white.withAlpha(220), AppColors.limeLight.withAlpha(24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.limeLight.withAlpha(180), Colors.white.withAlpha(40)]),
                ),
                child: ClipOval(
                  child: Image.asset(category.assetPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.pets)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(category.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Lihat', style: TextStyle(color: AppColors.darkGray.withAlpha(160), fontSize: 12)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllCategoryChip extends StatelessWidget {
  final VoidCallback? onTap;
  const _AllCategoryChip({this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 6))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.grid_view, color: AppColors.darkGray),
          const SizedBox(height: 6),
          Text('Semua', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGray, fontSize: 12)),
        ]),
      ),
    );
  }
}

/// card used in grid — big image + overlay info + glass footer
class _FancyPetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _FancyPetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // image background
            Positioned.fill(
              child: Image.asset(
                pet.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.limeLight.withAlpha(60)),
              ),
            ),

            // gradient overlay to make text readable
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.tealDark.withAlpha(40),
                      Colors.white.withAlpha(160),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // floating badge: type
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(200), borderRadius: BorderRadius.circular(10)),
                child: Text(pet.type, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGray, fontSize: 12)),
              ),
            ),

            // glassy footer with name + traits snippet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _GlassInfoFooter(pet: pet),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassInfoFooter extends StatelessWidget {
  final Pet pet;
  const _GlassInfoFooter({required this.pet});

  @override
  Widget build(BuildContext context) {
    // small glass panel
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(180),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(pet.traits, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.darkGray.withAlpha(200), fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 8),
              Column(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.limeLight, AppColors.greenFresh]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: AppColors.darkGray.withAlpha(30), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(''),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeResultTile extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  const _LargeResultTile({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Hero(
          tag: 'pet-${pet.id}',
          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(pet.imagePath, width: 84, height: 84, fit: BoxFit.cover)),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(pet.traits, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.chevron_right, color: AppColors.darkGray.withAlpha(160)),
      ),
    );
  }
}

/// Top bar with search embedded
class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _TopBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(children: [
        Expanded(child: Text('Katalog Hewan', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkGray))),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 6))],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama hewan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Category page that shows list of pets in a category
class _CategoryPetsPage extends StatelessWidget {
  final String category;
  final List<Pet> pets;
  const _CategoryPetsPage({required this.category, required this.pets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: AppColors.tealDark),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: pets.length,
        itemBuilder: (context, idx) {
          final p = pets[idx];
          return ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailPage(pet: p))),
            leading: Hero(tag: 'pet-${p.id}', child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(p.imagePath, width: 72, height: 72, fit: BoxFit.cover))),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(p.traits, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Icon(Icons.chevron_right, color: AppColors.darkGray.withAlpha(160)),
          );
        },
      ),
    );
  }
}

/// Animated blobs painter used as decorative background
class _AnimatedBlobs extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBlobs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(painter: _BlobsPainter(progress: controller.value));
      },
    );
  }
}

class _BlobsPainter extends CustomPainter {
  final double progress;
  _BlobsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paints = <Paint>[];
    final center = Offset(size.width / 2, size.height / 2);
    // three blobs with different colors from AppColors
    final blobSpecs = [
      (_BlobSpec(offset: Offset(size.width * 0.18 + sin(progress * 2 * pi) * 20, size.height * 0.22 + cos(progress * 2 * pi) * 18), radius: size.shortestSide * 0.28, color: AppColors.limeLight.withAlpha(40))),
      (_BlobSpec(offset: Offset(size.width * 0.85 + cos(progress * 1.5 * pi) * 16, size.height * 0.18 + sin(progress * 1.5 * pi) * 12), radius: size.shortestSide * 0.18, color: AppColors.greenFresh.withAlpha(38))),
      (_BlobSpec(offset: Offset(size.width * 0.32 + sin(progress * 1.3 * pi) * 20, size.height * 0.78 + cos(progress * 1.3 * pi) * 16), radius: size.shortestSide * 0.36, color: AppColors.orangeBright.withAlpha(28))),
    ];

    for (final b in blobSpecs) {
      final rect = Rect.fromCircle(center: b.offset, radius: b.radius);
      final shader = RadialGradient(colors: [b.color, Colors.transparent]).createShader(rect);
      final p = Paint()..shader = shader;
      canvas.drawCircle(b.offset, b.radius, p);
    }

    // faint diagonal lines to add texture
    final linePaint = Paint()..color = Colors.white.withAlpha(6)..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 28) {
      canvas.drawLine(Offset(x + progress * 20, 0), Offset(x + progress * 20 + size.height, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter old) => old.progress != progress;
}

class _BlobSpec {
  final Offset offset;
  final double radius;
  final Color color;
  _BlobSpec({required this.offset, required this.radius, required this.color});
}

class _Category {
  final String name;
  final String assetPath;
  const _Category(this.name, this.assetPath);
}
