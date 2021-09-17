import 'package:digital_aligner_app/screens/criar_nova_senha.dart';
import 'package:digital_aligner_app/screens/primeiro_cadastro.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/login_form_provider.dart';
import '../providers/auth_provider.dart';
import 'administrativo/gerenciar_pacientes_v1.dart';
import 'recuperar_senha.dart';

import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  final bool showLoginMessage;
  final Map<String, String> queryStringsForPasswordReset;
  LoginScreen({
    this.queryStringsForPasswordReset = const {},
    this.showLoginMessage = false,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _blockUi = false;
  bool _cadastroScreenOpen = false;

  //VERSION UI TEXT
  String _version = 'V1.91';

  Future<void> _submit(LoginFormProvider _loginStore, context) async {
    setState(() => _isLoading = true);

    if (_loginStore.validateInput()) {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_loginStore.email, _loginStore.senha)
          .then(
        (mensagem) {
          if (mensagem.containsKey('error')) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 8),
                content: Text(
                  mensagem['message'].toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
            _loginStore.setSenha('');
            setState(() => _isLoading = false);
          } else {
            html.window.location.reload();
          }
          //setState(() => _isLoading = false);
        },
      );
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(
          'Informe dados completos',
          textAlign: TextAlign.center,
        ),
      ));
      setState(() => _isLoading = false);
    }
  }

  Widget _form({
    BuildContext? context,
    bool isMobile = false,
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    final LoginFormProvider _loginStore =
        Provider.of<LoginFormProvider>(context!);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          )
        : Form(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 10,
              ),
              height: 1200,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[],
                  ),
                  TextFormField(
                    initialValue: _loginStore.email,
                    onChanged: (value) {
                      _loginStore.setEmail(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Insira seu e-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      _submit(_loginStore, context);
                    },
                    obscureText: true,
                    initialValue: _loginStore.senha,
                    onChanged: (value) {
                      _loginStore.setSenha(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Insira sua senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        const SizedBox(
                          height: 60,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecuperarSenha(),
                              ),
                            );
                          },
                          child: Text('Recuperar senha'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _submit(_loginStore, context);
                      },
                      child: const Text(
                        'Entrar',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (constraints.maxWidth > 768)
                    Expanded(
                      child: Container(),
                    )
                  else
                    const SizedBox(height: 20),
                  //novo cadastro - Brasil
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _cadastroScreenOpen = true;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrimeiroCadastro(),
                          ),
                        ).then((_) {
                          _cadastroScreenOpen = false;
                        });
                      },
                      child: const Text(
                        'Cadastro Brasil',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _cadastroScreenOpen = true;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrimeiroCadastro(
                              isPortugal: true,
                            ),
                          ),
                        ).then((_) {
                          _cadastroScreenOpen = false;
                        });
                      },
                      child: const Text(
                        'Cadastro Portugal',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _layoutDesktop(
    BuildContext? ctx,
    BoxConstraints? c,
  ) {
    // Outer card with shadow
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 20,
        child: Container(
          height: 500,
          width: 768,
          // Row - holds the left and right content
          child: Row(
            children: [
              // Left content (blue side)
              Expanded(
                flex: 3,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Image(
                                image: new AssetImage(
                                  'logos/marca_padrao.png',
                                ),
                                width: 150,
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                'Bem-Vindo',
                                style: TextStyle(
                                  color: Color.fromRGBO(83, 86, 90, 1),
                                  fontSize: 30,
                                  fontFamily: 'Houschka',
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Aqui você acessa a plataforma dos alinhadores estéticos revolucionários da Digital Aligner. Se precisar de ajuda, clique numa das opções abaixo.',
                                style: TextStyle(
                                  color: Color.fromRGBO(83, 86, 90, 1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: const Text(
                            'PRECISA DE AJUDA?',
                            style: const TextStyle(
                              color: Color.fromRGBO(83, 86, 90, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            IconButton(
                              tooltip: 'Whatsapp',
                              onPressed: () {
                                /*
                                  html.window.open(
                                      'https://api.whatsapp.com/send?phone=5581992777557&text=Ol%C3%A1,%20preciso%20de%20ajuda%20com%20o%20site%20do%20Digital%20Aligner...',
                                      'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.send_to_mobile),
                            ),
                            IconButton(
                              tooltip: 'Email',
                              onPressed: () {
                                /*html.window.open(
                                      'contato@digitalaligner.com.br',
                                      'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.mail),
                            ),
                            IconButton(
                              tooltip: 'Atendimento',
                              onPressed: () {
                                /*html.window
                                      .open('tel:+5581992777557', 'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.phone),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _version,
                          style: TextStyle(
                            color: Color.fromRGBO(83, 86, 90, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                indent: 100,
                endIndent: 100,
                color: Color.fromRGBO(200, 200, 200, 0.5),
              ),
              //Right content
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _form(context: ctx, isMobile: false, constraints: c!),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _layoutMobile(
    BuildContext ctx,
    BoxConstraints c,
  ) {
    // Outer card with shadow
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 20,
        child: Container(
          height: 1300,
          width: 500,
          // column - holds the top and bottom content
          child: Column(
            children: [
              // top content (blue side)
              Expanded(
                flex: 2,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              new Image(
                                image: new AssetImage(
                                  'logos/marca_padrao.png',
                                ),
                                width: 150,
                              ),
                              const SizedBox(height: 100),
                              const Text(
                                'Bem-Vindo',
                                style: TextStyle(
                                  color: Color.fromRGBO(83, 86, 90, 1),
                                  fontSize: 50,
                                  fontFamily: 'Houschka',
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Aqui você acessa a plataforma dos alinhadores estéticos revolucionários da Digital Aligner. Se precisar de ajuda, clique numa das opções abaixo.',
                                style: TextStyle(
                                  color: Color.fromRGBO(83, 86, 90, 1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: const Text(
                            'PRECISA DE AJUDA?',
                            style: const TextStyle(
                              color: Color.fromRGBO(83, 86, 90, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            IconButton(
                              tooltip: 'Whatsapp',
                              onPressed: () {
                                /*
                                  html.window.open(
                                      'https://api.whatsapp.com/send?phone=5581992777557&text=Ol%C3%A1,%20preciso%20de%20ajuda%20com%20o%20site%20do%20Digital%20Aligner...',
                                      'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.send_to_mobile),
                            ),
                            IconButton(
                              tooltip: 'Email',
                              onPressed: () {
                                /*html.window.open(
                                      'contato@digitalaligner.com.br',
                                      'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.mail),
                            ),
                            IconButton(
                              tooltip: 'Atendimento',
                              onPressed: () {
                                /*html.window
                                      .open('tel:+5581992777557', 'new tab');*/
                              },
                              color: Color.fromRGBO(83, 86, 90, 1),
                              icon: const Icon(Icons.phone),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _version,
                          style: TextStyle(
                            color: Color.fromRGBO(83, 86, 90, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                indent: 100,
                endIndent: 100,
                color: Color.fromRGBO(200, 200, 200, 0.5),
              ),
              //bottom content
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _form(context: ctx, isMobile: true, constraints: c),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.showLoginMessage) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5),
          content: const Text('Por favor realize login.'),
        ));
      }

      if (Navigator.canPop(context) && !_cadastroScreenOpen) {
        Navigator.pop(context);
      }

      if (authStore.isAuth) {
        if (authStore.role == 'Credenciado') {
          Navigator.of(context).pushReplacementNamed(
            GerenciarPacientesV1.routeName,
            arguments: ScreenArguments(
              title: 'Meus Pacientes',
              message: '',
            ),
          );
        } else if (authStore.role == 'Administrador' ||
            authStore.role == 'Gerente') {
          Navigator.of(context).pushReplacementNamed(
            GerenciarPacientesV1.routeName,
            arguments: ScreenArguments(
              title: 'Gerenciar Pacientes',
              message: '',
            ),
          );
        }
      } //If logged out, autologin failed and passed query strings for rest, show reset ui
      else if (widget.queryStringsForPasswordReset.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CriarNovaSenha(
              queryStringsForPasswordReset: widget.queryStringsForPasswordReset,
            ),
          ),
        );
      }
    });

    double height = MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AbsorbPointer(
        absorbing: _blockUi,
        child: Scrollbar(
          thickness: 15,
          isAlwaysShown: width < 768 ? true : false,
          showTrackOnHover: width < 768 ? true : false,
          child: Stack(
            children: <Widget>[
              //Background image
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: new AssetImage('backgrounds/background_azul.png'),
                  ),
                ),
              ),
              // signin/login form
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    return _layoutDesktop(context, constraints);
                  } else {
                    return SingleChildScrollView(
                      child: _layoutMobile(context, constraints),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
