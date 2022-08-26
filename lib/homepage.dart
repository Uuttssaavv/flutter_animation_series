import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'line.dart';

class PolygonAnimation extends StatefulWidget {
  const PolygonAnimation({Key? key}) : super(key: key);

  @override
  State<PolygonAnimation> createState() => _PolygonAnimationState();
}

class _PolygonAnimationState extends State<PolygonAnimation>
    with TickerProviderStateMixin {
  final List<Widget> linesWidgets = [];
  int value = 3;
  late AnimationController _controller;
  late Animation<double> animation;

  final Tween<double> _rotationTween = Tween(begin: 3, end: 12);
  bool isFilled = false;
  Color color = Colors.black;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      upperBound: 1.0,
      lowerBound: 0.0,
    );
    animation = _rotationTween.animate(_controller);
    _controller.addListener(() {
      setState(() {
        //   print('setstae');
      });
    });
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    value = (_controller.value * 12).toInt();
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 60.0,
            left: 20.0,
            right: 20.0,
            child: Center(
              child: Text(
                'Selected sides: $value',
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.3,
            right: 20.0,
            top: size.height * 0.35,
            bottom: 30.0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, valu) {
                return Line(
                  toOffset: Offset(size.width, size.height / 2),
                  initialPosition:
                      _getOffset(3 * 180 / value, size.width / value),
                  path: getLines(
                    value,
                    size,
                    value * 40,
                  ),
                  isFilled: isFilled,
                  color: color,
                );
              },
            ),
          ),
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: SizedBox(
                          height: size.height * 0.55,
                          width: size.width,
                          child: ColorPicker(
                            onColorChanged: (col) {
                              setState(() {
                                color = col;
                              });
                            },
                            pickerColor: color,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Choose Color'),
                ),
                Column(
                  children: [
                    const Text('Filled'),
                    Switch(
                      value: isFilled,
                      onChanged: (_) {
                        setState(() {
                          isFilled = !isFilled;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: InkWell(
                  onTap: () async {
                    _controller.animateTo(
                      e / 12,
                      duration: const Duration(milliseconds: 600),
                    );

                    setState(() {
                      value = e;
                    });
                  },
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value == e ? Colors.green : Colors.white,
                      border: Border.all(
                        color: value != e ? Colors.green : Colors.white,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$e',
                        style: TextStyle(
                          color: value != e ? Colors.green : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Path getLines(int val, Size size, double angle) {
    final path = Path();
    var offsets = [];
    var an = 360 / val;
    var radius = size.width / 4;
    for (int i = 0; i <= val; i++) {
      var currentAngle = an * i;
      Offset current = _getOffset(currentAngle.toDouble(), radius, ngle: angle);
      if (i == 0) {
        path.moveTo(current.dx, current.dy);
      } else {
        path.lineTo(current.dx, current.dy);
      }

      offsets.add(current);
    }
    return path;
  }

  double _angleToRadian(double angle) {
    return angle * (pi / 180);
  }

  Offset _getOffset(double angle, double radius, {double ngle = 0.0}) {
    final rotationAwareAngle = angle - 90 + ngle;

    final radian = _angleToRadian(rotationAwareAngle);
    final x = sin(radian) * radius + radius;
    final y = cos(radian) * radius + radius;

    return Offset(x, y);
  }
}
