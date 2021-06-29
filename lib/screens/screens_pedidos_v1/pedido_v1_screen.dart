import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pacientes_v1.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/status_pedidov1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/file_uploader.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../rotas_url.dart';

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

  // pedido type (for post request)
  String tipoPedido = 'pedido';
  //id pedido
  int _id = 0;
  //dados paciente
  final _nomePacContr = TextEditingController();
  final _dataNascContr = TextEditingController();
  //queixa e obj
  final _queixaPrincipal = TextEditingController();
  final _tratarContr = TextEditingController();
  final _objContr = TextEditingController();
  //linha media
  final _linhaMediaSupContr = TextEditingController();
  final _linhaMediaSupMMContr = TextEditingController();
  //supcontr + sup mm on send
  String _linhaMediaSupComplete = '';

  final _linhaMediaInfContr = TextEditingController();
  final _linhaMediaInfMMContr = TextEditingController();
  //infcontr + inf mm on send
  String _linhaMediaInfComplete = '';
  //overjet
  final _overJetContr = TextEditingController();
  //overbite
  final _overbiteContr = TextEditingController();
  //just for init
  String _overbiteInit1 = '';
  String _overbiteInit2 = '';
  String _overbiteInit3 = '';
  String _overbiteInit4 = '';
  //overbitecont + mm
  String _overbiteComplete = '';
  //res apinh
  final List<String> resApinUiList = const [
    'DIP (Desgaste Interproximal)',
    'Distalização sequencial',
    'Expansão (posterior)',
    'Inclinação anteriores',
  ];
  List<int> resApinSupUiSelectedPos = [];
  List<int> resApinInfUiSelectedPos = [];
  final _resApinSupContr = TextEditingController();
  final _resApinInfContr = TextEditingController();
  //dentes geral
  final List<String> dentesUiList = const [
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
  ];
  //dentes -> extração virtual
  List<int> extracaoVirtualUiSelectedPos = [];
  final _extracaoVirtualContr = TextEditingController();
  //dentes -> não movimentar seguintes elementos
  List<int> naoMovimentarUiSelectedPos = [];
  final _naoMovimentarContr = TextEditingController();
  //dentes -> não colocar attachments
  List<int> naoColocarAttachUiSelectedPos = [];
  final _naoColocarAttachContr = TextEditingController();
  //opcionais
  final _opcAceitoDip = TextEditingController();
  int _opcAceitoDipSelected = -1;
  final _opcRecorteElastico = TextEditingController();
  int _opcRecorteElasticoSelected = -1;
  bool _opcRecorteElasticoMm = false;
  final _opcRecorteBotao = TextEditingController();
  int _opcRecorteBotaoSelected = -1;
  bool _opcRecorteBotaoMm = false;
  final _opcBracoForca = TextEditingController();
  int _opcBracoForcaSelected = -1;
  bool _opcBracoForcaMm = false;
  //link para documentação
  final _linkDocumentacao = TextEditingController();
  //endereco selecionado
  List<EnderecoModel> eModel = [];
  EnderecoModel enderecoSelecionado = EnderecoModel();
  //termos
  String termos = '';
  //status pedido (id = 1 for new pedidos)
  int statusPedido = 1;
  List<StatusPedidoV1Model> sModel = [];
  StatusPedidoV1Model _selectedStatus = StatusPedidoV1Model();
  //pedido of type refinamento
  bool _isPedidoRefinamento = false;
  //payload
  Map<String, dynamic> _payload = Map();

  //ui
  bool _nomePacienteEnabled = true;
  bool _dataNascimentoEnabled = true;

  double textSize = 18;
  bool mmDirLinhaMediaSupVis = false;
  bool mmEsqLinhaMediaSupVis = false;
  bool mmDirLinhaMediaInfVis = false;
  bool mmEsqLinhaMediaInfVis = false;
  bool mmOverbiteVis1 = false;
  bool mmOverbiteVis2 = false;
  bool mmOverbiteVis3 = false;
  bool mmOverbiteVis4 = false;
  bool modeloEmGesso = false;

  String mmLinhaMediaGPOvalue = '';

  bool firstRun = true;

  ScreenArguments _args = ScreenArguments();

  // OBS: FOR UPDATE PEDIDO, FILE UPLOAD WIDGET
  bool _firstPedidoSaveToProvider = true;
  bool _isEditarPedido = false;
  int _isEditarPedidoPos = -1;

  PedidoV1Model _mapFieldsToPedidoV1() {
    try {
      PedidoV1Model p = PedidoV1Model(
        id: _id,
        nomePaciente: _nomePacContr.text,
        dataNascimento: _dataNascContr.text,
        tratar: _tratarContr.text,
        queixaPrincipal: _queixaPrincipal.text,
        objetivosTratamento: _objContr.text,
        linhaMediaSuperior: _linhaMediaSupComplete,
        linhaMediaInferior: _linhaMediaInfComplete,
        overjet: _overJetContr.text,
        overbite: _overbiteComplete,
        resApinSup: _resApinSupContr.text,
        resApinInf: _resApinInfContr.text,
        dentesExtVirtual: _extracaoVirtualContr.text,
        dentesNaoMov: _naoMovimentarContr.text,
        dentesSemAttach: _naoColocarAttachContr.text,
        opcAceitoDesg: _opcAceitoDip.text,
        opcRecorteElas: _opcRecorteElastico.text,
        opcRecorteAlin: _opcRecorteBotao.text,
        opcAlivioAlin: _opcBracoForca.text,
        modeloGesso: modeloEmGesso,
        linkModelos: _linkDocumentacao.text,
        enderecoEntrega: enderecoSelecionado,
        usuario: UsuarioV1Model(id: _authStore!.id),
        statusPedido: StatusPedidoV1Model(id: statusPedido),
        pedidoRefinamento: _isPedidoRefinamento,
        payload: _payload,
      );

      return p;
    } catch (e) {
      print('mapFieldsToPedidoV1 ->' + e.toString());
      return PedidoV1Model();
    }
  }

  String _mapIntListToString(
    List<int> selectedIntList,
    List<String> uiStringList,
  ) {
    String s = '';
    for (int i = 0; i < selectedIntList.length; i++) {
      if (i == selectedIntList.length - 1) {
        s += uiStringList[selectedIntList[i]];
      } else {
        s += uiStringList[selectedIntList[i]] + ', ';
      }
    }
    return s;
  }

  List<int> _mapStringToSelectedIntList(String s, List<String> uiStringList) {
    List<int> mappedIntValues = [];

    List<String> formatedString = s.split(', ');

    for (int i = 0; i < uiStringList.length; i++) {
      for (int j = 0; j < formatedString.length; j++) {
        if (formatedString[j] == uiStringList[i]) {
          mappedIntValues.add(i);
        }
      }
    }
    return mappedIntValues;
  }

  //manage ui states
  bool isSending = false;

  @override
  void dispose() {
    _nomePacContr.dispose();
    _dataNascContr.dispose();
    _queixaPrincipal.dispose();
    _tratarContr.dispose();
    _linhaMediaSupContr.dispose();
    _linhaMediaSupMMContr.dispose();
    _linhaMediaInfContr.dispose();
    _linhaMediaInfMMContr.dispose();
    _overJetContr.dispose();
    _overbiteContr.dispose();
    _resApinSupContr.dispose();
    _resApinInfContr.dispose();
    _extracaoVirtualContr.dispose();
    _naoMovimentarContr.dispose();
    _naoColocarAttachContr.dispose();
    _opcAceitoDip.dispose();
    _opcRecorteElastico.dispose();
    _opcRecorteBotao.dispose();
    _opcBracoForca.dispose();
    _linkDocumentacao.dispose();
    _objContr.dispose();
    super.dispose();
  }

  Widget _nomePaciente() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLength: 60,
        enabled: _nomePacienteEnabled,
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
        enabled: _dataNascimentoEnabled,
        initialValue: DateTime.tryParse(_dataNascContr.text),
        onSaved: (DateTime? value) {
          _dataNascContr.text = value.toString();
        },
        onChanged: (value) {
          if (value != null) {
            _dataNascContr.text = value.toString();
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Por favor insira sua data de nascimento';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Data de Nascimento: *',
          border: const OutlineInputBorder(),
        ),
        format: DateFormat('dd/MM/yyyy'),
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

  Widget _queixaPrinc() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        initialValue: _queixaPrincipal.text,
        maxLines: 4,
        maxLength: 455,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        //initialValue: _nomePacContr.text,
        onSaved: (value) {
          _queixaPrincipal.text = value ?? '';
        },
        onChanged: (value) {
          _queixaPrincipal.text = value;
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
        initialValue: _objContr.text,
        maxLines: 6,
        maxLength: 755,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        //initialValue: _nomePacContr.text,
        onSaved: (value) {
          _objContr.text = value ?? '';
        },
        onChanged: (value) {
          _objContr.text = value;
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
            width: 265,
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
                      _linhaMediaSupComplete = value ?? '';
                      mmLinhaMediaGPOvalue = '';
                      mmDirLinhaMediaSupVis = false;
                      mmEsqLinhaMediaSupVis = false;
                      _linhaMediaSupContr.text = value ?? '';
                      _linhaMediaSupMMContr.text = '';
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
                      mmDirLinhaMediaSupVis = true;
                      mmEsqLinhaMediaSupVis = false;
                      _linhaMediaSupContr.text = value ?? '';
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmDirLinhaMediaSupVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: mmDirLinhaMediaSupVis,
                    validator: (String? value) {
                      if (!mmDirLinhaMediaSupVis) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _linhaMediaSupComplete =
                          _linhaMediaSupContr.text + ': ' + (value ?? '');
                    },
                    controller: _linhaMediaSupMMContr,
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
                  title: const Text('Mover para esquerda'),
                  value: 'Mover para esquerda',
                  groupValue: _linhaMediaSupContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmLinhaMediaGPOvalue = '';
                      mmDirLinhaMediaSupVis = false;
                      mmEsqLinhaMediaSupVis = true;
                      _linhaMediaSupContr.text = value ?? '';
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmEsqLinhaMediaSupVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: mmEsqLinhaMediaSupVis,
                    validator: (String? value) {
                      if (!mmEsqLinhaMediaSupVis) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _linhaMediaSupComplete =
                          _linhaMediaSupContr.text + ': ' + (value ?? '');
                    },
                    controller: _linhaMediaSupMMContr,
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
            width: 265,
            child: Text(
              'Linha média inferior: *',
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
                      _linhaMediaInfComplete = value ?? '';
                      mmDirLinhaMediaInfVis = false;
                      mmEsqLinhaMediaInfVis = false;
                      _linhaMediaInfContr.text = value ?? '';
                      _linhaMediaInfMMContr.text = '';
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
                      mmDirLinhaMediaInfVis = true;
                      mmEsqLinhaMediaInfVis = false;
                      _linhaMediaInfContr.text = value ?? '';
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmDirLinhaMediaInfVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: mmDirLinhaMediaInfVis,
                    validator: (String? value) {
                      if (!mmDirLinhaMediaInfVis) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _linhaMediaInfComplete =
                          _linhaMediaInfContr.text + ': ' + (value ?? '');
                    },
                    controller: _linhaMediaInfMMContr,
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
                  title: const Text('Mover para esquerda'),
                  value: 'Mover para esquerda',
                  groupValue: _linhaMediaInfContr.text,
                  onChanged: (String? value) {
                    setState(() {
                      mmDirLinhaMediaInfVis = false;
                      mmEsqLinhaMediaInfVis = true;
                      _linhaMediaInfContr.text = value ?? '';
                    });
                  },
                ),
              ),
              Visibility(
                visible: mmEsqLinhaMediaInfVis,
                child: SizedBox(
                  width: 80,
                  child: TextFormField(
                    maxLength: 5,
                    enabled: mmEsqLinhaMediaInfVis,
                    validator: (String? value) {
                      if (!mmEsqLinhaMediaInfVis) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _linhaMediaInfComplete =
                          _linhaMediaInfContr.text + ': ' + (value ?? '');
                    },
                    controller: _linhaMediaInfMMContr,
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
        ],
      ),
    );
  }

  Widget _overJet() {
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
              SizedBox(
                width: 80,
              )
            ],
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
                      _overbiteComplete = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: RadioListTile<String>(
                  activeColor: Colors.blue,
                  title: const Text('Intruir anterior sup'),
                  value: 'Intruir anterior sup',
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
                    initialValue: _overbiteInit1,
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      if (!mmOverbiteVis1) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      if (value != null)
                        _overbiteComplete = 'Intruir anterior sup: ' + value;
                    },
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
                  value: 'Intruir anterior inf',
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
                    initialValue: _overbiteInit2,
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      if (!mmOverbiteVis2) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      if (value != null)
                        _overbiteComplete = 'Intruir anterior inf: ' + value;
                    },
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
                  value: 'Extruir posterior sup',
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
                    initialValue: _overbiteInit3,
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      if (!mmOverbiteVis3) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      if (value != null)
                        _overbiteComplete = 'Extruir posterior sup: ' + value;
                    },
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
                  value: 'Extruir posterior inf',
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
                    initialValue: _overbiteInit4,
                    maxLength: 5,
                    enabled: true,
                    validator: (String? value) {
                      if (!mmOverbiteVis4) return null;
                      return value == null || value.isEmpty
                          ? 'Campo vazio'
                          : null;
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      if (value != null)
                        _overbiteComplete = 'Extruir posterior inf: ' + value;
                    },

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
          GroupButton(
            selectedButtons: resApinSupUiSelectedPos,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              if (isSelected) {
                resApinSupUiSelectedPos.add(index);
                _resApinSupContr.text = _mapIntListToString(
                  resApinSupUiSelectedPos,
                  resApinUiList,
                );
              } else {
                resApinSupUiSelectedPos.remove(index);
                _resApinSupContr.text = _mapIntListToString(
                  resApinSupUiSelectedPos,
                  resApinUiList,
                );
              }
            },
            buttons: resApinUiList,
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
          GroupButton(
            selectedButtons: resApinInfUiSelectedPos,
            selectedColor: Colors.blue,
            isRadio: false,
            spacing: 10,
            onSelected: (index, isSelected) {
              if (isSelected) {
                resApinInfUiSelectedPos.add(index);
                _resApinInfContr.text = _mapIntListToString(
                  resApinInfUiSelectedPos,
                  resApinUiList,
                );
              } else {
                resApinInfUiSelectedPos.remove(index);
                _resApinInfContr.text = _mapIntListToString(
                  resApinInfUiSelectedPos,
                  resApinUiList,
                );
              }
            },
            buttons: resApinUiList,
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
      child: GroupButton(
        selectedButtons: extracaoVirtualUiSelectedPos,
        buttonHeight: 35,
        buttonWidth: 35,
        selectedColor: Colors.blue,
        isRadio: false,
        spacing: 10,
        onSelected: (index, isSelected) {
          if (isSelected) {
            extracaoVirtualUiSelectedPos.add(index);
            _extracaoVirtualContr.text = _mapIntListToString(
              extracaoVirtualUiSelectedPos,
              dentesUiList,
            );
          } else {
            extracaoVirtualUiSelectedPos.remove(index);
            _extracaoVirtualContr.text = _mapIntListToString(
              extracaoVirtualUiSelectedPos,
              dentesUiList,
            );
          }
        },
        buttons: dentesUiList,
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
      child: GroupButton(
        selectedButtons: naoMovimentarUiSelectedPos,
        buttonHeight: 35,
        buttonWidth: 35,
        selectedColor: Colors.blue,
        isRadio: false,
        spacing: 10,
        onSelected: (index, isSelected) {
          if (isSelected) {
            naoMovimentarUiSelectedPos.add(index);
            _naoMovimentarContr.text = _mapIntListToString(
              naoMovimentarUiSelectedPos,
              dentesUiList,
            );
          } else {
            naoMovimentarUiSelectedPos.remove(index);
            _naoMovimentarContr.text = _mapIntListToString(
              naoMovimentarUiSelectedPos,
              dentesUiList,
            );
          }
        },
        buttons: dentesUiList,
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
      child: GroupButton(
        selectedButtons: naoColocarAttachUiSelectedPos,
        buttonHeight: 35,
        buttonWidth: 35,
        selectedColor: Colors.blue,
        isRadio: false,
        spacing: 10,
        onSelected: (index, isSelected) {
          if (isSelected) {
            naoColocarAttachUiSelectedPos.add(index);
            _naoColocarAttachContr.text = _mapIntListToString(
              naoColocarAttachUiSelectedPos,
              dentesUiList,
            );
          } else {
            naoColocarAttachUiSelectedPos.remove(index);
            _naoColocarAttachContr.text = _mapIntListToString(
              naoColocarAttachUiSelectedPos,
              dentesUiList,
            );
          }
        },
        buttons: dentesUiList,
      ),
    );
  }

  Widget _opcionaisTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Opcionais',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _opcionais() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 500,
            child: GroupButton(
              selectedButtons: [_opcAceitoDipSelected],
              selectedColor: Colors.blue,
              isRadio: false,
              spacing: 10,
              onSelected: (index, isSelected) {
                if (isSelected) {
                  _opcAceitoDip.text = 'Aceito desgastes interproximais (DIP)';
                } else {
                  _opcAceitoDip.text = '';
                }
              },
              buttons: [
                'Aceito desgastes interproximais (DIP)',
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 500,
            child: Wrap(
              children: [
                GroupButton(
                  selectedButtons: [_opcRecorteElasticoSelected],
                  selectedColor: Colors.blue,
                  isRadio: false,
                  spacing: 10,
                  onSelected: (index, isSelected) {
                    setState(() {
                      _opcRecorteElasticoMm = !_opcRecorteElasticoMm;
                      _opcRecorteElastico.text = '';
                    });
                  },
                  buttons: [
                    'Recorte para elástico no alinhador (especificar dente)',
                  ],
                ),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: TextFormField(
                    maxLength: 11,
                    enabled: _opcRecorteElasticoMm,
                    validator: (String? value) {
                      /*
                  return value == null || value.isEmpty
                      ? 'Campo vazio'
                      : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _opcRecorteElastico.text = value ?? '';
                    },
                    controller: _opcRecorteElastico,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '18,17,16,15',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'Dentes',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 500,
            child: Wrap(
              children: [
                GroupButton(
                  selectedButtons: [_opcRecorteBotaoSelected],
                  selectedColor: Colors.blue,
                  isRadio: false,
                  spacing: 10,
                  onSelected: (index, isSelected) {
                    setState(() {
                      _opcRecorteBotaoMm = !_opcRecorteBotaoMm;
                      _opcRecorteBotao.text = '';
                    });
                  },
                  buttons: [
                    'Recorte no alinhador para botão (especificar dente)',
                  ],
                ),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: TextFormField(
                    maxLength: 11,
                    enabled: _opcRecorteBotaoMm,
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
                    controller: _opcRecorteBotao,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '18,17,16,15',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'Dentes',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 500,
            child: Wrap(
              children: [
                GroupButton(
                  selectedButtons: [_opcBracoForcaSelected],
                  selectedColor: Colors.blue,
                  isRadio: false,
                  spacing: 10,
                  onSelected: (index, isSelected) {
                    setState(() {
                      _opcBracoForcaMm = !_opcBracoForcaMm;
                      _opcBracoForca.text = '';
                    });
                  },
                  buttons: [
                    'Alívio no alinhador para braço de força (especificar dente)',
                  ],
                ),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: TextFormField(
                    maxLength: 11,
                    enabled: _opcBracoForcaMm,
                    validator: (String? value) {
                      /*
                    return value == null || value.isEmpty
                  ? 'Campo vazio'
                  : null;*/
                    },
                    //initialValue: _nomePacContr.text,
                    onSaved: (value) {
                      _opcBracoForca.text = value ?? '';
                    },
                    controller: _opcBracoForca,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[,0-9]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '18,17,16,15',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      labelText: 'Dentes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carregarModelosDigitaisTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Modelos digitais',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _formatoDeModelos() {
    bool block = true;
    double opac = 1;
    if (_args.messageMap!.containsKey('isEditarPaciente')) {
      if (_args.messageMap!['isEditarPaciente']) {
        block = false;
        opac = 0.4;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AbsorbPointer(
        absorbing: !block,
        child: Opacity(
          opacity: opac,
          child: GroupButton(
            selectedColor: Colors.blue,
            selectedButton: modeloEmGesso ? 1 : 0,
            isRadio: true,
            spacing: 10,
            onSelected: (index, isSelected) {
              if (isSelected && index == 1) {
                setState(() {
                  modeloEmGesso = true;
                });
              } else {
                setState(() {
                  modeloEmGesso = false;
                });
              }
            },
            buttons: [
              'Digital (em arquivos .stl',
              'Gesso (gesso em pedra tipo IV)'
            ],
          ),
        ),
      ),
    );
  }

  Widget _modelosDigitais() {
    int updatePedidoId = -1;
    if (_isEditarPedido) {
      updatePedidoId = _pedidoStore!.getPedido(position: _args.messageInt).id;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          FileUploader(
            filesQt: 1,
            acceptedFileExt: ['stl'],
            sendButtonText: 'CARREGAR MODELO SUPERIOR',
            firstPedidoSaveToProvider: true,
            uploaderType: 'modelo superior',
            isEditarPedido: _isEditarPedido,
            isEditarPedidoPos: _isEditarPedidoPos,
            updatePedidoId: updatePedidoId,
          ),
          const SizedBox(height: 20),
          FileUploader(
            filesQt: 1,
            acceptedFileExt: ['stl'],
            sendButtonText: 'CARREGAR MODELO INFERIOR',
            firstPedidoSaveToProvider: true,
            uploaderType: 'modelo inferior',
            isEditarPedido: _isEditarPedido,
            isEditarPedidoPos: _isEditarPedidoPos,
            updatePedidoId: updatePedidoId,
          ),
          _linkDoc(),
        ],
      ),
    );
  }

  Widget _modeloCompactado() {
    int updatePedidoId = -1;
    if (_isEditarPedido) {
      updatePedidoId = _pedidoStore!.getPedido(position: _args.messageInt).id;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          FileUploader(
            filesQt: 1,
            acceptedFileExt: ['zip', 'rar'],
            sendButtonText: 'CARREGAR COMPACTADO',
            uploaderType: 'modelo compactado',
            firstPedidoSaveToProvider: _firstPedidoSaveToProvider,
            isEditarPedido: _isEditarPedido,
            isEditarPedidoPos: _isEditarPedidoPos,
            updatePedidoId: updatePedidoId,
          ),
        ],
      ),
    );
  }

  Widget _carregarFotografiasTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Fotografias',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _carregarFotografias() {
    int updatePedidoId = -1;
    if (_isEditarPedido) {
      updatePedidoId = _pedidoStore!.getPedido(position: _args.messageInt).id;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FileUploader(
        filesQt: 16,
        acceptedFileExt: ['jpg', 'jpeg', 'png'],
        sendButtonText: 'CARREGAR FOTOGRAFIAS',
        firstPedidoSaveToProvider: _firstPedidoSaveToProvider,
        uploaderType: 'fotografias',
        isEditarPedido: _isEditarPedido,
        isEditarPedidoPos: _isEditarPedidoPos,
        updatePedidoId: updatePedidoId,
      ),
    );
  }

  Widget _carregarRadiografiasTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Radiografias',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _carregarRadiografias() {
    int updatePedidoId = -1;
    if (_isEditarPedido) {
      updatePedidoId = _pedidoStore!.getPedido(position: _args.messageInt).id;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FileUploader(
        filesQt: 16,
        acceptedFileExt: ['jpg', 'jpeg', 'png'],
        sendButtonText: 'CARREGAR RADIOGRAFIAS',
        uploaderType: 'radiografias',
        firstPedidoSaveToProvider: _firstPedidoSaveToProvider,
        isEditarPedido: _isEditarPedido,
        isEditarPedidoPos: _isEditarPedidoPos,
        updatePedidoId: updatePedidoId,
      ),
    );
  }

  Widget _modeloEmGessoTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        '• AVISO PARA MODELOS EM GESSO: \n• Os modelos de gesso enviados devem ser feitos com Gesso pedra tipo IV, sempre superior e inferior.Deve ser enviado o registro de oclusão do paciente juntamente com os modelos em gesso. Devem estar bem embalados, para evitar a quebra.Se possível, a base do modelo deve vir recortada. Enviar com as informações referentes ao paciente (nome, data de nascimento e dentista responsável pelo caso). *Os casos que não seguirem essas recomendações não serão *O prazo para planejamento só será contado a partir do recebimento da documentação completa (fotos, radiografia e a prescrição do pedido devem ser enviados via plataforma Digital Aligner \n• Favor enviar os modelos em gesso para o escaneamento no endereço abaixo: UPDENTALL TECNOLOGIA EM ODONTOLOGIA LTDA. Rua das Pernambucanas, 407, sala 1305 Graças 52011 010 Recife, PE',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _manageModelType() {
    if (modeloEmGesso) {
      return _modeloEmGessoTexto();
    } else {
      return _modelosDigitais();
    }
  }

  Widget _linkDoc() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLength: 255,
        enabled: !_isEditarPedidoCheck(),
        validator: (String? value) {},
        initialValue: _linkDocumentacao.text,
        onChanged: (value) {
          _linkDocumentacao.text = value;
        },
        onSaved: (value) {
          _linkDocumentacao.text = value ?? '';
        },
        decoration: const InputDecoration(
          helperStyle: TextStyle(
            fontSize: 16,
          ),
          helperText:
              'Caso tenha problema em carregar os arquivos, compartilhe no We Transfer , One Drive, Google Drive, copie e cole o link aqui',
          hintText:
              'Caso tenha problema em carregar os arquivos, compartilhe no We Transfer , One Drive, Google Drive, copie e cole o link aqui',
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Link *',
        ),
      ),
    );
  }

  Widget _arquivosCompactadoTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Arquivos compactado',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
      ),
    );
  }

  Widget _selecioneEnderecoTexto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        'Selecion endereço de entrega',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: textSize,
        ),
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
          _queixaPrinc(),
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
          _opcionaisTexto(),
          _opcionais(),
          _carregarFotografiasTexto(),
          _carregarFotografias(),
          _carregarRadiografiasTexto(),
          _carregarRadiografias(),
          _carregarModelosDigitaisTexto(),
          _formatoDeModelos(),
          _manageModelType(),
          _arquivosCompactadoTexto(),
          _modeloCompactado(),
          _selecioneEnderecoTexto(),
          _enderecoSelection(),
          _termos(),
          _sendButton()
        ],
      ),
    );
  }

  //for editing pedido
  Widget _form2() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _nomePaciente(),
          _dataNascimento(),
          _tratar(),
          _queixaPrinc(),
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
          _opcionaisTexto(),
          _opcionais(),
          _selecioneEnderecoTexto(),
          _enderecoSelection(),
          _termos(),
          _atualizarPedidoButton(),
          if (_authStore!.roleId != 1) _statusSelection(),
          _carregarFotografiasTexto(),
          _carregarFotografias(),
          _carregarRadiografiasTexto(),
          _carregarRadiografias(),
          _carregarModelosDigitaisTexto(),
          _formatoDeModelos(),
          _manageModelType(),
          _arquivosCompactadoTexto(),
          _modeloCompactado(),
        ],
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _args.title.isEmpty ? 'Novo paciente' : _args.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Future<List<EnderecoModel>> _fetchUserEndereco() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEnderecosV1 + '?userId=' + _authStore!.id.toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    try {
      List<dynamic> _enderecos = json.decode(response.body);
      if (_enderecos[0].containsKey('endereco')) {
        eModel = [];
        _enderecos.forEach((e) {
          eModel.add(
            EnderecoModel(
              id: e['id'],
              bairro: e['bairro'],
              cep: e['cep'],
              cidade: e['cidade'],
              complemento: e['complemento'],
              endereco: e['endereco'],
              numero: e['numero'],
              pais: e['pais'],
              uf: e['estado'],
            ),
          );
        });
        return eModel;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

  Future<List<StatusPedidoV1Model>> _fetchStatus() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaStatusV1,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    try {
      List<dynamic> _status = json.decode(response.body);
      if (_status[0].containsKey('status')) {
        sModel = [];
        _status.forEach((s) {
          sModel.add(
            StatusPedidoV1Model(id: s['id'], status: s['status']),
          );
        });
        return sModel;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

  Widget _enderecoSelection() {
    return Column(
      children: [
        DropdownSearch<EnderecoModel>(
          scrollbarProps: ScrollbarProps(isAlwaysShown: true),
          validator: (value) {
            if (_isEditarPedidoCheck()) {
              return null;
            }
            if (value == null) {
              return 'Por favor escolha endereco';
            }
            return null;
          },
          dropdownBuilder: (buildContext, string, string2) {
            if (_isEditarPedidoCheck()) {
              return Text(enderecoSelecionado.endereco);
            }
            if (eModel.length == 0) {
              return Text('sem endereços');
            }
            return Text(eModel[0].endereco);
          },
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
          emptyBuilder: (buildContext, string) {
            return Center(child: Text('Sem dados'));
          },
          loadingBuilder: (buildContext, string) {
            return Center(child: Text('Carregando...'));
          },
          errorBuilder: (buildContext, string, dynamic) {
            return Center(child: Text('Erro'));
          },
          onFind: (string) => _fetchUserEndereco(),
          itemAsString: (EnderecoModel e) => e.endereco,
          mode: Mode.MENU,
          label: 'Selecione endereço: *',
          onChanged: (EnderecoModel? selectedEnd) {
            setState(() {
              enderecoSelecionado = selectedEnd ?? EnderecoModel();
            });
          },
        ),
        const SizedBox(
          height: 20,
        ),
        enderecoSelecionado.endereco.isEmpty
            ? Text('')
            : Text(
                '*Endereço de entrega* \nEndereço: ${enderecoSelecionado.endereco}\nNúmero: ${enderecoSelecionado.numero}\nComplemento: ${enderecoSelecionado.complemento}\nBairro: ${enderecoSelecionado.bairro}\nCEP: ${enderecoSelecionado.cep}\nPaís: ${enderecoSelecionado.pais}\nUF: ${enderecoSelecionado.uf}\nCidade: ${enderecoSelecionado.cidade}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
      ],
    );
  }

  Future<bool> _atualizarStatusPedido(StatusPedidoV1Model s) async {
    var p = _pedidoStore!.getPedido(position: _args.messageInt);
    try {
      var _response = await http.put(
        Uri.parse(RotasUrl.rotaPedidoV1Status),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode({'pedidoId': p.id, 'status_pedido': s.toJson()}),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('atualizarStatusPedido ->' + e.toString());
      return false;
    }
  }

  Widget _statusSelection() {
    return Column(
      children: [
        DropdownSearch<StatusPedidoV1Model>(
          scrollbarProps: ScrollbarProps(isAlwaysShown: true),
          /*
          validator: (value) {
            if (value == null) {
              return 'Por favor escolha status';
            }
            return null;
          },*/

          dropdownBuilder: (buildContext, string, string2) {
            if (_isEditarPedidoCheck()) {
              return Text(_selectedStatus.status);
            }
            if (sModel.length == 0) {
              return Text('Sem status');
            }
            return Text(_selectedStatus.status);
          },
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
          emptyBuilder: (buildContext, string) {
            return Center(child: Text('Sem dados'));
          },
          loadingBuilder: (buildContext, string) {
            return Center(child: Text('Carregando...'));
          },
          errorBuilder: (buildContext, string, dynamic) {
            return Center(child: Text('Erro'));
          },
          onFind: (string) => _fetchStatus(),
          itemAsString: (StatusPedidoV1Model s) => s.status,
          mode: Mode.MENU,
          label: 'Selecione status: *',
          onChanged: (StatusPedidoV1Model? selSt) async {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text(
                  'Atualizando status do pedido...',
                  textAlign: TextAlign.center,
                ),
              ),
            );
            bool result =
                await _atualizarStatusPedido(selSt ?? StatusPedidoV1Model());
            if (result) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    'Status do pedido atualizado!',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              setState(() {
                _selectedStatus = selSt ?? StatusPedidoV1Model();
              });
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    'Não foi possível atualizar.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

//Taxa de Planejamento: Estou ciente que caso o planejamento não seja aprovado em até 60 dias, será cobrado o valor de R$ 350,00
  Widget _termos() {
    Future<dynamic> getAlert() {
      return showDialog(
        context: context,
        builder: (context) {
          return SizedBox(
            child: AlertDialog(
              title: Text('Termos'),
              content: RawScrollbar(
                  radius: Radius.circular(10),
                  thumbColor: Colors.grey,
                  thickness: 15,
                  isAlwaysShown: true,
                  child: SingleChildScrollView(child: Text(termos))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('fechar'),
                )
              ],
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GroupButton(
        selectedColor: Colors.blue,
        isRadio: false,
        spacing: 10,
        onSelected: (index, isSelected) {
          if (isSelected) {
            getAlert();
          }
        },
        buttons: [
          'Li e estou de acordo com os termos',
        ],
      ),
    );
  }

  ScaffoldFeatureController _msgPacienteCriado(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          msg,
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                PedidoV1Model p = _mapFieldsToPedidoV1();
                bool result = await _pedidoStore!.enviarPrimeiroPedido(
                  pedido: p,
                  token: _authStore!.token,
                  tipoPedido: tipoPedido,
                );
                if (result) {
                  if (tipoPedido == 'refinamento') {
                    _msgPacienteCriado('Refinamento criado com sucesso!');
                    Navigator.pop(context);
                    return;
                  }
                  _msgPacienteCriado('Pedido criado com sucesso!');
                  if (_authStore!.role == 'Credenciado') {
                    Navigator.of(context).pushReplacementNamed(
                      GerenciarPacientesV1.routeName,
                      arguments: ScreenArguments(
                        title: 'Meus Pacientes',
                        message: '',
                      ),
                    );
                  } else if (_authStore!.role == 'Administrador' ||
                      _authStore!.role == 'Gerente') {
                    Navigator.of(context).pushReplacementNamed(
                      GerenciarPacientesV1.routeName,
                      arguments: ScreenArguments(
                        title: 'Gerenciar Pacientes',
                        message: '',
                      ),
                    );
                  }
                }
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

  Widget _atualizarPedidoButton() {
    return ElevatedButton(
      onPressed: isSending
          ? null
          : () async {
              setState(() {
                isSending = true;
              });
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                PedidoV1Model p = _mapFieldsToPedidoV1();

                bool result = await _pedidoStore!.enviarAtualizarPedido(
                  pedido: p,
                  token: _authStore!.token,
                );
                if (result) {
                  _msgPacienteCriado('Pedido atualizado');
                  Navigator.pop(context);
                }
              }

              setState(() {
                isSending = false;
              });
            },
      child: Text(
        isSending ? 'aguarde...' : 'Atualizar pedido',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _getTermos() async {
    String t = await rootBundle.loadString('texts/termos.txt');
    setState(() {
      termos = t;
    });
  }

  List<String> _convertDbValuesToUi(String s) {
    return s.split(': ');
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
    _getTermos();
    if (firstRun) {
      try {
        _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
      } catch (e) {
        print(e);
      }
      //if is new paciente, and not refinamento clear data
      if (_args.messageMap != null) {
        if (_args.messageMap!.containsKey('isRefinamento')) {
          if (_args.messageMap!['isRefinamento'] == false) {
            _pedidoStore!.clearDataAllProviderData();
            tipoPedido = 'pedido';
          } else {
            _isPedidoRefinamento = true;
            _dataNascimentoEnabled = false;
            _nomePacienteEnabled = false;
            _payload = {
              'pedidoId': _args.messageMap!['pedidoId'] ?? '',
            };
            tipoPedido = 'refinamento';
          }
        }
        if (_args.messageMap!.containsKey('nomePaciente')) {
          _nomePacContr.text = _args.messageMap!['nomePaciente'];
          _dataNascContr.text = _args.messageMap!['dataNascimento'];
        }
        if (_args.messageMap!.containsKey('isEditarPaciente')) {
          if (_args.messageMap!['isEditarPaciente']) {
            try {
              var p = _pedidoStore!.getPedido(position: _args.messageInt);
              _id = p.id;
              _nomePacContr.text = p.nomePaciente;
              _dataNascContr.text = p.dataNascimento;
              _tratarContr.text = p.tratar;
              _queixaPrincipal.text = p.queixaPrincipal;
              _objContr.text = p.objetivosTratamento;

              List<String> lmsConv = _convertDbValuesToUi(p.linhaMediaSuperior);

              if (lmsConv.length == 2) {
                print('im in');
                if (lmsConv[0] == 'Mover para esquerda') {
                  mmEsqLinhaMediaSupVis = true;
                } else if (lmsConv[0] == 'Mover para direita') {
                  mmDirLinhaMediaSupVis = true;
                }
                _linhaMediaSupContr.text = lmsConv[0];
                _linhaMediaSupMMContr.text = lmsConv[1];
              } else {
                _linhaMediaSupContr.text = p.linhaMediaSuperior;
                _linhaMediaSupComplete = p.linhaMediaSuperior;
              }

              List<String> lmiConv = _convertDbValuesToUi(p.linhaMediaInferior);

              if (lmiConv.length == 2) {
                if (lmiConv[0] == 'Mover para esquerda') {
                  mmEsqLinhaMediaInfVis = true;
                } else if (lmiConv[0] == 'Mover para direita') {
                  mmDirLinhaMediaInfVis = true;
                }
                _linhaMediaInfContr.text = lmiConv[0];
                _linhaMediaInfMMContr.text = lmiConv[1];
              } else {
                _linhaMediaInfContr.text = p.linhaMediaInferior;
                _linhaMediaInfComplete = p.linhaMediaInferior;
              }

              _overJetContr.text = p.overjet;

              //overbite
              List<String> ovrbConv = _convertDbValuesToUi(p.overbite);
              if (ovrbConv.length == 2) {
                _overbiteContr.text = ovrbConv[0];
                if (_overbiteContr.text == 'Intruir anterior sup') {
                  _overbiteInit1 = ovrbConv[1];
                  mmOverbiteVis1 = true;
                } else if (_overbiteContr.text == 'Intruir anterior inf') {
                  _overbiteInit2 = ovrbConv[1];
                  mmOverbiteVis2 = true;
                } else if (_overbiteContr.text == 'Extruir posterior sup') {
                  _overbiteInit3 = ovrbConv[1];
                  mmOverbiteVis3 = true;
                } else if (_overbiteContr.text == 'Extruir posterior inf') {
                  _overbiteInit4 = ovrbConv[1];
                  mmOverbiteVis4 = true;
                }
              } else {
                _overbiteContr.text = p.overbite;
                _overbiteComplete = p.overbite;
              }

              //res apinh superior
              resApinSupUiSelectedPos = _mapStringToSelectedIntList(
                p.resApinSup,
                resApinUiList,
              );
              _resApinSupContr.text = p.resApinSup;
              //res apinh inferior
              resApinInfUiSelectedPos = _mapStringToSelectedIntList(
                p.resApinInf,
                resApinUiList,
              );
              _resApinInfContr.text = p.resApinInf;
              // dentes - extração virtual
              extracaoVirtualUiSelectedPos = _mapStringToSelectedIntList(
                p.dentesExtVirtual,
                dentesUiList,
              );
              _extracaoVirtualContr.text = p.dentesExtVirtual;
              // dentes - não movimentar
              naoMovimentarUiSelectedPos = _mapStringToSelectedIntList(
                p.dentesNaoMov,
                dentesUiList,
              );
              _naoMovimentarContr.text = p.dentesNaoMov;
              // dentes - não colocar attach
              naoColocarAttachUiSelectedPos = _mapStringToSelectedIntList(
                p.dentesSemAttach,
                dentesUiList,
              );
              _naoColocarAttachContr.text = p.dentesSemAttach;

              //opc aceito desg
              _opcAceitoDip.text = p.opcAceitoDesg;
              if (_opcAceitoDip.text.isNotEmpty) _opcAceitoDipSelected = 0;
              //opc recorte para elástico
              _opcRecorteElastico.text = p.opcRecorteElas;
              if (_opcRecorteElastico.text.isNotEmpty) {
                _opcRecorteElasticoSelected = 0;
                _opcRecorteElasticoMm = true;
              }
              //opc recorte no alinhador para botão
              _opcRecorteBotao.text = p.opcRecorteAlin;
              if (_opcRecorteBotao.text.isNotEmpty) {
                _opcRecorteBotaoSelected = 0;
                _opcRecorteBotaoMm = true;
              }

              //opc alívio no alinhador
              _opcBracoForca.text = p.opcAlivioAlin;
              if (_opcBracoForca.text.isNotEmpty) {
                _opcBracoForcaSelected = 0;
                _opcBracoForcaMm = true;
              }
              //endereco
              enderecoSelecionado = p.enderecoEntrega ?? EnderecoModel();
              //modelo tipo selecionado
              modeloEmGesso = p.modeloGesso;
              //link documentação
              _linkDocumentacao.text = p.linkModelos;
              _selectedStatus = p.statusPedido ?? StatusPedidoV1Model();
            } catch (e) {
              print('erro ao tentar converter valores para ui');
            }
            //---
            _isEditarPedido = true;
            _isEditarPedidoPos = _args.messageInt;
          }
        }
      }
      firstRun = false;
    }
    super.didChangeDependencies();
  }

  PreferredSizeWidget _buildAppbar() {
    bool isRef = false;
    bool isEdit = false;

    if (_args.messageMap != null) {
      if (_args.messageMap!.containsKey('isRefinamento')) {
        isRef = _args.messageMap!['isRefinamento'];
      }
      if (_args.messageMap!.containsKey('isEditarPaciente')) {
        isEdit = _args.messageMap!['isEditarPaciente'];
        if (isEdit) _firstPedidoSaveToProvider = false;
      }
    }
    if (isRef || isEdit) return SecondaryAppbar();
    return MyAppBar();
  }

  bool _isEditarPedidoCheck() {
    bool isEdit = false;
    if (_args.messageMap != null) {
      if (_args.messageMap!.containsKey('isEditarPaciente')) {
        isEdit = _args.messageMap!['isEditarPaciente'];
      }
    }
    return isEdit;
  }

  @override
  Widget build(BuildContext context) {
    if (!_authStore!.isAuth) {
      return LoginScreen();
    }
    return Scaffold(
      appBar: _buildAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: _screenSize!.width < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: _screenSize!.width < 768 ? 5800 : 5100,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _isEditarPedidoCheck() ? _form2() : _form(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
