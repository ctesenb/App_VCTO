import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:restart_app/restart_app.dart';

class PdfView extends StatelessWidget {
  final pw.Document doc;
  final String title;
  const PdfView({Key? key, required this.doc, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_outlined),
          ),
          title: Text(title),
          centerTitle: true,
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Restart.restartApp();
                  },
                  child: Row(
                    children: const [
                      Text('Reiniciar App',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.refresh, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: PdfPreview(
          build: (fortmat) => doc.save(),
          allowSharing: true,
          allowPrinting: true,
          initialPageFormat: PdfPageFormat.a4,
          pdfFileName: '$title.pdf',
        ));
  }
}
