import 'package:flutter/material.dart';

class WatermarkWidget extends StatelessWidget {
  static const Key watermarkKey = Key('watermark_custom_paint');
  final Widget child;
  final String text;
  final double opacity;
  final Color color;
  final double rotationAngle;
  final double fontSize;
  final double horizontalInterval;
  final double verticalInterval;

  const WatermarkWidget({
    super.key,
    required this.child,
    required this.text,
    this.opacity = 0.2,
    this.color = Colors.black,
    this.rotationAngle = -0.5,
    this.fontSize = 10,
    this.horizontalInterval = 100,
    this.verticalInterval = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: CustomPaint(
                painter: _WatermarkPainter(
                  text: text,
                  opacity: opacity,
                  color: color,
                  rotationAngle: rotationAngle,
                  fontSize: fontSize,
                  horizontalInterval: horizontalInterval,
                  verticalInterval: verticalInterval,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String text;
  final double opacity;
  final Color color;
  final double rotationAngle;
  final double fontSize;
  final double horizontalInterval;
  final double verticalInterval;

  _WatermarkPainter({
    required this.text,
    required this.opacity,
    required this.color,
    required this.rotationAngle,
    required this.fontSize,
    required this.horizontalInterval,
    required this.verticalInterval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: color.withValues(alpha: opacity),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    for (double i = -size.height; i < size.height * 2; i += verticalInterval) {
      for (
        double j = -size.width;
        j < size.width * 2;
        j += horizontalInterval
      ) {
        canvas.save();
        canvas.translate(j, i);
        canvas.rotate(rotationAngle);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
