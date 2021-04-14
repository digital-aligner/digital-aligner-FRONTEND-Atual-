import 'dart:convert';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../rotas_url.dart';

class CriarNovaSenha extends StatefulWidget {
  final Map<String, String> queryStringsForPasswordReset;

  CriarNovaSenha({this.queryStringsForPasswordReset});

  @override
  _CriarNovaSenhaState createState() => _CriarNovaSenhaState();
}

class _CriarNovaSenhaState extends State<CriarNovaSenha> {
  final _formKey = GlobalKey<FormState>();
  bool _sendingRequest = false;

  String _password;
  String _passwordConfirm;

  Future<Map> _sendPassword() async {
    Map<String, dynamic> _data = {
      'cpf': widget.queryStringsForPasswordReset['user'],
      'new_password': _password,
      'token': widget.queryStringsForPasswordReset['token']
    };

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaRecuperarSenhaNova),
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
            Container(
              height: 80,
              child: TextFormField(
                obscureText: true,
                onSaved: (String value) async {
                  _password = value;
                  Map result = await _sendPassword();
                  if (result.containsKey('statusCode')) {
                    if (result['statusCode'] == 200) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 3),
                          content: Text(result['message']),
                        ),
                      );
                      await Future.delayed(Duration(seconds: 3));
                      html.window.location.reload();
                    }
                  }

                  setState(() {
                    _sendingRequest = false;
                  });
                },
                validator: (value) {
                  if (value.length < 6) {
                    return 'Sua senha deve ter no mínimo 6 characteres';
                  }
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
            const SizedBox(width: 20),
            //password confirm
            Container(
              height: 80,
              child: TextFormField(
                obscureText: true,
                onChanged: (String value) {
                  _passwordConfirm = value;
                },
                validator: (value) {
                  if (value.length < 6) {
                    return 'Sua senha deve ter no mínimo 6 characteres';
                  }
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
            const SizedBox(height: 40),
            Align(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: !_sendingRequest
                      ? () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _sendingRequest = true;
                            });
                            _formKey.currentState.save();
                          }
                        }
                      : null,
                  child: !_sendingRequest
                      ? const Text(
                          'ENVIAR',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      : CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.blue,
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
      body: Scrollbar(
        isAlwaysShown: true,
        thickness: 15,
        showTrackOnHover: true,
        child: Container(
          child: Column(
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
          ),
        ),
      ),
    );
  }
}
