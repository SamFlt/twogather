import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BasePage extends StatelessWidget {
  final String title;
  final List<String> text;
  final String assetPath;
  final bool center;

  final void Function()? transition;

  const BasePage({
    super.key,
    required this.title,
    required this.text,
    required this.assetPath,
    this.transition,
    this.center = false
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: (MediaQuery.paddingOf(context) * 2).add(.fromLTRB(30, 0, 30, 0)),
      child: Center(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Center(child: Text(title, style: textTheme.headlineLarge)),
            Center(
              child: SvgPicture.asset(
                assetPath,
                semanticsLabel: 'logopart',
                height: 300,
              ),
            ),
            const SizedBox(height: 20),
            ...text.map(
              (s) => Text(s, style: textTheme.bodyLarge, textAlign: .start),
            ),
            const SizedBox(height: 50),
            if (transition != null)
              Center(
                child: ElevatedButton(
                  onPressed: transition,
                  
                  child: Text("C'est parti", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSecondary), ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PageYou extends BasePage {
  const PageYou({super.key})
    : super(
        title: "Pour toi!",
        assetPath: "assets/logo_left.svg",
        text: const [
          "J'ai fait cette appli pour toi car je sais que tu aimes redécouvrir le passé",
          "",
          "Car je te vois le soir chérir tes memories snap",
          "Car je veux que tu puisses les partager avec moi",
          "Car je t'aime",
        ],
      );
}

class PageMe extends BasePage {
  const PageMe({super.key})
    : super(
        title: "Pour moi!",
        assetPath: "assets/logo_right.svg",
        text: const [
          "Mais elle est aussi pour moi!",
          "",
          "J'ai peut-être une bonne mémoire pour tout ce qui est prénoms et nombres",
          "Mais ma mémoire à long terme c'est pas trop ça",
          "",
          "Je ne veux pas perdre une miette du temps qu'on passe ensemble",
          "Je veux pouvoir t'entendre, même quand tu n'es pas avec moi"
          "",
        ],
      );
}

class PageUs extends BasePage {
  const PageUs({super.key, transition})
    : super(
        title: "Pour nous!",
        assetPath: "assets/logo.svg",
        text: const [
          "Pour qu'on rigole",
          "Pour qu'on partage",
          "Pour qu'on découvre l'avenir ensemble"
          "",
          "",
          
          "Joyeux anniversaire",
          "🎉🎉🎉"
        ],
        transition: transition,
        center: true
      );
}

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.transition});
  final void Function() transition;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: .bottomCenter,
        children: <Widget>[
          PageView(
            /// [PageView.scrollDirection] defaults to [Axis.horizontal].
            /// Use [Axis.vertical] to scroll vertically.
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,

            children: <Widget>[
              const PageYou(),
              const PageMe(),
              PageUs(transition: widget.transition),
            ],
          ),
          PageIndicator(
            tabController: _tabController,
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    // if (!_isOnDesktopAndWeb) {
    //   return;
    // }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        .macOS || .linux || .windows => true,
        .android || .iOS || .fuchsia => false,
      };
}

/// Page indicator for desktop and web platforms.
///
/// On Desktop and Web, drag gesture for horizontal scrolling in a PageView is disabled by default.
/// You can defined a custom scroll behavior to activate drag gestures,
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag.
///
/// In this sample, we use a TabPageSelector to navigate between pages,
/// in order to build natural behavior similar to other desktop applications.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    // if (!isOnDesktopAndWeb) {
    //   return const SizedBox.shrink();
    // }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: .fromLTRB(0, 0, 0, MediaQuery.paddingOf(context).bottom * 2),
      child: Row(
        mainAxisAlignment: .center,
        children: <Widget>[
          if (isOnDesktopAndWeb)
            IconButton(
              splashRadius: 16.0,
              padding: .zero,
              onPressed: () {
                if (currentPageIndex == 0) {
                  return;
                }
                onUpdateCurrentPageIndex(currentPageIndex - 1);
              },
              icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
            ),
          TabPageSelector(
            controller: tabController,
            indicatorSize: 16,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          if (isOnDesktopAndWeb)
            IconButton(
              splashRadius: 16.0,
              padding: .zero,
              onPressed: () {
                if (currentPageIndex == 2) {
                  return;
                }
                onUpdateCurrentPageIndex(currentPageIndex + 1);
              },
              icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
            ),
        ],
      ),
    );
  }
}
