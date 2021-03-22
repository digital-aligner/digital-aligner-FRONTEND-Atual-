import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import 'model_viewer_inf.dart';

class ViewModeloScreenInf extends StatefulWidget {
  final String modeloInfLink;

  ViewModeloScreenInf({this.modeloInfLink});

  @override
  _ViewModeloScreenInfState createState() => _ViewModeloScreenInfState();
}

class _ViewModeloScreenInfState extends State<ViewModeloScreenInf> {
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
            child: ModelViewerInf(
              modeloInfLink: widget.modeloInfLink,
            ),
          ),
        ),
      ),
    );
  }
}
