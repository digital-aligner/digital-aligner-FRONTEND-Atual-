import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/pedido_provider.dart';

class DadosIniciais extends StatefulWidget {
  final bool isNovoPedidoOrRefinamento;
  final bool isEditarPedido;
  final Map pacienteDados;
  final bool blockUi;

  DadosIniciais({
    this.isNovoPedidoOrRefinamento,
    this.pacienteDados,
    this.isEditarPedido,
    @required this.blockUi,
  });
  @override
  _DadosIniciaisState createState() => _DadosIniciaisState();
}

class _DadosIniciaisState extends State<DadosIniciais>
    with AutomaticKeepAliveClientMixin<DadosIniciais> {
  @override
  bool get wantKeepAlive => true;

  DateFormat format = DateFormat("dd/MM/yyyy");

  FocusNode _dateFocusNode = FocusNode();

  PedidoProvider _novoPedStore;

  //For use to remove any text focus when clicking on radio.
  void _removeFocus(var context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    //For the "wantToKeepAlive" mixin
    super.build(context);
    _novoPedStore = Provider.of<PedidoProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: <Widget>[
          if (widget.isNovoPedidoOrRefinamento != null &&
              widget.isNovoPedidoOrRefinamento == false)
            //Nome Paciente
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    child: TextFormField(
                      maxLength: 255,
                      enabled: !widget.isEditarPedido,
                      validator: (String value) {
                        return value.isEmpty ? 'Campo vazio!' : null;
                      },
                      onFieldSubmitted: (_) {
                        //_removeNodeFocus(context);
                      },
                      initialValue: _novoPedStore.getNomePaciente(),
                      onChanged: (value) {
                        _novoPedStore.setNomePaciente(value);
                      },
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Nome do Paciente *',
                        //hintText: 'Nome do Paciente *',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (widget.isNovoPedidoOrRefinamento != null &&
              widget.isNovoPedidoOrRefinamento == true)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    child: TextFormField(
                      maxLength: 255,
                      enabled: false,
                      validator: (String value) {
                        return value.isEmpty ? 'Campo vazio!' : null;
                      },
                      onFieldSubmitted: (_) {
                        //_removeNodeFocus(context);
                      },
                      initialValue: widget.pacienteDados['nome_paciente'],
                      onChanged: (value) {
                        _novoPedStore.setNomePaciente(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Nome do Paciente *',
                        //hintText: 'Nome do Paciente *',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          if (widget.isNovoPedidoOrRefinamento != null &&
              widget.isNovoPedidoOrRefinamento == false)
            //Data Nascimento
            Container(
              height: 80,
              child: DateTimeField(
                enabled: !widget.isEditarPedido,
                maxLength: 255,
                validator: (DateTime value) {
                  return value == null ? 'Campo vazio!' : null;
                },
                initialValue: _novoPedStore.getDataNasc(),
                focusNode: _dateFocusNode,
                onChanged: (value) {
                  _novoPedStore.setDataNasc(value);
                },
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Data de Nascimento: *',
                  //hintText: 'Data de Nascimento: *',
                  border: const OutlineInputBorder(),
                ),
                format: format,
                onShowPicker: (context, currentValue) async {
                  //Obs: Datepicker must use async await, else
                  //bug when scrolling dates on flutter web
                  return await showDatePicker(
                    fieldLabelText: '',
                    initialEntryMode: DatePickerEntryMode.input,
                    locale: Localizations.localeOf(context),
                    errorFormatText: 'Escolha data válida',
                    errorInvalidText: 'Data invalida',
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
              ),
            ),
          if (widget.isNovoPedidoOrRefinamento != null &&
              widget.isNovoPedidoOrRefinamento == true)
            //Data Nascimento
            Container(
              height: 80,
              child: DateTimeField(
                maxLength: 255,
                enabled: false,
                validator: (DateTime value) {
                  return value == null ? 'Campo vazio!' : null;
                },
                initialValue:
                    DateTime.parse(widget.pacienteDados['data_nascimento']),
                focusNode: _dateFocusNode,
                onChanged: (value) {
                  _novoPedStore.setDataNasc(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento: *',
                  //hintText: 'Data de Nascimento: *',
                  border: const OutlineInputBorder(),
                ),
                format: format,
                onShowPicker: (context, currentValue) async {
                  //Obs: Datepicker must use async await, else
                  //bug when scrolling dates on flutter web
                  return await showDatePicker(
                    fieldLabelText: '',
                    initialEntryMode: DatePickerEntryMode.input,
                    locale: Localizations.localeOf(context),
                    errorFormatText: 'Escolha data válida',
                    errorInvalidText: 'Data invalida',
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
              ),
            ),
          const SizedBox(height: 40),
          //Text: Tratar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TRATAR:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '*',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          //Tratar (responsive function)
          //ERROR MESSAGE
          Column(
            children: [
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
                          return _novoPedStore
                                      .getTratarRadioValue('_tratarRadio') ==
                                  0
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
          Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: <Widget>[
              SizedBox(
                width: 150,
                child: Row(children: [
                  Radio(
                    activeColor: Colors.blue,
                    groupValue:
                        _novoPedStore.getTratarRadioValue('_tratarRadio'),
                    onChanged: widget.blockUi
                        ? null
                        : (value) {
                            _removeFocus(context);
                            _novoPedStore.setTratarRadio(1, '_tratarRadio');
                          },
                    value: 1,
                  ),
                  const Text('Ambos os arcos'),
                ]),
              ),
              SizedBox(
                width: 150,
                child: Row(children: [
                  Radio(
                    activeColor: Colors.blue,
                    groupValue:
                        _novoPedStore.getTratarRadioValue('_tratarRadio'),
                    onChanged: widget.blockUi
                        ? null
                        : (value) {
                            _removeFocus(context);
                            _novoPedStore.setTratarRadio(2, '_tratarRadio');
                          },
                    value: 2,
                  ),
                  const Text('Apenas o Superior'),
                ]),
              ),
              SizedBox(
                width: 150,
                child: Row(children: [
                  Radio(
                    activeColor: Colors.blue,
                    groupValue:
                        _novoPedStore.getTratarRadioValue('_tratarRadio'),
                    onChanged: widget.blockUi
                        ? null
                        : (value) {
                            _removeFocus(context);
                            _novoPedStore.setTratarRadio(3, '_tratarRadio');
                          },
                    value: 3,
                  ),
                  const Text('Apenas o Inferior'),
                ]),
              ),
            ],
          ),
          //Descreva principal queixa
          const SizedBox(height: 40),
          Container(
            child: TextFormField(
              enabled: !widget.blockUi,
              initialValue: _novoPedStore.getDiPrincipalQueixa(),
              maxLength: 2000,
              maxLines: 15,
              onChanged: (value) {
                _novoPedStore.setDiPrincipalQueixa(value);
              },
              decoration: const InputDecoration(
                hintText:
                    'Descreva a queixa principal e os objetivos do tratamento em detalhe: *',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          //Texto: Para um melhor...
          const SizedBox(height: 40),
          const Text(
            'Para um melhor desempenho e celeridade no processo de desenvolvimento do SetUp virtual, simplificamos a Prescrição, seguindo um Método que contempla 4 dimensões (SAGITAL, VERTICAL, TRANSVERSAL E PROBLEMAS INDIVIDUAIS) a fim de alcançar os objetivos da sua prescrição. \n \nAssinale, abaixo, os objetivos e como você deseja alcançá-los:',
            textAlign: TextAlign.center,
            style: const TextStyle(
                //fontSize: 18,
                //fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
