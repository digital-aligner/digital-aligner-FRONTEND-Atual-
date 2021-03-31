import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pacientes.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pedido.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_permissoes.dart';
import 'package:digital_aligner_app/screens/administrativo/meus_setups.dart';
import 'package:digital_aligner_app/screens/administrativo/minhas_revisoes.dart';
import 'package:digital_aligner_app/screens/novo_paciente.dart';
import 'package:digital_aligner_app/screens/perfil.dart';

import '../screens/meus_pacientes.dart';
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
              backgroundColor: Colors.lightBlue[700],
              title: Padding(
                padding: const EdgeInsets.fromLTRB(54, 0, 0, 0),
                child: Text(
                  'Digital Aligner',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BigNoodleTitling',
                    color: Colors.white,
                  ),
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
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
                ),
              ),
              onTap: () {
                Route route = ModalRoute.of(context);
                final routeName = route.settings.name;
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
                                  fontSize: 20,
                                  fontFamily: 'BigNoodleTitling',
                                ),
                              ),
                            ],
                          ),
                          tooltip: 'Mostrar mais!',
                          onSelected: (selectedValue) {
                            if (selectedValue == 'Gerenciar Cadastros') {
                              print(selectedValue);
                              Navigator.of(context).pushReplacementNamed(
                                  GerenciarCadastros.routeName);
                            } else if (selectedValue ==
                                'Gerenciar Permissões') {
                              print(selectedValue);
                              Navigator.of(context).pushReplacementNamed(
                                  GerenciarPermissoes.routeName);
                            } else if (selectedValue == 'Gerenciar Pedidos') {
                              Route route = ModalRoute.of(context);
                              final routeName = route.settings.name;
                              if (routeName != null &&
                                  routeName != '/gerenciar-pedidos') {
                                Navigator.of(context).pushReplacementNamed(
                                    GerenciarPedidos.routeName);
                              }
                            } else if (selectedValue == 'Gerenciar Pacientes') {
                              Route route = ModalRoute.of(context);
                              final routeName = route.settings.name;

                              if (routeName != null &&
                                  routeName != '/gerenciar-pacientes') {
                                Navigator.of(context).pushReplacementNamed(
                                    GerenciarPacientes.routeName);
                              }
                            } else if (selectedValue == 'Meus Setups') {
                              Route route = ModalRoute.of(context);
                              final routeName = route.settings.name;

                              if (routeName != null &&
                                  routeName != '/meus-setups') {
                                Navigator.of(context)
                                    .pushReplacementNamed(MeusSetups.routeName);
                              }
                            } else if (selectedValue == 'Minhas Revisões') {
                              Route route = ModalRoute.of(context);
                              final routeName = route.settings.name;

                              if (routeName != null &&
                                  routeName != '/minhas-revisoes') {
                                Navigator.of(context).pushReplacementNamed(
                                    MinhasRevisoes.routeName);
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              child: const Text(
                                'Gerenciar Pedidos',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'BigNoodleTitling',
                                ),
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
                            if (authStore.role == 'Administrador')
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
                    fontSize: 20,
                    fontFamily: 'BigNoodleTitling',
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    MeusPacientes.routeName,
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
                    fontSize: 20,
                    fontFamily: 'BigNoodleTitling',
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    NovoPaciente.routeName,
                  );
                },
              ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.play_circle_fill),
              title: const Text(
                'Mídia',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
                ),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.sensor_door),
              title: const Text(
                'Sair',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
                ),
              ),
              onTap: () {
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
                _pedidosListStore.setToken(null);*/
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.send_to_mobile),
              title: const Text(
                'Whatsapp',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
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
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
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
                  fontSize: 20,
                  fontFamily: 'BigNoodleTitling',
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
