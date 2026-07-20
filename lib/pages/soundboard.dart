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
    if (_soundHandle != null) {
      // Only one sound can be played at the same time
      SoLoud.instance.stop(_soundHandle!);
    }
    if (s.audio != null) {
      _soundHandle = await SoLoud.instance.play(s.audio!);
      s.handle = _soundHandle;
      notifyListeners();
    } else {
      throw StateError("Tried to sound but audio source was not loaded");
    }
  }

  Future<void> togglePause(Sound s) async {
    if (_soundHandle == null) {
      return;
    }
    if (s.handle != _soundHandle) {
      Talker t = Talker();
      t.warning("Sound handle and for sound ${s.name} is badly set");
    }

    SoLoud.instance.pauseSwitch(_soundHandle!);
    notifyListeners();
  }

  void stop(Sound s) {
    if (s.handle != null) {
      SoLoud.instance.stop(s.handle!);
      notifyListeners();
    }
  }

  bool audioIsPlaying() {
    if (_soundHandle == null) {
      return false;
    }

    return SoLoud.instance.getIsValidVoiceHandle(_soundHandle!);
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
        return PopArtButton(
          label: sound.name,
          onPressed: () => _onPressed(value),
          color: c,
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
        builder: (context, value, child) {
          if (value.loading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => onAddPressed(context, value),
                child: Icon(Icons.add),
              ),
              body: GridView.count(
                crossAxisCount: 2,
                children: value._sounds
                    .map((sound) => SoundButtonWidget(sound))
                    .toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
