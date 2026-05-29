import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import '../../../data/models/doa_model.dart';
import '../controllers/doa_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WARNA
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static Color get bg => R.color.bg1;
  static Color get surface => R.color.bg2;
  static Color get surface2 => R.color.emeraldMedium;
  static Color get gold => R.color.gold;
  static Color get goldLight => R.color.goldLight;
  static Color get goldDim => R.color.goldDim;
  static Color get emerald => R.color.emerald;
  static Color get emeraldLight => R.color.emeraldLight;
  static Color get text => R.color.textSoft;
  static Color get textMuted => R.color.textMuted;
  static Color get red => R.color.red;
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DoaView extends StatefulWidget {
  const DoaView({super.key});

  @override
  State<DoaView> createState() => _DoaViewState();
}

class _DoaViewState extends State<DoaView> with TickerProviderStateMixin {
  final controller = Get.find<DoaController>();
  late AnimationController _headerAnim;
  late AnimationController _listAnim;

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ScrollController _chipScroll = ScrollController();

  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();
    _listAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();

    // Infinite scroll listener
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        controller.loadMoreDoa();
      }
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _listAnim.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  void _onFilterChange(String kat) {
    controller.updateCategory(kat);
    _listAnim.forward(from: 0);
  }

  void _openDetail(DataDoa doa) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => DoaDetailScreen(doa: doa),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Color _getColorForGroup(String group) {
    if (group == 'Semua') return R.color.emerald;
    final int hash = group.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
  }

  String _getEmoji(DataDoa doa) {
    final name = doa.nama.toLowerCase();
    final group = doa.grup.toLowerCase();
    final tags = doa.tag.map((e) => e.toLowerCase()).toList();

    if (name.contains('tidur') || group.contains('tidur') || tags.contains('tidur')) {
      return '🌙';
    }
    if (name.contains('makan') || group.contains('makan') || tags.contains('makan')) {
      return '🍽️';
    }
    if (name.contains('masjid') || group.contains('masjid') || tags.contains('masjid')) {
      return '🕌';
    }
    if (name.contains('wudhu') || group.contains('wudhu') || tags.contains('wudhu')) {
      return '💧';
    }
    if (name.contains('rumah') || group.contains('rumah') || tags.contains('rumah')) {
      return '🏠';
    }
    if (name.contains('kendaraan') || name.contains('safar') || group.contains('perjalanan') || tags.contains('perjalanan')) {
      return '🚗';
    }
    if (name.contains('sakit') || name.contains('sehat') || group.contains('sakit') || tags.contains('sakit')) {
      return '❤️‍🩹';
    }
    if (name.contains('ilmu') || name.contains('belajar') || group.contains('pendidikan') || tags.contains('pendidikan')) {
      return '📚';
    }
    if (name.contains('rezeki') || name.contains('uang') || name.contains('harta') || group.contains('rezeki') || tags.contains('rezeki')) {
      return '💰';
    }
    if (name.contains('sholat') || name.contains('doa') || group.contains('shalat') || tags.contains('shalat')) {
      return '🧎';
    }
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildChips(),
          Obx(() => _buildStats(controller.filteredDoas.length)),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoading();
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildError(controller.errorMessage.value);
              }
              if (controller.displayedDoas.isEmpty) {
                return _buildEmpty();
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: controller.displayedDoas.length + (controller.hasMore.value ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == controller.displayedDoas.length) {
                    return _buildLoadMoreIndicator();
                  }
                  final delay = (i * 0.06).clamp(0.0, 0.6);
                  final doa = controller.displayedDoas[i];
                  return _DoaCard(
                    doa: doa,
                    isFavorit: controller.favoritIds.contains(doa.id),
                    emoji: _getEmoji(doa),
                    color: _getColorForGroup(doa.grup),
                    index: i,
                    animDelay: delay,
                    listAnim: _listAnim,
                    onTap: () => _openDetail(doa),
                    onFavorit: () => controller.toggleFavorit(doa.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnim,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20, right: 16, bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2A1A), Color(0xFF0A1A12)],
          ),
          border: Border(
            bottom: BorderSide(color: _C.goldDim.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.goldDim.withValues(alpha: 0.3)),
                  color: _C.surface2,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.goldLight, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [_C.goldDim, _C.goldLight],
                    ).createShader(b),
                    child: Text(
                      R.string.prayerTitle,
                      style: R.textStyle.extraLargeBold.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Obx(() => Text(
                    '${controller.filteredDoas.length} ${R.string.prayerCount}',
                    style: R.textStyle.small(color: _C.textMuted),
                  )),
                ],
              ),
            ),
            // Favorit toggle
            Obx(() {
              final active = controller.showFavoritOnly.value;
              return _AnimPressButton(
                onTap: () {
                  controller.toggleShowFavorit();
                  _listAnim.forward(from: 0);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: active
                        ? _C.red.withValues(alpha: 0.15)
                        : _C.surface2,
                    border: Border.all(
                      color: active
                          ? _C.red.withValues(alpha: 0.4)
                          : _C.goldDim.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: active ? _C.red : _C.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Favorit',
                        style: R.textStyle.small(
                          color: active ? _C.red : _C.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _C.surface2,
          border: Border.all(
            color: _searchActive
                ? _C.goldDim.withValues(alpha: 0.5)
                : _C.goldDim.withValues(alpha: 0.15),
          ),
          boxShadow: _searchActive
              ? [BoxShadow(color: _C.gold.withValues(alpha: 0.08), blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.search_rounded, color: _C.textMuted, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: R.textStyle.medium(color: _C.text),
                onChanged: (v) => controller.updateSearch(v),
                onTap: () => setState(() => _searchActive = true),
                onEditingComplete: () => setState(() => _searchActive = false),
                decoration: InputDecoration(
                  hintText: R.string.prayerSearchHint,
                  hintStyle: R.textStyle.medium(color: _C.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                ),
                cursorColor: _C.gold,
              ),
            ),
            Obx(() => controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      controller.updateSearch('');
                      setState(() { _searchActive = false; });
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded, color: _C.textMuted, size: 18),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // ── Category Chips ────────────────────────────────────────────────────────
  Widget _buildChips() {
    return Obx(() {
      final list = controller.kategoriList;
      return SizedBox(
        height: 44,
        child: ListView.separated(
          controller: _chipScroll,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final kat = list[i];
            final active = kat == controller.currentCategory.value;
            final color = _getColorForGroup(kat);
            return _AnimPressButton(
              onTap: () => _onFilterChange(kat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: active ? color.withValues(alpha: 0.2) : _C.surface2,
                  border: Border.all(
                    color: active ? color.withValues(alpha: 0.7) : _C.goldDim.withValues(alpha: 0.15),
                    width: active ? 1.2 : 1,
                  ),
                ),
                child: Text(
                  kat,
                  style: R.textStyle.small(
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? Color.lerp(color, Colors.white, 0.5) : _C.textMuted,
                  ).copyWith(letterSpacing: 0.3),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────
  Widget _buildStats(int count) {
    final favCount = controller.favoritIds.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Text(
            '$count doa ditemukan',
            style: R.textStyle.small(color: _C.textMuted).copyWith(fontSize: 11),
          ),
          const Spacer(),
          if (favCount > 0) ...[
            Icon(Icons.favorite_rounded, color: _C.red, size: 12),
            const SizedBox(width: 4),
            Text(
              '$favCount favorit',
              style: R.textStyle.small(color: _C.red).copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomLoader(size: 50),
          const SizedBox(height: 16),
          Text(
            'Memuat daftar doa...',
            style: R.textStyle.medium(color: _C.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: R.textStyle.mediumBold.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: R.textStyle.small(color: _C.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.fetchDoaList(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.surface2,
                foregroundColor: _C.goldLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _C.goldDim.withValues(alpha: 0.3)),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: _AnimatedEmptyState(
        isFavoritEmpty: controller.showFavoritOnly.value,
      ),
    );
  }

  // ── Load More Indicator ──────────────────────────────────────────────────
  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CustomLoader(size: 30),
      ),
    );
  }

  // ── FAB scroll to top ─────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton(
      mini: true,
      onPressed: () => _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ),
      backgroundColor: _C.surface2,
      elevation: 4,
      child: Icon(Icons.keyboard_arrow_up_rounded, color: _C.gold),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPSI PENGATURAN BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
void _showSettingsBottomSheet(BuildContext context, DoaController controller) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: _C.goldDim.withValues(alpha: 0.15)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _C.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengaturan Tampilan',
                style: R.textStyle.mediumBold.copyWith(color: _C.goldLight),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close_rounded, color: _C.textMuted, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Slider font size
          Text(
            'Ukuran Font Arab',
            style: R.textStyle.smallBold.copyWith(color: _C.text),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Text('A', style: TextStyle(color: _C.textMuted, fontSize: 16)),
              Expanded(
                child: Slider(
                  value: controller.arabicFontSize.value,
                  min: 18.0,
                  max: 40.0,
                  activeColor: _C.gold,
                  inactiveColor: _C.surface2,
                  onChanged: (val) => controller.setArabicFontSize(val),
                ),
              ),
              Text('A', style: TextStyle(color: _C.goldLight, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          )),
          const SizedBox(height: 16),
          
          // Latin toggle custom widget
          Obx(() => _buildSettingToggle(
            label: 'Tampilkan Transliterasi (Latin)',
            value: controller.showLatin.value,
            onTap: () => controller.toggleLatin(),
          )),
          
          const Divider(color: Colors.white10),
          
          // Translation toggle custom widget
          Obx(() => _buildSettingToggle(
            label: 'Tampilkan Terjemahan (Arti)',
            value: controller.showTranslation.value,
            onTap: () => controller.toggleTranslation(),
          )),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildSettingToggle({
  required String label,
  required bool value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: R.textStyle.medium(color: _C.text)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 26,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: value ? _C.emerald : _C.surface2,
              border: Border.all(
                color: value ? _C.emeraldLight.withValues(alpha: 0.3) : _C.goldDim.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  left: value ? 20.0 : 0.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DOA CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DoaCard extends StatefulWidget {
  final DataDoa doa;
  final bool isFavorit;
  final String emoji;
  final Color color;
  final int index;
  final double animDelay;
  final AnimationController listAnim;
  final VoidCallback onTap;
  final VoidCallback onFavorit;

  const _DoaCard({
    required this.doa,
    required this.isFavorit,
    required this.emoji,
    required this.color,
    required this.index,
    required this.animDelay,
    required this.listAnim,
    required this.onTap,
    required this.onFavorit,
  });

  @override
  State<_DoaCard> createState() => _DoaCardState();
}

class _DoaCardState extends State<_DoaCard> with SingleTickerProviderStateMixin {
  late AnimationController _favAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _favAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _favAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doa = widget.doa;
    final catColor = widget.color;

    return AnimatedBuilder(
      animation: widget.listAnim,
      builder: (_, child) {
        final t = ((widget.listAnim.value - widget.animDelay) / (1 - widget.animDelay))
            .clamp(0.0, 1.0);
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _C.surface,
              border: Border.all(color: _C.goldDim.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Left accent bar
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  // Subtle inner glow at top
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            catColor.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji badge
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: catColor.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: catColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(widget.emoji,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doa.nama,
                                    style: R.textStyle.mediumBold.copyWith(
                                      color: _C.text,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              _Chip(label: doa.grup, color: catColor),
                                              const SizedBox(width: 6),
                                              if (doa.tag.isNotEmpty)
                                                ...doa.tag.map((tag) => Padding(
                                                  padding: const EdgeInsets.only(right: 4),
                                                  child: _Chip(label: '#$tag', color: _C.gold),
                                                )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Favorit button
                            GestureDetector(
                              onTap: () {
                                widget.onFavorit();
                                if (!widget.isFavorit) {
                                  _favAnim.forward(from: 0);
                                }
                              },
                              child: AnimatedBuilder(
                                animation: _favAnim,
                                builder: (_, __) {
                                  final scale = _favAnim.isAnimating
                                      ? Tween<double>(begin: 1, end: 1.4)
                                          .chain(CurveTween(curve: Curves.elasticOut))
                                          .evaluate(_favAnim)
                                      : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      widget.isFavorit
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: widget.isFavorit ? _C.red : _C.textMuted,
                                      size: 22,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Arabic text preview
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _C.surface2,
                            border: Border.all(
                              color: _C.goldDim.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            doa.ar,
                            textAlign: TextAlign.right,
                            style: R.textStyle.largeNormal.copyWith(
                              fontFamily: 'Poppins',
                              color: _C.goldLight,
                              height: 1.7,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Arti preview
                        Text(
                          doa.idn,
                          style: R.textStyle.small(
                            color: _C.textMuted,
                          ).copyWith(height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Baca selengkapnya',
                              style: R.textStyle.small(
                                color: _C.emeraldLight,
                              ).copyWith(fontSize: 11, letterSpacing: 0.3),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: _C.emeraldLight, size: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DoaDetailScreen extends StatefulWidget {
  final DataDoa doa;

  const DoaDetailScreen({
    super.key,
    required this.doa,
  });

  @override
  State<DoaDetailScreen> createState() => _DoaDetailScreenState();
}

class _DoaDetailScreenState extends State<DoaDetailScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<DoaController>();
  late AnimationController _anim;
  bool _copied = false;
  bool _latinVisible = true;
  bool _artiVisible = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _copyAll() {
    final text = '${widget.doa.ar}\n\n${widget.doa.tr}\n\n${widget.doa.idn}';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Color _getColorForGroup(String group) {
    final int hash = group.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
  }

  String _getEmoji(DataDoa doa) {
    final name = doa.nama.toLowerCase();
    final group = doa.grup.toLowerCase();
    final tags = doa.tag.map((e) => e.toLowerCase()).toList();

    if (name.contains('tidur') || group.contains('tidur') || tags.contains('tidur')) {
      return '🌙';
    }
    if (name.contains('makan') || group.contains('makan') || tags.contains('makan')) {
      return '🍽️';
    }
    if (name.contains('masjid') || group.contains('masjid') || tags.contains('masjid')) {
      return '🕌';
    }
    if (name.contains('wudhu') || group.contains('wudhu') || tags.contains('wudhu')) {
      return '💧';
    }
    if (name.contains('rumah') || group.contains('rumah') || tags.contains('rumah')) {
      return '🏠';
    }
    if (name.contains('kendaraan') || name.contains('safar') || group.contains('perjalanan') || tags.contains('perjalanan')) {
      return '🚗';
    }
    if (name.contains('sakit') || name.contains('sehat') || group.contains('sakit') || tags.contains('sakit')) {
      return '❤️‍🩹';
    }
    if (name.contains('ilmu') || name.contains('belajar') || group.contains('pendidikan') || tags.contains('pendidikan')) {
      return '📚';
    }
    if (name.contains('rezeki') || name.contains('uang') || name.contains('harta') || group.contains('rezeki') || tags.contains('rezeki')) {
      return '💰';
    }
    if (name.contains('sholat') || name.contains('doa') || group.contains('shalat') || tags.contains('shalat')) {
      return '🧎';
    }
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    final doa = widget.doa;
    final catColor = _getColorForGroup(doa.grup);
    final emoji = _getEmoji(doa);

    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          Obx(() {
            final isFav = controller.favoritIds.contains(doa.id);
            return SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: _C.bg,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                    border: Border.all(color: _C.goldDim.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: _C.goldLight, size: 16),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => _showSettingsBottomSheet(context, controller),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                      border: Border.all(
                        color: _C.goldDim.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: _C.goldLight,
                      size: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleFavorit(doa.id),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                      border: Border.all(
                        color: isFav
                            ? _C.red.withValues(alpha: 0.4)
                            : _C.goldDim.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? _C.red : _C.goldLight,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildDetailHeader(doa, catColor, emoji),
              ),
            );
          }),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text box
                  _buildSection(
                    label: 'Arab',
                    icon: '✦',
                    delay: 0.1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _C.surface,
                        border: Border.all(color: _C.goldDim.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: _C.gold.withValues(alpha: 0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Obx(() => Text(
                        doa.ar,
                        textAlign: TextAlign.right,
                        style: R.textStyle.extraLargeNormal.copyWith(
                          fontFamily: 'Poppins',
                          color: _C.goldLight,
                          fontSize: controller.arabicFontSize.value,
                          height: 2.0,
                          shadows: [
                            Shadow(
                              color: _C.gold.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      )),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Latin
                  Obx(() {
                    if (!controller.showLatin.value) return const SizedBox.shrink();
                    return _buildToggleSection(
                      label: 'Latin',
                      visible: _latinVisible,
                      onToggle: () => setState(() => _latinVisible = !_latinVisible),
                      delay: 0.2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _C.surface,
                          border: Border.all(color: _C.emerald.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          doa.tr,
                          style: R.textStyle.mediumNormal.copyWith(
                            fontStyle: FontStyle.italic,
                            color: _C.emeraldLight,
                            height: 1.7,
                          ),
                        ),
                      ),
                    );
                  }),

                  Obx(() => controller.showLatin.value ? const SizedBox(height: 16) : const SizedBox.shrink()),

                  // Arti
                  Obx(() {
                    if (!controller.showTranslation.value) return const SizedBox.shrink();
                    return _buildToggleSection(
                      label: 'Artinya',
                      visible: _artiVisible,
                      onToggle: () => setState(() => _artiVisible = !_artiVisible),
                      delay: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _C.surface,
                          border: Border.all(color: _C.goldDim.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 60,
                              margin: const EdgeInsets.only(right: 12, top: 2),
                              decoration: BoxDecoration(
                                color: _C.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '"${doa.idn}"',
                                style: R.textStyle.mediumNormal.copyWith(
                                  color: _C.text,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  Obx(() => controller.showTranslation.value ? const SizedBox(height: 20) : const SizedBox.shrink()),

                  // Tentang
                  if (doa.tentang.isNotEmpty) ...[
                    _buildSection(
                      label: 'Tentang',
                      icon: '📖',
                      delay: 0.4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _C.surface2,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: _C.goldDim, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doa.tentang,
                                style: R.textStyle.small(
                                  color: _C.textMuted,
                                ).copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Copy button
                  _AnimPressButton(
                    onTap: _copyAll,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: _copied
                              ? [_C.emerald, _C.emeraldLight]
                              : [_C.goldDim, _C.gold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_copied ? _C.emerald : _C.gold)
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _copied ? Icons.check_rounded : Icons.copy_rounded,
                            color: const Color(0xFF0A1A12),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _copied ? R.string.copied : R.string.copyPrayer,
                            style: R.textStyle.mediumBold.copyWith(
                              color: const Color(0xFF0A1A12),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(DataDoa doa, Color catColor, String emoji) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            catColor.withValues(alpha: 0.4),
            _C.bg,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(
                painter: _DiamondPatternPainter(color: _C.gold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56,
              left: 20, right: 20, bottom: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: catColor.withValues(alpha: 0.2),
                    border: Border.all(color: catColor.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        doa.nama,
                        style: R.textStyle.largeBold.copyWith(
                          color: _C.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Chip(label: doa.grup, color: catColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required String icon,
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, c) {
        final t = (((_anim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve)),
            child: c,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: R.textStyle.smallBold.copyWith(
                    color: _C.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required double delay,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, c) {
        final t = (((_anim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve)),
            child: c,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2),
              child: Row(
                children: [
                  Text(
                    label,
                    style: R.textStyle.smallBold.copyWith(
                      color: _C.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: visible ? 0 : -0.25,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.textMuted,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: child,
            secondChild: const SizedBox.shrink(),
            crossFadeState: visible
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: R.textStyle.smallBold.copyWith(
          fontSize: 10,
          color: Color.lerp(color, Colors.white, 0.5),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _AnimPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimPressButton({required this.child, required this.onTap});

  @override
  State<_AnimPressButton> createState() => _AnimPressButtonState();
}

class _AnimPressButtonState extends State<_AnimPressButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────
class _DiamondPatternPainter extends CustomPainter {
  final Color color;
  const _DiamondPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const sp = 50.0;
    const r = 18.0;

    for (double x = 0; x < size.width + sp; x += sp) {
      for (double y = 0; y < size.height + sp; y += sp) {
        final path = Path()
          ..moveTo(x, y - r)
          ..lineTo(x + r, y)
          ..lineTo(x, y + r)
          ..lineTo(x - r, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedEmptyState extends StatefulWidget {
  final bool isFavoritEmpty;
  const _AnimatedEmptyState({required this.isFavoritEmpty});

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState> with TickerProviderStateMixin {
  late AnimationController _bobController;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // Bobbing & rotating animation for the main badge
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Particle animation loop
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        _updateParticles();
      })..repeat();

    // Generate initial particles scattered around
    for (int i = 0; i < 15; i++) {
      _particles.add(_createParticle(isInitial: true));
    }
  }

  _Particle _createParticle({bool isInitial = false}) {
    return _Particle(
      x: _random.nextDouble() * 220 - 110,
      y: isInitial ? (_random.nextDouble() * 160 - 80) : 80.0,
      size: _random.nextDouble() * 6 + 3,
      speed: _random.nextDouble() * 0.9 + 0.4,
      opacity: _random.nextDouble() * 0.6 + 0.2,
      angle: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.06,
    );
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _particles.length; i++) {
        final p = _particles[i];
        p.y -= p.speed;
        p.angle += p.rotationSpeed;
        if (p.y < -80) {
          _particles[i] = _createParticle();
        }
      }
    });
  }

  @override
  void dispose() {
    _bobController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isFavoritEmpty ? _C.red : _C.gold;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Particle backdrop
            CustomPaint(
              size: const Size(200, 160),
              painter: _ParticlePainter(particles: _particles, color: themeColor),
            ),
            // Bobbing badge
            AnimatedBuilder(
              animation: _bobController,
              builder: (context, child) {
                final double translation = math.sin(_bobController.value * math.pi * 2) * 8.0;
                final double rotation = math.sin(_bobController.value * math.pi * 2) * 0.08;
                return Transform.translate(
                  offset: Offset(0, translation),
                  child: Transform.rotate(
                    angle: rotation,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.1),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.isFavoritEmpty ? '❤️' : '🔍',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          widget.isFavoritEmpty ? 'Belum ada doa favorit' : 'Doa tidak ditemukan',
          style: R.textStyle.mediumBold.copyWith(color: _C.text),
        ),
        if (widget.isFavoritEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
            child: Text(
              'Tekan ♡ pada doa untuk menyimpannya',
              textAlign: TextAlign.center,
              style: R.textStyle.small(color: _C.textMuted.withValues(alpha: 0.8)),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double angle;
  double rotationSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
    required this.rotationSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final double progress = ((80.0 - p.y).abs() / 160.0).clamp(0.0, 1.0);
      final double currentOpacity = p.opacity * (1.0 - progress);
      
      final paint = Paint()
        ..color = color.withValues(alpha: currentOpacity)
        ..style = PaintingStyle.fill;

      final double px = center.dx + p.x;
      final double py = center.dy + p.y;
      
      final path = Path();
      final double r = p.size;
      final double innerR = r * 0.35;
      
      // Draw 4-point star
      for (int i = 0; i < 8; i++) {
        final double angle = p.angle + i * math.pi / 4;
        final double currentR = (i % 2 == 0) ? r : innerR;
        final double sx = px + currentR * math.cos(angle);
        final double sy = py + currentR * math.sin(angle);
        if (i == 0) {
          path.moveTo(sx, sy);
        } else {
          path.lineTo(sx, sy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}