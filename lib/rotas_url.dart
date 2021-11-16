class RotasUrl {
  // --------------- ROUTES DEV AND PRODUCTION --------------
  static const rotaHeroku = 'https://digital-aligner-strapi.herokuapp.com/';
  static const rotaLocalHost = 'http://localhost:1337/';

  // ------------------- BASE ROUTE -----------------------
  static const rotaBase = rotaHeroku;
  //LOGIN ROUTE
  static const rotaLogin = rotaBase + 'auth/local/';

  //USER ROUTE
  static const rotaCadastro = rotaBase + 'users/';

  //MY USER ROUTE
  static const rotaUserMe = rotaBase + 'users/me';

  //CADASTROS ROUTES
  static const rotaCadastrosAprovados = rotaBase + 'cadastros-aprovados/';
  static const rotaCadastrosAguardando = rotaBase + 'cadastros-aguardando/';
  static const rotaCadastrosNegado = rotaBase + 'cadastros-negado/';
  static const rotaCadastrosAdministrador =
      rotaBase + 'cadastros-administrador/';
  static const rotaCadastrosGerente = rotaBase + 'cadastros-gerente/';
  static const rotaCadastrosCredenciado = rotaBase + 'cadastros-credenciado/';
  static const rotaCadastroExteriorV1 = rotaBase + 'cadastro-exterior';

  //USER REPRESENTANTE ROUTE
  static const rotaRepresentantes = rotaBase + 'representantes/';
  //ONBOARDING ROUTE
  static const rotaOnboardings = rotaBase + 'onboardings/';

  static const rotaAprovacao = rotaBase + 'aprovacao-usuarios/';

  static const rotaPaisesV1 = rotaBase + 'paises-v1';
  static const rotaOnboardingV1 = rotaBase + 'onboarding-v1/1';
  static const rotaCidadesV1 = rotaBase + 'cidades-v1';
  static const rotaEstadosV1 = rotaBase + 'estados-v1';
  static const rotaEnderecosV1 = rotaBase + 'enderecos-v1';
  static const rotaPedidosV1 = rotaBase + 'pedidos-v1/';
  static const rotaStatusV1 = rotaBase + 'status-pedidos-v1';

  static const rotaPedidosAprovados = rotaBase + 'pedidos-aprovados/';
  static const rotaPedidosAlterados = rotaBase + 'pedidos-alterados/';
  static const rotaNovosPedidosCount = rotaBase + 'novos-pedidos-count/';
  static const rotaAlteracoesPedidos = rotaBase + 'alteracoes-pedidos/';
  static const rotaPedidoV1Status = rotaBase + 'pedidos-v1-status';
  static const rotaPedidosV1UpdateFiles = rotaBase + 'pedidos-v1-update-files';
  static const rotaPedidosV1SimpleUpdate =
      rotaBase + 'pedidos-v1-simple-update/';
  static const rotaPedidosRefinamentoV1 = rotaBase + 'pedidos-v1-refinamento';
  static const rotaPacienteFotoPerfilV1 = rotaBase + 'paciente-foto-perfil';
  static const rotaRelatoriosV1 = rotaBase + 'relatorios-v1/';
  static const rotaAprovarRelatoriosV1 = rotaBase + 'relatorios-v1-aprovar';
  static const rotaHistoricoPacV1 = rotaBase + 'historico-pac-v1/';
  static const rotaRecuperarSenha = rotaBase + 'recuperar-senha/';
  static const rotaRecuperarSenhaNova = rotaBase + 'recuperar-senha-nova/';

  static const rotaUpload = rotaBase + 'upload/';
  static const rotaDelete = rotaBase + 'upload/files/';
}
