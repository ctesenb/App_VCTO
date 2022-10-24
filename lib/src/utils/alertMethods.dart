import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertMethods {
  AlertMethods();

  void alertaInfo(String msj) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mensaje de Información'),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle: const TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: Text(msj),
          contentPadding: const EdgeInsets.all(10),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(
            Icons.info,
            color: Colors.orangeAccent,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          scrollable: false,
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }

  void alertaError(String msj) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mensaje de Error'),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: Text(msj),
          contentPadding: const EdgeInsets.all(10),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(
            Icons.info,
            color: Colors.redAccent,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          scrollable: false,
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }

  void mostrarDato(String code) {
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 5,
            title: Text.rich(
              TextSpan(
                text: 'Dato Escaneado: ',
                style: const TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: '$code',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }
}
