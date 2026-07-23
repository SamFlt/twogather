import 'package:flutter/material.dart';
import 'package:twogather/pages/calendar_page.dart';
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
    return CalendarPage();
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
        title: Text(widget.title, style: Theme.of(context).textTheme.headlineLarge,),
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
            selectedIcon: iconFn(Icons.hearing, true),
            icon: iconFn(Icons.hearing_outlined, false),
            label: 'Hear',
          ),
          NavigationDestination(
            selectedIcon: iconFn(Icons.remove_red_eye, true),
            icon: iconFn(Icons.remove_red_eye_outlined, false),
            label: 'See',
          ),
          NavigationDestination(
            icon: iconFn(Icons.watch_later, false),
            selectedIcon: iconFn(Icons.watch_later_outlined, true),
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
