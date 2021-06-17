import 'package:digital_aligner_app/providers/check_new_data_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pacientes.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pedido.dart';

import 'package:digital_aligner_app/screens/perfil.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';

import '../screens/administrativo/gerenciar_permissoes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/meus_pacientes.dart';
import '../screens/administrativo/gerenciar_cadastro.dart';

import '../providers/auth_provider.dart';

import 'dart:html' as html;

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double _prefferedHeight = 56.0;
  @override
  _MyAppBarState createState() => _MyAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(_prefferedHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  CheckNewDataProvider? checkDataStore;
  AuthProvider? authStore;
  int novosPedidosCount = -1;
  bool timerBlock = false;

  var duration;

  Future<void> checkForNewPedidosTimer() async {
    timerBlock = true;
    while (true) {
      await Future.delayed(Duration(seconds: 60));
      await checkDataStore!.checkNovosPedidoCount();
      if (novosPedidosCount > 0 &&
          novosPedidosCount < checkDataStore!.novosPedidosCount) {
        novosPedidosCount = checkDataStore!.novosPedidosCount;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: const Text(
              'Novo(s) pedido(s) recebido! Atualize a página ou acesse Gerenciar Pedidos.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() async {
    authStore = Provider.of<AuthProvider>(context);
    checkDataStore = Provider.of<CheckNewDataProvider>(context);
    if (authStore!.role == 'Administrador' || authStore!.role == 'Gerente') {
      novosPedidosCount = checkDataStore!.novosPedidosCount;
      if (checkDataStore!.getFetchDataBool()) {
        checkDataStore!.setfetchDataBool(false);
        checkDataStore!.setToken(authStore!.token);
        await checkDataStore!.fetchNovoPedidoCount();
        novosPedidosCount = checkDataStore!.novosPedidosCount;
      }
      if (timerBlock == false) {
        checkForNewPedidosTimer();
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final sWidth = MediaQuery.of(context).size.width;

    return AppBar(
      centerTitle: sWidth > 1200 ? false : true,
      flexibleSpace: Container(
        color: Color(0xff2240b5),
        /*
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2240b5), Theme.of(context).primaryColor],
            stops: [0.5, 1.0],
          ),
        ),*/
      ),
      elevation: 0,
      title: Image.asset(
        'assets/logos/da-logo-branco.png',
        height: 35,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
      actions: sWidth > 1200
          ? <Widget>[
              _navUsuario(context, authStore!.name),
              const SizedBox(width: 30),
              _navAdmin(context, authStore!.role),
              if (authStore!.role == 'Credenciado') const SizedBox(width: 30),
              if (authStore!.role == 'Credenciado')
                _navPainelPacientes(context),
              if (authStore!.role == 'Credenciado') const SizedBox(width: 30),
              if (authStore!.role == 'Credenciado') _navNovoPaciente(context),
              const SizedBox(width: 30),
              _midia(context),
              const SizedBox(width: 30),
              _sair(context, authStore!),
              const Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: VerticalDivider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),
              _whatsapp(context),
              _phone(context),
              _mail(context),
              //SizedBox(width: 10),
            ]
          : null,
    );
  }

  Widget _navUsuario(context, name) {
    return TextButton.icon(
      onPressed: () {
        ModalRoute<Object?>? route = ModalRoute.of(context);
        final routeName = route!.settings.name;
        if (routeName != null && routeName != '/perfil') {
          //Remove any messages (if any) on changing routes
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(Perfil.routeName);
        }
      },
      icon: const Icon(Icons.person),
      label: Text(
        'Olá, $name',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _navAdmin(context, role) {
    return role == 'Administrador' || role == 'Gerente'
        ? Container(
            height: 50,
            width: 125,
            child: PopupMenuButton(
              offset: Offset(-20, 50),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Administrativo',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'BigNoodleTitling',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              tooltip: 'Mostrar mais!',
              onSelected: (selectedValue) {
                if (selectedValue == 'Gerenciar Cadastros') {
                  checkDataStore!.setfetchDataBool(true);
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;
                  if (routeName != null &&
                      routeName != '/gerenciar-cadastros') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarCadastros.routeName);
                  }
                } else if (selectedValue == 'Gerenciar Permissões') {
                  checkDataStore!.setfetchDataBool(true);
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;
                  if (routeName != null &&
                      routeName != '/gerenciar-permissoes') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarPermissoes.routeName);
                  }
                } else if (selectedValue == 'Gerenciar Pedidos') {
                  checkDataStore!.setfetchDataBool(true);
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;

                  if (routeName != null && routeName != '/gerenciar-pedidos') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarPedidos.routeName);
                  }
                } else if (selectedValue == 'Gerenciar Pacientes') {
                  checkDataStore!.setfetchDataBool(true);
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;

                  if (routeName != null &&
                      routeName != '/gerenciar-pacientes') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    checkDataStore!.setfetchDataBool(true);

                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarPacientes.routeName);
                  }
                } else if (selectedValue == 'Meus Setups') {
                  //Remove any messages (if any) on changing routes
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  checkDataStore!.setfetchDataBool(true);
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;

                  if (routeName != null && routeName != '/meus-setups') {}
                } else if (selectedValue == 'Minhas Revisões') {}
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text(
                        'Gerenciar Pedidos',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'BigNoodleTitling',
                        ),
                      ),
                      if (novosPedidosCount > 0)
                        Positioned(
                          top: -15,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: ClipOval(
                              child: Material(
                                color: Colors.blue,
                                child: Center(
                                    child: Text(
                                  novosPedidosCount.toString(),
                                  style: const TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                          ),
                        )
                      else if (novosPedidosCount == -1)
                        Positioned(
                          top: -15,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  value: 'Gerenciar Pedidos',
                ),
                PopupMenuItem(
                  child: const Text(
                    'Gerenciar Cadastros',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                  value: 'Gerenciar Cadastros',
                ),
                if (role == 'Administrador')
                  PopupMenuItem(
                    child: const Text(
                      'Gerenciar Permissões',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'BigNoodleTitling',
                      ),
                    ),
                    value: 'Gerenciar Permissões',
                  ),
                PopupMenuItem(
                  child: const Text(
                    'Gerenciar Pacientes',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                  value: 'Gerenciar Pacientes',
                ),
                PopupMenuItem(
                  child: const Text(
                    'Meus Setups',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                  value: 'Meus Setups',
                ),
                PopupMenuItem(
                  child: const Text(
                    'Minhas Revisões',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'BigNoodleTitling',
                    ),
                  ),
                  value: 'Minhas Revisões',
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _navPainelPacientes(context) {
    return TextButton.icon(
      onPressed: () {
        ModalRoute<Object?>? route = ModalRoute.of(context);
        final routeName = route!.settings.name;
        print(routeName);
        if (routeName != null && routeName != '/meus-pacientes') {
          //Remove any messages (if any) on changing routes
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(MeusPacientes.routeName);
        }
      },
      icon: const Icon(Icons.shopping_bag_rounded),
      label: const Text(
        'Meus Pacientes',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  //when making these futures routes, remember to pop snackbars
  Widget _navNovoPaciente(context) {
    return TextButton.icon(
      onPressed: () {
        ModalRoute<Object?>? route = ModalRoute.of(context);
        final routeName = route!.settings.name;
        print(routeName);
        /*
        if (routeName != null && routeName != '/novo-paciente') {
          Navigator.of(context).pushReplacementNamed(NovoPaciente.routeName);
        }*/
        if (routeName != null && routeName != '/pedido-v1') {
          Navigator.of(context).pushReplacementNamed(PedidoV1Screen.routeName);
        }
      },
      icon: const Icon(Icons.add),
      label: const Text(
        'Novo Paciente',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _midia(context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.play_circle_fill),
      label: const Text(
        'Mídia',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _sair(context, AuthProvider authStore) {
    return TextButton.icon(
      onPressed: () {
        authStore.logout();
        html.window.location.reload();
        /*
        PedidosListProvider _pedidosListStore =
            Provider.of<PedidosListProvider>(
          context,
        );
        PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(
          context,
        );
        RelatorioProvider _relatorioStore =
            Provider.of<RelatorioProvider>(context, listen: false);
        CadastroProvider _cadastroStore =
            Provider.of<CadastroProvider>(context);
        //CLEAR VALUES
        _novoPedStore.clearAll();
        _relatorioStore.clearSelectedRelatorio();
        _relatorioStore.clearToken();
        _cadastroStore.clearCadastros();
        _pedidosListStore.clearPedidosOnLeave();
        _pedidosListStore.setToken(null); */
      },
      icon: const Icon(Icons.sensor_door),
      label: const Text(
        'Sair',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'BigNoodleTitling',
        ),
      ),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _whatsapp(context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.send_to_mobile),
      label: const Text(''),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _phone(context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.phone),
      label: const Text(''),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }

  Widget _mail(context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.mail),
      label: const Text(''),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white.withOpacity(0.05);
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.white;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return Color(0xff2240b5); // Use the component's default.
          },
        ),
      ),
    );
  }
}
