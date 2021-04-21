import 'package:digital_aligner_app/page_transition_web.dart';
import 'package:digital_aligner_app/providers/check_new_data_provider.dart';
import 'package:digital_aligner_app/providers/pacientes_list_provider.dart';
import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:digital_aligner_app/providers/s3_relatorio_delete_provider.dart';
import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';
import 'package:digital_aligner_app/screens/meus_refinamentos.dart';
import 'package:digital_aligner_app/screens/administrativo/meus_setups.dart';
import 'package:digital_aligner_app/screens/administrativo/minhas_revisoes.dart';
import 'package:digital_aligner_app/screens/paciente_screen.dart';
import 'package:digital_aligner_app/screens/pedido_view_screen.dart';
import 'package:digital_aligner_app/screens/perfil.dart';
import 'package:digital_aligner_app/screens/refinamento_pedido.dart';

import './providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/screens/administrativo/gerenciar_pedido.dart';
import 'package:digital_aligner_app/screens/editar_pedido.dart';

import './screens/administrativo/gerenciar_permissoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './screens/login_screen.dart';
import 'screens/administrativo/gerenciar_pacientes.dart';
import 'screens/editar_relatorio_screen.dart';
import 'screens/meus_pacientes.dart';
import 'screens/meus_pedidos.dart';
import 'screens/novo_paciente.dart';
import 'screens/novo_pedido.dart';
import './screens/loading_screen.dart';
import './screens/administrativo/gerenciar_cadastro.dart';
import './screens/editar_cadastro.dart';

import 'providers/login_form_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/cadastro_provider.dart';
import 'screens/relatorio_view_screen.dart';

import 'dart:js' as js;

void main() {
  runApp(MyApp());
}

Map<String, String> _queryStrings() {
  Uri uri = Uri.tryParse(js.context['location']['href']);
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
          create: (ctx) => S3DeleteProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => S3RelatorioDeleteProvider(),
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
            fontFamily: 'Questrial',
            splashColor: Colors.transparent,
            elevatedButtonTheme: ElevatedButtonThemeData(
              //font for all elevated buttons
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontFamily: 'Questrial',
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
                  color: Colors.lightBlue,
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

            primarySwatch: Colors.blue,
            accentColor: Colors.white,
            //Custom textheme for use anywhere in app
            textTheme: const TextTheme(
              //Para titulos nas telas
              headline1: const TextStyle(
                color: Color.fromRGBO(12, 47, 118, 1),
                fontSize: 40,
                fontFamily: 'BigNoodleTitling',
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
            MeusPacientes.routeName: (ctx) => MeusPacientes(),
            NovoPaciente.routeName: (ctx) => NovoPaciente(),
            GerenciarCadastros.routeName: (ctx) => GerenciarCadastros(),
            GerenciarPedidos.routeName: (ctx) => GerenciarPedidos(),
            EditarCadastro.routeName: (ctx) => EditarCadastro(),
            EditarPedido.routeName: (ctx) => EditarPedido(),
            GerenciarPermissoes.routeName: (ctx) => GerenciarPermissoes(),
            GerenciarPacientes.routeName: (ctx) => GerenciarPacientes(),
            GerarRelatorioScreen.routeName: (ctx) => GerarRelatorioScreen(),
            PacienteScreen.routeName: (ctx) => PacienteScreen(),
            EditarRelatorioScreen.routeName: (ctx) => EditarRelatorioScreen(),
            MeusPedidos.routeName: (ctx) => MeusPedidos(),
            NovoPedido.routeName: (ctx) => NovoPedido(),
            RefinamentoPedido.routeName: (ctx) => RefinamentoPedido(),
            MeusRefinamentos.routeName: (ctx) => MeusRefinamentos(),
            Perfil.routeName: (ctx) => Perfil(),
            PedidoViewScreen.routeName: (ctx) => PedidoViewScreen(),
            MeusSetups.routeName: (ctx) => MeusSetups(),
            MinhasRevisoes.routeName: (ctx) => MinhasRevisoes(),
            RelatorioViewScreen.routeName: (ctx) => RelatorioViewScreen(),
          },
        ),
      ),
    );
  }
}
