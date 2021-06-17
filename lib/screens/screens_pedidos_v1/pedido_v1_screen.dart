import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/file_uploader.dart';

import 'package:flutter/material.dart';
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

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _nomePaciente(),
          _dataNascimento(),
          _tratar(),
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
          acceptedFileExt: ['jpg', 'jpeg', 'jpe', 'gif', 'png'],
          sendButtonText: 'CARREGAR FOTOGRAFIAS',
          firstPedidoSaveToProvider: false,
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;
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
            height: 1000,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _form(),
                _carregarArquivos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
