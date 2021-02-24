import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ViewImagesScreen extends StatelessWidget {
  final String imgUrl;

  ViewImagesScreen({this.imgUrl});

  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    if (!authStore.isAuth) {
      return LoginScreen();
    }
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: InteractiveViewer(
            panEnabled: true, // Set it to false to prevent panning.
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imgUrl,
              width: MediaQuery.of(context).size.width,
              //height: 200,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                return loadingProgress == null
                    ? child
                    : LinearProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}
