import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:twogather/core/theme.dart';
import 'package:twogather/data/db.dart';
import 'package:twogather/pages/soudboard.dart';


void main() async {
  await SoLoud.instance.init();
  await SoLoud.instance.init(
    sampleRate: 44100,
    bufferSize: 2048,
    channels: Channels.mono,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'TwoGather',
      theme: getTheme(),
      home: FutureBuilder<void>(future: DataRepository.instance.connectToDb(), builder:(context, snapshot) {
        
        if (snapshot.connectionState == .done) {
          return const MyHomePage(title: 'TwoGather');
        } else {
          return Center(child:CircularProgressIndicator());
        }
      },) ,
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  Widget build(BuildContext context) {
    var primary = Theme.of(context).colorScheme.primary;

    Widget iconFn(IconData d, bool selected) {
      var colorScheme = Theme.of(context).colorScheme;
      return Icon(d, color: selected ? colorScheme.primary: colorScheme.secondary, size: 20);
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
        labelTextStyle: WidgetStateProperty.fromMap(<WidgetStatesConstraint, TextStyle>{
          WidgetState.selected: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
          WidgetState.any: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
        }),
        indicatorColor: Theme.of(context).colorScheme.secondary,
        indicatorShape: StarBorder(points: 8, innerRadiusRatio: 0.8, valleyRounding: 0.25, pointRounding: 0.1),
        height: 70,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: iconFn(Icons.speaker, true),
            icon: iconFn(Icons.speaker_outlined, false),
            label: 'Sounds of love',
          ),
          NavigationDestination(
            selectedIcon: iconFn(Icons.lightbulb_outlined, true),
            icon: iconFn(Icons.lightbulb, false),
            label: 'Memories',
          ),
          NavigationDestination(
            icon: iconFn(Icons.hourglass_top, false),
            selectedIcon: iconFn(Icons.hourglass_bottom_outlined, true),
            label: 'Events',
          ),
        ],
      ),
      body: [soundPage, memoriesPage, eventPage][currentPageIndex](context),
    );
  }
}
