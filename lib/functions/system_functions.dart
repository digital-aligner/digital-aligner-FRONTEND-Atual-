class SystemFunctions {
  static String formatCpf({String cpf = ''}) {
    if (cpf.isEmpty) return cpf;
    String _formatedCpf = cpf.substring(0, 3) +
        '.' +
        cpf.substring(3, 6) +
        '.' +
        cpf.substring(6, 9) +
        '-' +
        cpf.substring(9, 11);
    return _formatedCpf;
  }

  static String formatCpfRemoveFormating({String cpf = ''}) {
    if (cpf.isEmpty) return cpf;
    String removeCpfDots = cpf.replaceAll('.', '');
    String removeCpfDash = removeCpfDots.replaceAll('-', '');
    return removeCpfDash;
  }

  static String formatCep({String cep = ''}) {
    if (cep.isEmpty) return cep;
    String _formatedCep = cep.substring(0, 5) + '-' + cep.substring(5, 8);
    return _formatedCep;
  }

  static String formatCepRemoveFormating({String cep = ''}) {
    if (cep.isEmpty) return cep;
    String removeCepDash = cep.replaceAll('-', '');
    return removeCepDash;
  }

  static String formatTelefone({String telefone = ''}) {
    if (telefone.isEmpty) return telefone;
    String _formatedTelefone = '(' +
        telefone.substring(0, 2) +
        ')' +
        ' ' +
        telefone.substring(2, 6) +
        '-' +
        telefone.substring(6, 10);
    return _formatedTelefone;
  }

  static String formatTelefoneRemoveFormating({String telefone = ''}) {
    if (telefone.isEmpty) return telefone;
    String removedBracket1 = telefone.replaceAll('(', '');
    String removedBracket2 = removedBracket1.replaceAll(')', '');
    String removedSpace = removedBracket2.replaceAll(' ', '');
    String removedDash = removedSpace.replaceAll('-', '');
    return removedDash;
  }

  static String formatCellphone({String cellphone = ''}) {
    if (cellphone.isEmpty) return cellphone;
    String formatedCellphone = '(' +
        cellphone.substring(0, 2) +
        ')' +
        ' ' +
        cellphone.substring(2, 7) +
        '-' +
        cellphone.substring(7, 11);
    return formatedCellphone;
  }

  static String formatCellphoneRemoveFormating({String cellphone = ''}) {
    if (cellphone.isEmpty) return cellphone;
    String removedBracket1 = cellphone.replaceAll('(', '');
    String removedBracket2 = removedBracket1.replaceAll(')', '');
    String removedSpace = removedBracket2.replaceAll(' ', '');
    String removedDash = removedSpace.replaceAll('-', '');
    return removedDash;
  }
}
