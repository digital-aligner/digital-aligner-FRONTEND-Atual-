import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/midia_screen/youtube_videos.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentoriaBrasil extends StatefulWidget {
  static const routeName = '/mentoria-brasil';
  @override
  _MentoriaBrasilState createState() => _MentoriaBrasilState();
}

class _MentoriaBrasilState extends State<MentoriaBrasil> {
  bool _blockVideos = false;

  Widget _buildVideos() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        YoutubeVideos(
          videosId: 'FqKKvi5TKwo',
        ),
      ],
    );
  }

  Widget _buildHeaders() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Center(
          child: Text(
            'Mentoria Brasil',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ],
    );
  }

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
      onDrawerChanged: (value) {
        setState(() {
          _blockVideos = value;
        });
      },
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            padding: sWidth > 768
                ? const EdgeInsets.symmetric(horizontal: 100)
                : const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                _buildHeaders(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
