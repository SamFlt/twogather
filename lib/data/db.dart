import 'package:pocketbase/pocketbase.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class DataRepository {
  
  
  static DataRepository instance = DataRepository._internal();

  late PocketBase _db;
  bool init = false;
  bool connected = false;

  Future<PocketBase?> get db async {
    if(init) {
      return _db;
    } else {
      try {
        await connectToDb();
        return _db;
      } on Exception {
        return null;
      }
    }
  }

  DataRepository._internal();

  Future<Result<int>> connectToDb() async {
    if(init && connected) {
      return Success(0);
    }
    
    final Talker talker = Talker();

    // for simplicity we are using a simple SharedPreferences instance
    // but you can also replace it with its safer EncryptedSharedPreferences alternative
    final prefs = await SharedPreferences.getInstance();
    talker.info(prefs);
    // initialize the async store
    final store = AsyncAuthStore(
    save:    (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
    );
    talker.info(store);
    _db = PocketBase('http://192.168.1.188:8090', authStore: store);

    init = true;
    talker.info(_db);
    try {
      await _db.collection('users').authWithPassword('karam.maslef@gmail.com', '_-1il6JCQwJXXRKM8rPa');
      talker.info(_db.authStore.record);
      connected = true;
      return Success(0);

    } on Exception catch(e) {
      connected = false;
      return Failure(e);
    }
  }
}