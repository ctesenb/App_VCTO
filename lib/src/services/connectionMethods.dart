import 'package:app1c/src/services/apiMethods.dart';
import 'package:app1c/src/utils/alertMethods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/internal_connection.dart';

class ConnectionMethods {
  ConnectionMethods();

  Future<void> connectionInternalExternal(String rucBusiness) async {
    try {
      /*
    *NOTA: No tocar, es la consulta para obtener la conexion a la base de datos externa
    */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var db = await RucConnection().getConnection();
      var empresa = await db
          .query('SELECT * FROM empresas_allow WHERE EMPRESA = "$rucBusiness"');
      await db.close();
      if (empresa.isNotEmpty) {
        List<String> temp = [];
        for (var i = 0; i < empresa.length; i++) {
          temp.add(empresa.elementAt(i).toString());
        }
        String ruc = temp[0].split(',')[0].split('{')[1].split(':')[1].trim();
        String host = temp[0].split(',')[1].split(':')[1].trim();
        String port = temp[0].split(',')[5].split(':')[1].split('}')[0].trim();
        String user = temp[0].split(',')[2].split(':')[1].trim();
        String password = temp[0].split(',')[3].split(':')[1].trim();
        String db = temp[0].split(',')[4].split(':')[1].trim();
        await prefs.setString('host', host);
        await prefs.setString('port', port);
        await prefs.setString('user', user);
        await prefs.setString('password', password);
        await prefs.setString('db', db);
        await prefs.setString('ruc', ruc);
        String? nombreEmpresa = await ApiMethods().getNameXRuc(ruc);
        await prefs.setString('nombre', nombreEmpresa!);
        AlertMethods().alertaInfo('Conexion establecida\n\n Empresa: $nombreEmpresa');
      } else {
        AlertMethods().alertaError('No se encontro la empresa en la DB');
      }
    } catch (e) {
      print('Connection Internal External Error: $e');
      AlertMethods().alertaError('Conexion fallida');
    }
  }

  Future<List<String?>?> connectionInternalExternalList(String? usuario) async {
    try {
      /*
    *NOTA: No tocar, es la consulta para los usuarios
    */
      var db = await RucConnection().getConnection();
      var empresa = await db
          .query('SELECT BUSINESS FROM usuarios_allow WHERE USER = "$usuario"');
      await db.close();
      List<String> empresas = [];
      for (var item in empresa) {
        empresas.add(item[0]);
      }
      return empresas;
    } catch (e) {
      print('Connection Internal External: $e');
    }
  }
}
