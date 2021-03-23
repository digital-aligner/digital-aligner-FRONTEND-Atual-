import 'dart:convert';

import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:digital_aligner_app/screens/meus_pacientes.dart';
import 'package:digital_aligner_app/widgets/file_uploads/compactado_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_inferior_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_superior_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/nemo_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/radiografia_upload.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/6_endereco/editar_endereco_entrega.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/7_termos/termos.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/8_status_pedido/status_pedido.dart';

import 'package:dropdown_search/dropdown_search.dart';

import '../../rotas_url.dart';
import '../../widgets/novo_paciente/5_problemas_individuais/problemas_individuais.dart';

import '../file_uploads/photo_upload.dart';

import '../../providers/auth_provider.dart';
import '../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import './1_dados_iniciais/dados_iniciais.dart';
import './2_sagital/sagital.dart';
import './3_vertical/vertical.dart';
import './4_transversal/transversal.dart';
import '6_endereco/endereco_entrega.dart';

import 'package:http/http.dart' as http;

class PedidoForm extends StatefulWidget {
  final int pedidoId;
  final int userId;
  final int enderecoId;
  final bool isEditarPedido;
  final bool isNovoPedido;
  final bool isNovoPaciente;
  final bool isNovoRefinamento;
  final String pedidoHeader;
  final Map pedidoDados;
  final Map pacienteDados;
  final bool blockUi;

  PedidoForm({
    this.pedidoId,
    this.userId,
    @required this.isNovoPedido,
    @required this.isNovoPaciente,
    @required this.isEditarPedido,
    @required this.isNovoRefinamento,
    this.enderecoId,
    this.pedidoHeader,
    this.pedidoDados,
    this.pacienteDados,
    @required this.blockUi,
  });

  @override
  _PedidoFormState createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  final _formKey = GlobalKey<FormState>();
  bool _initialSetup = true;
  S3DeleteProvider _s3deleteStore;
  bool _sendingPedido = false;

  //For nemo dropdown
  List<dynamic> _cadistas;

  //For revisor dropdown
  List<dynamic> _revisores;

  String _formatCpf(String cpf) {
    String _formatedCpf = cpf.substring(0, 3) +
        '.' +
        cpf.substring(3, 6) +
        '.' +
        cpf.substring(6, 9) +
        '-' +
        cpf.substring(9, 11);
    return _formatedCpf;
  }

  String _getCpfFromSelectedValue(String value) {
    String onlyCpf = value.substring(value.indexOf('|') + 1, value.length);
    String removeCpfSpace = onlyCpf.replaceAll(' ', '');
    String removeCpfDots = removeCpfSpace.replaceAll('.', '');
    String removeCpfDash = removeCpfDots.replaceAll('-', '');

    return removeCpfDash;
  }

  Future<List<dynamic>> fetchCadistas() async {
    //Fetch cadistas if last fetch was with error
    if (_cadistas != null && !_cadistas[0].containsKey('error')) {
      return _cadistas;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaCadistas),
        headers: requestHeaders,
      );
      _cadistas = json.decode(response.body);
    } catch (error) {
      print(error.toString());
    }
    return _cadistas;
  }

  Future<List<dynamic>> fetchRevisores() async {
    //Fetch revisores if last fetch was with error
    if (_revisores != null && !_revisores[0].containsKey('error')) {
      return _revisores;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaRevisores),
        headers: requestHeaders,
      );
      _revisores = json.decode(response.body);
    } catch (error) {
      print(error.toString());
    }
    return _revisores;
  }

  List<Function> _formList = [];

  Widget _nemoUi() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'PARA CADISTAS',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        DropdownSearch<String>(
          enabled: !widget.blockUi,
          errorBuilder: (context, searchEntry, exception) {
            return Center(child: const Text('Algum erro ocorreu.'));
          },
          emptyBuilder: (context, searchEntry) {
            return Center(child: const Text('Nada'));
          },
          loadingBuilder: (context, searchEntry) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Colors.blue,
                ),
              ),
            );
          },
          onFind: (_) async {
            await fetchCadistas();
            //Error handling
            if (_cadistas[0].containsKey('error')) {
              if (_cadistas[0]['statusCode'] != 404) {
                //Will go to errorBuilder
                throw Error();
              } else {
                //Will go to emptyBuilder
                return null;
              }
            }
            List<String> _cadUi = [];
            for (var _cadista in _cadistas) {
              _cadUi.add(
                _cadista['nome'] +
                    ' ' +
                    _cadista['sobrenome'] +
                    ' | ' +
                    _formatCpf(_cadista['username']),
              );
            }
            return _cadUi;
          },
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
          maxHeight: 350,
          mode: Mode.MENU,
          showSearchBox: true,
          showSelectedItem: true,
          //items: _enderecoUiList,
          //label: 'UF: *',
          //hint: 'UF: *',
          popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
          onChanged: (value) {
            int selectedValueId = 0;
            String _selectedCpf = _getCpfFromSelectedValue(value);
            //Match with list of cadistas cpf
            for (var _cadista in _cadistas) {
              if (_cadista['username'] == _selectedCpf) {
                selectedValueId = _cadista['id'];
              }
            }
            //Setting the value in the pedido provider for update on backend
            _novoPedStore.setCadistaResponsavelId(selectedValueId);
          },
          selectedItem: widget.pedidoDados['cadista_responsavel'] == null
              ? 'selecione um cadista'
              : widget.pedidoDados['cadista_responsavel']['nome'] +
                  ' ' +
                  widget.pedidoDados['cadista_responsavel']['sobrenome'] +
                  ' | ' +
                  _formatCpf(
                    widget.pedidoDados['cadista_responsavel']['username'],
                  ),
        ),
        _modeloNemo(),
        const SizedBox(
          height: 50,
          child: const Divider(
            thickness: 2,
          ),
        ),
      ],
    );
  }

  Widget _revisorUi() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'PARA REVISOR',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        DropdownSearch<String>(
          enabled: !widget.blockUi,
          errorBuilder: (context, searchEntry, exception) {
            return Center(child: const Text('Algum erro ocorreu.'));
          },
          emptyBuilder: (context, searchEntry) {
            return Center(child: const Text('Nada'));
          },
          loadingBuilder: (context, searchEntry) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Colors.blue,
                ),
              ),
            );
          },
          onFind: (_) async {
            await fetchRevisores();
            //Error handling
            if (_revisores[0].containsKey('error')) {
              if (_revisores[0]['statusCode'] != 404) {
                //Will go to errorBuilder
                throw Error();
              } else {
                //Will go to emptyBuilder
                return null;
              }
            }
            List<String> _revUi = [];
            for (var _revisor in _revisores) {
              _revUi.add(
                _revisor['nome'] +
                    ' ' +
                    _revisor['sobrenome'] +
                    ' | ' +
                    _formatCpf(_revisor['username']),
              );
            }
            return _revUi;
          },
          dropdownSearchDecoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          ),
          maxHeight: 350,
          mode: Mode.MENU,
          showSearchBox: true,
          showSelectedItem: true,
          //items: _enderecoUiList,
          //label: 'UF: *',
          //hint: 'UF: *',
          popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
          onChanged: (value) {
            int selectedValueId = 0;
            String _selectedCpf = _getCpfFromSelectedValue(value);
            //Match with list of revisores cpf
            for (var _revisor in _revisores) {
              if (_revisor['username'] == _selectedCpf) {
                selectedValueId = _revisor['id'];
              }
            }
            //Setting the value in the pedido provider for update on backend
            _novoPedStore.setRevisorResponsavelId(selectedValueId);
          },
          selectedItem: widget.pedidoDados['revisor_responsavel'] == null
              ? 'selecione um revisor'
              : widget.pedidoDados['revisor_responsavel']['nome'] +
                  ' ' +
                  widget.pedidoDados['revisor_responsavel']['sobrenome'] +
                  ' | ' +
                  _formatCpf(
                    widget.pedidoDados['revisor_responsavel']['username'],
                  ),
        ),
        const SizedBox(
          height: 50,
          child: const Divider(
            thickness: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _formList.add(_pedidoFormUi1);
    _formList.add(_pedidoFormUi2);

    _authStore = Provider.of<AuthProvider>(context);
    _novoPedStore = Provider.of<PedidoProvider>(context);
    _s3deleteStore = Provider.of<S3DeleteProvider>(
      context,
      listen: false,
    );
    double _sWidth = MediaQuery.of(context).size.width;
    double _sHeight = MediaQuery.of(context).size.height;

    PedidosListProvider _pedidosListStore = Provider.of<PedidosListProvider>(
      context,
      listen: false,
    );

    if (widget.isEditarPedido && _initialSetup) {
      _novoPedStore.clearAll();
      _novoPedStore.setToken(_authStore.token);
      _novoPedStore.setPedido(widget.pedidoDados);

      _initialSetup = false;
    } else {
      if (_initialSetup) {
        _novoPedStore.clearAll();
        _initialSetup = false;
      }
    }

    if (widget.isNovoPedido || widget.isNovoRefinamento) {
      _novoPedStore.setPacienteId(widget.pacienteDados['id']);
    }

    //Id set if novo pedido or editar pedido
    _novoPedStore.setUserId(widget.userId);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _form(
        _novoPedStore,
        _authStore,
        _pedidosListStore,
        _sWidth,
        _sHeight,
      ),
    );
  }

  Widget _form(
    PedidoProvider _novoPedStore,
    AuthProvider _authStore,
    PedidosListProvider _pedidosListStore,
    double _sWidth,
    double _sHeight,
  ) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        thickness: 15,
        isAlwaysShown: true,
        showTrackOnHover: true,
        child: ListView.builder(
          itemCount: 2,
          itemExtent: null,
          itemBuilder: (context, index2) {
            return _formList[index2](
              _authStore,
              _novoPedStore,
              _pedidosListStore,
              _sWidth,
              _sHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _pedidoFormUi1(
    AuthProvider _authStore,
    PedidoProvider _novoPedStore,
    PedidosListProvider _pedidosListStore,
    double _sWidth,
    double _sHeight,
  ) {
    return Container(
      width: _sWidth,
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          //Form
          Expanded(
            flex: 8,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    widget.pedidoHeader,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                const SizedBox(height: 80),
                DadosIniciais(
                  isNovoPedidoOrRefinamento:
                      widget.isNovoPedido != null && widget.isNovoPedido ||
                              widget.isNovoRefinamento != null &&
                                  widget.isNovoRefinamento
                          ? true
                          : false,
                  isEditarPedido: widget.isEditarPedido,
                  pacienteDados: widget.pacienteDados,
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Sagital(
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Vertical(
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Transversal(
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _pedidoFormUi2(
    AuthProvider _authStore,
    PedidoProvider _novoPedStore,
    PedidosListProvider _pedidosListStore,
    double _sWidth,
    double _sHeight,
  ) {
    return Container(
      width: _sWidth,
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          //Form
          Expanded(
            flex: 8,
            child: Column(
              children: [
                ProblemasIndividuais(
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Envio de Imagens (Exames)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Envio de Imagens (Exames)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                //Text: Fotografias
                const SizedBox(height: 20),
                PhotoUpload(
                  isEdit: widget.isEditarPedido,
                  pedidoDados: widget.pedidoDados,
                  blockUi: widget.blockUi,
                ),
                const SizedBox(height: 20),
                //Text: Radiografias
                const SizedBox(height: 20),
                RadiografiaUpload(
                  isEdit: widget.isEditarPedido,
                  pedidoDados: widget.pedidoDados,
                  blockUi: widget.blockUi,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Text: Formato dos Modelos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Formato dos Modelos',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                                return _novoPedStore.getFormatoModelos() == 0
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
                _manageModelType(_novoPedStore),
                const SizedBox(height: 20),
                if (_novoPedStore.getFormatoModelos() == 0)
                  Container()
                else if (_novoPedStore.getFormatoModelos() == 1)
                  _modelosDigitais()
                else
                  _modelosGesso(),
                //LINK MODELOS
                const SizedBox(height: 40),
                Container(
                  height: 80,
                  child: TextFormField(
                    enabled: !widget.blockUi,
                    onFieldSubmitted: (_) {
                      //_removeNodeFocus(context);
                    },
                    initialValue: _novoPedStore.getLinkModelos(),
                    onChanged: (value) {
                      _novoPedStore.setLinkModelos(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Link dos modelos *',
                      hintText:
                          'Caso tenha problema em carregar os arquivos, compartilhe no We Transfer, One Drive, Google Drive, copie e cole o link aqui',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //REVISOR

                //MODELO NEMO
                if (widget.isEditarPedido && _authStore.role != 'Credenciado')
                  _nemoUi(),
                if (widget.isEditarPedido && _authStore.role != 'Credenciado')
                  _revisorUi(),
                //Text: Endereço Entrega
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ENDEREÇO DE ENTREGA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Gerencie endereços no seu perfil',
                      style: const TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Icon(Icons.person),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.isNovoPaciente ||
                    widget.isNovoPedido ||
                    widget.isNovoRefinamento)
                  EnderecoEntrega(
                    idUsuario: widget.userId,
                  ),
                if (widget.isEditarPedido)
                  EditarEnderecoEntrega(
                    idUsuario: widget.userId,
                    idEndereco: widget.enderecoId,
                    blockUi: widget.blockUi,
                  ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Termos
                Termos(
                  blockUi: widget.blockUi,
                ),
                //Status pedido
                const SizedBox(height: 40),
                //Widget makes request to server
                if (_authStore.role != 'Credenciado' && widget.isEditarPedido)
                  StatusPedido(
                    blockUi: widget.blockUi,
                  ),
                const SizedBox(height: 20),
                //Enviar
                Row(
                  children: [
                    Expanded(child: Container()),
                    //Atualizar pedido btn
                    if (widget.isEditarPedido && widget.blockUi)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: null,
                          child: const Text(
                            'ATUALIZAR PEDIDO',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    if (widget.isEditarPedido && !widget.blockUi)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: !_sendingPedido
                              ? () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      _sendingPedido = true;
                                    });

                                    //Get token from auth provider
                                    //and send to pedido provider
                                    _novoPedStore.setToken(_authStore.token);
                                    _novoPedStore
                                        .atualizarPedido(
                                            widget.pedidoDados['id'])
                                        .then((data) {
                                      setState(() {
                                        _sendingPedido = false;
                                      });
                                      //Delete from s3 if pedido is deleted
                                      _s3deleteStore.batchDeleteFiles();
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 8),
                                          content: Text(data[0]['message']),
                                        ),
                                      );
                                      if (!data[0].containsKey('error')) {
                                        Navigator.pop(context, true);
                                      }
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 8),
                                        content: const Text(
                                          'Por favor preencha os campos obrigatórios!',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: !_sendingPedido
                              ? const Text(
                                  'ATUALIZAR PEDIDO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                        ),
                      ),
                    //Novo paciente
                    if (widget.isNovoPaciente)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: !_sendingPedido
                              ? () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      _sendingPedido = true;
                                    });
                                    //Get token from auth provider
                                    //and send to pedido provider
                                    _novoPedStore.setToken(_authStore.token);
                                    _novoPedStore.enviarPaciente().then((data) {
                                      setState(() {
                                        _sendingPedido = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 8),
                                          content: Text(data[0]['message']),
                                        ),
                                      );
                                      if (!data[0].containsKey('error')) {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                          MeusPacientes.routeName,
                                        );
                                      }
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 8),
                                        content: const Text(
                                          'Por favor preencha os campos obrigatórios!',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: !_sendingPedido
                              ? const Text(
                                  'ENVIAR NOVO PACIENTE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                        ),
                      ),
                    //Novo pedido
                    if (widget.isNovoPedido)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: !_sendingPedido
                              ? () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      _sendingPedido = true;
                                    });
                                    //Get token from auth provider
                                    //and send to pedido provider
                                    _novoPedStore.setToken(_authStore.token);
                                    _novoPedStore
                                        .enviarNovoPedido()
                                        .then((data) {
                                      setState(() {
                                        _sendingPedido = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 8),
                                          content: Text(data[0]['message']),
                                        ),
                                      );
                                      if (!data[0].containsKey('error')) {
                                        Navigator.pop(context);
                                      }
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 8),
                                        content: const Text(
                                          'Por favor preencha os campos obrigatórios!',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: !_sendingPedido
                              ? const Text(
                                  'ENVIAR NOVO PEDIDO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                        ),
                      ),
                    //Novo refinamento
                    if (widget.isNovoRefinamento)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              //Get token from auth provider
                              //and send to pedido provider
                              _novoPedStore.setToken(_authStore.token);
                              _novoPedStore
                                  .enviarNovoRefinamento()
                                  .then((data) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(data[0]['message']),
                                  ),
                                );
                                if (!data[0].containsKey('error')) {
                                  Navigator.pop(context);
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: const Text(
                                    'Por favor preencha os campos obrigatórios!',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'ENVIAR NOVO REFINAMENTO',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Expanded(child: Container()),
                  ],
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _modeloNemo() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        NemoUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
          blockUi: widget.blockUi,
        ),
      ],
    );
  }

  Widget _modelosDigitais() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Modelos digitais',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ModeloSuperiorUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
          blockUi: widget.blockUi,
        ),
        const SizedBox(height: 20),
        ModeloInferiorUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
          blockUi: widget.blockUi,
        ),
        const SizedBox(height: 20),
        CompactadoUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
          blockUi: widget.blockUi,
        ),
      ],
    );
  }

  Widget _modelosGesso() {
    return Container(
      width: 600,
      height: 300,
      child: Column(
        children: <Widget>[
          Flexible(
            child: const Text(
              'AVISO PARA MODELOS EM GESSO:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: const Text(
                '\nOs modelos de gesso enviados devem ser feitos com Gesso pedra tipo IV, sempre superior e inferior. Deve ser enviado o registro de oclusão do paciente juntamente com os modelos em gesso. Devem estar bem embalados, para evitar a quebra. Se possível, a base do modelo deve vir recortada. Enviar com as informações referentes ao paciente (nome, data de nascimento e dentista responsável pelo caso). *Os casos que não seguirem essas recomendações não serão escaneados. *O prazo para planejamento só será contado a partir do recebimento da documentação completa (fotos, radiografia e a prescrição do pedido devem ser enviados via plataforma Digital Aligner). Favor enviar os modelos em gesso para o escaneamento no endereço abaixo:'),
          ),
          Flexible(
            child: const Text(
                '\nUPDENTALL - TECNOLOGIA EM ODONTOLOGIA LTDA. Rua das Pernambucanas, 407, sala 203 Graças 52011-010 Recife, PE'),
          ),
        ],
      ),
    );
  }

  Widget _manageModelType(_novoPedStore) {
    //Digital ou Gesso
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getFormatoModelos(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _novoPedStore.setFormatoModelos(value);
                },
          value: 1,
        ),
        const Text('Digital'),
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getFormatoModelos(),
          onChanged: widget.blockUi
              ? null
              : (value) {
                  _novoPedStore.setFormatoModelos(value);
                },
          value: 2,
        ),
        const Text('Gesso'),
      ],
    );
  }
}
