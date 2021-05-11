import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'editar_cadastro.dart';

class Perfil extends StatefulWidget {
  static const routeName = '/perfil';
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  CadastroProvider cadastroStore;
  AuthProvider authStore;

/*
  @override
  void deactivate() {
    cadastroStore.clearCadastros();
    cadastroStore.clearSelectedCad();
    super.deactivate();
  }*/

  Widget _userDataUi(List<dynamic> data, double sWidth, double sHeight) {
    return ResponsiveGridRow(
      children: [
        //Name (headline)
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                    data[0]['nome'] + ' ' + data[0]['sobrenome'],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ) ??
                  '',
            ),
          ),
        ),
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Divider(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        //CPF
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' CPF: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(data[0]['username']) ?? '',
            ),
          ),
        ),
        //CRO
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' CRO: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(data[0]['cro_uf'] + ' - ' + data[0]['cro_num']) ?? '',
            ),
          ),
        ),
        //Data nasc.
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Data de Nascimento: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(data[0]['data_nasc'])) ??
                  ''),
            ),
          ),
        ),
        //End. principal
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Endereço Principal (Consultório): '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data[0]['endereco_usuarios'][0]['endereco'] +
                          ', ' +
                          data[0]['endereco_usuarios'][0]['numero']) ??
                      '',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data[0]['endereco_usuarios'][0]['bairro']) ?? '',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data[0]['endereco_usuarios'][0]['cidade'] +
                          ' - ' +
                          data[0]['endereco_usuarios'][0]['uf']) ??
                      '',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data[0]['endereco_usuarios'][0]['cep']) ?? '',
                ),
              ],
            ),
          ),
        ),
        //Tel. fixo
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Telefone Fixo: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(data[0]['telefone']) ?? '',
            ),
          ),
        ),
        //Celular
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Celular: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(data[0]['celular']) ?? '',
            ),
          ),
        ),
        //email
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Email: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(data[0]['email']) ?? '',
            ),
          ),
        ),
      ],
    );
  }

  bool firstFetch = true;

  @override
  Widget build(BuildContext context) {
    //Bug fix: Listen to false. When updating cadastro and notify listener
    //both screens pop. Use onPop method to update instead.
    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);
    cadastroStore.setToken(authStore.token);

    //To fix list not fetching bug
    if (firstFetch) {
      cadastroStore.clearCadastros();
      firstFetch = false;
    }

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;
    int mediaQuerySm = 576;
    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            padding: sWidth > mediaQuerySm
                ? const EdgeInsets.symmetric(horizontal: 100)
                : const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    'Perfil',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                if (cadastroStore.getCadastros() == null)
                  FutureBuilder(
                    future: cadastroStore.fetchMyCadastro(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null) {
                          return Container(
                            child: Text(
                                'Erro ao se connectar. Verifique sua conexão ou tente novamente mais tarde.'),
                          );
                        } else if (snapshot.data[0].containsKey('error')) {
                          return Container(
                            child: Text(
                              snapshot.data[0]['message'] ?? '',
                            ),
                          );
                        } else {
                          return _userDataUi(snapshot.data, sWidth, sHeight);
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      }
                    },
                  ),
                if (cadastroStore.getCadastros() != null)
                  _userDataUi(
                    cadastroStore.getCadastros(),
                    sWidth,
                    sHeight,
                  ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text(
                        "Editar Cadastro",
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(
                          EditarCadastro.routeName,
                        )
                            .then((value) {
                          if (value) {
                            Future.delayed(Duration(microseconds: 600))
                                .then((value) => setState(() {
                                      firstFetch = true;
                                    }));
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      child: const Text(
                        "Alterar Senha",
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                      onPressed: () {
                        //Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
