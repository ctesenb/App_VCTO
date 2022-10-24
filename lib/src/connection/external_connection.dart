import 'package:mysql1/mysql1.dart';

import '../interfaces/pages/home/logic/pref_logic.dart';

class Mysql {
  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
        host: (await getHost())!,
        port: int.parse((await getPort())!),
        user: (await getUser())!,
        password: (await getPassword())!,
        db: (await getDb())!);

    return await MySqlConnection.connect(settings);
  }
}
