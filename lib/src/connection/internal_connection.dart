import 'package:mysql1/mysql1.dart';

class RucConnection {
  static String host = '',
      user = '',
      password = '',
      db = '';
  static int port = ;
  RucConnection();
  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db);
    return await MySqlConnection.connect(settings);
  }
}
