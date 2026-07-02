import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';
import '../models/refeicao_model.dart';
import '../models/plano_alimentar_model.dart';

/// Serviço de armazenamento local usando SharedPreferences.
<<<<<<< HEAD
/// Guarda sessão do usuário, histórico de refeições, planos alimentares
/// e comentários do nutricionista — sem necessitar de Firebase configurado.
=======
/// Guarda sessão do usuário e histórico de refeições localmente,
/// permitindo que o app funcione sem Firebase configurado (desenvolvimento).
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98
class LocalStorageService {
  static const _keyUsuario = 'usuario_logado';
  static const _keyRefeicoes = 'refeicoes';
  static const _keyUsuariosCadastrados = 'usuarios_cadastrados';
  static const _keyPlano = 'plano_alimentar';

  // ─── Sessão ────────────────────────────────────────────────────────────────

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

<<<<<<< HEAD
  // ─── Usuários ──────────────────────────────────────────────────────────────
=======
  // ─── Usuários cadastrados (sem Firebase) ────────────────────────────────
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98

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

<<<<<<< HEAD
  /// Retorna todos os clientes cadastrados (excluindo o nutricionista fixo).
  Future<List<UsuarioModel>> listarClientes() async {
    final usuarios = await _carregarUsuarios();
    final lista = <UsuarioModel>[];
    for (final entry in usuarios.entries) {
      final dados = entry.value as Map<String, dynamic>;
      if (dados['tipo'] != 'nutricionista') {
        lista.add(UsuarioModel.fromMap(dados, dados['uid'] as String));
      }
    }
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  // ─── Refeições ─────────────────────────────────────────────────────────────
=======
  // ─── Refeições ──────────────────────────────────────────────────────────
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98

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

  /// Atualiza o comentário do nutricionista em uma refeição específica.
  Future<void> atualizarComentarioRefeicao(
    String userId,
    String mealId,
    String comentario,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final refeicoes = await carregarRefeicoes(userId);
    final idx = refeicoes.indexWhere((r) => r.id == mealId);
    if (idx == -1) return;
    refeicoes[idx] = refeicoes[idx].copyWith(
      comentarioNutricionista: comentario.trim(),
    );
    await prefs.setString(
      '${_keyRefeicoes}_$userId',
      jsonEncode(refeicoes.map((r) => r.toMap()).toList()),
    );
  }

  // ─── Plano Alimentar ───────────────────────────────────────────────────────

  Future<PlanoAlimentarModel?> carregarPlanoAlimentar(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_keyPlano}_$userId');
    if (json == null) return null;
    return PlanoAlimentarModel.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  Future<void> salvarPlanoAlimentar(PlanoAlimentarModel plano) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyPlano}_${plano.userId}',
      jsonEncode(plano.toMap()),
    );
  }
}
