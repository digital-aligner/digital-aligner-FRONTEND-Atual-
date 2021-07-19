import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:easy_web_view2/easy_web_view2.dart';
import 'package:flutter/material.dart';

class VisualizarModeloSupV1 extends StatelessWidget {
  const VisualizarModeloSupV1({
    Key? key,
    @required this.key1,
  }) : super(key: key);

  final key1;

  Widget _webViewModeloSuperior() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EasyWebView(
          key: key1,
          src: 'stl_viewer/modelo_sup_viewer.html',
          isHtml: false, // Use Html syntax
          isMarkdown: false, // Use markdown syntax
          convertToWidgets: false, // Try to convert to flutter widgets
          onLoaded: () => null,
          width: 800,
          height: 500,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      drawer: null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: 600,
            width: MediaQuery.of(context).size.width,
            padding: MediaQuery.of(context).size.width < 758
                ? EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.symmetric(horizontal: 50),
            child: _webViewModeloSuperior(),
          ),
        ),
      ),
    );
  }
}
