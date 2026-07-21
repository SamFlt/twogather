import 'package:flutter/foundation.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderHelper {
  static bool _init = false;
  
  static Future<bool> requestMic() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return Permission.microphone.request().isGranted;
    }

    return true;
  }

  static Future<void> init() async {
    if(!_init) {
      await Recorder.instance.init(androidInputPreset: AndroidInputPreset.voiceCommunication);
      Recorder.instance.start();
      _init = true;
    }
  }
}
