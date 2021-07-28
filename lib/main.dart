import 'package:digital_aligner_app/default_colors.dart';
import 'package:digital_aligner_app/page_transition_web.dart';
import 'package:digital_aligner_app/providers/check_new_data_provider.dart';
import 'package:digital_aligner_app/providers/pacientes_list_provider.dart';
import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/screens/gerenciar_relatorio_v1.dart';
import 'package:digital_aligner_app/screens/midia_screen/midia.dart';
import 'package:digital_aligner_app/screens/perfil.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';

import './providers/pedidos_list_provider.dart';

import './screens/administrativo/gerenciar_permissoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './screens/login_screen.dart';

import 'screens/administrativo/gerenciar_pacientes_v1.dart';
import './screens/loading_screen.dart';
import './screens/administrativo/gerenciar_cadastro.dart';
import './screens/editar_cadastro.dart';

import 'providers/login_form_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/cadastro_provider.dart';

import 'dart:js' as js;

import 'screens/visualizar_paciente_v1.dart';

void main() {
  runApp(MyApp());
}

Map<String, String> _queryStrings() {
  Uri? uri = Uri.tryParse(js.context['location']['href']);
  List<String> uriStringAfterQuestionMark = uri.toString().split('?');
  //If the url has no query strings, its length will be 1
  if (uriStringAfterQuestionMark.length == 1) return Map<String, String>();
  Map<String, String> queryString = Uri.splitQueryString(
    uriStringAfterQuestionMark[1],
  );
  return queryString;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, String> _qStrings = _queryStrings();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LoginFormProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PedidoProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CadastroProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PedidosListProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PacientesListProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => RelatorioProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CheckNewDataProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          localizationsDelegates: [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('pt', 'BR'),
          ],
          debugShowCheckedModeBanner: false,
          title: 'Digital Aligner',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionWeb(),
            //Primary font for everything
            fontFamily: 'Inter-VariableFont',
            splashColor: Colors.transparent,
            elevatedButtonTheme: ElevatedButtonThemeData(
              //font for all elevated buttons
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontFamily: 'Inter-VariableFont',
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedErrorBorder: OutlineInputBorder(
                //borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              errorBorder: OutlineInputBorder(
                //borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              labelStyle: const TextStyle(fontSize: 20),
              filled: true,
              fillColor: Colors.white,
              focusColor: Colors.white,
              hoverColor: Color.fromRGBO(210, 210, 210, 0.5),
              focusedBorder: OutlineInputBorder(
                //borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 1.5,
                  color: DefaultColors.digitalAlignBlue,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                //borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Colors.black26,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
              ),
            ),

            primarySwatch: DefaultColors.digitalAlignBlue,
            accentColor: Colors.white,
            //Custom textheme for use anywhere in app
            textTheme: const TextTheme(
              //Para titulos nas telas
              headline1: const TextStyle(
                color: Color.fromRGBO(83, 86, 90, 1),
                fontSize: 30,
                fontFamily: 'Houschka',
              ),
            ),
          ),
          home: FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState == ConnectionState.done) {
                return LoginScreen(
                  queryStringsForPasswordReset: _qStrings,
                );
              } else {
                return LoadingScreen();
              }
            },
          ),
          routes: {
            GerenciarCadastros.routeName: (ctx) => GerenciarCadastros(),
            EditarCadastro.routeName: (ctx) => EditarCadastro(),
            GerenciarPermissoes.routeName: (ctx) => GerenciarPermissoes(),
            GerenciarPacientesV1.routeName: (ctx) => GerenciarPacientesV1(),
            VisualizarPacienteV1.routeName: (ctx) => VisualizarPacienteV1(),
            Perfil.routeName: (ctx) => Perfil(),
            Midia.routeName: (ctx) => Midia(),
            PedidoV1Screen.routeName: (ctx) => PedidoV1Screen(),
            GerenciarRelatorioV1.routeName: (ctx) => GerenciarRelatorioV1(),
          },
        ),
      ),
    );
  }
}
