import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiMethods {
  ApiMethods();

  Future<double?> getChange() async {
  try {
    var url = Uri.parse('https://api.apis.net.pe/v1/tipo-cambio-sunat');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    return data['venta'];
  } catch (e) {
    print('Get Change: $e');
  }
}

Future<String?> getNameXRuc(String ruc) async {
  try {
    var dato = '';
    var url = Uri.parse('https://api.apis.net.pe/v1/ruc?numero=$ruc');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    if (data['nombre'] != null) {
      dato = data['nombre'];
    } else {
      dato = 'No se encontró el nombre';
    }
    return dato;
  } catch (e) {
    print('Get Name Empresa: $e');
  }
}

Future<String?> getDireccionXRuc(String ruc) async {
  try {
    var dato = '';
    var url = Uri.parse('https://api.apis.net.pe/v1/ruc?numero=$ruc');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    if (data['direccion'] != null) {
      dato = data['direccion'];
    } else {
      dato = 'No hay dirección';
    }
    return dato;
  } catch (e) {
    print('Get Name Persona: $e');
  }
}

Future<String?> getNameXDni(String dni) async {
  try {
    var dato = '';
    var url = Uri.parse('https://api.apis.net.pe/v1/dni?numero=$dni');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    if (data['nombre'] != null) {
      dato = data['nombre'];
    } else {
      dato = 'No se encontró el nombre';
    }
    return dato;
  } catch (e) {
    print('Get Name Persona: $e');
  }
}
}