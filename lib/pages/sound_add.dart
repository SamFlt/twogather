import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:twogather/data/sound.dart';
import 'package:twogather/pages/soudboard.dart';

class SoundAddModel extends ChangeNotifier {
  Sound s = Sound(id: "0", name: "Temp", filename: null);

  Uint8List soundData = Uint8List(0);

  String? selectedFileName;

  bool playing = false;

  bool canValidate() {
    return selectedFileName != null || soundData.isNotEmpty;
  }

  void setSelectedFile(FilePickerResult res) async {
    if (res.files.length != 1) {
      throw StateError("Expected to have only one fille selected");
    }
    PlatformFile f = res.files[0];
    if(f.path == null) {
      return;
    }
    selectedFileName = f.name;
    s.audio = await SoLoud.instance.loadFile(f.path!);

    notifyListeners();
  }

  void validate() {}
  
  void togglePause(SoundModel model) {
    if(s.audio != null) {
      model.togglePause(s);
      playing = !playing;
      notifyListeners();
    }
  }

  void playSound(SoundModel model) {
    if(s.audio != null) {
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

  BoxDecoration groupBorder(BuildContext context) {
    return BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.secondary,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(5),
      shape: BoxShape.rectangle,
    );
  }

  BoxDecoration buttonDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.tertiary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(5),
      color: Theme.of(context).colorScheme.tertiary,
      shape: BoxShape.rectangle,
    );
  }

  Widget groupTitle(BuildContext context, double fontSize) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          top: fontSize / 2,
          bottom: fontSize / 2,
          left: fontSize / 2,
          right: fontSize / 2,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Text('Choose a file', style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundAddModel>(
      builder: (context, addModel, child) => Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            decoration: groupBorder(context),
            child: Container(
              decoration: buttonDecoration(context),
              child: Center(
                child: TextButton(
                  onPressed: () => addFilePressed(addModel),
                  child: Column(
                    children: addModel.selectedFileName == null
                        ? [Icon(Icons.add), Text("Click to select file")]
                        : [
                            Icon(Icons.change_circle),
                            Text(addModel.selectedFileName!),
                          ],
                  ),
                ),
              ),
            ),
          ),
          groupTitle(context, 16),
        ],
      ),
    );
  }
}

class SoundAddControls extends StatelessWidget {
  const SoundAddControls({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Consumer2<SoundModel, SoundAddModel>(
      builder: (context, soundModel, addModel, child) {
        List<Widget> children = [];

        if (!addModel.playing) {
          children.add(
            ElevatedButton(
              onPressed: () => addModel.s.audio != null ? () => addModel.playSound(soundModel) : null,
              child: Icon(
                Icons.play_arrow,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          );
        } else {
          children.add(
            ElevatedButton(
              onPressed: () => addModel.s.audio != null ? addModel.stopSound(soundModel) : null,
              child: Icon(
                Icons.stop,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          );
        }

        children.add(SizedBox(width: 20));

        if (addModel.canValidate()) {
          children.add(
            ElevatedButton(
              child: Text('Save'),
              onPressed: () => addModel.validate(),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: .all(Radius.circular(20)),
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
  const SoundAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => SoundAddModel(),
      builder: (context, child) {
        return Consumer2<SoundModel, SoundAddModel>(
          builder: (context, soundModel, addModel, child) {
            return Scaffold(
              appBar: AppBar(title: Text('Add a sound')),
              floatingActionButtonLocation: .centerFloat,
              floatingActionButton: SoundAddControls(),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(label: Text("Sound name")),
                      ),
                      FilePickerWidget(),
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
