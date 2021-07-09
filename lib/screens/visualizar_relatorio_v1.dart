import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class VisualizarRelatorioV1 extends StatefulWidget {
  final String url;

  VisualizarRelatorioV1({this.url = ''});

  @override
  _VisualizarRelatorioV1State createState() => _VisualizarRelatorioV1State();
}

class _VisualizarRelatorioV1State extends State<VisualizarRelatorioV1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SfPdfViewer.network(
          widget.url,
          enableDoubleTapZooming: true,
          enableTextSelection: true,
          enableDocumentLinkAnnotation: true,
        ),
      ),
    );
  }
}
