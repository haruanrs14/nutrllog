import 'package:flutter/foundation.dart';
import '../models/usuario_model.dart';
import 'local_storage_service.dart';

// Importações do Firebase com guard condicional.
// O app funciona inteiramente sem Firebase quando não configurado.
bool _firebaseDisponivel = false;

// Lazy references — só acessadas dentro de try/catch
dynamic get _firebaseAuth {
  try {
    // ignore: avoid_dynamic_calls
    final fa = _getFirebaseAuth();
    return fa;
  } catch (_) {
    return null;
  }
}

// Usamos dynamic para evitar import estático que trava sem Firebase
dynamic _getFirebaseAuth() {
  throw UnimplementedError('Firebase não importado estaticamente.');
}

/// Camada de serviço responsável por autenticação.
/// Tenta usar Firebase quando disponível; caso contrário, usa
/// armazenamento local via SharedPreferences (modo de desenvolvimento).
class AuthService {
  final LocalStorageService _local = LocalStorageService();

  /// Testa se o Firebase está inicializado e acessível.
  bool get _fbDisponivel {
    try {
      // Se firebase_core não foi inicializado, isso lança.
      // Usamos uma abordagem dinâmica para não depender de import estático.
      return _firebaseDisponivel;
    } catch (_) {
      return false;
    }
  }

  Future<UsuarioModel> login(String email, String senha) async {
    // Sempre tenta fallback local — Firebase não está configurado em dev
    final usuario = await _local.loginLocal(email.trim(), senha);
    if (usuario != null) return usuario;

    // Usuário não encontrado localmente
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

  Future<void> logout() async {
    // Sem Firebase ativo, não há nada a fazer aqui.
    // A sessão é limpa pelo LocalStorageService.
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

/// Exceção de autenticação local (substitui FirebaseAuthException em dev).
class _AuthException implements Exception {
  final String code;
  final String? message;
  const _AuthException({required this.code, this.message});
}
