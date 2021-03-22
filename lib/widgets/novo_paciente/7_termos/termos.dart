import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Termos extends StatefulWidget {
  final bool blockUi;

  Termos({this.blockUi});
  @override
  _TermosState createState() => _TermosState();
}

class _TermosState extends State<Termos> {
  //For use to remove any text focus when clicking on radio.
  void _removeFocus(var context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _novoPedStore = Provider.of<PedidoProvider>(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          //Error message
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  Container(
                    height: 10,
                    width: 130,
                    child: IgnorePointer(
                      child: TextFormField(
                        readOnly: true,
                        validator: (_) {
                          return _novoPedStore.getTermos() == false
                              ? 'Selecione um valor!'
                              : null;
                        },
                        decoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(fontSize: 20),
                          filled: false,
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          hoverColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),

          //Termos
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Li e estou de acordo com os termos de uso.',
            ),
            value: _novoPedStore.getTermos(),
            onChanged: widget.blockUi
                ? null
                : (value) {
                    /*
              if (_novoPedStore.getCorrigirApinSelecionado()) {
                _novoPedStore.setExpArcoSupApin(value);
                if (value == false) {
                  _novoPedStore.clearExpArcoSupFields(
                      clearParentCheckbox: false);
                }
              }
              */
                    _removeFocus(context);
                    _novoPedStore.setTermos(value);
                  },
            activeColor: Colors.black12,
            checkColor: Colors.blue,
          ),

          const SizedBox(height: 20),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Taxa de Planejamento: Estou ciente que caso o planejamento não seja aprovado em até 60 dias, será cobrado o valor de R\$ 350,00.',
            ),
            value: _novoPedStore.getTaxaPlanejamento(),
            onChanged: widget.blockUi
                ? null
                : (value) {
                    /*
              if (_novoPedStore.getCorrigirApinSelecionado()) {
                _novoPedStore.setExpArcoSupApin(value);
                if (value == false) {
                  _novoPedStore.clearExpArcoSupFields(
                      clearParentCheckbox: false);
                }
              }
              */
                    //_novoPedStore.setTermos(value);
                    _removeFocus(context);
                  },
            activeColor: Colors.black12,
            checkColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
