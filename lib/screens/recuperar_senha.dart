import 'dart:convert';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../rotas_url.dart';

class RecuperarSenha extends StatefulWidget {
  @override
  _RecuperarSenhaState createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  final _formKey = GlobalKey<FormState>();
  bool _sendingRequest = false;
  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();

  Future<Map> _recoverPasswordRequest(String email) async {
    Map<String, dynamic> _email = {
      'email': email,
    };

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaRecuperarSenha),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_email),
    );

    Map data = json.decode(_response.body);

    return data;
  }

  Widget _recoverPasswordRequestUi() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            TextFormField(
              onSaved: (value) async {
                Map result = await _recoverPasswordRequest(value);
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
                setState(() {
                  _sendingRequest = false;
                });
              },
              validator: (value) {
                return value.length == 0 ? 'Insira seu email' : null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Insira seu e-mail',
                border: OutlineInputBorder(),
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
                          'RECUPERAR ACESSO',
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
        child: ListView.builder(
          itemCount: 1,
          itemExtent: null,
          itemBuilder: (context, index2) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 50),
                //HEADLINE TEXT
                Center(
                  child: const Text(
                    'RECUPERAR ACESSO',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 50,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _recoverPasswordRequestUi(),
              ],
            );
          },
        ),
      ),
    );
  }
}
