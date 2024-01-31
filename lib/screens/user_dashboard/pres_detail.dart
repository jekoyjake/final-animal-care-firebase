import 'package:animalcare/models/prescription.dart';

import 'package:flutter/material.dart';

class PrescriptionDetail extends StatelessWidget {
  final Prescription prescription;
  final String petname;

  const PrescriptionDetail(
      {super.key, required this.prescription, required this.petname});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Prescription Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SingleChildScrollView(
              child: !isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/lagunalogo.png",
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(width: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Text("Patient Name: "),
                                Text(
                                  petname,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 150),
                            Row(
                              children: [
                                const Text("Date: "),
                                Text(
                                  prescription.prescriptionDate,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 30),
                            Image.asset(
                              "assets/rx.png",
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(width: 70),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("Diagnosis "),
                                    Text(
                                      prescription.dianosis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("Medication Name: "),
                                    Text(
                                      prescription.medicationName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("Dosage: "),
                                    Text(
                                      prescription.dosage,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("Frequency: "),
                                    Text(
                                      prescription.frequency,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 50),
                                const Text("Provincial Veterinarian Signature"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement your print functionality here
                          },
                          child: const Text('Print Prescription'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              "assets/lagunalogo.png",
                              width: 200,
                              height: 200,
                            ),
                            const Text("Patient Name: "),
                            Text(
                              petname,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 150),
                            const Text("Date: "),
                            Text(
                              prescription.prescriptionDate,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Diagnosis "),
                            Text(
                              prescription.dianosis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Medication Name: "),
                            Text(
                              prescription.medicationName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Dosage: "),
                            Text(
                              prescription.dosage,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Frequency: "),
                            Text(
                              prescription.frequency,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 30),
                            Image.asset(
                              "assets/rx.png",
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(width: 30),
                            const Text("Provincial-Veterinarian-Signature"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement your print functionality here
                          },
                          child: const Text('Print Prescription'),
                        ),
                      ],
                    ),
            ),
          ),
        ));
  }
}

/* Future<void> generatePdf() async {
  final pdf = pw.Document();

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
                  pw.Image(
                    pw.MemoryImage(
                        File('assets/lagunalogo.png').readAsBytesSync()),
                    width: 200,
                    height: 200,
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text("Patient Name: "),
                          pw.Text(
                            "John Doe", // Replace with actual patient name
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
                            "2024-01-30", // Replace with actual date
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
                  pw.Image(
                    pw.MemoryImage(File('assets/rx.png').readAsBytesSync()),
                    width: 100,
                    height: 100,
                  ),
                  pw.SizedBox(width: 70),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Diagnosis "),
                          pw.Text(
                            "Some diagnosis", // Replace with actual diagnosis
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
                            "Medicine XYZ", // Replace with actual medication name
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
                            "2 tablets", // Replace with actual dosage
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
                            "Twice daily", // Replace with actual frequency
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
              pw.SizedBox(height: 20),
              // Custom-styled button
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(5.0),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.PdfLogo(),
                    pw.Text('Print PDF Prescription',
                        style: pw.TextStyle(color: PdfColors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Save the PDF file
  final file = File('example.pdf');
  await file.writeAsBytes(await pdf.save());
} */
