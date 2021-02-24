import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/pedido_form.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class EditarPedido extends StatefulWidget {
  static const routeName = '/editar-pedido';
  @override
  _EditarPedidoState createState() => _EditarPedidoState();
}

class _EditarPedidoState extends State<EditarPedido> {
  S3DeleteProvider _s3deleteStore;
  AuthProvider authStore;
  @override
  void dispose() {
    super.dispose();
    _s3deleteStore.clearData();
  }

  @override
  Widget build(BuildContext context) {
    final Map _idsMap = ModalRoute.of(context).settings.arguments;
    authStore = Provider.of<AuthProvider>(context);
    _s3deleteStore = Provider.of<S3DeleteProvider>(context, listen: false);
    _s3deleteStore.setToken(authStore.token);

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: PedidoForm(
          pedidoHeader: _idsMap['codigoPedido'],
          pedidoId: _idsMap['pedidoId'],
          userId: _idsMap['userId'],
          enderecoId: _idsMap['enderecoId'],
          isEditarPedido: true,
          isNovoPedido: false,
          isNovoPaciente: false,
          pedidoDados: _idsMap['pedidoDados'],
          isNovoRefinamento: false,
        ),
      ),
    );
  }
}
