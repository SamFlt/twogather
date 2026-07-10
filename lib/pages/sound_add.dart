import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twogather/data/sound.dart';
import 'package:twogather/pages/soudboard.dart';

class SoundAddModel extends ChangeNotifier {
  Sound s = Sound(id: "0", name: "Temp", filename: null);

  Uint8List soundData = Uint8List(0);

  String? selectedFileName;

  void setSelectedFile(FilePickerResult res) {
    if (res.files.length != 1) {
      throw StateError("Expected to have only one fille selected");
    }
    PlatformFile f = res.files[0];
    selectedFileName = f.name;
    notifyListeners();
  }

  void validate() {}
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
        padding: EdgeInsets.only(top: fontSize / 2, bottom: fontSize / 2, left: fontSize / 2, right: fontSize / 2),
        color: Theme.of(context).colorScheme.surface,
        child: Text(
          'Choose a file',
          style: TextStyle(fontSize: fontSize),
        ),
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
