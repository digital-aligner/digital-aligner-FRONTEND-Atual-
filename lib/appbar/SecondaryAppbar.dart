import 'package:flutter/material.dart';

class SecondaryAppbar extends StatelessWidget implements PreferredSizeWidget {
  final double _prefferedHeight = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(_prefferedHeight);

  @override
  Widget build(BuildContext context) {
    //final _sWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AppBar(
          leading: BackButton(color: Colors.white),
          //backgroundColor: Color.fromRGBO(83, 86, 90, 1),
          backgroundColor: Color.fromRGBO(89, 203, 232, 1),
          centerTitle: true,
          title: Image.asset('logos/da-logo-branco.png', height: 35),
          //title: Image.asset('logos/logo_branco_azul.png', height: 35),
          elevation: 5,
        );
      },
    );
  }
}
