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
        print(constraints.maxWidth);
        return AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/logos/da-logo-branco.png',
            height: 35,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue[900], Theme.of(context).primaryColor],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          elevation: 0,
        );
      },
    );
  }
}
