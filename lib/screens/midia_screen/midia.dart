import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/midia_screen/youtube_videos.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Midia extends StatefulWidget {
  static const routeName = '/midia';
  @override
  _MidiaState createState() => _MidiaState();
}

class _MidiaState extends State<Midia> {
  @override
  Widget build(BuildContext context) {
    CadastroProvider cadastroStore = Provider.of<CadastroProvider>(context);
    AuthProvider authStore = Provider.of<AuthProvider>(context);
    cadastroStore.setToken(authStore.token);

    if (!authStore.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
      );
    }

    final double sWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    'Mídia',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                YoutubeVideos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
