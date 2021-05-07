import 'package:flutter/services.dart';

import '../../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Sagital extends StatefulWidget {
  final bool blockUi;

  Sagital({@required this.blockUi});

  @override
  _SagitalState createState() => _SagitalState();
}

class _SagitalState extends State<Sagital> {
  final _controllerLocalRecElastAlinh = TextEditingController();
  final _controllerLocalRecAlinhBotao = TextEditingController();
  final _controllerLocalAlivioAlinhador = TextEditingController();
  @override
  void dispose() {
    _controllerLocalRecElastAlinh.dispose();
    _controllerLocalRecAlinhBotao.dispose();
    _controllerLocalAlivioAlinhador.dispose();
    super.dispose();
  }

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
    double width = MediaQuery.of(context).size.width;
    //loading provider values to controller
    _controllerLocalRecElastAlinh.text = _novoPedStore.getLocalRecElastAlinh();
    _controllerLocalRecAlinhBotao.text = _novoPedStore.getLocalRecAlinhBotao();
    _controllerLocalAlivioAlinhador.text =
        _novoPedStore.getLocalAlivioAlinhador();

    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Text(
            'SAGITAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _relacaoMolar(_novoPedStore, width),
          const SizedBox(height: 20),
          _relacaoCanino(_novoPedStore, width),
          const SizedBox(height: 20),
          _opcionais(_novoPedStore),
        ],
      ),
    );
  }

  Widget _relacaoMolar(PedidoProvider _novoPedStore, double width) {
    return Column(
      children: <Widget>[
        //Texto: Relação molar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RELAÇÃO MOLAR:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        //Error message (lado direito)
        Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Container(
                  height: 10,
                  width: 130,
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      validator: (_) {
                        //If any values empty
                        if (_novoPedStore.getRmRadioValue('_rmLd') == 0 ||
                            _novoPedStore.getRmRadioValue('_rmLe') == 0) {
                          return 'Selecione um valor!';
                          //If both is "manter"
                        } else if (_novoPedStore.getRmRadioValue('_rmLd') ==
                                1 &&
                            _novoPedStore.getRmRadioValue('_rmLe') == 1) {
                          return null;
                          //If any value is "corrigir" check both
                        } else if (_novoPedStore.getRmRadioValue('_rmLd') ==
                                2 ||
                            _novoPedStore.getRmRadioValue('_rmLe') == 2) {
                          //check lado direito (sup dir, inf dir)
                          if (_novoPedStore.getRmRadioValue('_rmLd') == 2) {
                            if (_novoPedStore.getRmRadioValue('_rmSd') == 0 ||
                                _novoPedStore.getRmRadioValue('_rmId') == 0) {
                              return 'Selecione um valor!';
                            }
                          }
                          //check lado esquerdp (sup esq, inf esq)
                          if (_novoPedStore.getRmRadioValue('_rmLe') == 2) {
                            if (_novoPedStore.getRmRadioValue('_rmSe') == 0 ||
                                _novoPedStore.getRmRadioValue('_rmIe') == 0) {
                              return 'Selecione um valor!';
                            }
                          }
                        }
                        return null;
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
        Card(
          elevation: 5,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: width > 800 ? Axis.horizontal : Axis.vertical,
                children: [
                  //lado direto
                  Column(
                    children: [
                      //lado direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Lado direito',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmLd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRmRadio(
                                              value, '_rmLd');
                                          _novoPedStore.manageRmLadoDireito();
                                        },
                                  value: 1,
                                ),
                                const Text('Manter'),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmLd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRmRadio(
                                              value, '_rmLd');
                                          _novoPedStore.manageRmLadoDireito();
                                        },
                                  value: 2,
                                ),
                                const Text('Corrigir'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //superior direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Superior direito',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRmLdState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSd',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSd',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSd',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //inferior direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Inferior direito',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRmLdState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmId',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmId',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLdState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmId',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  //lado esquerdo
                  Column(
                    children: [
                      //lado esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            const Text(
                              'Lado esquerdo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmLe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRmRadio(
                                              value, '_rmLe');
                                          _novoPedStore.manageRmLadoEsquerdo();
                                        },
                                  value: 1,
                                ),
                                const Text('Manter'),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmLe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRmRadio(
                                              value, '_rmLe');
                                          _novoPedStore.manageRmLadoEsquerdo();
                                        },
                                  value: 2,
                                ),
                                const Text('Corrigir'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //superior esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Superior esquerdo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRmLeState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSe',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSe',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmSe',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //inferior esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Inferior esquerdo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRmLeState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmIe',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmIe',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRmRadioValue('_rmIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRmLeState()) {
                                            _novoPedStore.setRmRadio(
                                              value,
                                              '_rmIe',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRmLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          child: TextFormField(
            enabled: !widget.blockUi,
            maxLength: 2000,
            maxLines: 15,
            initialValue: _novoPedStore.getRmOutro(),
            onChanged: (value) {
              _novoPedStore.setRmOutro(value);
            },
            decoration: InputDecoration(
              labelText: 'Outro (Especifique): *',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _relacaoCanino(PedidoProvider _novoPedStore, double width) {
    return Column(
      children: <Widget>[
        //Texto: Relação molar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RELAÇÃO CANINO:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        //Error message
        Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Container(
                  height: 10,
                  width: 130,
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      validator: (_) {
                        //If any values empty
                        if (_novoPedStore.getRcRadioValue('_rcLd') == 0 ||
                            _novoPedStore.getRcRadioValue('_rcLe') == 0) {
                          return 'Selecione um valor!';
                          //If both is "manter"
                        } else if (_novoPedStore.getRcRadioValue('_rcLd') ==
                                1 &&
                            _novoPedStore.getRcRadioValue('_rcLe') == 1) {
                          return null;
                          //If any value is "corrigir" check both
                        } else if (_novoPedStore.getRcRadioValue('_rcLd') ==
                                2 ||
                            _novoPedStore.getRcRadioValue('_rcLe') == 2) {
                          //check lado direito (sup dir, inf dir)
                          if (_novoPedStore.getRcRadioValue('_rcLd') == 2) {
                            if (_novoPedStore.getRcRadioValue('_rcSd') == 0 ||
                                _novoPedStore.getRcRadioValue('_rcId') == 0) {
                              return 'Selecione um valor!';
                            }
                          }
                          //check lado esquerdo (sup esq, inf esq)
                          if (_novoPedStore.getRcRadioValue('_rcLe') == 2) {
                            if (_novoPedStore.getRcRadioValue('_rcSe') == 0 ||
                                _novoPedStore.getRcRadioValue('_rcIe') == 0) {
                              return 'Selecione um valor!';
                            }
                          }
                        }
                        return null;
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
        const SizedBox(height: 20),
        Card(
          elevation: 5,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                direction: width > 800 ? Axis.horizontal : Axis.vertical,
                children: [
                  //lado direito
                  Column(
                    children: [
                      //lado direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            const Text(
                              'Lado direito',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcLd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRcRadio(
                                              value, '_rcLd');
                                          _novoPedStore.manageRcLadoDireito();
                                        },
                                  value: 1,
                                ),
                                const Text('Manter'),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcLd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRcRadio(
                                              value, '_rcLd');
                                          _novoPedStore.manageRcLadoDireito();
                                        },
                                  value: 2,
                                ),
                                const Text('Corrigir'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //superior direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Superior direito',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRcLdState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSd',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSd',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSd'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSd',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //inferior direito
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Inferior direito',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRcLdState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcId',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcId',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcId'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLdState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcId',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLdState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  //lado esquerdo
                  Column(
                    children: [
                      //lado esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            const Text(
                              'Lado esquerdo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcLe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRcRadio(
                                              value, '_rcLe');
                                          _novoPedStore.manageRcLadoEsquerdo();
                                        },
                                  value: 1,
                                ),
                                const Text('Manter'),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcLe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          _novoPedStore.setRcRadio(
                                              value, '_rcLe');
                                          _novoPedStore.manageRcLadoEsquerdo();
                                        },
                                  value: 2,
                                ),
                                const Text('Corrigir'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //superior esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Superior esquerdo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRcLeState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSe',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSe',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcSe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcSe',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //inferior esquerdo
                      Container(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              'Inferior esquerdo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _novoPedStore.getRcLeState()
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcIe',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'Distalize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcIe',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'Mesialize',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getRcRadioValue('_rcIe'),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore.getRcLeState()) {
                                            _novoPedStore.setRcRadio(
                                              value,
                                              '_rcIe',
                                            );
                                          }
                                        },
                                  value: 3,
                                ),
                                Text(
                                  'Manter',
                                  style: TextStyle(
                                    color: _novoPedStore.getRcLeState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        //Outros
        Container(
          child: TextFormField(
            enabled: !widget.blockUi,
            maxLength: 2000,
            maxLines: 15,
            initialValue: _novoPedStore.getRcOutro(),
            onChanged: (value) {
              _novoPedStore.setRcOutro(value);
            },
            decoration: InputDecoration(
              labelText: 'Outro (Especifique): *',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _opcionais(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'OPCIONAIS:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Aceito desgastes interproximais (DIP)'),
          value: _novoPedStore.getSgOpAceitoDesgastes(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  _novoPedStore.setSgOpAceitoDesgastes(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Wrap(
            children: [
              const Text(
                'Recorte para elástico no alinhador (especificar o dente)',
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 125,
                child: TextFormField(
                  onChanged: (value) {
                    if (!_novoPedStore.getSgOpRecorteElastico()) {
                      _novoPedStore.setLocalRecElastAlinh('');
                    } else {
                      _novoPedStore.setLocalRecElastAlinh(value);
                    }
                  },
                  textAlign: TextAlign.center,
                  onSaved: (String value) {
                    //sc.usernameCpf = value;
                  },
                  enabled: widget.blockUi
                      ? !widget.blockUi
                      : _novoPedStore.getSgOpRecorteElastico(),
                  validator: (value) {
                    if (value.length < 0) {
                      return 'Não valido.';
                    }
                    return null;
                  },
                  maxLength: 11,
                  controller: _controllerLocalRecElastAlinh,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ex: 18,17,16',
                    //To hide cpf length num
                    counterText: '',
                    //labelText: 'Quantos mm?',
                    // border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
          value: _novoPedStore.getSgOpRecorteElastico(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  if (!value) {
                    _novoPedStore.setLocalRecElastAlinh('');
                  }
                  _novoPedStore.setSgOpRecorteElastico(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Wrap(
            children: [
              const Text(
                'Recorte no alinhador para botão (especificar o dente)',
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 125,
                child: TextFormField(
                  onChanged: (value) {
                    if (!_novoPedStore.getSgOpRecorteAlinhador()) {
                      _novoPedStore.setLocalRecAlinhBotao('');
                    } else {
                      _novoPedStore.setLocalRecAlinhBotao(value);
                    }
                  },
                  textAlign: TextAlign.center,
                  onSaved: (String value) {
                    //sc.usernameCpf = value;
                  },
                  enabled: widget.blockUi
                      ? !widget.blockUi
                      : _novoPedStore.getSgOpRecorteAlinhador(),
                  validator: (value) {
                    if (value.length < 0) {
                      return 'Não valido.';
                    }
                    return null;
                  },
                  maxLength: 11,
                  controller: _controllerLocalRecAlinhBotao,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ex: 18,17,16',
                    //To hide cpf length num
                    counterText: '',
                    //labelText: 'Quantos mm?',
                    // border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
          value: _novoPedStore.getSgOpRecorteAlinhador(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  if (!value) {
                    _novoPedStore.setLocalRecAlinhBotao('');
                  }
                  _novoPedStore.setSgOpRecorteAlinhador(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Wrap(
            children: [
              const Text(
                'Alívio no alinhador para braço de força (especificar o dente)',
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 125,
                child: TextFormField(
                  onChanged: (value) {
                    if (!_novoPedStore.getSgOpAlivioAlinhador()) {
                      _novoPedStore.setLocalAlivioAlinhador('');
                    } else {
                      _novoPedStore.setLocalAlivioAlinhador(value);
                    }
                  },
                  textAlign: TextAlign.center,
                  onSaved: (String value) {
                    //sc.usernameCpf = value;
                  },
                  enabled: widget.blockUi
                      ? !widget.blockUi
                      : _novoPedStore.getSgOpAlivioAlinhador(),
                  validator: (value) {
                    if (value.length < 0) {
                      return 'Não valido.';
                    }
                    return null;
                  },
                  maxLength: 11,
                  controller: _controllerLocalAlivioAlinhador,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ex: 18,17,16',
                    //To hide cpf length num
                    counterText: '',
                    //labelText: 'Quantos mm?',
                    // border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
          value: _novoPedStore.getSgOpAlivioAlinhador(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  if (!value) {
                    _novoPedStore.setLocalAlivioAlinhador('');
                  }
                  _novoPedStore.setSgOpAlivioAlinhador(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
      ],
    );
  }

//

}
