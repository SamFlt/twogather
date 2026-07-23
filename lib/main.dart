import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:result_dart/result_dart.dart';
import 'package:twogather/core/theme.dart';
import 'package:twogather/data/db.dart';
import 'package:twogather/pages/home_page.dart';
import 'package:twogather/pages/intro_page.dart';


void main() async {
  await SoLoud.instance.init(
    sampleRate: 44100,
    bufferSize: 2048,
    channels: Channels.mono,
  );
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwoGather',
      theme: getTheme(),
      home: RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}


enum RootPageFlowStatus {
  intro,
  login,
  content
}

class _RootPageState extends State<RootPage> {

  RootPageFlowStatus status = .intro;

  @override
  void initState() {
    super.initState();
  }

  void changeStatus(RootPageFlowStatus status) {
    setState(() {
      this.status = status;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    switch(status) {
      
      case RootPageFlowStatus.intro:
        return IntroPage(transition: () => changeStatus(.content));
      case RootPageFlowStatus.login:
        throw UnimplementedError();
      case RootPageFlowStatus.content:
        return FutureBuilder<Result<int>>(future: DataRepository.instance.connectToDb(), builder:(context, snapshot) {
        if (snapshot.connectionState == .done) {

          if(snapshot.data == null) {
            return HomePage(title: 'TwoGater (local)');
          }
          return snapshot.data!.fold((success) => HomePage(title: 'TwoGather'),
            (failure) {
              final snackBar = SnackBar(
              content: Text(failure.toString()),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              );
              return HomePage(title: 'TwoGather (local)', message: snackBar);
            },
          );
           
        } else {
          return Center(child:CircularProgressIndicator());
        }
      });
    }
  }

}

