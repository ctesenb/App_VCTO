import 'dart:ffi';
import 'dart:math';
import 'package:app1c/src/connection/external_connection.dart';
import 'package:app1c/src/services/datetimeMethods.dart';
import 'package:mysql1/mysql1.dart';

class MovementMethods {
  MovementMethods();

  Future<String?> createNewIdMovement(
      String movementType, bool isTicket, bool isBill, bool isProforma,
      [int length = 4]) async {
    try {
      var random = Random.secure();
      var values = List<int>.generate(length, (i) => random.nextInt(26));
      String? id1 = null;
      if (isTicket == true) {
        id1 = 'BO';
      } else if (isBill == true) {
        id1 = 'FA';
      } else if (isProforma == true) {
        id1 = 'PR';
      } else if (movementType == 'Consumo') {
        id1 = 'CO';
      } else if (movementType == 'TrasS') {
        id1 = 'TS';
      } else if (movementType == 'TrasI') {
        id1 = 'TI';
      } else if (movementType == 'Otro') {
        id1 = 'OT';
      } else if (movementType == 'InvF') {
        id1 = 'IF';
      }
      var id2 = String.fromCharCodes(values.map((index) => index + 65));
      return id1!+id2;
    } catch (e) {
      print('createNewIdMovement: $e');
    }
  }

  Future<String?> getIdMovementIdMovement(String idMovement) async {
    try {
      var sql = 'SELECT codigo FROM list_mov WHERE codigo = "$idMovement"';
      var db = await Mysql().getConnection();
      var results = await db.query(sql);
      results.forEach((row) {
        return row[0];
      });
    } catch (e) {
      print('getIdMovement: $e');
    }
  }

  Future<bool?> existsIdMovement(String idMovement) async {
    try {
      String? idMovementItem = await getIdMovementIdMovement(idMovement);
      if (idMovementItem != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('existsIdMovement: $e');
      return false;
    }
  }

  Future<int?> insertMovement(String idMovement, String nameBusiness, String rucClient, String client, String user, String movementType, String totalSoles, String totalDollars, String nameType) async {
    try {
      String? time = await DateTimeMethods().getTime();
      String? date = await DateTimeMethods().getDate();
      var db = await Mysql().getConnection();
      String sql = 'START TRANSACTION;INSERT INTO list_mov (codigo, emisor, rucreceptor, receptor, usuario, hora, fecha, mov, totalsoles, totaldolares, tipo) VALUES ("prueba", "prueba", "prueba", "client", "user", "time", "date", "movementType", "totalSoles", "totalDollars", "nameType");SELECT LAST_INSERT_ID();COMMIT;';
      var results = await db.query(sql);
      results.forEach((row) {
        return row[0];
      });
    } catch (e) {
      print('insertMovement: $e');
    }
  }

  Future<void> insertMovementDetails(String idAutomatico, String codeMov, String reference, String externalCode, String description, String count, String totalPrice) async {
    try {
      var sql = 'INSERT INTO list_vcto (id_mov, code_mov, dato, qr, descrip, cantidad, preciototal) VALUES ("$idAutomatico", "$codeMov", "$reference", "$externalCode", "$description", "$count", "$totalPrice")';
      var db = await Mysql().getConnection();
      await db.query(sql);
    } catch (e) {
      print('insertMovementDetails: $e');
    }
  }
}
