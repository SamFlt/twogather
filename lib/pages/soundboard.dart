import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';
import 'package:talker/talker.dart';
import 'package:twogather/core/theme.dart';
import 'package:twogather/data/sound.dart';
import 'package:twogather/pages/sound_add.dart';

class SoundModel extends ChangeNotifier {
  final List<Sound> _sounds = [];
  Sound? playing;

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
    stopCurrentSound();
    if (s.audio != null) {
      s.handle = await SoLoud.instance.play(s.audio!);
      playing = s;
      notifyListeners();
      return Future.delayed(SoLoud.instance.getLength(s.audio!), () { playing = null; notifyListeners(); });
    } else {
      throw StateError("Tried to sound but audio source was not loaded");
    }
  }

  Future<void> togglePause(Sound s) async {
    if (playing == null) {
      return;
    }
    if (s != playing) {
      Talker t = Talker();
      t.warning("Sound handle and for sound ${s.name} is badly set");
    }

    SoLoud.instance.pauseSwitch(s.handle!);
    
    notifyListeners();
  }

  void stop(Sound s) {
    if (s.handle != null) {
      SoLoud.instance.stop(s.handle!);
      notifyListeners();
    }
  }

  bool audioIsPlaying() {
    if (playing == null) {
      return false;
    }

    return SoLoud.instance.getIsValidVoiceHandle(playing!.handle!);
  }

  Future<void> fetchSounds() async {
    loading = true;
    notifyListeners();

    _sounds.addAll(await _service.getSounds());
    loading = false;
    notifyListeners();
  }

  Future<Result<Sound>> addSound(Sound s, Uint8List data) async {
    var result = await _service.addSound(s, data);

    result = result.onSuccess((sound) {
      _sounds.add(sound);
    });

    notifyListeners();

    return result;
  }
  
  void stopCurrentSound() {

    if(playing != null) {
      stop(playing!);
      playing = null;
      notifyListeners();
    }
  }
}

class SoundButtonWidget extends StatelessWidget {
  final Sound sound;
  const SoundButtonWidget(this.sound, {super.key});

  void _onPressed(SoundModel model) async {
    if (sound.audio == null) {
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
        return ElevatedButton(
          
          style: ButtonStyle(
            shape: WidgetStateOutlinedBorder.fromMap({
              WidgetState.any: RoundedRectangleBorder(borderRadius: .all(.circular(5)))
            }),
            
            backgroundColor: WidgetStateColor.fromMap({
              WidgetState.any: c
            })
          ),
          onPressed: () => _onPressed(value),
          child: Text(sound.name),
          
        );
      },
    );
  }
}

class SoundBoardWidget extends StatefulWidget {
  const SoundBoardWidget({super.key});
  @override
  State<StatefulWidget> createState() => _SoundBoardWidgetState();
}

class _SoundBoardWidgetState extends State<SoundBoardWidget> {

  void onAddPressed(BuildContext context, SoundModel model) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SoundAddPage(soundModel: model),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SoundModel(),
      child: Consumer<SoundModel>(
        builder: (context, model, child) {
          if (model.loading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => onAddPressed(context, model),
                child: Icon(Icons.add),
              ),
              body: Stack(
                children:[GridView.count(
                padding: .fromLTRB(5, 5, 5, 5),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 2,
                children: model._sounds
                    .map((sound) => SoundButtonWidget(sound))
                    .toList(),
              ),
              if (model.playing != null) FloatingActionButton(child: Text("prout"), onPressed: () {
                if(model.playing != null) {
                  model.stopCurrentSound();
                }
              })
              
              ]
              ),
            );
          }
        },
      ),
    );
  }
}
