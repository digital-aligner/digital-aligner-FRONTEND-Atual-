import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class ModelViewerInf extends StatefulWidget {
  final String modeloInfLink;

  ModelViewerInf({this.modeloInfLink});

  @override
  _ModelViewerInfState createState() => _ModelViewerInfState();
}

class _ModelViewerInfState extends State<ModelViewerInf> {
  static ValueKey key = ValueKey('key_1');
  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    if (!authStore.isAuth) {
      return LoginScreen();
    }

    return Column(children: <Widget>[
      //Modelos digitais
      widget.modeloInfLink == null
          ? Center(
              child: const Text('Sem modelo inferior'),
            )
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 50,
              ),
              child: Column(
                children: [
                  const Center(child: const Text('Modelo Inferior')),
                  Card(
                    elevation: 0,
                    child: EasyWebView(
                      key: key,
                      src:
                          'https://digital-aligner-e0e72.web.app/stl_viewer/modelo_inf_viewer.html',
                      isHtml: false, // Use Html syntax
                      isMarkdown: false, // Use markdown syntax
                      convertToWidgets:
                          false, // Try to convert to flutter widgets
                      onLoaded: () => null,
                      width: 2000,
                      height: 500,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await launch(widget.modeloInfLink);
                    },
                    icon: const Icon(Icons.download_done_rounded),
                    label: const Text('Baixar'),
                  ),
                ],
              ),
            ),
    ]);
  }
}
