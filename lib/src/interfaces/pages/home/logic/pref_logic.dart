import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getBusiness() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('empresa');
  } catch (e) {
    print('getBusiness(): $e\n\nError al obtener empresa');
    return null;
  }
}

Future getNombre() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Future Nombre: ${prefs.getString('nombre')}');
    return prefs.getString('nombre') ?? '';
  } catch (e) {
    print('Error Nombre: $e');
  }
}

Future<String?> getHost() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('host') ?? '';
  } catch (e) {
    print('Error Host: $e');
  }
}

Future<String?> getUser() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user') ?? '';
  } catch (e) {
    print('Error user: $e');
  }
}

Future<String?> getPassword() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') ?? '';
  } catch (e) {
    print('Error pass: $e');
  }
}

Future<String?> getDb() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('db') ?? '';
  } catch (e) {
    print('Error db: $e');
  }
}

Future<String?> getPort() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('port') ?? '';
  } catch (e) {
    print('Error port: $e');
  }
}
