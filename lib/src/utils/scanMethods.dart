import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'alertMethods.dart';

class ScanQBMethods {
  ScanQBMethods();

  Future<String?> scan() async {
    try {
      String scan = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.DEFAULT);
      if (scan == '') {
        return null;
      } else {
        return scan;
      }
    } on PlatformException catch (e) {
      AlertMethods().alertaError('No se ha podido acceder a la camara');
      return null;
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
      AlertMethods().alertaError('Presionaste el botón Atrás antes de escanear algo');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }
}
