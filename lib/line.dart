import 'package:flutter/material.dart';

class Line extends StatefulWidget {
  final Offset toOffset;
  final Offset initialPosition;
  final Path path;
  final Color? color;
  final bool isFilled;
  const Line({
    Key? key,
    this.isFilled = false,
    this.color,
    required this.toOffset,
    required this.initialPosition,
    required this.path,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LineState();
}

class _LineState extends State<Line> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(
        toOffset: widget.toOffset,
        initialPosition: widget.initialPosition,
        path: widget.path,
        isFilled: widget.isFilled,
        color: widget.color,
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  Paint? _paint;
  final Offset initialPosition;
  final Offset toOffset;
  final Path path;
  final Color? color;
  final bool isFilled;
  LinePainter(
      {required this.toOffset,
      this.isFilled = false,
      this.color,
      required this.initialPosition,
      required this.path}) {
    _paint = Paint()
      ..color = color ?? Colors.black
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..blendMode = BlendMode.darken
      ..strokeWidth = 2.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, _paint!);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return true;
  }
}
