class RotasApi {
  //rota produção
  static const _rotaProducao = 'https://digital-aligner-strapi.herokuapp.com';
  //rota desenvolvimento
  static const _rotaDev = 'http://localhost:1337';
  //rota do app
  static const rotaBase = _rotaDev;

  //rotas stl view
  static const rotaModSupWebView =
      'https://app.digitalaligner.com.br/stl_viewer/modelo_sup_viewer.html';
  static const rotaModInfWebView =
      'https://app.digitalaligner.com.br/stl_viewer/modelo_inf_viewer.html';

  static const rotaPedidosRascunho = '$rotaBase/pedidos/rascunhos';
}
