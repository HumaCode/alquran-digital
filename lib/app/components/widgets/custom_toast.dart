import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/r.dart';

enum ToastType { success, info, error }

class CustomToast {
  static OverlayEntry? _currentOverlay;
  static _DynamicIslandToastWidgetState? _currentState;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // If there is an existing toast, tell it to animate out immediately
    if (_currentState != null && _currentState!.mounted) {
      _currentState!.animateOutAndRemove(() {
        _createNewToast(context, message, type, duration);
      });
    } else {
      // Remove overlay if it exists but state is gone
      dismiss();
      _createNewToast(context, message, type, duration);
    }
  }

  static void _createNewToast(
    BuildContext context,
    String message,
    ToastType type,
    Duration duration,
  ) {
    final overlayState = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder: (context) => _DynamicIslandToastWidget(
        message: message,
        type: type,
        duration: duration,
        onCreated: (state) {
          _currentState = state;
        },
        onDismissComplete: () {
          dismiss();
        },
      ),
    );

    overlayState.insert(_currentOverlay!);
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentState = null;
  }
}

class _DynamicIslandToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final Function(_DynamicIslandToastWidgetState) onCreated;
  final VoidCallback onDismissComplete;

  const _DynamicIslandToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onCreated,
    required this.onDismissComplete,
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

  Timer? _displayTimer;
  bool _isRemovedTriggered = false;

  @override
  void initState() {
    super.initState();
    widget.onCreated(this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Snappy and fast transition
    );

    // Dynamic Island sizes
    _islandWidth = Tween<double>(begin: 110.0, end: 320.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _islandHeight = Tween<double>(begin: 30.0, end: 54.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _borderRadius = Tween<double>(begin: 15.0, end: 27.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Start opening transition immediately on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController.forward().then((_) {
          // Once opened, start the auto-dismiss timer
          _displayTimer = Timer(widget.duration, () {
            animateOutAndRemove(null);
          });
        });
      }
    });
  }

  // Animates the toast out and calls a callback (or dismiss helper)
  void animateOutAndRemove(VoidCallback? onComplete) {
    if (_isRemovedTriggered) return;
    _isRemovedTriggered = true;

    _displayTimer?.cancel();
    _animController.reverse().then((_) {
      widget.onDismissComplete();
      if (onComplete != null) {
        onComplete();
      }
    });
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxToastWidth = (screenWidth - 24).clamp(300.0, 420.0);

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
              // Fade entire toast container out at the very end of reverse animation
              final double scale = 0.8 + (_animController.value * 0.2);
              final double opacity = (_animController.value * 5.0).clamp(0.0, 1.0);
              final double currentWidth = Tween<double>(
                begin: 110.0,
                end: maxToastWidth,
              ).transform(_animController.value);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: currentWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    constraints: BoxConstraints(
                      minHeight: _islandHeight.value,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070E0B), // Deep notch pure dark
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
                        widthFactor: 1.0,
                        heightFactor: 1.0,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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
