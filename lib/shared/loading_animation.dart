import 'package:flutter/material.dart';
import 'dart:math';

class LoaderCircle extends StatefulWidget {
  final double circleSize;
  final double lineSize;
  final double rotation;
  const LoaderCircle(
      {Key? key,
      required this.circleSize,
      required this.lineSize,
      required this.rotation})
      : super(key: key);

  @override
  State<LoaderCircle> createState() => _LoaderCircleState();
}

class _LoaderCircleState extends State<LoaderCircle> {
  //final double circleSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0,
      height: 100.0,
      child: Center(
          child: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((0 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((0 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: ((6 + widget.rotation) * pi) / 12,
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((2 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((2 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((8 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((4 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((4 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((10 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((6 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((6 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: ((12 + widget.rotation) * pi) / 12,
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((8 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((8 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((14 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((10 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((10 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((16 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((12 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((12 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((18 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((14 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((14 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((20 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((16 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((16 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((22 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((18 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((18 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((24 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((20 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((20 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((26 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
                widget.circleSize * cos(((22 + widget.rotation) * pi) / 12),
                widget.circleSize * sin(((22 + widget.rotation) * pi) / 12)),
            child: Transform.rotate(
              angle: (((28 + widget.rotation) * pi) / 12),
              child: Bar(
                width: 5.0,
                height: widget.lineSize,
              ),
            ),
          )
        ],
      )),
    );
  }
}

class Bar extends StatelessWidget {
  const Bar({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double width;
  final double height;
  final Color color = const Color.fromARGB(255, 154, 212, 241);
  final double radius = 1.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
      ),
    );
  }
}

class LoadAnimation extends StatefulWidget {
  final double size;

  const LoadAnimation({Key? key, this.size = 1.0}) : super(key: key);

  @override
  State<LoadAnimation> createState() => _LoadAnimationState();
}

class _LoadAnimationState extends State<LoadAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    pulseController = AnimationController(
        vsync: this, duration: const Duration(microseconds: 500000));

    final Animation<double> curve =
        CurvedAnimation(parent: pulseController, curve: Curves.easeOutSine);

    pulseAnimation = Tween<double>(begin: 50.0, end: 67.0).animate(curve);

    controller.repeat();
    pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.size,
      child: Center(
          child: Stack(children: [
        AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: controller.value * 6.3,
              child: child,
            );
          },
          child: const LoaderCircle(
            circleSize: 25.0,
            lineSize: 13.5,
            rotation: 1,
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: controller.value * -6.3,
              child: child,
            );
          },
          child: const LoaderCircle(
            circleSize: 40.0,
            lineSize: 20.0,
            rotation: 0,
          ),
        ),
        AnimatedBuilder(
          animation: pulseController,
          builder: (BuildContext context, Widget? child) {
            return LoaderCircle(
              circleSize: pulseAnimation.value,
              lineSize: 30.0,
              rotation: 1,
            );
          },
          child: null,
        )
      ])),
    );
  }
}
