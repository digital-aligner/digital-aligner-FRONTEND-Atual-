import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/screens/criar_nova_senha.dart';
import 'package:digital_aligner_app/screens/primeiro_cadastro.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/login_form_provider.dart';
import '../providers/auth_provider.dart';
import 'meus_pacientes.dart';
import 'recuperar_senha.dart';

class LoginScreen extends StatefulWidget {
  final Map<String, String> queryStringsForPasswordReset;
  LoginScreen({this.queryStringsForPasswordReset});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _blockUi = true;
  bool _firstRun = true;

  Future<void> _submit(_loginStore, context) async {
    setState(() => _isLoading = true);

    if (_loginStore.validateInput()) {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_loginStore.email, _loginStore.senha)
          .then(
        (mensagem) {
          if (mensagem != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 8),
              content: Text(
                mensagem.toString(),
                textAlign: TextAlign.center,
              ),
            ));
          }

          setState(() => _isLoading = false);
        },
      );
      _loginStore.setEmail('');
      _loginStore.setSenha('');
    } else {
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
    BuildContext context,
    bool isMobile,
    BoxConstraints constraints,
  }) {
    //final double _desktopHeight = 500;
    //final double _mobileHeight = 450;
    final LoginFormProvider _loginStore =
        Provider.of<LoginFormProvider>(context);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          )
        : Form(
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                height: 500,
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
                          'ENTRAR',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrimeiroCadastro(),
                            ),
                          );
                        },
                        child: const Text(
                          'NOVO CADASTRO',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _layoutDesktop(
    BuildContext ctx,
    BoxConstraints c,
  ) {
    final cor = Theme.of(ctx).primaryColor;
    return Center(
      child: SingleChildScrollView(
        // Outer card with shadow
        child: Card(
          elevation: 10,
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
                    elevation: 10,
                    margin: EdgeInsets.all(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cor, Colors.indigo[700]],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Column(
                              children: [
                                new Image(
                                  image:
                                      new AssetImage('assets/logos/logo.png'),
                                  height: 70.0,
                                  width: 70.0,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Bem-Vindo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontFamily: 'BigNoodleTitling',
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Aqui você acessa a plataforma dos alinhadores estéticos revolucionários da Digital Aligner. Se precisar de ajuda, clique numa das opções abaixo.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Quicksand Light',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(
                              'PRECISA DE AJUDA?',
                              style: TextStyle(
                                color: Colors.white,
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
                                color: Colors.white,
                                icon: const Icon(Icons.send_to_mobile),
                              ),
                              IconButton(
                                tooltip: 'Email',
                                onPressed: () {
                                  /*html.window.open(
                                      'contato@digitalaligner.com.br',
                                      'new tab');*/
                                },
                                color: Colors.white,
                                icon: const Icon(Icons.mail),
                              ),
                              IconButton(
                                tooltip: 'Atendimento',
                                onPressed: () {
                                  /*html.window
                                      .open('tel:+5581992777557', 'new tab');*/
                                },
                                color: Colors.white,
                                icon: const Icon(Icons.phone),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Right content
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _form(context: ctx, isMobile: false, constraints: c),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _layoutMobile(
    BuildContext ctx,
    BoxConstraints c,
  ) {
    final cor = Theme.of(ctx).primaryColor;
    return Center(
      child: SingleChildScrollView(
        // Outer card with shadow
        child: Card(
          elevation: 10,
          child: Container(
            height: 768,
            width: 500,
            // Row - holds the left and right content
            child: Column(
              children: [
                // top content (blue side)
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 10,
                    margin: EdgeInsets.all(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cor, Colors.indigo[700]],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Column(
                              children: [
                                new Image(
                                  image:
                                      new AssetImage('assets/logos/logo.png'),
                                  height: 70.0,
                                  width: 70.0,
                                ),
                                SizedBox(height: 5),
                                const Text(
                                  'Bem-Vindo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontFamily: 'BigNoodleTitling',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Aqui você acessa a plataforma dos alinhadores estéticos revolucionários da Digital Aligner. Se precisar de ajuda, clique numa das opções abaixo.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Quicksand Light',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: const Text(
                              'PRECISA DE AJUDA?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authStore = Provider.of<AuthProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_firstRun) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: const Text('Entrando...'),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (authStore.isAuth) {
          Navigator.of(context).pushReplacementNamed(MeusPacientes.routeName);
          return;
        } else {
          //Unblock ui for login
          setState(() {
            _blockUi = false;
            _firstRun = false;
          });
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1500),
              content: const Text('Por favor favor entre na sua conta.'),
            ),
          );

          //If logged out, autologin failed and passed query strings for rest, show reset ui
          if (widget.queryStringsForPasswordReset.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CriarNovaSenha(
                  queryStringsForPasswordReset:
                      widget.queryStringsForPasswordReset,
                ),
              ),
            );
          }
        }
      }
    });

    return Scaffold(
      body: AbsorbPointer(
        absorbing: _blockUi,
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: new AssetImage('assets/backgrounds/login_screen.jpg'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  'V1.0',
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  return _layoutDesktop(context, constraints);
                } else {
                  return _layoutMobile(context, constraints);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
