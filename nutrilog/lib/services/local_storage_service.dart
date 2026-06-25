import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';
import '../models/refeicao_model.dart';


class LocalStorageService {
  static const _keyUsuario = 'usuario_logado';
  static const _keyRefeicoes = 'refeicoes';
  static const _keyUsuariosCadastrados = 'usuarios_cadastrados';

  // ─── Sessão do usuário ───────────────────────────────────────────────────

  Future<void> salvarSessao(UsuarioModel usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final map = usuario.toMap()..['uid'] = usuario.uid;
    await prefs.setString(_keyUsuario, jsonEncode(map));
  }

  Future<UsuarioModel?> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUsuario);
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UsuarioModel.fromMap(map, map['uid'] as String);
  }

  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
  }

  // ─── Usuários cadastrados (sem Firebase) ────────────────────────────────

  Future<Map<String, dynamic>> _carregarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUsuariosCadastrados);
    if (json == null) return {};
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> cadastrarUsuarioLocal({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = await _carregarUsuarios();
    final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
    usuarios[email] = {
      'uid': uid,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo': 'cliente',
    };
    await prefs.setString(_keyUsuariosCadastrados, jsonEncode(usuarios));
  }

  Future<UsuarioModel?> loginLocal(String email, String senha) async {
    final usuarios = await _carregarUsuarios();
    final dados = usuarios[email] as Map<String, dynamic>?;
    if (dados == null) return null;
    if (dados['senha'] != senha) return null;
    return UsuarioModel.fromMap(dados, dados['uid'] as String);
  }

  Future<bool> emailJaCadastrado(String email) async {
    final usuarios = await _carregarUsuarios();
    return usuarios.containsKey(email);
  }

  Future<void> atualizarFotoPerfil(String email, String fotoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = await _carregarUsuarios();
    if (usuarios.containsKey(email)) {
      (usuarios[email] as Map<String, dynamic>)['fotoPerfil'] = fotoPath;
      await prefs.setString(_keyUsuariosCadastrados, jsonEncode(usuarios));
    }
  }

  // ─── Refeições ──────────────────────────────────────────────────────────

  Future<List<RefeicaoModel>> carregarRefeicoes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_keyRefeicoes}_$userId');
    if (json == null) return [];
    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map((e) => RefeicaoModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarRefeicao(RefeicaoModel refeicao) async {
    final prefs = await SharedPreferences.getInstance();
    final refeicoes = await carregarRefeicoes(refeicao.userId);
    refeicoes.insert(0, refeicao); // mais recente primeiro
    await prefs.setString(
      '${_keyRefeicoes}_${refeicao.userId}',
      jsonEncode(refeicoes.map((r) => r.toMap()).toList()),
    );
  }
}
