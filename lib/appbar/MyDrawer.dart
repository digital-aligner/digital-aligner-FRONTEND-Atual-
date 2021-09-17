import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_onboarding.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pacientes_v1.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_permissoes.dart';
import 'package:digital_aligner_app/screens/midia_screen/mentoria_portugal.dart';

import 'package:digital_aligner_app/screens/perfil.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../screens/administrativo/gerenciar_cadastro.dart';
import 'dart:html' as html;

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final AuthProvider authStore = Provider.of<AuthProvider>(context);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: Padding(
                padding: const EdgeInsets.fromLTRB(54, 0, 0, 0),
                child: Column(
                  children: [
                    Image.asset(
                      'logos/da-logo-branco.png',
                      height: 35,
                    ),
                  ],
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                'Olá, ${authStore.name}',
                style: const TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {
                ModalRoute<Object?>? route = ModalRoute.of(context);
                final routeName = route!.settings.name;
                if (routeName != null && routeName != '/perfil') {
                  Navigator.of(context).pushReplacementNamed(Perfil.routeName);
                }
              },
            ),
            authStore.role == 'Administrador' || authStore.role == 'Gerente'
                ? Column(
                    children: [
                      Divider(),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: PopupMenuButton(
                          offset: Offset(220, 0),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 28),
                              const Text(
                                'Administrativo',
                                style: TextStyle(
                                  fontFamily: 'Houschka',
                                ),
                              ),
                            ],
                          ),
                          tooltip: 'Mostrar mais!',
                          onSelected: (selectedValue) {
                            if (selectedValue == 'Gerenciar Cadastros') {
                              print(selectedValue);
                              Navigator.of(context).pushReplacementNamed(
                                GerenciarCadastros.routeName,
                                arguments: ScreenArguments(
                                  title: 'Gerenciar Cadastros',
                                  message: '',
                                ),
                              );
                            } else if (selectedValue ==
                                'Gerenciar Permissões') {
                              print(selectedValue);
                              Navigator.of(context).pushReplacementNamed(
                                  GerenciarPermissoes.routeName);
                            } else if (selectedValue == 'Gerenciar Pacientes') {
                              ModalRoute<Object?>? route =
                                  ModalRoute.of(context);
                              final routeName = route!.settings.name;

                              if (routeName != null &&
                                  routeName != '/gerenciar-pacientes-v1') {
                                Navigator.of(context).pushReplacementNamed(
                                  GerenciarPacientesV1.routeName,
                                  arguments: ScreenArguments(
                                    title: 'Gerenciar Pacientes',
                                    message: '',
                                  ),
                                );
                              }
                            } else if (selectedValue ==
                                'Gerenciar Onboarding') {
                              ModalRoute<Object?>? route =
                                  ModalRoute.of(context);
                              final routeName = route!.settings.name;

                              if (routeName != null &&
                                  routeName != '/gerenciar-onboarding') {
                                //Remove any messages (if any) on changing routes
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();

                                Navigator.of(context).pushReplacementNamed(
                                    GerenciarOnboarding.routeName);
                              } else if (selectedValue == 'Meus Setups') {
                                ModalRoute<Object?>? route =
                                    ModalRoute.of(context);
                                final routeName = route!.settings.name;

                                if (routeName != null &&
                                    routeName != '/meus-setups') {}
                              } else if (selectedValue == 'Minhas Revisões') {
                                ModalRoute<Object?>? route =
                                    ModalRoute.of(context);
                                final routeName = route!.settings.name;

                                if (routeName != null &&
                                    routeName != '/minhas-revisoes') {}
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              child: const Text(
                                'Gerenciar Cadastros',
                                style: const TextStyle(
                                  fontFamily: 'Houschka',
                                ),
                              ),
                              value: 'Gerenciar Cadastros',
                            ),
                            if (authStore.role == 'Administrador')
                              PopupMenuItem(
                                child: const Text(
                                  'Gerenciar Permissões',
                                  style: const TextStyle(
                                    fontFamily: 'Houschka',
                                  ),
                                ),
                                value: 'Gerenciar Permissões',
                              ),
                            PopupMenuItem(
                              child: const Text(
                                'Gerenciar Pacientes',
                                style: const TextStyle(
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
                      ),
                    ],
                  )
                : Container(),
            if (authStore.role == 'Credenciado') Divider(),
            if (authStore.role == 'Credenciado')
              ListTile(
                leading: const Icon(Icons.shopping_bag_rounded),
                title: const Text(
                  'Meus Pacientes',
                  style: TextStyle(
                    fontFamily: 'Houschka',
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    GerenciarPacientesV1.routeName,
                    arguments: ScreenArguments(
                      title: 'Meus Pacientes',
                      message: '',
                    ),
                  );
                },
              ),
            if (authStore.role == 'Credenciado') Divider(),
            if (authStore.role == 'Credenciado')
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text(
                  'Novo Paciente',
                  style: TextStyle(
                    fontFamily: 'Houschka',
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    PedidoV1Screen.routeName,
                    arguments: ScreenArguments(
                      title: 'Novo Paciente',
                      messageMap: {
                        'isEditarPaciente': false,
                      },
                    ),
                  );
                },
              ),
            Divider(),
            /*ListTile(
              leading: const Icon(Icons.play_circle_fill),
              title: const Text(
                'Mentoria Brasil',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  MentoriaBrasil.routeName,
                );
              },
            ),
            Divider(),*/
            ListTile(
              leading: const Icon(Icons.play_circle_fill),
              title: const Text(
                'Mentoria Portugal',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  MentoriaPortugal.routeName,
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.sensor_door),
              title: const Text(
                'Sair',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {
                authStore.logout();
                PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(
                  context,
                  listen: false,
                );
                //CLEAR VALUES
                _novoPedStore.clearDataAllProviderData();
                html.window.location.reload();
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.send_to_mobile),
              title: const Text(
                'Whatsapp',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text(
                'Atendimento',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Houschka',
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
