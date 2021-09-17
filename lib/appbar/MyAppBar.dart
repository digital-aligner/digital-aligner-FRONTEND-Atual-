import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_onboarding.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pacientes_v1.dart';
import 'package:digital_aligner_app/screens/midia_screen/mentoria_brasil.dart';
import 'package:digital_aligner_app/screens/midia_screen/mentoria_portugal.dart';

import 'package:digital_aligner_app/screens/perfil.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';

import '../screens/administrativo/gerenciar_permissoes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  AuthProvider? authStore;
  int novosPedidosCount = -1;
  bool timerBlock = false;

  var duration;

  @override
  void didChangeDependencies() async {
    authStore = Provider.of<AuthProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final sWidth = MediaQuery.of(context).size.width;

    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: sWidth > 1200 ? false : true,
      elevation: 5,
      title: Image.asset(
        'logos/da-logo-branco.png',
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
              //_mentoriaBrasil(context),
              //const SizedBox(width: 30),
              _mentoriaPortugal(context),
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
          fontFamily: 'Houschka',
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
                      fontFamily: 'Houschka',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              tooltip: 'Mostrar mais!',
              onSelected: (selectedValue) {
                if (selectedValue == 'Gerenciar Cadastros') {
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;
                  if (routeName != null &&
                      routeName != '/gerenciar-cadastros') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context).pushReplacementNamed(
                      GerenciarCadastros.routeName,
                      arguments: ScreenArguments(
                        title: 'Gerenciar Cadastros',
                        message: '',
                      ),
                    );
                  }
                } else if (selectedValue == 'Gerenciar Permissões') {
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;
                  if (routeName != null &&
                      routeName != '/gerenciar-permissoes') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarPermissoes.routeName);
                  }
                } else if (selectedValue == 'Gerenciar Pacientes') {
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;

                  if (routeName != null &&
                      routeName != '/gerenciar-pacientes-v1') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    Navigator.of(context).pushReplacementNamed(
                      GerenciarPacientesV1.routeName,
                      arguments: ScreenArguments(
                        title: 'Gerenciar Pacientes',
                        message: '',
                      ),
                    );
                  }
                } else if (selectedValue == 'Gerenciar Onboarding') {
                  ModalRoute<Object?>? route = ModalRoute.of(context);
                  final routeName = route!.settings.name;

                  if (routeName != null &&
                      routeName != '/gerenciar-onboarding') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    Navigator.of(context)
                        .pushReplacementNamed(GerenciarOnboarding.routeName);
                  } else if (selectedValue == 'Meus Setups') {
                    //Remove any messages (if any) on changing routes
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ModalRoute<Object?>? route = ModalRoute.of(context);
                    final routeName = route!.settings.name;

                    if (routeName != null && routeName != '/meus-setups') {}
                  } else if (selectedValue == 'Minhas Revisões') {}
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: const Text(
                    'Gerenciar Cadastros',
                    style: TextStyle(
                      fontFamily: 'Houschka',
                    ),
                  ),
                  value: 'Gerenciar Cadastros',
                ),
                if (role == 'Administrador')
                  PopupMenuItem(
                    child: const Text(
                      'Gerenciar Permissões',
                      style: TextStyle(
                        fontFamily: 'Houschka',
                      ),
                    ),
                    value: 'Gerenciar Permissões',
                  ),
                PopupMenuItem(
                  child: const Text(
                    'Gerenciar Pacientes',
                    style: TextStyle(
                      fontFamily: 'Houschka',
                    ),
                  ),
                  value: 'Gerenciar Pacientes',
                ),
                PopupMenuItem(
                  child: const Text(
                    'Gerenciar Onboarding',
                    style: TextStyle(
                      fontFamily: 'Houschka',
                    ),
                  ),
                  value: 'Gerenciar Onboarding',
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
          Navigator.of(context).pushReplacementNamed(
            GerenciarPacientesV1.routeName,
            arguments: ScreenArguments(
              title: 'Meus Pacientes',
              message: '',
            ),
          );
        }
      },
      icon: const Icon(Icons.shopping_bag_rounded),
      label: const Text(
        'Meus Pacientes',
        style: TextStyle(
          fontFamily: 'Houschka',
          color: Colors.white,
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
          Navigator.of(context).pushReplacementNamed(
            PedidoV1Screen.routeName,
            arguments: ScreenArguments(
              title: 'Novo Paciente',
              messageMap: {
                'isEditarPaciente': false,
              },
            ),
          );
        }
      },
      icon: const Icon(Icons.add),
      label: const Text(
        'Novo Paciente',
        style: TextStyle(
          fontFamily: 'Houschka',
          color: Colors.white,
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
      ),
    );
  }

  Widget _mentoriaBrasil(context) {
    return TextButton.icon(
      onPressed: () {
        ModalRoute<Object?>? route = ModalRoute.of(context);
        final routeName = route!.settings.name;
        if (routeName != null && routeName != '/mentoria-brasil') {
          //Remove any messages (if any) on changing routes
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(MentoriaBrasil.routeName);
        }
      },
      icon: const Icon(Icons.play_circle_fill),
      label: const Text(
        'Mentoria Brasil',
        style: TextStyle(
          fontFamily: 'Houschka',
          color: Colors.white,
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
      ),
    );
  }

  Widget _mentoriaPortugal(context) {
    return TextButton.icon(
      onPressed: () {
        ModalRoute<Object?>? route = ModalRoute.of(context);
        final routeName = route!.settings.name;
        if (routeName != null && routeName != '/mentoria-portugal') {
          //Remove any messages (if any) on changing routes
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.of(context)
              .pushReplacementNamed(MentoriaPortugal.routeName);
        }
      },
      icon: const Icon(Icons.play_circle_fill),
      label: const Text(
        'Mentoria Portugal',
        style: TextStyle(
          fontFamily: 'Houschka',
          color: Colors.white,
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
      ),
    );
  }

  Widget _sair(context, AuthProvider authStore) {
    return TextButton.icon(
      onPressed: () {
        authStore.logout();
        PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(
          context,
          listen: false,
        );
        //CLEAR VALUES
        _novoPedStore.clearDataAllProviderData();
        html.window.location.reload();
      },
      icon: const Icon(Icons.sensor_door),
      label: const Text(
        'Sair',
        style: TextStyle(
          fontFamily: 'Houschka',
          color: Colors.white,
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
      ),
    );
  }

  Widget _whatsapp(context) {
    return TextButton.icon(
      onPressed: () {
        html.window.open(
            'https://api.whatsapp.com/send?phone=5581992777557&text=Ol%C3%A1,%20preciso%20de%20ajuda%20com%20o%20site%20do%20Digital%20Aligner...',
            "_blank");
      },
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
      ),
    );
  }

  Widget _phone(context) {
    return TextButton.icon(
      onPressed: () {
        html.window.open('tel:+5581992777557', "_blank");
      },
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
      ),
    );
  }

  Widget _mail(context) {
    return TextButton.icon(
      onPressed: () {
        html.window.open('mailto:contato@digitalaligner.com.br', "_blank");
      },
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
      ),
    );
  }
}
