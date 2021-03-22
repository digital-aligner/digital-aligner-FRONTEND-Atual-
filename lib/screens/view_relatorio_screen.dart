import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ViewRelatorioScreen extends StatefulWidget {
  final String relatorioUrl;
  ViewRelatorioScreen({this.relatorioUrl});

  @override
  _ViewRelatorioScreenState createState() => _ViewRelatorioScreenState();
}

class _ViewRelatorioScreenState extends State<ViewRelatorioScreen> {
  PdfController pdfController;
  bool firstFetch = true;

  Future<dynamic> _fetchRelatorioPDF(String url) async {
    var response = await http.get(Uri.parse(url));
    setState(() {
      firstFetch = false;
      pdfController = PdfController(
        document: PdfDocument.openData(response.bodyBytes),
      );
    });
    return pdfController;
  }

  Widget _relatorioView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width - 60 < 100
              ? 100
              : MediaQuery.of(context).size.width - 60,
          height: MediaQuery.of(context).size.height - 200 < 250
              ? 200
              : MediaQuery.of(context).size.height - 200,
          child: PdfView(
            pageSnapping: true,
            controller: pdfController,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                pdfController.previousPage(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              icon: Icon(Icons.arrow_back),
              label: Text('Anterior'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                pdfController.nextPage(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                );
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Próximo'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstFetch) {
      _fetchRelatorioPDF(widget.relatorioUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    if (!authStore.isAuth) {
      return LoginScreen();
    }
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                firstFetch
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      )
                    : _relatorioView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
