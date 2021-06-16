import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

import '../widgets/novo_paciente/pedido_form.dart';

class NovoPedido extends StatefulWidget {
  static const routeName = '/novo-pedido';

  @override
  _NovoPedidoState createState() => _NovoPedidoState();
}

class _NovoPedidoState extends State<NovoPedido> {
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
          pedidoHeader: 'Novo Pedido',
          userId: authStore.id,
          pedidoId: null,
          isEditarPedido: false,
          isNovoPaciente: false,
          isNovoPedido: true,
          isNovoRefinamento: false,
          pacienteDados: args,
          blockUi: false,
        ),
      ),
    );
  }
}
