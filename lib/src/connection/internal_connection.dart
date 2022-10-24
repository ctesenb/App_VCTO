import 'package:mysql1/mysql1.dart';

class RucConnection {
  static String host = 'mysql-43314-0.cloudclusters.net',
      user = 'admin',
      password = 'adbO1NJG',
      db = 'neo-deter';
  static int port = 19751;
  RucConnection();
  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db);
    return await MySqlConnection.connect(settings);
  }
}
