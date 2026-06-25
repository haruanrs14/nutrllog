/// Utilitários de validação de formulários usados nas telas de Login e Cadastro.
class Validadores {
  /// Valida e-mail no formato padrão.
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail é obrigatório.';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(valor.trim())) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  /// Valida senha com os requisitos do trabalho:
 
  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha é obrigatória.';
    }
    if (valor.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }
    if (!valor.contains(RegExp(r'[A-Z]'))) {
      return 'A senha precisa ter pelo menos uma letra maiúscula.';
    }
    if (!valor.contains(RegExp(r'[0-9]'))) {
      return 'A senha precisa ter pelo menos um número.';
    }
    if (!valor.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;`~/]'))) {
      return 'A senha precisa ter pelo menos um caractere especial.';
    }
    return null;
  }

  /// Valida confirmação de senha.
  static String? confirmarSenha(String? valor, String senhaOriginal) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme sua senha.';
    }
    if (valor != senhaOriginal) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Valida nome completo (mínimo dois nomes).
  static String? nomeCompleto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O nome completo é obrigatório.';
    }
    final partes = valor.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.length < 2) {
      return 'Digite seu nome completo (nome e sobrenome).';
    }
    return null;
  }

  /// Retorna lista de requisitos da senha com status (atendido/não atendido).
  static List<RequisitoSenha> requisitos(String senha) {
    return [
      RequisitoSenha(
        'Mínimo 6 caracteres',
        senha.length >= 6,
      ),
      RequisitoSenha(
        'Pelo menos uma letra maiúscula',
        senha.contains(RegExp(r'[A-Z]')),
      ),
      RequisitoSenha(
        'Pelo menos um número',
        senha.contains(RegExp(r'[0-9]')),
      ),
      RequisitoSenha(
        'Pelo menos um caractere especial',
        senha.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;`~/]')),
      ),
    ];
  }
}

class RequisitoSenha {
  final String descricao;
  final bool atendido;
  const RequisitoSenha(this.descricao, this.atendido);
}
