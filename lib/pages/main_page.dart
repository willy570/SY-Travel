// ignore_for_file: deprecated_member_use

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

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PageOffsetNotifier(_pageController),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.centerLeft,
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
            ],
          ),
        ),
      ),
    );
  }
}

class VultureImage extends StatelessWidget {
  const VultureImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Positioned(
          left:
              1.25 * MediaQuery.of(context).size.width - 0.85 * notifier.offset,
          child: child!,
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
    return const Positioned(
      top: 120.0 + 32 + 400,
      right: 24,
      child: Icon(
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
    return Container();
  }
}
