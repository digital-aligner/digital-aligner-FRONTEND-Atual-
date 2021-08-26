import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/midia_screen/youtube_videos.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentoriaPortugal extends StatefulWidget {
  static const routeName = '/mentoria-portugal';
  @override
  _MentoriaPortugalState createState() => _MentoriaPortugalState();
}

class _MentoriaPortugalState extends State<MentoriaPortugal> {
  bool _blockVideos = false;

  Future<void> _showMyDialog(String link) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vídeo'),
          content: SingleChildScrollView(
            child: YoutubeVideos(
              videosId: link,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideos() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        TextButton(
          onPressed: () => _showMyDialog('FqKKvi5TKwo'),
          child: const Text(
            'Três habilidades fundamentais para trabalhar com alinhadores',
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        TextButton(
          onPressed: () => _showMyDialog('3X0sN8A5KzM'),
          child: const Text(
            'Alternativas de precificação para tratamentos lucrativos com alinhadores',
          ),
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
            'Mentoria Portugal',
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
      onDrawerChanged: (value) {
        setState(() {
          _blockVideos = value;
        });
      },
      drawer: sWidth < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1800,
            padding: sWidth > 768
                ? const EdgeInsets.symmetric(horizontal: 100)
                : const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                _buildHeaders(),
                if (!_blockVideos) _buildVideos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
