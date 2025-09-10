import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_hewan_peliharaan/pages/pet_detail_page.dart';
import '../data/pets_data.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';

/// PetListPage — top green box removed, clean header inside body, fokus hijau.

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> with TickerProviderStateMixin {
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
  String? selectedCategory;

  late final AnimationController _bgController;
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _listController.forward();
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
      results = query.isEmpty ? [] : petsData.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
      _listController.forward(from: 0);
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  void _selectCategory(String? category) {
    setState(() {
      if (selectedCategory == category) selectedCategory = null;
      else selectedCategory = category;
      _listController.forward(from: 0);
    });
  }

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween<double>(begin: 0.99, end: 1.0).animate(anim), child: child),
        ),
      );

  List<Pet> _computeDisplayList() {
    final bool searching = query.isNotEmpty;
    Iterable<Pet> base = searching ? results : petsData;
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      base = base.where((p) => p.type.toLowerCase() == selectedCategory!.toLowerCase());
    }
    return base.toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = query.isNotEmpty;
    final theme = Theme.of(context);
    final displayList = _computeDisplayList();

    return Scaffold(
      // remove prominent AppBar box — keep a minimal status bar area
      appBar: AppBar(
        toolbarHeight: 6, // almost invisible bar to keep status bar color
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: false,
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
                    AppColors.bgLight,
                    AppColors.limeLight.withValues(alpha: 0.08),
                    Colors.white,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ===== Clean header (replaces the big green box) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // left accent circle + short title
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.limeLight.withValues(alpha: 0.95), AppColors.greenFresh.withValues(alpha: 0.95)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: AppColors.darkGray.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.pets, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),

                      // title + subtitle stacked
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            'Temukan Hewan Peliharaan',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkGray, fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedCategory == null ? 'Pilih kategori atau cari nama hewan' : 'Kategori: $selectedCategory',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkGray.withValues(alpha: 0.6)),
                          ),
                        ]),
                      ),

                      // clear all / show-all quick button
                      IconButton(
                        onPressed: () {
                          _selectCategory(null);
                          _clearSearch();
                        },
                        icon: Icon(Icons.clear_all, color: AppColors.darkGray.withValues(alpha: 0.7)),
                        tooltip: 'Reset filter',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SEARCH BOX
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _TopBar(controller: _controller, onChanged: _onSearchChanged, onClear: _clearSearch),
                ),

                const SizedBox(height: 12),

                // category chips
                SizedBox(
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          return _AllCategoryChip(
                            selected: selectedCategory == null,
                            onTap: () {
                              _selectCategory(null);
                              _clearSearch();
                            },
                          );
                        }
                        final c = categories[idx - 1];
                        final isSelected = selectedCategory?.toLowerCase() == c.name.toLowerCase();
                        return _CategoryChip(category: c, selected: isSelected, onTap: () => _selectCategory(c.name));
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // result count / hint
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      searching ? 'Menampilkan ${displayList.length} hasil untuk "$query"' : (selectedCategory == null ? 'Semua hewan' : 'Menampilkan ${displayList.length} item'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkGray.withValues(alpha: 0.6)),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // grid area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: displayList.isEmpty
                        ? Center(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.search_off, size: 80, color: AppColors.darkGray.withValues(alpha: 0.6)),
                              const SizedBox(height: 12),
                              Text(searching ? 'Tidak ada hasil' : 'Belum ada item', style: TextStyle(color: AppColors.darkGray)),
                            ]),
                          )
                        : _buildGridFromList(context, displayList),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridFromList(BuildContext context, List<Pet> list) {
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
          child: _FancyPetCard(pet: pet, onTap: () => Navigator.of(context).push(_fadeRoute(PetDetailPage(pet: pet)))),
        );
      },
    );
  }
}

/// -------------------- Small widgets (unchanged visual language, focused green) --------------------

class _CategoryChip extends StatelessWidget {
  final _Category category;
  final VoidCallback onTap;
  final bool selected;
  const _CategoryChip({required this.category, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? LinearGradient(colors: [AppColors.greenFresh.withValues(alpha: 1.0), AppColors.limeLight.withValues(alpha: 1.0)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : LinearGradient(colors: [Colors.white.withOpacity(0.98), AppColors.limeLight.withValues(alpha: 0.24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.greenFresh.withValues(alpha: 0.36) : Colors.black.withAlpha(8),
                blurRadius: selected ? 18 : 8,
                offset: Offset(0, selected ? 10 : 6),
              ),
            ],
            border: selected ? Border.all(color: AppColors.greenFresh.withValues(alpha: 0.7), width: 1.5) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? RadialGradient(colors: [AppColors.limeLight.withValues(alpha: 0.9), AppColors.greenFresh.withValues(alpha: 0.7)])
                      : RadialGradient(colors: [AppColors.limeLight.withValues(alpha: 0.7), Colors.white.withAlpha(40)]),
                  boxShadow: [
                    BoxShadow(
                      color: selected ? AppColors.greenFresh.withValues(alpha: 0.36) : Colors.black.withAlpha(8),
                      blurRadius: selected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(child: Image.asset(category.assetPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.pets))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(category.name, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.darkGray)),
                  const SizedBox(height: 4),
                  Text('Lihat', style: TextStyle(color: selected ? Colors.white70 : AppColors.darkGray.withValues(alpha: 0.6), fontSize: 12)),
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
  final bool selected;
  const _AllCategoryChip({this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenFresh : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 6))],
          border: selected ? Border.all(color: AppColors.limeLight.withValues(alpha: 0.86), width: 1.5) : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.grid_view, color: selected ? Colors.white : AppColors.darkGray),
          const SizedBox(height: 6),
          Text('Semua', style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.darkGray, fontSize: 12)),
        ]),
      ),
    );
  }
}

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
            Positioned.fill(child: Image.asset(pet.imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.limeLight.withValues(alpha: 0.6)))),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.greenFresh.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.95)],
                    stops: [0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(left: 12, top: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withAlpha(220), borderRadius: BorderRadius.circular(10)), child: Text(pet.type, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGray, fontSize: 12)))),
            Positioned(left: 0, right: 0, bottom: 0, child: _GlassInfoFooter(pet: pet)),
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withAlpha(200), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)), boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, -2))]),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(pet.traits, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.darkGray.withValues(alpha: 0.8), fontSize: 12))])),
            const SizedBox(width: 8),
            Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.limeLight, AppColors.greenFresh]), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: AppColors.darkGray.withValues(alpha: 0.3), blurRadius: 8)]), child: const Icon(Icons.arrow_forward, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

/// simple top search bar
class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _TopBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 6))]),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari nama hewan...',
            prefixIcon: Icon(Icons.search, color: AppColors.darkGray),
            suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
      ),
    );
  }
}

/// Animated background blobs (subtle, greenish)
class _AnimatedBlobs extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBlobs({required this.controller});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (_, __) => CustomPaint(painter: _BlobsPainter(progress: controller.value)));

}

class _BlobsPainter extends CustomPainter {
  final double progress;
  _BlobsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final blobSpecs = [
      _BlobSpec(offset: Offset(size.width * 0.18 + sin(progress * 2 * pi) * 20, size.height * 0.22 + cos(progress * 2 * pi) * 18), radius: size.shortestSide * 0.28, color: AppColors.limeLight.withValues(alpha: 0.40)),
      _BlobSpec(offset: Offset(size.width * 0.85 + cos(progress * 1.5 * pi) * 16, size.height * 0.18 + sin(progress * 1.5 * pi) * 12), radius: size.shortestSide * 0.18, color: AppColors.greenFresh.withValues(alpha: 0.38)),
      _BlobSpec(offset: Offset(size.width * 0.32 + sin(progress * 1.3 * pi) * 20, size.height * 0.78 + cos(progress * 1.3 * pi) * 16), radius: size.shortestSide * 0.36, color: AppColors.orangeBright.withValues(alpha: 0.28)),
    ];

    for (final b in blobSpecs) {
      final rect = Rect.fromCircle(center: b.offset, radius: b.radius);
      final shader = RadialGradient(colors: [b.color, Colors.transparent]).createShader(rect);
      final p = Paint()..shader = shader;
      canvas.drawCircle(b.offset, b.radius, p);
    }

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
