import 'package:app1c/src/interfaces/pages/home/logic/model/temp_model.dart';
import 'package:app1c/src/interfaces/pages/home/logic/pref_logic.dart';
import 'package:app1c/src/interfaces/widgets/pdfPreview.dart';
import 'package:app1c/src/services/apiMethods.dart';
import 'package:app1c/src/services/datetimeMethods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfMethods {
  PdfMethods();

  Future<void> createPdfMix(
      String totalSoles,
      String totalDolares,
      String cliente,
      String idMovimiento,
      List<ItemTemp> listaTemporal,
      String tipoPdf) async {
    final doc = pw.Document();
    final ttf = await PdfGoogleFonts.nunitoExtraLight();
    var empresa = await getBusiness();
    var empresaNombre = await getNombre();
    var empresaDireccion = await ApiMethods().getDireccionXRuc(empresa!);
    var hora = await DateTimeMethods().getTime();
    var fecha = await DateTimeMethods().getDate();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(tipoPdf, style: pw.TextStyle(font: ttf, fontSize: 40)),
              ],
            ),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Datos de la Empresa',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Nombre: $empresaNombre',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'RUC: $empresa',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Direccion: $empresaDireccion',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Fecha: $fecha',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Hora: $hora',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Datos del Cliente',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Nombre: $cliente',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Detalle',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Descripción', 'Cantidad', 'Precio Unitario', 'Total'],
              ...listaTemporal.map((item) => [
                    item.description.toString(),
                    item.quantity.toString(),
                    item.price.toString(),
                    item.total.toString(),
                  ]),
            ],
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Totales',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Total Soles: $totalSoles',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Total Dolares: $totalDolares',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Center(
              child: pw.Column(children: [
            pw.BarcodeWidget(
              barcode: pw.Barcode.code39(),
              data: idMovimiento,
              width: 200,
              height: 80,
            ),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text: 'Documento Electronico',
              style: pw.TextStyle(font: ttf, fontSize: 14),
            ),
            pw.Paragraph(
              text: '$empresaNombre - $fecha',
              style: pw.TextStyle(font: ttf, fontSize: 14),
            ),
          ])),
        ],
      ),
    );
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => PdfView(
          doc: doc,
          title: '$tipoPdf-$idMovimiento',
        ),
      ),
    );
  }

  Future<void> createPdf(
      String cliente,
      String idMovimiento,
      List<ItemTemp> listaTemporal,
      String tipoPdf) async {
    final doc = pw.Document();
    final ttf = await PdfGoogleFonts.nunitoExtraLight();
    var empresa = await getBusiness();
    var empresaNombre = await getNombre();
    var empresaDireccion = await ApiMethods().getDireccionXRuc(empresa!);
    var hora = await DateTimeMethods().getTime();
    var fecha = await DateTimeMethods().getDate();
    if(tipoPdf == 'TrasS'){
      tipoPdf = 'Traslado de Salida';
    } else if (tipoPdf == 'InvF'){
      tipoPdf = 'Inventario Fisico';
    } else if (tipoPdf == 'TrasI'){
      tipoPdf = 'Traslado Ingreso';
    }
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(tipoPdf, style: pw.TextStyle(font: ttf, fontSize: 40)),
              ],
            ),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Datos de la Empresa',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Nombre: $empresaNombre',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'RUC: $empresa',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Direccion: $empresaDireccion',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Fecha: $fecha',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Paragraph(
            text: 'Hora: $hora',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Datos del Movimiento',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Nombre: $cliente',
            style: pw.TextStyle(font: ttf, fontSize: 14),
          ),
          pw.Header(
            level: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Detalle',
                    style: pw.TextStyle(font: ttf, fontSize: 20)),
              ],
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Descripción', 'Cantidad'],
              ...listaTemporal.map((item) => [
                    item.description.toString(),
                    item.quantity.toString(),
                  ]),
            ],
          ),
          pw.Center(
              child: pw.Column(children: [
            pw.SizedBox(height: 10),
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: idMovimiento,
              width: 200,
              height: 80,
            ),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text: 'Documento Electronico',
              style: pw.TextStyle(font: ttf, fontSize: 14),
            ),
            pw.Paragraph(
              text: '$empresaNombre - $fecha',
              style: pw.TextStyle(font: ttf, fontSize: 14),
            ),
          ])),
        ],
      ),
    );
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => PdfView(
          doc: doc,
          title: '$tipoPdf-$idMovimiento',
        ),
      ),
    );
  }
}
