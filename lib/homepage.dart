import 'dart:math';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:flutter/material.dart';

Color color = Colors.blue;
late AnimationController controller;
int bubbles = 5;
late AnimationController rotationController;
bool rotate = false;
bool randomColor = false;
bool animate = false;
List<Color> colors = [
  Colors.green,
  Colors.purple,
  Colors.cyan,
  Colors.blue,
  Colors.orange,
  Colors.red,
];

class BubbleAnimation extends StatefulWidget {
  const BubbleAnimation({Key? key}) : super(key: key);

  @override
  State<BubbleAnimation> createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    rotationController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this);
    controller.repeat(reverse: true);
    rotationController.repeat(reverse: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: size * 0.2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Item counts'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (bubbles > 0) {
                        setState(() {
                          bubbles--;
                        });
                      }
                    },
                    icon: const Icon(Icons.minimize),
                  ),
                  Text('$bubbles'),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          bubbles++;
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              chooseColorButton(context, size)
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            switchTitle('Animate', animate, () {
              animate = !animate;
            }),
            switchTitle('Rotate', rotate, () {
              rotate = !rotate;
            }),
            switchTitle('Dynamic colors', randomColor, () {
              randomColor = !randomColor;
            }),
            // chooseColorButton(context, size),
          ],
        ),
      ],
      body: SizedBox(
        height: size.height * 0.5,
        width: size.width,
        child: Stack(
          children: List.generate(
            bubbles,
            (index) {
              var list = [];
              list.addAll(List<int>.generate(
                  bubbles,
                  (index) => bubbles == 2
                      ? index == 0
                          ? 2
                          : (index) * 4
                      : index));
              var rad = bubbles == 2 ? list[index] * 4 : list[index].toDouble();

              return RadialAnimation(
                radius: rad > 4 ? rad * 2 : rad * 4,
                itemColor: randomColor ? colors[index % 6] : color,
              );
            },
          ),
        ),
      ),
    );
  }

  ElevatedButton chooseColorButton(BuildContext context, Size size) {
    return ElevatedButton(
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
      child: const Text('Choose color'),
    );
  }

  Widget switchTitle(String title, bool value, Function onchanged) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
        Switch(
          value: value,
          onChanged: (val) {
            setState(() {
              onchanged();
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RadialAnimation extends StatelessWidget {
  final Animation<double> translation;
  final Animation<double> sTranslation;
  final items = 16;
  final num radius;
  final Color itemColor;

  RadialAnimation({
    Key? key,
    required this.radius,
    required this.itemColor,
  })  : translation = Tween<double>(
          begin: !animate ? radius * 8 : radius * 6,
          end: !animate ? radius * 8 : radius * 11,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        sTranslation = Tween<double>(
          end: !animate ? radius * 6 : radius * 6,
          begin: !animate ? radius * 6 : radius * 11,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return RotationTransition(
            turns: Tween(
              begin: rotate ? 0.0 : 1.0,
              end: 1.0,
            ).animate(rotationController),
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(
                items,
                (index) => (360 / items) + (index * (360 / items)),
              ).map((e) {
                final double rad = radians(e.toDouble());
                return Transform(
                  transform: !animate
                      ? (Matrix4.identity()
                        ..translate(
                          (sTranslation.value) * sin(rad),
                          (sTranslation.value) * cos(rad),
                        ))
                      : e % 45 == 0
                          ? (Matrix4.identity()
                            ..translate(
                              (sTranslation.value) * sin(rad),
                              (sTranslation.value) * cos(rad),
                            ))
                          : (Matrix4.identity()
                            ..translate(
                              (translation.value) * cos(rad),
                              (translation.value) * sin(rad),
                            )),
                  child: CircleAvatar(
                    radius: bubbles == 1
                        ? 8
                        : radius <= 0
                            ? 2
                            : double.parse(radius.toString()),
                    backgroundColor: itemColor,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
