import 'package:flutter/material.dart';

class SbMessages {
  static const cadastroAprovado = const SnackBar(
    duration: const Duration(seconds: 4),
    content: const Text(
      'Cadastro Aprovado!',
      textAlign: TextAlign.center,
    ),
  );
  static const algoDeuErrado = const SnackBar(
    duration: const Duration(seconds: 4),
    content: const Text(
      'Algo deu errado.',
      textAlign: TextAlign.center,
    ),
  );
  static const cadastroAtualizado = const SnackBar(
    duration: const Duration(seconds: 4),
    content: const Text(
      'Cadastro Atualizado!',
      textAlign: TextAlign.center,
    ),
  );
  static const dadosIncorretos = const SnackBar(
    duration: const Duration(seconds: 4),
    content: const Text(
      'Dados incorretos!',
      textAlign: TextAlign.center,
    ),
  );
  static const permissaoSucesso = const SnackBar(
    duration: const Duration(seconds: 4),
    content: const Text(
      'Permissão alterada com sucesso!',
      textAlign: TextAlign.center,
    ),
  );
}
