import '../models/usuario_model.dart';
import 'local_storage_service.dart';

/// Camada de serviço responsável por autenticação.
/// Usa armazenamento local via SharedPreferences.
/// O nutricionista possui conta fixa hardcoded — sem necessidade de cadastro.
class AuthService {
  final LocalStorageService _local = LocalStorageService();

  // ── Conta fixa do nutricionista (admin) ─────────────────────────────────
  static const String _emailNutri = 'nutricionista@gmail.com';
  static const String _senhaNutri = 'Nutri123@';

  Future<UsuarioModel> login(String email, String senha) async {
    final emailLower = email.trim().toLowerCase();

    // Verifica primeiro se é o acesso do nutricionista
    if (emailLower == _emailNutri && senha == _senhaNutri) {
      return UsuarioModel(
        uid: 'nutri_admin',
        nome: 'Nutricionista',
        email: emailLower,
        tipo: TipoUsuario.nutricionista,
      );
    }

    // Verifica usuários clientes cadastrados localmente
    final usuario = await _local.loginLocal(emailLower, senha);
    if (usuario != null) return usuario;

    throw _AuthException(
      code: 'wrong-password',
      message: 'E-mail ou senha incorretos.',
    );
  }

  Future<UsuarioModel> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailLower = email.trim().toLowerCase();

    // Impede cadastro com o e-mail reservado ao nutricionista
    if (emailLower == _emailNutri) {
      throw _AuthException(
        code: 'email-already-in-use',
        message: 'Esse e-mail já está cadastrado.',
      );
    }

    final jaExiste = await _local.emailJaCadastrado(emailLower);
    if (jaExiste) {
      throw _AuthException(
        code: 'email-already-in-use',
        message: 'Esse e-mail já está cadastrado.',
      );
    }

    await _local.cadastrarUsuarioLocal(
      nome: nome.trim(),
      email: emailLower,
      senha: senha,
    );

    final usuario = await _local.loginLocal(emailLower, senha);
    return usuario!;
  }

  Future<void> logout() async {
    // A sessão é gerenciada pelo LocalStorageService.
  }

  String mensagemDeErro(dynamic erro) {
    if (erro is _AuthException) {
      switch (erro.code) {
        case 'user-not-found':
          return 'Não encontramos uma conta com esse e-mail.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'email-already-in-use':
          return 'Esse e-mail já está cadastrado.';
        case 'weak-password':
          return 'A senha precisa ter pelo menos 6 caracteres.';
        case 'invalid-email':
          return 'E-mail inválido.';
        default:
          return erro.message ?? 'Erro ao autenticar.';
      }
    }
    return 'Erro inesperado: $erro';
  }
}

/// Exceção de autenticação local.
class _AuthException implements Exception {
  final String code;
  final String? message;
  const _AuthException({required this.code, this.message});
}
