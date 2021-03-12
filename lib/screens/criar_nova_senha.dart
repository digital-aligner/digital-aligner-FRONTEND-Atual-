import 'dart:convert';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../rotas_url.dart';

class CriarNovaSenha extends StatefulWidget {
  final Map<String, String> queryStringsForPasswordReset;

  CriarNovaSenha({this.queryStringsForPasswordReset});

  @override
  _CriarNovaSenhaState createState() => _CriarNovaSenhaState();
}

class _CriarNovaSenhaState extends State<CriarNovaSenha> {
  final _formKey = GlobalKey<FormState>();

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();

  String _password;
  String _passwordConfirm;

  Future<Map> _sendPassword() async {
    Map<String, dynamic> _data = {
      'cpf': widget.queryStringsForPasswordReset['user'],
      'new_password': _password,
      'token': widget.queryStringsForPasswordReset['token']
    };

    var _response = await http.post(
      RotasUrl.rotaRecuperarSenhaNova,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_data),
    );

    Map data = json.decode(_response.body);

    return data;
  }

  Widget _sendPasswordRequestUi() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            //password
            Expanded(
              child: Container(
                height: 80,
                child: TextFormField(
                  obscureText: true,
                  onSaved: (String value) async {
                    _password = value;
                    Map result = await _sendPassword();
                    if (result.containsKey('statusCode')) {
                      if (result['statusCode'] == 200) {
                        Navigator.pop(context);
                      }
                    }
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 5),
                        content: Text(result['message']),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value.length == 0) {
                      return 'Por favor insira sua senha';
                    }
                    if (value != _passwordConfirm) {
                      return 'Senhas não correspondem';
                    }
                    return null;
                  },
                  initialValue: null,
                  decoration: InputDecoration(
                    labelText: 'Senha: *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            //password confirm
            Expanded(
              child: Container(
                height: 80,
                child: TextFormField(
                  obscureText: true,
                  onChanged: (String value) {
                    _passwordConfirm = value;
                  },
                  validator: (value) {
                    if (value.length == 0) {
                      return 'Por favor confirme sua senha';
                    }
                    return null;
                  },
                  initialValue: null,
                  decoration: InputDecoration(
                    labelText: 'Confirme sua senha.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Align(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                    }
                  },
                  child: const Text(
                    'ENVIAR',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: DraggableScrollbar.rrect(
        heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight,
        backgroundColor: ScrollBarWidgetConfig.color,
        alwaysVisibleScrollThumb: false,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 1,
          itemExtent: null,
          itemBuilder: (context, index2) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 50),
                //HEADLINE TEXT
                Center(
                  child: const Text(
                    'ESCOLHA NOVA SENHA',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 50,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _sendPasswordRequestUi(),
              ],
            );
          },
        ),
      ),
    );
  }
}
