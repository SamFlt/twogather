import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twogather/data/sound.dart';



class SoundModel extends ChangeNotifier {
  final List<Sound> _sounds = [];
  bool loading = false;


  SoundModel() {
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    loading = true;
    notifyListeners();
    return Future.delayed(Duration(seconds: 5), () {
      _sounds.add(
        Sound(id: 0, name: 'TROUA', hash: 'AAAA')
      );
      loading = false;
      notifyListeners();

    });
  }
  
}

class SoundBoardWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SoundBoardWidgetState();

}

class _SoundBoardWidgetState extends State<SoundBoardWidget> {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SoundModel(),
      child: Consumer<SoundModel>(
        builder:(context, value, child) {
          if(value.loading) {
            return CircularProgressIndicator();
          } else {
            return GridView.count(crossAxisCount: 2, children: value._sounds.map((sound) => Text('a')).toList());
          }
        },
        
      
    ));
  }

}