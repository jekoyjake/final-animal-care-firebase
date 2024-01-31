import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Generate extends StatelessWidget {
  const Generate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ElevatedButton(
            onPressed: () {
              generatePdf();
            },
            child: Text("Press Me")),
      ),
    );
  }
}

Future<Uint8List> _readAssetBytes(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}

Future<void> generatePdf() async {
  final pdf = pw.Document();

  final Uint8List lagunaLogoBytes =
      await _readAssetBytes('assets/lagunalogo.png');
  final Uint8List rxImageBytes = await _readAssetBytes('assets/rx.png');

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          width: 600,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2.0),
            borderRadius: pw.BorderRadius.circular(10.0),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Image(pw.MemoryImage(lagunaLogoBytes)),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text("Patient Name: "),
                          pw.Text(
                            "petname", // Replace with actual pet name
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 150),
                      pw.Row(
                        children: [
                          pw.Text("Date: "),
                          pw.Text(
                            "prescription.prescriptionDate", // Replace with actual date
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.SizedBox(width: 30),
                  pw.Image(pw.MemoryImage(rxImageBytes)),
                  pw.SizedBox(width: 70),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Diagnosis "),
                          pw.Text(
                            "prescription.dianosis", // Replace with actual diagnosis
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Medication Name: "),
                          pw.Text(
                            "prescription.medicationName", // Replace with actual medication name
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Dosage: "),
                          pw.Text(
                            "prescription.dosage", // Replace with actual dosage
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Frequency: "),
                          pw.Text(
                            "prescription.frequency", // Replace with actual frequency
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 50),
                      pw.Text("Provincial Veterinarian Signature"),
                    ],
                  ),
                ],
              ),
              /*    pw.SizedBox(height: 20),
              pw.ElevatedButton.icon(
                onPressed: () async {
                  // Implement your PDF generation and download logic here
                  // Placeholder: Generate a PDF and download
                  final pdfFile = File('prescription.pdf');
                  await pdfFile.writeAsBytes(await pdf.save());
                  print('PDF Generated: ${pdfFile.path}');
                },
                icon: pw.Icon(Icons.picture_as_pdf as pw.IconData),
                label: pw.Text('Print PDF Prescription'),
                style: pw.ElevatedButton.styleFrom(
                  backgroundColor: PdfColors.blue,
                ),
              ), */
            ],
          ),
        );
      },
    ),
  );
}
