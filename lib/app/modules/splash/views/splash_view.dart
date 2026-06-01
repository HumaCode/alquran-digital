import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/constants/r.dart';
import '../widgets/crescent_star_painter.dart';
import '../widgets/islamic_pattern_painter.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  Color get _bg1 => R.color.bg1;
  Color get _bg2 => R.color.bg2;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _emerald => R.color.emerald;
  Color get _emeraldDark => R.color.emeraldDark;
  Color get _textSoft => R.color.textSoft;

  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _bgController;
  late AnimationController _ornamentController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _exitController;

  // ── Animations ───────────────────────────────────────────────────────────
  late Animation<double> _bgAnim;
  late Animation<double> _ornamentScaleAnim;
  late Animation<double> _ornamentRotateAnim;
  late Animation<double> _ornamentOpacityAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoOpacityAnim;
  late Animation<Offset> _arabicSlideAnim;
  late Animation<double> _arabicOpacityAnim;
  late Animation<Offset> _titleSlideAnim;
  late Animation<double> _titleOpacityAnim;
  late Animation<Offset> _subtitleSlideAnim;
  late Animation<double> _subtitleOpacityAnim;
  late Animation<double> _dividerAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _exitAnim;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startSequence();
  }

  void _initControllers() {
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ornamentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Background fade-in
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeOut);

    // Ornament
    _ornamentScaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ornamentController, curve: Curves.elasticOut),
    );
    _ornamentRotateAnim = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _ornamentController, curve: Curves.easeOutCubic),
    );
    _ornamentOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ornamentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Logo
    _logoScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Arabic text
    _arabicSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
          ),
        );
    _arabicOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // App Title
    _titleSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    _titleOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    // Subtitle
    _subtitleSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // Divider line
    _dividerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Progress bar
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // Pulse glow
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Exit fade
    _exitAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _ornamentController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _progressController.forward();

    // Total splash = ~5 detik
    await Future.delayed(const Duration(milliseconds: 4600));
    await _exitController.forward();

    if (mounted) {
      Get.offNamed(Routes.HOME);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _ornamentController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for Android
        statusBarBrightness: Brightness.dark, // White icons for iOS
      ),
      child: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(opacity: _exitAnim.value, child: child);
        },
        child: Scaffold(
          body: AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.25),
                    radius: 1.4,
                    colors: [
                      Color.lerp(Colors.transparent, _bg2, _bgAnim.value)!,
                      Color.lerp(Colors.transparent, _bg1, _bgAnim.value)!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // ── Latar geometris ──────────────────────────────────────
                    ..._buildGeometricBg(),

                    // ── Konten Utama ─────────────────────────────────────────
                    SafeArea(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          _buildOrnamentTop(),
                          const SizedBox(height: 32),
                          _buildLogo(),
                          const SizedBox(height: 40),
                          _buildTexts(),
                          const Spacer(flex: 2),
                          _buildProgressArea(),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Geometric background circles ─────────────────────────────────────────
  List<Widget> _buildGeometricBg() {
    return [
      Positioned(
        top: -80,
        right: -80,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.06,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: -40,
        right: -40,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.05,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        left: -80,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.05,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _emerald, width: 1),
              ),
            ),
          ),
        ),
      ),
      // Star of David / Islamic geometric pattern (subtle)
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value,
            child: CustomPaint(painter: IslamicPatternPainter(color: _gold)),
          ),
        ),
      ),
    ];
  }

  // ── Ornamen atas (bulan bintang stilasi) ──────────────────────────────────
  Widget _buildOrnamentTop() {
    return AnimatedBuilder(
      animation: _ornamentController,
      builder: (context, _) => Opacity(
        opacity: _ornamentOpacityAnim.value,
        child: Transform.scale(
          scale: _ornamentScaleAnim.value,
          child: Transform.rotate(
            angle: _ornamentRotateAnim.value,
            child: SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(painter: CrescentStarPainter(color: _gold)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo bulat ────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, _) => Opacity(
        opacity: _logoOpacityAnim.value,
        child: Transform.scale(
          scale: _logoScaleAnim.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow luar
              Container(
                width: 148 * _pulseAnim.value,
                height: 148 * _pulseAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.15 * _pulseAnim.value),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Ring emas
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [_goldDim, _gold, _goldLight, _gold, _goldDim],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Inner circle
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [_emeraldDark, _bg1],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        R.string.appTitleArabic,
                        style: R.textStyle.large(
                          color: _goldLight,
                          fontWeight: FontWeight.w600,
                        ).copyWith(
                          fontFamily: 'serif',
                          fontSize: 26,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: _gold.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(width: 40, height: 1, color: _goldDim),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Teks utama ────────────────────────────────────────────────────────────
  Widget _buildTexts() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, _) => Column(
        children: [
          // Ayat bismillah
          ClipRect(
            child: SlideTransition(
              position: _arabicSlideAnim,
              child: Opacity(
                opacity: _arabicOpacityAnim.value,
                child: Text(
                  R.string.bismillah,
                  textAlign: TextAlign.center,
                  style: R.textStyle.large(
                    color: _goldLight,
                    fontWeight: FontWeight.w500,
                  ).copyWith(
                    fontSize: 20,
                    height: 1.8,
                    shadows: [
                      Shadow(color: _gold.withOpacity(0.5), blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Divider ornamen
          Opacity(
            opacity: _dividerAnim.value,
            child: ClipRect(
              child: SizedBox(
                width: 180 * _dividerAnim.value,
                height: 20,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: 180,
                  minHeight: 0,
                  maxHeight: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: _goldDim.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✦',
                          style: R.textStyle.small(color: _gold).copyWith(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: _goldDim.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Judul app
          ClipRect(
            child: SlideTransition(
              position: _titleSlideAnim,
              child: Opacity(
                opacity: _titleOpacityAnim.value,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [_goldDim, _goldLight, _gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    R.string.appTitle,
                    style: R.textStyle.extraLarge(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ).copyWith(
                      fontSize: 42,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          ClipRect(
            child: SlideTransition(
              position: _subtitleSlideAnim,
              child: Opacity(
                opacity: _subtitleOpacityAnim.value,
                child: Text(
                  R.string.subtitle,
                  style: R.textStyle.medium(
                    color: _textSoft.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                  ).copyWith(
                    fontSize: 15,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Area progress bawah ───────────────────────────────────────────────────
  Widget _buildProgressArea() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) => Opacity(
        opacity: math.min(_progressAnim.value * 4, 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final dotAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Interval(
                        i * 0.25,
                        i * 0.25 + 0.5,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  );
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Opacity(
                        opacity: dotAnim.value,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 3,
                  color: _goldDim.withOpacity(0.2),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnim.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_goldDim, _goldLight],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                R.string.loading,
                style: R.textStyle.small(
                  color: _textSoft.withOpacity(0.35),
                ).copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
