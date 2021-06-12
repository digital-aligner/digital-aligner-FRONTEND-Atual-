class RotasUrl {
  //static const rotaHeroku = 'https://aqueous-wave-03435.herokuapp.com/';
  //static const rotaBase = 'http://localhost:1337/';
  //STL VIEWER ROUTES
  static const rotaModSupWebView =
      'https://app.digitalaligner.com.br/stl_viewer/modelo_sup_viewer.html';
  static const rotaModInfWebView =
      'https://app.digitalaligner.com.br/stl_viewer/modelo_inf_viewer.html';

  static const rotaBase = 'http://localhost:1337/';
  static const rotaGetPaisesAndState = rotaBase + 'paises';
  static const rotaGetCities = rotaBase + 'cidades/';
  static const rotaLogin = rotaBase + 'auth/local/';
  static const rotaCadastro = rotaBase + 'users/';
  static const rotaPedidosAprovados = rotaBase + 'pedidos-aprovados/';
  static const rotaPedidosAlterados = rotaBase + 'pedidos-alterados/';
  static const rotaNovosPedidosCount = rotaBase + 'novos-pedidos-count/';
  static const rotaAlteracoesPedidos = rotaBase + 'alteracoes-pedidos/';
  static const rotaCadistas = rotaBase + 'cadistas/';
  static const rotaRepresentantes = rotaBase + 'representantes/';
  static const rotaRevisores = rotaBase + 'revisores/';
  static const rotaOnboardings = rotaBase + 'onboardings/';
  static const rotaCadastrosAprovados = rotaBase + 'cadastros-aprovados/';
  static const rotaCadastrosAguardando = rotaBase + 'cadastros-aguardando/';
  static const rotaCadastrosNegado = rotaBase + 'cadastros-negado/';
  static const rotaCadastrosAdministrador =
      rotaBase + 'cadastros-administrador/';
  static const rotaCadastrosGerente = rotaBase + 'cadastros-gerente/';
  static const rotaCadastrosCredenciado = rotaBase + 'cadastros-credenciado/';
  static const rotaAprovacao = rotaBase + 'aprovacao-usuarios/';
  static const rotaNovoPaciente = rotaBase + 'novo-paciente/';
  static const rotaPaciente = rotaBase + 'pacientes/';
  static const rotaNovoPedido = rotaBase + 'novo-pedido/';
  static const rotaNovoRefinamento = rotaBase + 'novo-refinamento/';
  static const rotaUpload = rotaBase + 'upload/';
  static const rotaUploads3Custom = rotaBase + 'dig-align-s-3-uploads/';
  static const rotaUploads3CustomZip =
      rotaBase + 'dig-align-s-3-uploads-get-zip/';
  static const rotaUserMe = rotaBase + 'users/me';
  static const rotaStatusPedido = rotaBase + 'status-pedidos/';
  static const rotaPedidos = rotaBase + 'pedidos/';
  static const rotaEnderecoUsuarios = rotaBase + 'endereco-usuarios/';
  static const rotaGetEnderecoUsuarios = rotaBase + 'get-enderecos-usuario/';
  static const rotaMeusPacientes = rotaBase + 'meus-pacientes/';
  static const rotaGerenciarPacientes = rotaBase + 'gerenciar-pacientes/';
  static const rotaMeuHistorico = rotaBase + 'meu-historico/';
  static const rotaMeusPedidos = rotaBase + 'meus-pedidos/';
  static const rotaMeusSetups = rotaBase + 'meus-setups/';
  static const rotaMinhasRevisoes = rotaBase + 'minhas-revisoes/';
  static const rotaMeusRefinamentos = rotaBase + 'meus-refinamentos/';
  static const rotaRefinamentos = rotaBase + 'refinamentos/';
  static const rotaPdfsList = rotaBase + 'pdfs-list/';
  static const rotaPptsList = rotaBase + 'ppts-list';
  static const rotafotografiasList = rotaBase + 'fotografias-list/';
  static const rotaRadiografiasList = rotaBase + 'radiografias-list/';
  static const rotaModeloSuperiorList = rotaBase + 'modelo-superior-list/';
  static const rotaModeloInferiorList = rotaBase + 'modelo-inferior-list/';
  static const rotaModeloCompactadoList = rotaBase + 'modelo-compactados-list/';
  static const rotaModeloNemoList = rotaBase + 'modelo-nemo-list/';
  static const rotaMeuRelatorio = rotaBase + 'meu-relatorio/';
  static const rotaSolicitarAlteracao = rotaBase + 'solicitar-alteracao/';
  static const rotaCriarRelatorio = rotaBase + 'criar-relatorio/';
  static const rotaAtualizarRelatorio = rotaBase + 'atualizar-relatorio/';
  static const rotaAprovarRelatorio = rotaBase + 'aprovar-relatorio/';
  static const rotaDadosBaseRelatorio = rotaBase + 'dados-base-relatorio/';
  static const rotaRecuperarSenha = rotaBase + 'recuperar-senha/';
  static const rotaRecuperarSenhaNova = rotaBase + 'recuperar-senha-nova/';

  //ROTAS VERSÃO V1
  static const rotaPaisesV1 = rotaBase + 'paises-v1';
  static const rotaCidadesV1 = rotaBase + 'cidades-v1';
  static const rotaEstadosV1 = rotaBase + 'estados-v1';
  //Note: These delete routes only used on editing screens (editar pedido, editar relatório)
  //Not for deleting pedido or relatório
  static const rotaDeleteS3 = rotaBase + 'upload/files/';
  static const rotaDeletePhoto = rotaBase + 'upload/files/';
  static const rotaDeleteRadiografia = rotaBase + 'upload/files/';
  static const rotaDeleteModeloSup = rotaBase + 'upload/files/';
  static const rotaDeleteModeloInf = rotaBase + 'upload/files/';
  static const rotaDeletecompactUpload = rotaBase + 'upload/files/';
  static const rotaDeleteNemoUpload = rotaBase + 'upload/files/';
  static const rotaDeleteRelatorioUpload = rotaBase + 'upload/files/';
  //Delete routes
  static const rotaDeletePedido = rotaBase + 'deletar-pedido/';
}
