import 'package:flutter/material.dart';

class StoryProgress extends StatefulWidget {
  final int totalStoryCount;
  final Duration? duration;
  final Color? color;
  final void Function(int index)? onIndexChanged;

  const StoryProgress({
    super.key,
    required this.totalStoryCount,
    this.duration,
    this.color,
    this.onIndexChanged,
  });

  @override
  State<StoryProgress> createState() => _StoryProgressState();
}

class _StoryProgressState extends State<StoryProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentStoryIndex < widget.totalStoryCount - 1) {
          currentStoryIndex++;
          widget.onIndexChanged?.call(currentStoryIndex);
          _controller.reset();
          _controller.forward();
        }
      }
    });

    // widget.onIndexChanged?.call(currentStoryIndex);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: StoryProgressPainter(
              totalStoryCount: widget.totalStoryCount,
              currentStoryIndex: currentStoryIndex,
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class StoryProgressPainter extends CustomPainter {
  final int totalStoryCount;
  final int currentStoryIndex;
  final double progress;
  final Color color;

  StoryProgressPainter({
    int? totalStoryCount,
    int? currentStoryIndex,
    double? progress,
    Color? color,
  })  : totalStoryCount = totalStoryCount ?? 1,
        currentStoryIndex = currentStoryIndex ?? 0,
        progress = progress ?? 0.0,
        color = color ?? Colors.blue;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var storyLineWidth = size.width / totalStoryCount;
    for (var i = 0; i < totalStoryCount; i++) {
      var path = Path()
        ..moveTo(i * storyLineWidth + 4, 0)
        ..lineTo(i * storyLineWidth + storyLineWidth - 4, 0);
      if (i == currentStoryIndex) {
        paint.color = color.withOpacity(0.5);
        canvas.drawPath(path, paint);
        path = Path()
          ..moveTo(i * storyLineWidth + 4, 0)
          ..lineTo((i * storyLineWidth + (storyLineWidth - 4) * progress), 0);
        paint.color = color;
      } else if (i < currentStoryIndex) {
        paint.color = color;
      } else {
        paint.color = color.withOpacity(0.5);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
