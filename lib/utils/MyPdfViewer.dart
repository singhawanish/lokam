import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class MyPdfViewer extends StatefulWidget {
  final String base64Pdf;
  MyPdfViewer({@required this.base64Pdf});
  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  String errorMessage = '';
  Uint8List pdfData; // Store the PDF data as bytes

  @override
  void initState() {
    super.initState();
    _loadPdfData();
  }

  void _loadPdfData() {
    // Decode the base64 string into bytes
    pdfData = base64Decode(widget.base64Pdf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('PDF Viewer'),
      ),
      body: Stack(
        children: [
          if (pdfData != null) // Display the PDF if data is available
            PDFView(
              pdfData: pdfData, // Provide the PDF data here
              fitEachPage: true,
              fitPolicy: FitPolicy.BOTH,
              onRender: (_pages) {
                setState(() {
                  totalPages = _pages;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
              },
              onViewCreated: (PDFViewController vc) {
                // You can handle the PDFViewController here if needed
              },
            ),
          if (pdfData ==
              null) // Display a loading indicator if data is being loaded
            Center(
              child: CircularProgressIndicator(),
            ),
          if (errorMessage
              .isNotEmpty) // Display an error message if an error occurs
            Center(
              child: Text(errorMessage),
            ),
        ],
      ),
    );
  }
}
