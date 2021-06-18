import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/paciente_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/file_uploader.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PedidoV1Screen extends StatefulWidget {
  static const routeName = '/pedido-v1';

  @override
  _PedidoV1ScreenState createState() => _PedidoV1ScreenState();
}

class _PedidoV1ScreenState extends State<PedidoV1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;

  final _nomePacContr = TextEditingController();
  final _dataNascContr = TextEditingController();
  final _tratarContr = TextEditingController();

  final _linhaMediaSupContr = TextEditingController();
  final _linhaMediaInfContr = TextEditingController();
  final _overJetContr = TextEditingController();
  final _overbiteContr = TextEditingController();

  //ui
  double textSize = 18;
  bool mmLinhaMediaSupVis = false;
  bool mmLinhaMediaInfVis = false;
  bool mmOverbiteVis1 = false;
  bool mmOverbiteVis2 = false;
  bool mmOverbiteVis3 = false;
  bool mmOverbiteVis4 = false;

  String mmLinhaMediaGPOvalue = '';

  bool firstRun = true;

  PedidoV1Model _mapFieldsToPedidoV1() {
    try {
      PedidoV1Model p = PedidoV1Model(
        paciente: PacienteV1Model(
          nomePaciente: _nomePacContr.text,
          dataNascimento: _dataNascContr.text,
        ),
        tratar: _tratarContr.text,
        usuario: UsuarioV1Model(id: _authStore!.id),
      );

      return p;
    } catch (e) {
      print('mapFieldsToPedidoV1 ->' + e.toString());
      return PedidoV1Model();
    }
  }

  //manage ui states
  bool isSending = false;

  @override
  void dispose() {
    _nomePacContr.dispose();
    _dataNascContr.dispose();
    _tratarContr.dispose();
    super.dispose();
  }

  Widget _nomePaciente() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLength: 60,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        initialValue: _nomePacContr.text,
        onSaved: (value) {
          _nomePacContr.text = value ?? '';
        },
        onChanged: (value) {
          _nomePacContr.text = value;
        },
        decoration: const InputDecoration(
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Nome do Paciente *',
        ),
      ),
    );
  }

  Widget _dataNascimento() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: DateTimeField(
        onSaved: (DateTime? value) {
          _dataNascContr.text = value.toString();
        },
        validator: (value) {
          if (value == null) {
            return 'Por favor insira sua data de nascimento';
          }
          return null;
        },
        controller: _dataNascContr,
        decoration: const InputDecoration(
          labelText: 'Data de Nascimento: *',
          border: const OutlineInputBorder(),
        ),
        format: DateFormat("dd/MM/yyyy"),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              initialEntryMode: DatePickerEntryMode.input,
              locale: Localizations.localeOf(context),
              errorFormatText: 'Escolha data válida',
              errorInvalidText: 'Data invalida',
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
      ),
    );
  }

  Widget _tratar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: RadioListTile<String>(
              activeColor: Colors.blue,
              title: const Text('Ambos os arcos'),
              value: 'Ambos os arcos',
              groupValue: _tratarContr.text,
              onChanged: (String? value) {
                setState(() {
                  _tratarContr.text = value ?? '';
                });
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: RadioListTile<String>(
              activeColor: Colors.blue,
              title: const Text('Apenas o superior'),
              value: 'Apenas o superior',
              groupValue: _tratarContr.text,
              onChanged: (String? value) {
                setState(() {
                  _tratarContr.text = value ?? '';
                });
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: RadioListTile<String>(
              activeColor: Colors.blue,
              title: const Text('Apenas o inferior'),
              value: 'Apenas o inferior',
              groupValue: _tratarContr.text,
              onChanged: (String? value) {
                setState(() {
                  _tratarContr.text = value ?? '';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _queixaPrincipal() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLines: 4,
        maxLength: 455,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        //initialValue: _nomePacContr.text,
        onSaved: (value) {
          //_nomePacContr.text = value ?? '';
        },
        onChanged: (value) {
          //_nomePacContr.text = value;
        },
        decoration: const InputDecoration(
          hintText: 'Por favor descreva a queixa principal do paciente',
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Queixa principal: *',
        ),
      ),
    );
  }

  Widget _textoObjetivos() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Text(
        'Objetivos do tratamento',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _objetivosTratamento() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLines: 6,
        maxLength: 755,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        //initialValue: _nomePacContr.text,
        onSaved: (value) {
          //_nomePacContr.text = value ?? '';
        },
        onChanged: (value) {
          //_nomePacContr.text = value;
        },
        decoration: const InputDecoration(
          hintText:
              'Por favor descreva os seus objetivos de tratamento em cada uma das seguintes dimensões: \n\n• SAGITAL \n• TRANSVERSAL \n• VERTICAL \n• DENTES',
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Objetivos do tratamento: *',
        ),
      ),
    );
  }

  Widget _linhaMediSuperior() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              'Linha média superior: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Manter'),
                  value: 'Manter',
                  groupValue: _linhaMediaSupContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaGPOvalue = '';
                      mmLinhaMediaSupVis = false;
                      _linhaMediaSupContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Mover para direita'),
                  value: 'Mover para direita',
                  groupValue: _linhaMediaSupContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaGPOvalue = '';
                      mmLinhaMediaSupVis = false;
                      _linhaMediaSupContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Mover para esquerda'),
                  value: 'Mover para esquerda',
                  groupValue: _linhaMediaSupContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaGPOvalue = '';
                      mmLinhaMediaSupVis = false;
                      _linhaMediaSupContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Qnt? (mm)'),
                  value: '0',
                  groupValue: mmLinhaMediaGPOvalue,
                  onChanged: (String? value) {
                    setState(() {
                      _linhaMediaSupContr.text = '';
                      mmLinhaMediaGPOvalue = value ?? '';
                      mmLinhaMediaSupVis = true;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmLinhaMediaSupVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _linhaMediaSupContr.text = value ?? '';
                    },
                    controller: _linhaMediaSupContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _linhaMediInferior() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              'Linha média superior: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Manter'),
                  value: 'Manter',
                  groupValue: _linhaMediaInfContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaInfVis = false;
                      _linhaMediaInfContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Mover para direita'),
                  value: 'Mover para direita',
                  groupValue: _linhaMediaInfContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaInfVis = false;
                      _linhaMediaInfContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Mover para esquerda'),
                  value: 'Mover para esquerda',
                  groupValue: _linhaMediaInfContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaInfVis = false;
                      _linhaMediaInfContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Qnt? (mm)'),
                  value: '0',
                  groupValue: _linhaMediaInfContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _linhaMediaInfContr.text = '0';
                      mmLinhaMediaInfVis = true;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmLinhaMediaInfVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      //_nomePacContr.text = value ?? '';
                    },
                    onChanged: (value) {
                      //_nomePacContr.text = value;
                    },
                    controller: _linhaMediaInfContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _overJet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 367,
            child: Text(
              'Overjet: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Manter'),
                  value: 'Manter',
                  groupValue: _overJetContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overJetContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Melhorar'),
                  value: 'Melhorar',
                  groupValue: _overJetContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overJetContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Corrigir'),
                  value: 'Corrigir',
                  groupValue: _overJetContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overJetContr.text = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _overBite() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              'Overbite: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Manter'),
                  value: 'Manter',
                  groupValue: _overbiteContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmOverbiteVis1 = false;
                      mmOverbiteVis2 = false;
                      mmOverbiteVis3 = false;
                      mmOverbiteVis4 = false;
                      _overbiteContr.text = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Intruir anterior sup'),
                  value: '0',
                  groupValue: _overbiteContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overbiteContr.text = value ?? '';
                      mmOverbiteVis1 = true;
                      mmOverbiteVis2 = false;
                      mmOverbiteVis3 = false;
                      mmOverbiteVis4 = false;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmOverbiteVis1,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      //_nomePacContr.text = value ?? '';
                    },
                    onChanged: (value) {
                      //_nomePacContr.text = value;
                    },
                    controller: _overbiteContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Intruir anterior inf'),
                  value: '2',
                  groupValue: _overbiteContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overbiteContr.text = value ?? '';
                      mmOverbiteVis1 = false;
                      mmOverbiteVis2 = true;
                      mmOverbiteVis3 = false;
                      mmOverbiteVis4 = false;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmOverbiteVis2,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      //_nomePacContr.text = value ?? '';
                    },
                    onChanged: (value) {
                      //_nomePacContr.text = value;
                    },
                    controller: _overbiteContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Extruir posterior sup'),
                  value: '3',
                  groupValue: _overbiteContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overbiteContr.text = value ?? '';
                      mmOverbiteVis1 = false;
                      mmOverbiteVis2 = false;
                      mmOverbiteVis3 = true;
                      mmOverbiteVis4 = false;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmOverbiteVis3,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      //_nomePacContr.text = value ?? '';
                    },
                    onChanged: (value) {
                      //_nomePacContr.text = value;
                    },
                    controller: _overbiteContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Extruir posterior inf'),
                  value: '4',
                  groupValue: _overbiteContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      _overbiteContr.text = value ?? '';
                      mmOverbiteVis1 = false;
                      mmOverbiteVis2 = false;
                      mmOverbiteVis3 = false;
                      mmOverbiteVis4 = true;
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmOverbiteVis4,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      /*
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      //_nomePacContr.text = value ?? '';
                    },
                    onChanged: (value) {
                      //_nomePacContr.text = value;
                    },
                    controller: _overbiteContr,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'mm',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'mm',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _textoResApin() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Text(
        'Resolução de apinhamento (múltipla escolha)',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _resApinhSup() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 390,
            child: Text(
              'Superior: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GroupButton(
                selectedColor: Colors.blue,
                isRadio: false,
                spacing: 10,
                onSelected: (index, isSelected) {
                  print(isSelected);
                },
                buttons: [
                  'DIP (Desgaste Interproximal)',
                  'Distalização sequencial',
                  'Expansão (posterior)',
                  'Inclinação anteriores',
                ],
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _resApinhInf() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            width: 390,
            child: Text(
              'Inferior: *',
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GroupButton(
                selectedColor: Colors.blue,
                isRadio: false,
                spacing: 10,
                onSelected: (index, isSelected) {
                  print(isSelected);
                },
                buttons: [
                  'DIP (Desgaste Interproximal)',
                  'Distalização sequencial',
                  'Expansão (posterior)',
                  'Inclinação anteriores',
                ],
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _extraVirtDentesTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Realizar extração virtual dos seguintes dentes',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _extraVirtDentes() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '18',
              '17',
              '16',
              '15',
              '14',
              '13',
              '12',
              '11',
              '21',
              '22',
              '23',
              '24',
              '25',
              '26',
              '27',
              '28',
            ],
          ),
          const SizedBox(height: 100),
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '48',
              '47',
              '46',
              '45',
              '44',
              '43',
              '42',
              '41',
              '31',
              '32',
              '33',
              '34',
              '35',
              '36',
              '37',
              '38',
            ],
          )
        ],
      ),
    );
  }

  Widget _naoMovElemTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Não movimentar os seguintes elementos',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _naoMovElem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '18',
              '17',
              '16',
              '15',
              '14',
              '13',
              '12',
              '11',
              '21',
              '22',
              '23',
              '24',
              '25',
              '26',
              '27',
              '28',
            ],
          ),
          const SizedBox(height: 100),
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '48',
              '47',
              '46',
              '45',
              '44',
              '43',
              '42',
              '41',
              '31',
              '32',
              '33',
              '34',
              '35',
              '36',
              '37',
              '38',
            ],
          )
        ],
      ),
    );
  }

  Widget _naoColocarAttachTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Não colocar attachments nos seguintes elementos (coroas, implantes, etc)',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _naoColocarAttach() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '18',
              '17',
              '16',
              '15',
              '14',
              '13',
              '12',
              '11',
              '21',
              '22',
              '23',
              '24',
              '25',
              '26',
              '27',
              '28',
            ],
          ),
          const SizedBox(height: 100),
          GroupButton(
            buttonHeight: 35,
            buttonWidth: 35,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              print(isSelected);
            },
            buttons: [
              '48',
              '47',
              '46',
              '45',
              '44',
              '43',
              '42',
              '41',
              '31',
              '32',
              '33',
              '34',
              '35',
              '36',
              '37',
              '38',
            ],
          )
        ],
      ),
    );
  }

  Widget _opcionais() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GroupButton(
                    selectedColor: Colors.blue,
                    isRadio: false,
                    spacing: 10,
                    onSelected: (index, isSelected) {
                      print(isSelected);
                    },
                    buttons: [
                      'Aceito desgastes interproximais (DIP)',
                    ],
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    child: Row(
                      children: [
                        GroupButton(
                          selectedColor: Colors.blue,
                          isRadio: false,
                          spacing: 10,
                          onSelected: (index, isSelected) {
                            print(isSelected);
                          },
                          buttons: [
                            'Recorte para elástico no alinhador (especificar dente)',
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: SizedBox(
                            height: 40,
                            width: 80,
                            child: TextFormField(
                              maxLength: 5,
                              enabled: true,
                              validator: (String? value) {
                                /*
                            return value == null || value.isEmpty
                                ? 'Campo vazio'
                                : null;*/
                              },
                              //initialValue: _nomePacContr.text,
                              onSaved: (value) {
                                //_nomePacContr.text = value ?? '';
                              },
                              onChanged: (value) {
                                //_nomePacContr.text = value;
                              },
                              controller: _overbiteContr,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[,0-9]')),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'mm',
                                border: const OutlineInputBorder(),
                                counterText: '',
                                labelText: 'mm',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    child: Row(
                      children: [
                        GroupButton(
                          selectedColor: Colors.blue,
                          isRadio: false,
                          spacing: 10,
                          onSelected: (index, isSelected) {
                            print(isSelected);
                          },
                          buttons: [
                            'Recorte para elástico no alinhador (especificar dente)',
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: SizedBox(
                            height: 40,
                            width: 80,
                            child: TextFormField(
                              maxLength: 5,
                              enabled: true,
                              validator: (String? value) {
                                /*
                            return value == null || value.isEmpty
                                ? 'Campo vazio'
                                : null;*/
                              },
                              //initialValue: _nomePacContr.text,
                              onSaved: (value) {
                                //_nomePacContr.text = value ?? '';
                              },
                              onChanged: (value) {
                                //_nomePacContr.text = value;
                              },
                              controller: _overbiteContr,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[,0-9]')),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'mm',
                                border: const OutlineInputBorder(),
                                counterText: '',
                                labelText: 'mm',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    child: Row(
                      children: [
                        GroupButton(
                          selectedColor: Colors.blue,
                          isRadio: false,
                          spacing: 10,
                          onSelected: (index, isSelected) {
                            print(isSelected);
                          },
                          buttons: [
                            'Alívio no alinhador para braço de força ()',
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: SizedBox(
                            height: 40,
                            width: 80,
                            child: TextFormField(
                              maxLength: 5,
                              enabled: true,
                              validator: (String? value) {
                                /*
                            return value == null || value.isEmpty
                                ? 'Campo vazio'
                                : null;*/
                              },
                              //initialValue: _nomePacContr.text,
                              onSaved: (value) {
                                //_nomePacContr.text = value ?? '';
                              },
                              onChanged: (value) {
                                //_nomePacContr.text = value;
                              },
                              controller: _overbiteContr,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[,0-9]')),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'mm',
                                border: const OutlineInputBorder(),
                                counterText: '',
                                labelText: 'mm',
                              ),
                            ),
                          ),
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
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _nomePaciente(),
          _dataNascimento(),
          _tratar(),
          _queixaPrincipal(),
          _textoObjetivos(),
          _objetivosTratamento(),
          _linhaMediSuperior(),
          _linhaMediInferior(),
          _overJet(),
          _overBite(),
          _textoResApin(),
          _resApinhSup(),
          _resApinhInf(),
          _extraVirtDentesTexto(),
          _extraVirtDentes(),
          _naoMovElemTexto(),
          _naoMovElem(),
          _naoColocarAttachTexto(),
          _naoColocarAttach(),
          _opcionais()
        ],
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Novo paciente',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Widget _carregarArquivos() {
    return Column(
      children: <Widget>[
        FileUploader(
          filesQt: 16,
          acceptedFileExt: ['jpg', 'jpeg', 'png'],
          sendButtonText: 'CARREGAR FOTOGRAFIAS',
          firstPedidoSaveToProvider: true,
        ),
        FileUploader(
          filesQt: 1,
          acceptedFileExt: ['stl'],
          sendButtonText: 'CARREGAR MODELO SUPERIOR',
          firstPedidoSaveToProvider: true,
        ),
      ],
    );
  }

  ScaffoldFeatureController _msgPacienteCriado() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          'Paciente criado com sucesso',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _sendButton() {
    return ElevatedButton(
      onPressed: isSending
          ? null
          : () async {
              setState(() {
                isSending = true;
              });

              PedidoV1Model p = _mapFieldsToPedidoV1();
              bool result = await _pedidoStore!.enviarPrimeiroPedido(
                p,
                _authStore!.token,
              );
              if (result) {
                _msgPacienteCriado();
              }
              setState(() {
                isSending = false;
              });
            },
      child: Text(
        isSending ? 'aguarde...' : 'Enviar',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    if (firstRun) {
      _pedidoStore!.clearDataOnRouteChange();
      firstRun = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore!.isAuth) {
      return LoginScreen();
    }
    return Scaffold(
      appBar: MyAppBar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: _screenSize!.width < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: 3000,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _form(),
                _carregarArquivos(),
                _sendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
