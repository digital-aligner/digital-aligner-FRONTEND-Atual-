import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPedido extends StatefulWidget {
  final bool blockUi;

  StatusPedido({this.blockUi});
  @override
  _StatusPedidoState createState() => _StatusPedidoState();
}

class _StatusPedidoState extends State<StatusPedido> {
  PedidoProvider _novoPedStore;
  AuthProvider _authStore;
  var _fetchDataHandler;
  String _status;

  void didChangeDependencies() {
    super.didChangeDependencies();
    _novoPedStore = Provider.of<PedidoProvider>(context, listen: false);
    _authStore = Provider.of<AuthProvider>(context);
    _fetchDataHandler = _novoPedStore.fetchStatusPedido(_authStore.token);
    //Bug: for some reason, when passing getcurrentstatus directly as
    //argument the data isn't fetched.
    _status = _novoPedStore.getCurrentStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Container(
            height: 80,
            child: FutureBuilder(
              future: _fetchDataHandler,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return DropdownSearch<String>(
                      enabled: !widget.blockUi,
                      //popupShape: null,
                      onSaved: (String value) {
                        _novoPedStore.setCurrentStatus(value);
                      },
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      ),
                      mode: Mode.MENU,
                      showSearchBox: false,
                      showSelectedItem: true,
                      items: snapshot.data,
                      label: 'Status do Pedido: *',
                      //hint: 'country in menu mode',
                      popupItemDisabled:
                          (String s) => /*s.startsWith('I')*/ null,
                      onChanged: (value) {
                        //_novoPedStore.setCurrentStatus(value);
                        //print(value);
                      },
                      selectedItem: _status == null ? 'Selecione' : _status);
                } else {
                  return CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
