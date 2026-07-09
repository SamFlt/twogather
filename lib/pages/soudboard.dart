import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:twogather/core/theme.dart';
import 'package:twogather/data/sound.dart';



class SoundModel extends ChangeNotifier {
  final List<Sound> _sounds = [];
  SoundHandle? _soundHandle; 

  bool loading = false;

  final SoundService _service = SoundService();


  SoundModel() {
    fetchSounds();
  }

  Future<void> updateSoundWithData(Sound s) async {
    await _service.getSoundData(s);
    notifyListeners();
  }

  Future<void> playAudio(Sound s) async {
  
    if(_soundHandle != null) {
      SoLoud.instance.stop(_soundHandle!);
    }
    if(s.audio != null) {
    _soundHandle = await SoLoud.instance.play(
        s.audio!,
    );
    notifyListeners();
    } else {
      throw StateError("Tried to sound but audio source was not loaded");
    }
    
    
  }

  Future<void> fetchSounds() async {
    loading = true;
    notifyListeners();

    _sounds.addAll(await _service.getSounds());
    loading = false;
    notifyListeners();
  }
}

class SoundButtonWidget extends StatelessWidget {
  final Sound sound;
  const SoundButtonWidget(this.sound, {super.key});

  void _onPressed(SoundModel model) async {
    if(sound.audio == null) {
      await model.updateSoundWithData(sound);
    }
    model.playAudio(sound);
  }

  @override
  Widget build(BuildContext context) {
    var cs = getColorPalette();
    var c = cs[sound.id.hashCode % cs.length];
    
    return Consumer<SoundModel>(
      builder: (context, value, child) {
      return PopArtButton(label: sound.name, onPressed: () => _onPressed(value), color: c);
      } 
    );
  }
}

class SoundBoardWidget extends StatefulWidget{
  const SoundBoardWidget({super.key});

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
            return GridView.count(crossAxisCount: 2, children: value._sounds.map((sound) => SoundButtonWidget(sound)).toList());
          }
        },
    ));
  }

}