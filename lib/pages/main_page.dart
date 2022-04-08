import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safarique/pages/leopard.dart';
import 'dart:math' as math;

import 'package:safarique/utils/app_theme.dart';

class PageOffsetNotifier with ChangeNotifier {
  double _offset = 0;
  double _page = 0;

  PageOffsetNotifier(PageController pageController) {
    pageController.addListener(() {
      _offset = pageController.offset;
      _page = pageController.page!;
      notifyListeners();
    });
  }

  double get offset => _offset;
  double get page => _page;
}

class MapAnimationNotifier with ChangeNotifier {
  final AnimationController _animationController;

  MapAnimationNotifier(this._animationController) {
    _animationController.addListener(_onAnimationControllerChanged);
  }

  double get value => _animationController.value;

  void forward() => _animationController.forward();

  void _onAnimationControllerChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationControllerChanged);
    super.dispose();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _mapAnimationController;

  double get maxHeight => 400.0 + 20 + 32;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 1000),
    );
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 1000),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PageOffsetNotifier(_pageController),
      child: ListenableProvider.value(
        value: _animationController,
        child: ChangeNotifierProvider(
          create: (_) => MapAnimationNotifier(_mapAnimationController),
          child: Scaffold(
            body: Stack(
              children: [
                const MapImage(),
                SafeArea(
                  child: GestureDetector(
                    onVerticalDragUpdate: _handleDragUpdate,
                    onVerticalDragEnd: _handleDragEnd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView(
                          controller: _pageController,
                          physics: const ClampingScrollPhysics(),
                          children: const [
                            LeopardPage(),
                            VulturePage(),
                          ],
                        ),
                        const AppBar(),
                        const LeopardImage(),
                        const VultureImage(),
                        const ShareButton(),
                        const PageIndicator(),
                        const ArrowIcon(),
                        const TravelDetailsLabel(),
                        const StartCampLabel(),
                        const StartTimeLabel(),
                        const BaseCampLabel(),
                        const BaseTimeLabel(),
                        const DistanceLabel(),
                        const HorizontalTravelDots(),
                        const MapButton(),
                        const VerticalTravelDots(),
                        const VultureIconLabel(),
                        const LeopardIconLabel()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _animationController.value -= (details.primaryDelta! / maxHeight);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.isAnimating ||
        _animationController.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0) {
      _animationController.fling(velocity: math.max(2.0, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      _animationController.fling(velocity: math.min(-2.0, -flingVelocity));
    } else {
      _animationController.fling(
          velocity: _animationController.value < 0.5 ? -2.0 : 2.0);
    }
  }
}

class MapHidder extends StatelessWidget {
  const MapHidder({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapAnimationNotifier>(
      builder: (context, notifier, child) {
        return Opacity(
          opacity: 1 - notifier.value,
          child: child,
        );
      },
    );
  }
}

class MapImage extends StatelessWidget {
  const MapImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapAnimationNotifier>(
      builder: (context, notifier, child) {
        double scale = 1 + 0.3 * (1 - notifier.value);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale, scale)
            ..rotateZ(0.05 * math.pi * (1 - notifier.value)),
          child: Opacity(
            opacity: notifier.value,
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(
          'assets/images/map.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class VultureImage extends StatelessWidget {
  const VultureImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapHidder(
      child: Consumer2<PageOffsetNotifier, AnimationController>(
        builder: (context, notifier, animation, child) {
          return Positioned(
            left: 1.25 * MediaQuery.of(context).size.width -
                0.85 * notifier.offset,
            child: Transform.scale(
              scale: 1 - 0.1 * animation.value,
              child: Opacity(
                opacity: 1 - 0.6 * animation.value,
                child: child!,
              ),
            ),
          );
        },
        child: IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: Image.asset(
              'assets/images/vulture.png',
              height: MediaQuery.of(context).size.height / 3,
            ),
          ),
        ),
      ),
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
        child: Row(
          children: const [
            Text(
              "SY",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Spacer(),
            Icon(Icons.menu)
          ],
        ),
      ),
    );
  }
}

class TravelDetailsLabel extends StatelessWidget {
  const TravelDetailsLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        return Positioned(
          top: 120.0 + (1 - animation.value) * (32 + 400),
          left: 24 + MediaQuery.of(context).size.width - notifier.offset,
          child: Opacity(
            opacity: math.max(
              0,
              4 * notifier.page - 3,
            ),
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Text(
            "Travel details",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      right: 24,
      bottom: 16,
      child: Icon(Icons.share),
    );
  }
}

class ArrowIcon extends StatelessWidget {
  const ArrowIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        return Positioned(
          top: 120.0 + (1 - animation.value) * (32 + 400 - 4),
          right: 24,
          child: child!,
        );
      },
      child: const Icon(
        Icons.keyboard_arrow_up,
        size: 28,
        color: lighterGrey,
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: notifier.page.round() == 0 ? white : lightGrey,
                    shape: BoxShape.circle,
                  ),
                  height: 6,
                  width: 6,
                ),
                const SizedBox(
                  width: 6.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: notifier.page.round() != 0 ? white : lightGrey,
                    shape: BoxShape.circle,
                  ),
                  height: 6,
                  width: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VulturePage extends StatelessWidget {
  const VulturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: VultureCircle());
  }
}

class StartCampLabel extends StatelessWidget {
  const StartCampLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        double opacity = math.max(
          0,
          4 * notifier.page - 3,
        );
        return Positioned(
          top: 120.0 + 400 + 32 + 16 + 32,
          width: (MediaQuery.of(context).size.width - 48) / 3,
          left: opacity * 24.0,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Start camp",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class StartTimeLabel extends StatelessWidget {
  const StartTimeLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        double opacity = math.max(
          0,
          4 * notifier.page - 3,
        );
        return Positioned(
          top: 120.0 + 400 + 32 + 16 + 32 + 40,
          width: (MediaQuery.of(context).size.width - 48) / 3,
          left: opacity * 24.0,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "02:40 pm",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: lighterGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class BaseCampLabel extends StatelessWidget {
  const BaseCampLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        double opacity = math.max(
          0,
          4 * notifier.page - 3,
        );
        return Positioned(
          top: 120.0 + 32 + 16 + 4 + (1 - animation.value) * (400 + 32 + -4),
          width: (MediaQuery.of(context).size.width - 48) / 3,
          right: opacity * 24.0,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Base camp",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class BaseTimeLabel extends StatelessWidget {
  const BaseTimeLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (
        context,
        notifier,
        animation,
        child,
      ) {
        double opacity = math.max(
          0,
          4 * notifier.page - 3,
        );
        return Positioned(
          top: 120.0 + 32 + 16 + 44 + (1 - animation.value) * (400 + 32 - 4),
          width: (MediaQuery.of(context).size.width - 48) / 3,
          right: opacity * 24.0,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "07:30 am",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: lighterGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class DistanceLabel extends StatelessWidget {
  const DistanceLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        double opacity = math.max(
          0,
          4 * notifier.page - 3,
        );
        return Positioned(
          top: 120.0 + 400 + 32 + 16 + 32 + 40,
          width: MediaQuery.of(context).size.width,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const MapHidder(
        child: Center(
          child: Text(
            "72 km",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
        ),
      ),
    );
  }
}

class HorizontalTravelDots extends StatelessWidget {
  const HorizontalTravelDots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
        builder: (context, notifier, animation, child) {
      double spacingFactor;
      double opacity;
      if (animation.value == 0) {
        spacingFactor = math.max(0, 4 * notifier.page - 3);
        opacity = spacingFactor;
      } else {
        spacingFactor = math.max(0, 1 - 6 * animation.value);
        opacity = 1;
      }

      return Positioned(
        top: 120.0 + 400 + 32 + 16 + 32 + 4,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                margin: EdgeInsets.only(left: spacingFactor * 10),
                decoration: const BoxDecoration(
                  color: lightGrey,
                  shape: BoxShape.circle,
                ),
                height: 4,
                width: 4,
              ),
              Container(
                margin: EdgeInsets.only(right: spacingFactor * 10),
                decoration: const BoxDecoration(
                  color: lightGrey,
                  shape: BoxShape.circle,
                ),
                height: 4,
                width: 4,
              ),
              Container(
                margin: EdgeInsets.only(right: spacingFactor * 40),
                decoration: BoxDecoration(
                  border: Border.all(color: white),
                  shape: BoxShape.circle,
                ),
                height: 8,
                width: 8,
              ),
              Container(
                margin: EdgeInsets.only(left: spacingFactor * 40),
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                height: 8,
                width: 8,
              ),
            ]),
          ),
        ),
      );
    });
  }
}

class MapButton extends StatelessWidget {
  const MapButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 0,
      child: Consumer<PageOffsetNotifier>(
        builder: (context, notifier, child) {
          double opacity = math.max(
            0,
            4 * notifier.page - 3,
          );
          return Opacity(
            opacity: opacity,
            child: child!,
          );
        },
        child: TextButton(
          child: const Text(
            'ON MAP',
            style: TextStyle(
              color: white,
              fontSize: 12,
            ),
          ),
          onPressed: () {
            final notifier =
                Provider.of<MapAnimationNotifier>(context, listen: false);
            notifier.value == 0
                ? notifier.forward()
                : notifier._animationController.reverse();
          },
        ),
      ),
    );
  }
}

class VultureCircle extends StatelessWidget {
  const VultureCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(builder: (
      context,
      notifier,
      animation,
      child,
    ) {
      double multiplier;
      if (animation.value == 0) {
        multiplier = math.max(0, 4 * notifier.page - 3);
      } else {
        multiplier = math.max(0, 1 - 4 * animation.value);
      }
      double size = MediaQuery.of(context).size.width * 0.5 * multiplier;
      return Container(
        margin: const EdgeInsets.only(
          bottom: 250.0,
        ),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: lightGrey,
        ),
        width: size,
        height: size,
      );
    });
  }
}

class VerticalTravelDots extends StatelessWidget {
  const VerticalTravelDots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnimationController, MapAnimationNotifier>(
      builder: (context, animation, notifier, child) {
        if (animation.value < 1 / 6 || notifier.value > 0) {
          return Container();
        }
        double startTop = 128.0 + 400 + 32 + 16 + 32 + 4;
        double endTop = 128.0 + 32 + 16 + 8;

        double top =
            endTop + (1 - 1.2 * (animation.value - 1 / 6)) * (400 + 32 - 4);
        double oneThird = (startTop - endTop) / 3;

        double bottom = MediaQuery.of(context).size.height - startTop - 23;
        return Positioned(
          top: top,
          bottom: bottom,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 2,
                  height: double.infinity,
                  color: Colors.white,
                ),
                Positioned(
                  top: top > oneThird + endTop ? 0 : oneThird + endTop - top,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
                Positioned(
                  top: top > 2 * oneThird + endTop
                      ? 0
                      : 2 * oneThird + endTop - top,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainBlack,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -1),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurvesDots extends StatelessWidget {
  const CurvesDots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapAnimationNotifier>(
      builder: (context, animation, child) {
        if (animation.value == 0) {
          return Container();
        }
        double startTop = 128.0 + 400 + 32 + 16 + 32 + 4;
        double endTop = 128.0 + 32 + 16 + 8;

        double oneThird = (startTop - endTop) / 3;

        double bottom = MediaQuery.of(context).size.height - startTop - 23;
        return Positioned(
          top: endTop,
          bottom: bottom,
          child: Positioned(
            top: endTop,
            bottom: bottom,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: oneThird,
                    right: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                      ),
                      height: 8,
                      width: 8,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: mainBlack,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      height: 8,
                      width: 8,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, -1),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                      ),
                      height: 8,
                      width: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VultureIconLabel extends StatelessWidget {
  const VultureIconLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        double startTop = 128.0 + 400 + 32 + 16 + 32 + 4;
        double endTop = 128.0 + 32 + 16 + 8;
        double oneThird = (startTop - endTop) / 3;
        double opacity;

        if (animation.value < 2 / 3) {
          opacity = 0;
        } else {
          opacity = 3 * (animation.value - 2 / 3);
        }
        return Positioned(
          top: endTop + 2 * oneThird - 28 - 10 - 7,
          right: 10 + opacity * 16,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const SmallAnimalIconLabel(
        isVulture: true,
        showLine: true,
      ),
    );
  }
}

class LeopardIconLabel extends StatelessWidget {
  const LeopardIconLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        double startTop = 128.0 + 400 + 32 + 16 + 32 + 4;
        double endTop = 128.0 + 32 + 16 + 8;
        double oneThird = (startTop - endTop) / 3;
        double opacity;

        if (animation.value < 3 / 4) {
          opacity = 0;
        } else {
          opacity = 4 * (animation.value - 3 / 4);
        }
        return Positioned(
          top: endTop + oneThird - 28 - 10 - 7,
          left: 10 + opacity * 16,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: const SmallAnimalIconLabel(
        isVulture: false,
        showLine: true,
      ),
    );
  }
}

class SmallAnimalIconLabel extends StatelessWidget {
  const SmallAnimalIconLabel(
      {Key? key, required this.isVulture, required this.showLine})
      : super(key: key);
  final bool isVulture;
  final bool showLine;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showLine && isVulture)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 16.0,
            height: 1,
            color: white,
          ),
        const SizedBox(
          width: 24.0,
        ),
        Column(
          children: [
            Image.asset(
              isVulture
                  ? 'assets/images/vultures.png'
                  : 'assets/images/leopards.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(
              height: 16.0,
            ),
            Text(
              isVulture ? 'Vultures' : 'Leopards',
              style: const TextStyle(
                fontSize: 14.0,
              ),
            )
          ],
        ),
        const SizedBox(
          width: 24.0,
        ),
        if (showLine && !isVulture)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 16.0,
            height: 1,
            color: white,
          ),
      ],
    );
  }
}
