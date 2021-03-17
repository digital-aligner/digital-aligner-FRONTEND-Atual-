import 'package:flutter/services.dart';

import '../../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Transversal extends StatefulWidget {
  final bool blockUi;

  Transversal({@required this.blockUi});
  @override
  _TransversalState createState() => _TransversalState();
}

class _TransversalState extends State<Transversal> {
  final _cLmSupDireita = TextEditingController();
  final _cLmSupEsquerda = TextEditingController();

  final _cLmInfDireita = TextEditingController();
  final _cLmInfEsquerda = TextEditingController();

  final _controllerLocalMcpRecElastAlinh = TextEditingController();
  final _controllerLocalMcpRecAlinhBotao = TextEditingController();

  @override
  void dispose() {
    _cLmSupDireita.dispose();
    _cLmSupEsquerda.dispose();
    _cLmInfDireita.dispose();
    _cLmInfEsquerda.dispose();

    _controllerLocalMcpRecElastAlinh.dispose();
    _controllerLocalMcpRecAlinhBotao.dispose();

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

    //loading text controllers where needed
    void setCustomInicialState() {
      _cLmSupDireita.text = _novoPedStore.getLmSupDireitaMm().toString();
      _cLmSupEsquerda.text = _novoPedStore.getLmSupEsquerdaMm().toString();

      _cLmInfDireita.text = _novoPedStore.getLmInfDireitaMm().toString();
      _cLmInfEsquerda.text = _novoPedStore.getLmInfEsquerdaMm().toString();

      _controllerLocalMcpRecElastAlinh.text =
          _novoPedStore.getLocalMcpRecElastAlinh();
      _controllerLocalMcpRecAlinhBotao.text =
          _novoPedStore.getLocalMcpRecAlinhBotao();
    }

    setCustomInicialState();
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const Text(
            'TRANSVERSAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _mordidaCruzadaPosterior(_novoPedStore),
          const SizedBox(height: 20),
          _expansaoArcoSuperior(_novoPedStore),
          const SizedBox(height: 20),
          _contracaoArcoInferior(_novoPedStore),
          const SizedBox(height: 20),
          _linhaMediaSupTop(_novoPedStore),
          _linhaMediaSup(_novoPedStore),
          _linhaMediaInfTop(_novoPedStore),
          _linhaMediaInf(_novoPedStore),
        ],
      ),
    );
  }

  Widget _mordidaCruzadaPosterior(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        //Texto: MORDIDA CRUZADA POSTERIOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MORDIDA CRUZADA POSTERIOR:',
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
                        return _novoPedStore.getMordidaCruzPostRadio() == 0
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

        const SizedBox(height: 20),
        //Manter ou corrigir
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
              activeColor: Colors.blue,
              groupValue: _novoPedStore.getMordidaCruzPostRadio(),
              onChanged: widget.blockUi
                  ? null
                  : (value) {
                      _removeFocus(context);
                      _novoPedStore.setMordidaCruzPostRadio(value);
                      _novoPedStore.manageFormMcp();
                    },
              value: 1,
            ),
            const Text('Manter'),
            Radio(
              activeColor: Colors.blue,
              groupValue: _novoPedStore.getMordidaCruzPostRadio(),
              onChanged: widget.blockUi
                  ? null
                  : (value) {
                      _removeFocus(context);
                      _novoPedStore.setMordidaCruzPostRadio(value);
                      _novoPedStore.manageFormMcp();
                    },
              value: 2,
            ),
            const Text('Corrigir'),
          ],
        ),
      ],
    );
  }

  Widget _expansaoArcoSuperior(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        //Texto
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Expansão do arco superior:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _novoPedStore.getMordidaCruzPost()
                    ? Colors.black
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                //Direito / esquerdo
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Direito',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasDireito(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setEasDireito(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Esquerdo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasEsquerdo(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setEasEsquerdo(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                //movimento de corpo
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Movimento de Corpo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasMovimentoCorpo(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setEasMovimentoCorpo(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Movimento de Corpo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasMovimentoCorpoEsq(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setEasMovimentoCorpoEsq(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                //inclinação / torque
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Inclinação / torque',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasInclinacaoTorque(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setEasInclinacaoTorque(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Inclinação / torque',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getEasInclinacaoTorqueEsq(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore
                                      .setEasInclinacaoTorqueEsq(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _contracaoArcoInferior(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contração do arco inferior:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _novoPedStore.getMordidaCruzPost()
                    ? Colors.black
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                //Direito / esquerdo
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Direito',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiDireito(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setCaiDireito(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Esquerdo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiEsquerdo(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setCaiEsquerdo(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                //movimento de corpo
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Movimento de Corpo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiMovimentoCorpo(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setCaiMovimentoCorpo(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Movimento de Corpo',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiMovimentoCorpoEsq(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setCaiMovimentoCorpoEsq(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                //inclinação / torque
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Inclinação / torque',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiInclinacaoTorque(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore.setCaiInclinacaoTorque(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Inclinação / torque',
                          style: TextStyle(
                            color: _novoPedStore.getMordidaCruzPost()
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        value: _novoPedStore.getCaiInclinacaoTorqueEsq(),
                        onChanged: widget.blockUi
                            ? null
                            : (value) {
                                _removeFocus(context);
                                if (_novoPedStore.getMordidaCruzPost()) {
                                  _novoPedStore
                                      .setCaiInclinacaoTorqueEsq(value);
                                }
                              },
                        activeColor: Colors.black12,
                        checkColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Opcionais:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Row(
            children: [
              const Text(
                'Recorte para elástico no alinhador (especificar o dente)',
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 75,
                child: TextFormField(
                  onChanged: (value) {
                    if (!_novoPedStore.getMcpRecorteElastico()) {
                      _novoPedStore.setLocalMcpRecElastAlinh('');
                    } else {
                      _novoPedStore.setLocalMcpRecElastAlinh(value);
                    }
                  },
                  textAlign: TextAlign.center,
                  onSaved: (String value) {
                    //sc.usernameCpf = value;
                  },
                  enabled: widget.blockUi
                      ? !widget.blockUi
                      : _novoPedStore.getMcpRecorteElastico(),
                  validator: (value) {
                    if (value.length < 0) {
                      return 'Não valido.';
                    }
                    return null;
                  },
                  maxLength: 5,
                  controller: _controllerLocalMcpRecElastAlinh,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(
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
          value: _novoPedStore.getMcpRecorteElastico(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  if (!value) {
                    _novoPedStore.setLocalMcpRecElastAlinh('');
                  }
                  _novoPedStore.setMcpRecorteElastico(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Row(
            children: [
              const Text(
                'Recorte no alinhador para botão (especificar o dente)',
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 75,
                child: TextFormField(
                  onChanged: (value) {
                    if (!_novoPedStore.getMcpRecorteAlinhador()) {
                      _novoPedStore.setLocalMcpRecAlinhBotao('');
                    } else {
                      _novoPedStore.setLocalMcpRecAlinhBotao(value);
                    }
                  },
                  textAlign: TextAlign.center,
                  onSaved: (String value) {
                    //sc.usernameCpf = value;
                  },
                  enabled: widget.blockUi
                      ? !widget.blockUi
                      : _novoPedStore.getMcpRecorteAlinhador(),
                  validator: (value) {
                    if (value.length < 0) {
                      return 'Não valido.';
                    }
                    return null;
                  },
                  maxLength: 5,
                  controller: _controllerLocalMcpRecAlinhBotao,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(
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
          value: _novoPedStore.getMcpRecorteAlinhador(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _removeFocus(context);
                  if (!value) {
                    _novoPedStore.setLocalMcpRecAlinhBotao('');
                  }
                  _novoPedStore.setMcpRecorteAlinhador(value);
                },
          activeColor: Colors.black12,
          checkColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _linhaMediaSupTop(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        //Texto: LINHA MÉDIA SUPERIOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LINHA MÉDIA:',
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
        const SizedBox(height: 20),
        //Text: Linha média superior
        Column(
          children: [
            Text(
              'Linha Média Superior:',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                        return _novoPedStore.getLinhaMediaSupRadio() == 0
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
      ],
    );
  }

  Widget _linhaMediaSup(PedidoProvider _novoPedStore) {
    return Card(
      elevation: 5,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          //Manter ou corrigir
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                activeColor: Colors.blue,
                groupValue: _novoPedStore.getLinhaMediaSupRadio(),
                onChanged: widget.blockUi
                    ? null
                    : (value) {
                        _removeFocus(context);
                        _novoPedStore.setLinhaMediaSupRadio(value);
                        _novoPedStore.manageFormLmSup();
                      },
                value: 1,
              ),
              const Text('Manter'),
              Radio(
                activeColor: Colors.blue,
                groupValue: _novoPedStore.getLinhaMediaSupRadio(),
                onChanged: widget.blockUi
                    ? null
                    : (value) {
                        _removeFocus(context);
                        _novoPedStore.setLinhaMediaSupRadio(value);
                        _novoPedStore.manageFormLmSup();
                      },
                value: 2,
              ),
              const Text('Corrigir'),
            ],
          ),
          const SizedBox(height: 40),
          //Texto: LINHA MÉDIA SUPERIOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SUPERIOR:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _novoPedStore.getLinhaMediaSupState()
                      ? Colors.black
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          //Intrusão
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //Esquerdo - mover direita
              Container(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getLmSupRadioValue(null),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                              .getLinhaMediaSupState()) {
                                            _novoPedStore.setLmSupRadio(
                                              value,
                                              '_lmSupDireita',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'mover para a direita - Qts mm? ',
                                  style: TextStyle(
                                    color: _novoPedStore.getLinhaMediaSupState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 75,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          _novoPedStore
                                              .setLmSupDireitaMm(value);
                                        },
                                        textAlign: TextAlign.center,
                                        onSaved: (String value) {
                                          //sc.usernameCpf = value;
                                        },
                                        enabled: widget.blockUi
                                            ? !widget.blockUi
                                            : _novoPedStore
                                                    .getLinhaMediaSupState() &&
                                                _novoPedStore
                                                    .getLmSupDireitaState(),
                                        validator: (value) {
                                          if (value.length < 0) {
                                            return 'Não valido.';
                                          }
                                          return null;
                                        },
                                        maxLength: 5,
                                        controller: _cLmSupDireita,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[,0-9]')),
                                        ],
                                        decoration: const InputDecoration(
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //Direito - mover esquerda
              Container(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getLmSupRadioValue(null),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                              .getLinhaMediaSupState()) {
                                            _novoPedStore.setLmSupRadio(
                                              value,
                                              '_lmSupEsquerda',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'mover para a esquerda - Qts mm? ',
                                  style: TextStyle(
                                    color: _novoPedStore.getLinhaMediaSupState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 75,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          _novoPedStore
                                              .setLmSupEsquerdaMm(value);
                                        },
                                        textAlign: TextAlign.center,
                                        onSaved: (String value) {
                                          //sc.usernameCpf = value;
                                        },
                                        enabled: widget.blockUi
                                            ? !widget.blockUi
                                            : _novoPedStore
                                                    .getLinhaMediaSupState() &&
                                                _novoPedStore
                                                    .getLmSupEsquerdaState(),
                                        validator: (value) {
                                          if (value.length < 0) {
                                            return 'Não valido.';
                                          }
                                          return null;
                                        },
                                        maxLength: 5,
                                        controller: _cLmSupEsquerda,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[,0-9]')),
                                        ],
                                        decoration: const InputDecoration(
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
                              ],
                            ),
                          ],
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
    );
  }

  Widget _linhaMediaInfTop(PedidoProvider _novoPedStore) {
    return Column(
      children: [
        const SizedBox(height: 20),
        //Text: Linha média inferior
        Column(
          children: [
            const Text(
              'Linha Média Inferior:',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                        return _novoPedStore.getLinhaMediaInfRadio() == 0
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
      ],
    );
  }

  Widget _linhaMediaInf(PedidoProvider _novoPedStore) {
    return Card(
      elevation: 5,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          //Manter ou corrigir
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                activeColor: Colors.blue,
                groupValue: _novoPedStore.getLinhaMediaInfRadio(),
                onChanged: widget.blockUi
                    ? null
                    : (value) {
                        _removeFocus(context);
                        _novoPedStore.setLinhaMediaInfRadio(value);
                        _novoPedStore.manageFormLmInf();
                      },
                value: 1,
              ),
              const Text('Manter'),
              Radio(
                activeColor: Colors.blue,
                groupValue: _novoPedStore.getLinhaMediaInfRadio(),
                onChanged: widget.blockUi
                    ? null
                    : (value) {
                        _removeFocus(context);
                        _novoPedStore.setLinhaMediaInfRadio(value);
                        _novoPedStore.manageFormLmInf();
                      },
                value: 2,
              ),
              const Text('Corrigir'),
            ],
          ),
          const SizedBox(height: 40),
          //Texto: LINHA MÉDIA INFERIOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'INFERIOR:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _novoPedStore.getLinhaMediaInfState()
                      ? Colors.black
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          //Intrusão
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //Esquerdo - mover direita
              Container(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getLmInfRadioValue(null),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                              .getLinhaMediaInfState()) {
                                            _novoPedStore.setLmInfRadio(
                                              value,
                                              '_lmInfDireita',
                                            );
                                          }
                                        },
                                  value: 1,
                                ),
                                Text(
                                  'mover para a direita - Qts mm? ',
                                  style: TextStyle(
                                    color: _novoPedStore.getLinhaMediaInfState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 75,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          _novoPedStore
                                              .setLmInfDireitaMm(value);
                                        },
                                        textAlign: TextAlign.center,
                                        onSaved: (String value) {
                                          //sc.usernameCpf = value;
                                        },
                                        enabled: widget.blockUi
                                            ? !widget.blockUi
                                            : _novoPedStore
                                                    .getLinhaMediaInfState() &&
                                                _novoPedStore
                                                    .getLmInfDireitaState(),
                                        validator: (value) {
                                          if (value.length < 0) {
                                            return 'Não valido.';
                                          }
                                          return null;
                                        },
                                        maxLength: 5,
                                        controller: _cLmInfDireita,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[,0-9]')),
                                        ],
                                        decoration: const InputDecoration(
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //Direito - mover esquerda
              Container(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  activeColor: Colors.blue,
                                  groupValue:
                                      _novoPedStore.getLmInfRadioValue(null),
                                  onChanged: widget.blockUi
                                      ? null
                                      : (value) {
                                          _removeFocus(context);
                                          if (_novoPedStore
                                              .getLinhaMediaInfState()) {
                                            _novoPedStore.setLmInfRadio(
                                              value,
                                              '_lmInfEsquerda',
                                            );
                                          }
                                        },
                                  value: 2,
                                ),
                                Text(
                                  'mover para a esquerda - Qts mm? ',
                                  style: TextStyle(
                                    color: _novoPedStore.getLinhaMediaInfState()
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 75,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          _novoPedStore
                                              .setLmInfEsquerdaMm(value);
                                        },
                                        textAlign: TextAlign.center,
                                        onSaved: (String value) {
                                          //sc.usernameCpf = value;
                                        },
                                        enabled: widget.blockUi
                                            ? !widget.blockUi
                                            : _novoPedStore
                                                    .getLinhaMediaInfState() &&
                                                _novoPedStore
                                                    .getLmInfEsquerdaState(),
                                        validator: (value) {
                                          if (value.length < 0) {
                                            return 'Não valido.';
                                          }
                                          return null;
                                        },
                                        maxLength: 5,
                                        controller: _cLmInfEsquerda,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[,0-9]')),
                                        ],
                                        decoration: const InputDecoration(
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
                              ],
                            ),
                          ],
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
    );
  }
}
