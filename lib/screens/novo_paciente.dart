import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../appbar/MyAppBar.dart';
import '../appbar/MyDrawer.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

import '../widgets/novo_paciente/pedido_form.dart';

class NovoPaciente extends StatefulWidget {
  static const routeName = '/novo-paciente';

  @override
  _NovoPacienteState createState() => _NovoPacienteState();
}

class _NovoPacienteState extends State<NovoPaciente> {
  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthProvider>(context);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    final sWidth = MediaQuery.of(context).size.width;
    final sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Container(
        width: sWidth,
        height: sHeight,
        child: PedidoForm(
          pedidoHeader: 'Novo Paciente',
          userId: authStore.id,
          pedidoId: null,
          isNovoPaciente: true,
          isEditarPedido: false,
          isNovoPedido: false,
          isNovoRefinamento: false,
        ),
      ),
    );
  }
}
