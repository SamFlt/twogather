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

    Widget iconFn(IconData d) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          begin: .bottomCenter,
          end: .topCenter,
          stops: [.5, 1],
          colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.surface],
        ).createShader(bounds),
        child: Icon(d),
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

      bottomNavigationBar: IconTheme(
        data: IconTheme.of(context),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },

          backgroundColor: primary,

          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: iconFn(Icons.speaker),
              icon: iconFn(Icons.speaker_outlined),
              label: 'Sounds of love',
            ),
            NavigationDestination(
              icon: iconFn(Icons.lightbulb),
              selectedIcon: iconFn(Icons.lightbulb_outlined),
              label: 'Memories',
            ),
            NavigationDestination(
              icon: iconFn(Icons.hourglass_top),
              selectedIcon: iconFn(Icons.hourglass_bottom_outlined),
              label: 'Events',
            ),
          ],
        ),
      ),
      body: [soundPage, memoriesPage, eventPage][currentPageIndex](context),
    );
  }
}
