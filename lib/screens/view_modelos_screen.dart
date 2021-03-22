import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/screens/model_viewer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ViewModelosScreen extends StatefulWidget {
  final String modeloSupLink;
  final String modeloInfLink;

  ViewModelosScreen({this.modeloSupLink, this.modeloInfLink});

  @override
  _ViewModelosScreenState createState() => _ViewModelosScreenState();
}

class _ViewModelosScreenState extends State<ViewModelosScreen> {
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
            height: 1500,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 760 ? 100 : 8,
              vertical: 50,
            ),
            child: ModelViewer(
              modeloSupLink: widget.modeloSupLink,
              modeloInfLink: widget.modeloInfLink,
            ),
          ),
        ),
      ),
    );
  }
}
