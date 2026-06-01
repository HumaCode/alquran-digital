import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                          SizedBox(height: 54.h),
                          _buildLogo(),
                          SizedBox(height: 54.h),
                          _buildTexts(),
                          const Spacer(flex: 2),
                          _buildProgressArea(),
                          SizedBox(height: 48.h),
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
        top: -80.h,
        right: -80.w,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.06,
            child: Container(
              width: 320.r,
              height: 320.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1.w),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: -40.h,
        right: -40.w,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.05,
            child: Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1.w),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100.h,
        left: -80.w,
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) => Opacity(
            opacity: _bgAnim.value * 0.05,
            child: Container(
              width: 350.r,
              height: 350.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _emerald, width: 1.w),
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
              width: 80.r,
              height: 80.r,
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
              // Mandala hiasan di belakang logo
              SizedBox(
                width: 250.r,
                height: 250.r,
                child: CustomPaint(
                  painter: MandalaPainter(color: _gold),
                ),
              ),
              // Glow luar
              Container(
                width: 148.r * _pulseAnim.value,
                height: 148.r * _pulseAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.15 * _pulseAnim.value),
                      blurRadius: 40.r,
                      spreadRadius: 10.r,
                    ),
                  ],
                ),
              ),
              // Ring emas
              Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [_goldDim, _gold, _goldLight, _gold, _goldDim],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
              ),
              // Inner circle
              Container(
                width: 118.r,
                height: 118.r,
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
                          fontSize: 26.sp,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: _gold.withValues(alpha: 0.6),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(width: 40.w, height: 1.h, color: _goldDim),
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
                    fontSize: 20.sp,
                    height: 1.8,
                    shadows: [
                      Shadow(color: _gold.withValues(alpha: 0.5), blurRadius: 12.r),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Divider ornamen
          Opacity(
            opacity: _dividerAnim.value,
            child: ClipRect(
              child: SizedBox(
                width: 180.w * _dividerAnim.value,
                height: 20.h,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: 180.w,
                  minHeight: 0,
                  maxHeight: 20.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.h,
                          color: _goldDim.withValues(alpha: 0.5),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          '✦',
                          style: R.textStyle.small(color: _gold).copyWith(fontSize: 10.sp),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.h,
                          color: _goldDim.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

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
                      fontSize: 42.sp,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Subtitle
          ClipRect(
            child: SlideTransition(
              position: _subtitleSlideAnim,
              child: Opacity(
                opacity: _subtitleOpacityAnim.value,
                child: Text(
                  R.string.subtitle,
                  style: R.textStyle.medium(
                    color: _textSoft.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w300,
                  ).copyWith(
                    fontSize: 15.sp,
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
          padding: EdgeInsets.symmetric(horizontal: 60.w),
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
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Opacity(
                        opacity: dotAnim.value,
                        child: Container(
                          width: 5.r,
                          height: 5.r,
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
              SizedBox(height: 14.h),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: Container(
                  height: 3.h,
                  color: _goldDim.withValues(alpha: 0.2),
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
                            color: _gold.withValues(alpha: 0.6),
                            blurRadius: 6.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                R.string.loading,
                style: R.textStyle.small(
                  color: _textSoft.withValues(alpha: 0.35),
                ).copyWith(
                  fontSize: 11.sp,
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
