import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';
import 'package:twogather/core/recorder.dart';
import 'package:twogather/data/sound.dart';
import 'package:twogather/pages/soundboard.dart';

class SoundAddModel extends ChangeNotifier {
  Sound s = Sound(id: "0", name: "", filename: null);


  BytesBuilder soundBuilder = BytesBuilder(copy: true);
  Uint8List soundData = Uint8List(0);

  String? selectedFileName;

  bool playing = false;

  bool recording = false;

  bool canValidate() {
    return selectedFileName != null || soundData.isNotEmpty;
  }

  bool canSelectFile() => !recording && soundData.isEmpty || selectedFileName != null;

  bool canRecord() => selectedFileName == null;

  void clearSelectedFile() {
    selectedFileName = null;
    s.filename = null;
    if (s.audio != null) {
      SoLoud.instance.disposeSource(s.audio!);
    }
    soundData = Uint8List(0);
    notifyListeners();
  }

  void setSelectedFile(FilePickerResult res) async {
    if (res.files.length != 1) {
      throw StateError("Expected to have only one fille selected");
    }
    PlatformFile f = res.files[0];
    if (f.path == null) {
      return;
    }
    selectedFileName = f.name;
    s.filename = f.name;

    final ff = File(f.path!);

    soundData = ff.readAsBytesSync();
    s.audio = await SoLoud.instance.loadMem(f.path!, soundData);

    notifyListeners();
  }

  Future<Result<Sound>> validate(SoundModel model) async {
    if (!canValidate()) {
      return Failure(Exception("Data not provided"));
    }

    Result<Sound> result = await model.addSound(s, soundData);
    notifyListeners();
    return result;
  }

  void togglePause(SoundModel model) {
    if (s.audio != null) {
      model.togglePause(s);
      playing = !playing;
      notifyListeners();
    }
  }

  void playSound(SoundModel model) {
    if (s.audio != null) {
      playing = true;
      model.playAudio(s);
      notifyListeners();
    }
  }

  void stopSound(SoundModel model) {
    playing = false;
    model.stop(s);
    notifyListeners();
  }

  Future<bool> startRecording() async {
    bool isGranted = await RecorderHelper.requestMic();
    if(isGranted) {
      await RecorderHelper.init();
      soundBuilder.clear();
      Recorder.instance.startStreamingData();
      Recorder.instance.uint8ListStream.listen((data) {
        soundBuilder.add(data.rawData);
      });
      recording = true;
    }
    notifyListeners();
    return isGranted;
  }
  Future<void> stopRecording() async {
    Recorder.instance.stopStreamingData();
    soundData = soundBuilder.toBytes();
    recording = false;
    notifyListeners();
  }
}

class FormGroup extends StatelessWidget {
  const FormGroup({
    required this.title,
    required this.child,
    required this.disabled,
    this.fontSize,
    super.key,
  });
  final String title;
  final Widget child;
  final bool disabled;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(5),
        shape: BoxShape.rectangle,
      ),
      child: child,
    );
    return Stack(
      children: [
        if (!disabled)
          container
        else
          Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
            child: container,
          ),
        groupTitle(context),
      ],
    );
  }

  Widget groupTitle(BuildContext context) {
    double fs = fontSize ?? 16.0;
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          top: fs / 2,
          bottom: fs / 2,
          left: fs / 2,
          right: fs / 2,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fs,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

class FilePickerWidget extends StatelessWidget {
  const FilePickerWidget({super.key});

  void addFilePressed(SoundAddModel model) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['wav', 'ogg', 'mp3'],
    );

    if (result != null) {
      model.setSelectedFile(result);
    }
  }

  BoxDecoration buttonDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.secondary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(5),
      color: Theme.of(context).colorScheme.secondary,
      shape: BoxShape.rectangle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundAddModel>(
      builder: (context, addModel, child) => FormGroup(
        title: 'Choose a file',
        disabled: !addModel.canSelectFile(),
        child: Container(
          decoration: buttonDecoration(context),
          child: Center(
            child: Column(
              children: [
                TextButton(
                  onPressed: () => addFilePressed(addModel),
                  child: Column(
                    children: addModel.selectedFileName == null
                        ? [Icon(Icons.add), Text("Select file")]
                        : [
                            Icon(Icons.change_circle),
                            Text(addModel.selectedFileName!),
                          ],
                  ),
                ),
                if (addModel.selectedFileName != null)
                  IconButton(
                    onPressed: () => addModel.clearSelectedFile(),
                    icon: Icon(Icons.delete),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoundAddControls extends StatelessWidget {
  const SoundAddControls(this.soundModel, {super.key});

  final SoundModel soundModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundAddModel>(
      builder: (context, addModel, child) {
        List<Widget> children = [];

        if (!addModel.playing) {
          children.add(
            ElevatedButton(
              onPressed: addModel.s.audio != null
                  ? () => addModel.playSound(soundModel)
                  : null,
              child: Icon(Icons.play_arrow),
            ),
          );
        } else {
          children.add(
            ElevatedButton(
              onPressed: () => addModel.s.audio != null
                  ? addModel.stopSound(soundModel)
                  : null,
              child: Icon(
                Icons.stop,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          );
        }

        children.add(SizedBox(width: 20));
        var validate = addModel.canValidate()
            ? () async {
                final result = await addModel.validate(soundModel);
                result.fold(
                  (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Sound was successfully saved")),
                    );
                    Navigator.pop(context);
                  },
                  (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "There was an issue saving the sound: $e",
                        ),
                      ),
                    );
                  },
                );
              }
            : null;
        children.add(ElevatedButton(onPressed: validate, child: Text('Save')));

        return Container(
          decoration: BoxDecoration(
            borderRadius: .all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.secondary,
          ),

          child: Padding(
            padding: .fromLTRB(20, 5, 20, 5),
            child: Row(
              mainAxisAlignment: .center,
              mainAxisSize: .min,
              children: children,
            ),
          ),
        );
      },
    );
  }
}

class SoundAddPage extends StatelessWidget {
  const SoundAddPage({super.key, required this.soundModel});

  final SoundModel soundModel;

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(color: Theme.of(context).colorScheme.secondary);
    return ChangeNotifierProvider(
      create: (BuildContext context) => SoundAddModel(),
      builder: (context, child) {
        return Consumer<SoundAddModel>(
          builder: (context, addModel, child) {
            return Scaffold(
              appBar: AppBar(title: Text('Add a sound')),
              floatingActionButtonLocation: .centerFloat,
              floatingActionButton: SoundAddControls(soundModel),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        style: textStyle,
                        decoration: InputDecoration(
                          label: Text("Sound name"),
                          hintStyle: textStyle,
                          labelStyle: textStyle,
                        ),
                      ),
                      FilePickerWidget(),

                      FormGroup(
                        title: 'Or record audio',
                        disabled: !addModel.canRecord(),
                        child: Column(
                          children: [
                            if(!addModel.recording) Center(
                              child:  IconButton(
                                onPressed: () async {
                                  bool isGranted = await addModel.startRecording();
                                  if(!isGranted) {
                                    if(context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please grant microphone access to record sound data")));
                                    }
                                  }
                                },
                                icon: Icon(Icons.record_voice_over),
                              ),
                            ),
                            if(addModel.recording) Center(
                              child:  IconButton(
                                onPressed: () async {
                                  await addModel.stopRecording();
                                },
                                icon: Icon(Icons.stop),
                              ),
                            ),
                          
                          
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
