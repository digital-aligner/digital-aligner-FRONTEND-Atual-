import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

import '../widgets/novo_paciente/pedido_form.dart';

class RefinamentoPedido extends StatefulWidget {
  static const routeName = '/pedido-refinamento';

  @override
  _RefinamentoPedidoState createState() => _RefinamentoPedidoState();
}

class _RefinamentoPedidoState extends State<RefinamentoPedido> {
  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthProvider>(context);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    final Map args = ModalRoute.of(context).settings.arguments;

    final sWidth = MediaQuery.of(context).size.width;
    final sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      //drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Container(
        width: sWidth,
        height: sHeight,
        child: PedidoForm(
          pedidoHeader: 'Pedido: Refinamento',
          userId: authStore.id,
          pedidoId: null,
          isEditarPedido: false,
          isNovoPedido: false,
          isNovoPaciente: false,
          isNovoRefinamento: true,
          pacienteDados: args,
          blockUi: false,
        ),
      ),
    );
  }
}
