class Sound {
  final int id;
  final String name;
  final String hash;
  String? data;
  Sound({required this.id, required this.name, required this.hash});  
}


class SoundList {
  List<Sound> sounds;
  SoundList(this.sounds);

}