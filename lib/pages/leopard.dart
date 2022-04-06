import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safarique/utils/app_theme.dart';
import 'dart:math' as math;
import 'main_page.dart';

class LeopardPage extends StatelessWidget {
  const LeopardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(
          height: 128.0,
        ),
        The72Text(),
        SizedBox(
          height: 31,
        ),
        TravelDescriptionLabel(),
        SizedBox(
          height: 31,
        ),
        LeopardDescription()
      ],
    );
  }
}

class TravelDescriptionLabel extends StatelessWidget {
  const TravelDescriptionLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Opacity(
          opacity: math.max(
            0,
            1 - 4 * notifier.page,
          ),
          child: child,
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 24.0),
        child: Text(
          "Travel description",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}

class LeopardDescription extends StatelessWidget {
  const LeopardDescription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Opacity(
          opacity: math.max(
            0,
            1 - 4 * notifier.page,
          ),
          child: child,
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "The leopard is distinguished by its well-camouflaged fur, opportunistic hunting behaviour, broad diet, and strength.",
          style: TextStyle(fontSize: 14, color: lightGrey),
        ),
      ),
    );
  }
}

class The72Text extends StatelessWidget {
  const The72Text({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Transform.translate(
          offset: Offset(-40 - 0.5 * notifier.offset, 0),
          child: child,
        );
      },
      child: const RotatedBox(
        quarterTurns: 1,
        child: SizedBox(
          width: 400,
          child: FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.cover,
            child: Text(
              "72",
              style: TextStyle(
                  //fontSize: 330.0,
                  fontWeight: FontWeight.bold,
                  textBaseline: TextBaseline.alphabetic),
            ),
          ),
        ),
      ),
    );
  }
}

class LeopardImage extends StatelessWidget {
  const LeopardImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (
        context,
        notifier,
        animation,
        child,
      ) {
        return Positioned(
          left: -0.85 * notifier.offset,
          width: MediaQuery.of(context).size.width * 1.6,
          child: Transform.scale(
            alignment: const Alignment(0.6, 0),
            scale: 1 - .1 * animation.value,
            child: Opacity(
              opacity: 1 - 0.6 * animation.value,
              child: child!,
            ),
          ),
        );
      },
      child: IgnorePointer(
        child: Image.asset('assets/images/leopard.png'),
      ),
    );
  }
}
