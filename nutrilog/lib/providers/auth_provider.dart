import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

enum AuthStatus { inicial, carregando, autenticado, erro }

/// Gerencia o estado de autenticação da aplicação usando o padrão Provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _local = LocalStorageService();

  AuthStatus _status = AuthStatus.inicial;
  UsuarioModel? _usuarioAtual;
  String? _mensagemErro;

  AuthStatus get status => _status;
  UsuarioModel? get usuarioAtual => _usuarioAtual;
  String? get mensagemErro => _mensagemErro;
  bool get estaLogado => _usuarioAtual != null;

  /// Tenta restaurar sessão salva localmente ao iniciar o app.
  Future<bool> tentarRestaurarSessao() async {
    final usuario = await _local.carregarSessao();
    if (usuario != null) {
      _usuarioAtual = usuario;
      _status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String senha) async {
    _setCarregando();
    try {
      _usuarioAtual = await _authService.login(email, senha);
      await _local.salvarSessao(_usuarioAtual!);
      _status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setErro(_authService.mensagemDeErro(e));
      return false;
    } catch (e) {
      _setErro('Erro inesperado ao fazer login. Tente novamente.');
      return false;
    }
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _setCarregando();
    try {
      _usuarioAtual = await _authService.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
      );
      await _local.salvarSessao(_usuarioAtual!);
      _status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setErro(_authService.mensagemDeErro(e));
      return false;
    } catch (e) {
      _setErro('Erro inesperado ao criar a conta. Tente novamente.');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _local.limparSessao();
    _usuarioAtual = null;
    _status = AuthStatus.inicial;
    notifyListeners();
  }

  /// Atualiza a foto de perfil do usuário atual.
  Future<void> atualizarFotoPerfil(String fotoPath) async {
    if (_usuarioAtual == null) return;
    _usuarioAtual = _usuarioAtual!.copyWith(fotoPerfil: fotoPath);
    await _local.atualizarFotoPerfil(_usuarioAtual!.email, fotoPath);
    await _local.salvarSessao(_usuarioAtual!);
    notifyListeners();
  }

  void _setCarregando() {
    _status = AuthStatus.carregando;
    _mensagemErro = null;
    notifyListeners();
  }

  void _setErro(String mensagem) {
    _status = AuthStatus.erro;
    _mensagemErro = mensagem;
    notifyListeners();
  }
}
