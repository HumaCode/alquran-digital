import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/r.dart';

enum ToastType { success, info, error }

class CustomToast {
  static OverlayEntry? _currentOverlay;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss existing toast if active
    dismiss();

    final overlayState = Overlay.of(context);
    
    // Create new OverlayEntry
    _currentOverlay = OverlayEntry(
      builder: (context) => _DynamicIslandToastWidget(
        message: message,
        type: type,
        onDismiss: () => dismiss(),
      ),
    );

    overlayState.insert(_currentOverlay!);

    // Start auto-dismiss timer
    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _DynamicIslandToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _DynamicIslandToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_DynamicIslandToastWidget> createState() => _DynamicIslandToastWidgetState();
}

class _DynamicIslandToastWidgetState extends State<_DynamicIslandToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _islandWidth;
  late Animation<double> _islandHeight;
  late Animation<double> _contentOpacity;
  late Animation<double> _borderRadius;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Initial notch-like properties morphing into full pill shape
    _islandWidth = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 110.0, end: 120.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 120.0, end: 320.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 80.0,
      ),
    ]).animate(_animController);

    _islandHeight = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 30.0, end: 25.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 25.0, end: 54.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 85.0,
      ),
    ]).animate(_animController);

    _borderRadius = Tween<double>(begin: 15.0, end: 28.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentOpacity = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    // Run entry animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isExpanded = true);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
    }
  }

  Color _getColor() {
    switch (widget.type) {
      case ToastType.success:
        return R.color.emeraldLight;
      case ToastType.info:
        return R.color.goldLight;
      case ToastType.error:
        return R.color.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusHeight = MediaQuery.of(context).padding.top;
    final topOffset = statusHeight > 0 ? statusHeight + 8.0 : 16.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: _islandWidth.value,
                height: _islandHeight.value,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF070E0B), // Deep notch-like pure dark
                  borderRadius: BorderRadius.circular(_borderRadius.value),
                  border: Border.all(
                    color: _getColor().withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getColor().withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_borderRadius.value),
                  child: Center(
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIcon(),
                            color: _getColor(),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: R.textStyle.medium(
                                color: R.color.textSoft,
                                fontWeight: FontWeight.w600,
                              ).copyWith(
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
