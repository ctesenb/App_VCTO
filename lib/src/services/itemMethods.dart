import 'dart:math';

import 'package:app1c/src/connection/external_connection.dart';
import 'package:app1c/src/services/datetimeMethods.dart';

class ItemMethods {
  ItemMethods();

  Future<String?> getExternalCodeItem(String description) async {
    try {
      var returnString;
      var db = await Mysql().getConnection();
      var sql = 'SELECT F5BARRAS FROM IF5PLA WHERE F5NOMPRO = "$description"';
      var results = await db.query(sql);
      results.forEach((row) {
        print(row[0]);
        returnString = row[0];
      });
      return returnString;
    } catch (e) {
      print('getQrItem: $e');
      return null;
    }
  }

  Future<bool?> existsExternalCodeItem(String descripcion) async {
    try {
      String? externalCode = await getExternalCodeItem(descripcion);
      if (externalCode != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('existsQr: $e');
      return false;
    }
  }

  Future<List<String>?> getListFamilyItem() async {
    try {
      List<String> listFamily = [];
      var sql = 'SELECT F7DESCON FROM SF7NIVEL01';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      if (results.isNotEmpty) {
        for (var item in results) {
          listFamily.add(item[0]);
        }
      }
      return listFamily;
    } catch (e) {
      print('getListFamilyItem: $e');
    }
  }

  Future<String?> getInternalCodeItem(String description) async {
    try {
      var returnString;
      var sql = 'SELECT F5CODPRO FROM IF5PLA WHERE F5NOMPRO = "$description"';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      results.forEach((row) {
        returnString = row[0];
      });
      return returnString;
    } catch (e) {
      print('getInternalCodeItem: $e');
      return null;
    }
  }

  Future<String?> getDescriptionItem(String externalCode) async {
    try {
      var returnString;
      var sql = 'SELECT F5NOMPRO FROM IF5PLA WHERE F5BARRAS = "$externalCode"';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      results.forEach((row) {
        returnString = row[0];
      });
      return returnString;
    } catch (e) {
      print('getDescriptionItem: $e');
      return null;
    }
  }

  Future<List<String>?> getListDescriptionItem() async {
    try {
      List<String> listDescription = [];
      var sql = 'SELECT F5NOMPRO FROM IF5PLA';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      if (results.isNotEmpty) {
        for (var item in results) {
          listDescription.add(item[0]);
        }
      }
      return listDescription;
    } catch (e) {
      print('getListDescriptionItem: $e');
    }
  }

  Future<bool?> existsInternalCodeItem(String description) async {
    try {
      String? internalCode = await getInternalCodeItem(description);
      if (internalCode != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('existsInternalCodeItem: $e');
      return false;
    }
  }

  Future<void> setExternalCodeItem(
      String description, String externalCode) async {
    try {
      var sql =
          'UPDATE IF5PLA SET F5BARRAS = "$externalCode" WHERE F5NOMPRO = "$description"';
      var db = await Mysql().getConnection();
      await db.query(sql);
    } catch (e) {
      print('setExternalCodeItem: $e');
    }
  }

  Future<double?> getPriceItem(String externalCode) async {
    try {
      var returnDouble;
      var db = await Mysql().getConnection();
      var sql = 'SELECT F5PRECIO FROM IF5PLA WHERE F5BARRAS = "$externalCode"';
      var results = await db.query(sql);
      results.forEach((row) {
        returnDouble = row[0];
      });
      return returnDouble;
    } catch (e) {
      print('getPriceItem: $e');
    }
  }

  Future<void> setPriceItem(String externalCode, String price) async {
    try {
      var sql =
          'UPDATE IF5PLA SET F5PRECIO = "$price" WHERE F5BARRAS = "$externalCode"';
      var db = await Mysql().getConnection();
      await db.query(sql);
    } catch (e) {
      print('setPriceItem: $e');
    }
  }

  Future<String?> getFamilyItem(String family) async {
    try {
      var returnString;
      var sql = 'SELECT F7CODCON FROM SF7NIVEL01 WHERE F7DESCON = "$family"';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      results.forEach((row) {
        returnString = row[0];
      });
      return returnString;
    } catch (e) {
      print('getFamilyItem: $e');
    }
  }

  Future<String?> createNewInternalCodeItem(String family,
      [int length = 4]) async {
    try {
      var returnString;
      var random = Random.secure();
      var values = List<int>.generate(length, (i) => random.nextInt(26));
      var id1 = await getFamilyItem(family);
      var id2 = String.fromCharCodes(values.map((index) => index + 65));
      returnString = '$id1$id2';
      return returnString;
    } catch (e) {
      print('createRandomInternalCodeItem: $e');
    }
  }

  Future<String?> getInternalCodeItemInternalCode(String internalCode) async {
    try {
      var returnString;
      var sql = 'SELECT F5CODPRO FROM IF5PLA WHERE F5CODPRO = "$internalCode"';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      results.forEach((row) {
        returnString = row[0];
      });
      return returnString;
    } catch (e) {
      print('existsInternalCodeItemInternalCode: $e');
    }
  }

  Future<bool?> existsInternalCodeItemInternalCode(String internalCode) async {
    try {
      String? internalCodeItem =
          await getInternalCodeItemInternalCode(internalCode);
      if (internalCodeItem != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('existsInternalCodeItemInternalCode: $e');
      return false;
    }
  }

  Future<void> insertNewItem(String externalCode, String internalCode,
      String description, String user, String stock, String price) async {
    try {
      DateTime? dateTime = await DateTimeMethods().getDateTimeYYYYMMDDHHMMSS();
      var sql =
          'INSERT INTO IF5PLA (F5BARRAS, F5CODPRO, F5NOMPRO, F5USERING, F5FECING, F5CANTIDAD, F5PRECIO) VALUES ("$externalCode", "$internalCode", "$description", "$user", "$dateTime", "$stock", "$price")';
      var db = await Mysql().getConnection();
      await db.query(sql);
    } catch (e) {
      print('insertNewItem: $e');
    }
  }

  String firstUp(String s) => s[0].toUpperCase() + s.substring(1);

  //Precio de soles a letras
  String convertirLetrasSoles(String precio) {
    String precioLetras = '';
    String precioString = precio;
    List<String> precioList = precioString.split('.');
    String precioEntero = precioList[0];
    String precioDecimal = precioList[1];
    if (precioEntero.length == 1) {
      precioEntero = '00' + precioEntero;
    } else if (precioEntero.length == 2) {
      precioEntero = '0' + precioEntero;
    }
    if (precioDecimal.length == 1) {
      precioDecimal = precioDecimal + '0';
    }
    precioLetras = precioEntero + '.' + precioDecimal;
    return precioLetras;
  }

//Precio de dolares a letras
  String convertirLetrasDolares(String precio) {
    String precioLetras = '';
    String precioString = precio;
    List<String> precioList = precioString.split('.');
    String precioEntero = precioList[0];
    String precioDecimal = precioList[1];
    if (precioEntero.length == 1) {
      precioEntero = '00' + precioEntero;
    } else if (precioEntero.length == 2) {
      precioEntero = '0' + precioEntero;
    }
    if (precioDecimal.length == 1) {
      precioDecimal = precioDecimal + '0';
    }
    precioLetras = precioEntero + '.' + precioDecimal;
    return precioLetras;
  }
}
