import 'package:flutter/foundation.dart';
import '../models/usuario_model.dart';
import 'local_storage_service.dart';

/// Camada de serviço responsável por autenticação.
/// Usa armazenamento local via SharedPreferences (modo de desenvolvimento).
/// Quando o Firebase for configurado, este serviço pode ser estendido.
class AuthService {
  final LocalStorageService _local = LocalStorageService();

  Future<UsuarioModel> login(String email, String senha) async {
    final usuario = await _local.loginLocal(email.trim(), senha);
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
    final jaExiste = await _local.emailJaCadastrado(email.trim());
    if (jaExiste) {
      throw _AuthException(
        code: 'email-already-in-use',
        message: 'Esse e-mail já está cadastrado.',
      );
    }
    await _local.cadastrarUsuarioLocal(
      nome: nome.trim(),
      email: email.trim(),
      senha: senha,
    );
    final usuario = await _local.loginLocal(email.trim(), senha);
    return usuario!;
  }

  Future<void> logout() async {}

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

/// Exceção de autenticação local (substitui FirebaseAuthException em dev).
class _AuthException implements Exception {
  final String code;
  final String? message;
  const _AuthException({required this.code, this.message});
}
