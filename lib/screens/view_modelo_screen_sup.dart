import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import 'model_viewer_sup.dart';

class ViewModelosScreenSup extends StatefulWidget {
  final String modeloSupLink;

  ViewModelosScreenSup({this.modeloSupLink});

  @override
  _ViewModelosScreenSupState createState() => _ViewModelosScreenSupState();
}

class _ViewModelosScreenSupState extends State<ViewModelosScreenSup> {
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
            child: ModelViewerSup(
              modeloSupLink: widget.modeloSupLink,
            ),
          ),
        ),
      ),
    );
  }
}
