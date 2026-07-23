import 'package:flutter/material.dart';
import 'package:twogather/pages/soundboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, this.message});

  final String title;
  final SnackBar? message;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  Widget soundPage(BuildContext context) {
    return SoundBoardWidget();
  }

  Widget memoriesPage(BuildContext context) {
    return Center(child: Column(children: [Text('Memories')]));
  }

  Widget eventPage(BuildContext context) {
    return Center(child: Column(children: [Text('Events')]));
  }

  @override
  void initState() {
    super.initState();
    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(widget.message!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var primary = Theme.of(context).colorScheme.primary;

    Widget iconFn(IconData d, bool selected) {
      var colorScheme = Theme.of(context).colorScheme;
      return Icon(
        d,
        color: selected ? colorScheme.primary : colorScheme.secondary,
        size: 20,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },

        backgroundColor: primary,
        labelTextStyle:
            WidgetStateProperty.fromMap(<WidgetStatesConstraint, TextStyle>{
              WidgetState.selected: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.secondary,
              ),
              WidgetState.any: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.secondary,
              ),
            }),
        indicatorColor: Theme.of(context).colorScheme.secondary,
        indicatorShape: StarBorder(
          points: 8,
          innerRadiusRatio: 0.8,
          valleyRounding: 0.25,
          pointRounding: 0.1,
        ),
        height: 70,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: iconFn(Icons.speaker, true),
            icon: iconFn(Icons.speaker_outlined, false),
            label: 'Hear',
          ),
          NavigationDestination(
            selectedIcon: iconFn(Icons.lightbulb_outlined, true),
            icon: iconFn(Icons.lightbulb, false),
            label: 'See',
          ),
          NavigationDestination(
            icon: iconFn(Icons.hourglass_top, false),
            selectedIcon: iconFn(Icons.hourglass_bottom, true),
            label: 'Meet',
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          return [soundPage, memoriesPage, eventPage][currentPageIndex](
            context,
          );
        },
      ),
    );
  }
}
