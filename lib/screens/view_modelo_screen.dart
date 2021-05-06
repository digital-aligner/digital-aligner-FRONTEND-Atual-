import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:easy_web_view/easy_web_view.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import 'login_screen.dart';

class ViewModeloScreen extends StatefulWidget {
  final String title;
  final String modelUrl;
  final String viewer3dUrl;
  final ValueKey key;

  ViewModeloScreen({
    this.title,
    this.modelUrl,
    this.viewer3dUrl,
    this.key,
  });

  @override
  _ViewModeloScreenState createState() => _ViewModeloScreenState();
}

class _ViewModeloScreenState extends State<ViewModeloScreen> {
  Widget _modelo3d({
    String title,
    String modelUrl,
    String viewer3dUrl,
    ValueKey key,
  }) {
    //Modelos digitais
    if (modelUrl == null) {
      return Center(
        child: const Text('Sem modelo'),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 50,
        ),
        child: Column(
          children: [
            Center(child: Text(title)),
            Card(
              elevation: 0,
              child: EasyWebView(
                key: key,
                src: viewer3dUrl,
                isHtml: false, // Use Html syntax
                isMarkdown: false, // Use markdown syntax
                convertToWidgets: false, // Try to convert to flutter widgets
                onLoaded: () => null,
                width: 800,
                height: 500,
              ),
            ),
            Link(
                uri: Uri.parse(modelUrl),
                builder: (context, followLink) {
                  return TextButton(
                    onPressed: followLink,
                    child: const Text('Baixar'),
                  );
                }),
          ],
        ),
      );
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
            height: 800,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 760 ? 100 : 8,
              vertical: 50,
            ),
            child: _modelo3d(
              key: widget.key,
              modelUrl: widget.modelUrl,
              title: widget.title,
              viewer3dUrl: widget.viewer3dUrl,
            ),
          ),
        ),
      ),
    );
  }
}
