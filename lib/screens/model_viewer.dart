import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ModelViewer extends StatefulWidget {
  @override
  _ModelViewerState createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer>
    with AutomaticKeepAliveClientMixin {
  static ValueKey key = ValueKey('key_0');
  static ValueKey key1 = ValueKey('key_1');
  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    if (!authStore.isAuth) {
      return LoginScreen();
    }
    super.build(null);
    return Column(children: <Widget>[
      //Modelos digitais
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 50,
        ),
        child: Column(
          children: [
            const Center(child: const Text('Modelo Superior')),
            Card(
              elevation: 0,
              child: EasyWebView(
                key: key,
                src:
                    'https://digital-aligner-e762d.web.app/stl_viewer/modelo_sup_viewer.html',
                isHtml: false, // Use Html syntax
                isMarkdown: false, // Use markdown syntax
                convertToWidgets: false, // Try to convert to flutter widgets
                onLoaded: () => null,
                width: 2000,
                height: 500,
              ),
            ),
          ],
        ),
      ),
      Container(
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
                key: key1,
                src:
                    'https://digital-aligner-e762d.web.app/stl_viewer/modelo_inf_viewer.html',
                isHtml: false, // Use Html syntax
                isMarkdown: false, // Use markdown syntax
                convertToWidgets: false, // Try to convert to flutter widgets
                onLoaded: () => null,
                width: 2000,
                height: 500,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
