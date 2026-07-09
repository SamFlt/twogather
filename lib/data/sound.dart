import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:talker/talker.dart';
import 'package:twogather/data/db.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Sound {
  final String id;
  String name;
  String? filename;
  AudioSource? audio;
  Sound({required this.id, required this.name, required this.filename});

  
  Sound.fromJson(Map<String, dynamic> json)
    :  id = json['id'] as String,
    name = json['name'] as String,
    filename = json['file'] as String?;

  Map<String, dynamic> toJson() => {'id': id,  'name': name, 'file': filename };
}


class SoundList {
  List<Sound> sounds;
  SoundList(this.sounds);
}


class SoundCache {
  late final Directory soundsDir;
  late final File soundListFile;
  bool _init = false;
  final Talker _log = Talker();

  Future<void> init() async {
    if(_init) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final soundsPath = '${directory.path}/sounds/';
    soundsDir = Directory(soundsPath);
    await soundsDir.create();
    soundListFile = File('${soundsDir.path}/sounds.json');
    _init = true;
  }

  void writeSoundList(List<Sound> sounds) async {
    await init();
    String jsonData = jsonEncode(sounds);
    _log.debug(jsonData);
    soundListFile.writeAsString(jsonData);
  }

  Future<List<Sound>> readSoundList() async {
    await init();

    if(!soundListFile.existsSync()){
      return [];
    }
    List<Sound> res = List<Sound>.from(jsonDecode(soundListFile.readAsStringSync()).map((elem) => Sound.fromJson(elem)));
    _log.debug(res);
    for(var r in res) {
      _log.debug('Loaded filename: ${r.filename}');
    }
    return res;
  }

  Future<void> writeSoundData(Sound s, Uint8List bytes) async {
      // Save the exact same bytes to disk
      final savePath = '${soundsDir.path}/${s.filename}';
      final file = File(savePath);
      await file.writeAsBytes(bytes);
      _log.info('Wrote ${s.filename} data');
  }

  Future<bool> readSoundData(Sound s) async {
    if(s.filename != null) {
      final savePath = '${soundsDir.path}/${s.filename}';
      final file = File(savePath);
      if(file.existsSync()) {
        _log.info('reading ${s.filename} data');
        s.audio = await SoLoud.instance.loadFile(savePath);
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

}

class SoundService extends ChangeNotifier {

  final DataRepository repo = DataRepository.instance;

  final SoundCache cache = SoundCache();


  Future<void> getSoundData(Sound s) async {
      bool loadedFromCache = await cache.readSoundData(s);
      if(loadedFromCache) {
        return;
      }

      // Try to get from db
      PocketBase? db = await repo.db;
      if(db == null) {
        throw StateError("Loading from cache not yet done");
        
      }
      var res = await db.collection("sounds").getOne(s.id, fields: "id,collectionId,file");
      var t = Talker();
      t.info(res.collectionId);
      t.info(res.data["file"]);
      var token = await db.files.getToken();
      var filename = res.data["file"];
      s.filename = filename;
      t.info(token);
      final url = db.files.getUrl(res, filename);
      t.info(url);

      // Fetch the bytes yourself first
      final response = await http.get(url);
      final bytes = response.bodyBytes;
      await cache.writeSoundData(s, bytes);

      s.audio = await SoLoud.instance.loadMem(
        s.id,
        bytes,
        mode: LoadMode.memory,
      );
  }

  Future<List<Sound>> getSounds() async {
    PocketBase? db = await repo.db;

    Future<List<Sound>> fcacheSounds = cache.readSoundList();

    if(db == null) {
      return [];
    }
    var listRes = await db.collection("sounds").getFullList(fields: "id,description,file");

    final dbSounds = listRes.map((e) {
      return Sound(id: e.data["id"], name: e.data["description"], filename: e.data["file"]);
    });

    final cacheSounds = await fcacheSounds;
    for(final c in dbSounds) {
      Sound? s = cacheSounds.cast<Sound?>().firstWhere((c2) => c2 != null && c2.id == c.id, orElse: () => null);
      
      if(s == null) {
        cacheSounds.add(c);
      } else {
        s.filename = c.filename;
        s.name = c.name;
      }
    }
    cache.writeSoundList(cacheSounds);

    return cacheSounds;
  }


}