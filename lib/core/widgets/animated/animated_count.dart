import 'package:flutter/material.dart';

/// An animated counter widget that counts from an initial value to a target value
/// with a smooth animation effect.
///
/// Usage:
/// ```dart
/// AnimatedCount(
///   count: 42,
///   duration: Duration(milliseconds: 600),
///   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
/// )
/// ```
class AnimatedCount extends StatelessWidget {
  /// The target count value to animate to
  final int count;

  /// Animation duration (default: 600ms)
  final Duration duration;

  /// Animation curve (default: easeOutCubic for smooth deceleration)
  final Curve curve;

  /// Text style for the count
  final TextStyle? style;

  /// Optional prefix text (e.g., "$")
  final String? prefix;

  /// Optional suffix text (e.g., " مهمة")
  final String? suffix;

  const AnimatedCount({
    super.key,
    required this.count,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final text = '${prefix ?? ''}$value${suffix ?? ''}';
        return Text(
          text,
          style: style,
        );
      },
    );
  }
}

/// An animated counter that shows "0" initially and animates to the target
/// when data is loaded. Handles the loading -> loaded transition smoothly.
///
/// This widget is designed for stats displays where you want to show "0"
/// during initial load, then animate to the actual value when loaded.
class AnimatedStatCount extends StatefulWidget {
  /// Whether data is still loading
  final bool isLoading;

  /// The target count value (used when isLoading is false)
  final int count;

  /// Animation duration (default: 600ms)
  final Duration duration;

  /// Animation curve (default: easeOutCubic)
  final Curve curve;

  /// Text style for the count
  final TextStyle? style;

  /// Optional prefix text
  final String? prefix;

  /// Optional suffix text
  final String? suffix;

  const AnimatedStatCount({
    super.key,
    required this.isLoading,
    required this.count,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedStatCount> createState() => _AnimatedStatCountState();
}

class _AnimatedStatCountState extends State<AnimatedStatCount> {
  /// Track if we've completed the initial load
  bool _hasLoadedOnce = false;

  /// The previous count value (for animation starting point)
  int _previousCount = 0;

  @override
  void didUpdateWidget(AnimatedStatCount oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When transitioning from loading to loaded, mark as loaded
    if (oldWidget.isLoading && !widget.isLoading) {
      _hasLoadedOnce = true;
    }

    // Store previous count for smooth transitions
    if (!widget.isLoading && widget.count != oldWidget.count) {
      _previousCount = oldWidget.count;
    }
  }

  @override
  Widget build(BuildContext context) {
    // During initial loading, show "0" static
    if (widget.isLoading && !_hasLoadedOnce) {
      return Text(
        '${widget.prefix ?? ''}0${widget.suffix ?? ''}',
        style: widget.style,
      );
    }

    // After loading, animate from previous value to current value
    return TweenAnimationBuilder<int>(
      key: ValueKey(widget.count), // Force rebuild when count changes
      tween: IntTween(
        begin: _hasLoadedOnce ? _previousCount : 0,
        end: widget.count,
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, child) {
        return Text(
          '${widget.prefix ?? ''}$value${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}
