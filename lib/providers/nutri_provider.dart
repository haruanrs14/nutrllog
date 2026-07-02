import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/refeicao_model.dart';
import '../models/plano_alimentar_model.dart';
import '../services/local_storage_service.dart';

/// Gerencia o estado do painel do nutricionista:
/// clientes, refeições de cada cliente, comentários e planos alimentares.
class NutriProvider extends ChangeNotifier {
  final LocalStorageService _local = LocalStorageService();

  List<UsuarioModel> _clientes = [];
  final Map<String, List<RefeicaoModel>> _refeicoesClientes = {};
  final Map<String, PlanoAlimentarModel> _planosClientes = {};
  bool _carregando = false;

  List<UsuarioModel> get clientes => _clientes;
  bool get carregando => _carregando;

  // ─── Clientes ──────────────────────────────────────────────────────────────

  Future<void> carregarClientes() async {
    _carregando = true;
    notifyListeners();
    _clientes = await _local.listarClientes();
    _carregando = false;
    notifyListeners();
  }

  /// Número de clientes que registraram ao menos uma refeição hoje.
  int get totalAtivosHoje {
    final hoje = DateTime.now();
    return _clientes.where((c) {
      final refeicoes = _refeicoesClientes[c.uid] ?? [];
      return refeicoes.any(
        (r) =>
            r.dataHora.year == hoje.year &&
            r.dataHora.month == hoje.month &&
            r.dataHora.day == hoje.day,
      );
    }).length;
  }

  /// Número de clientes SEM registro hoje.
  int get totalPendentes => _clientes.length - totalAtivosHoje;

  /// Total de refeições registradas hoje em todos os clientes.
  int get totalRefeicoesHoje {
    final hoje = DateTime.now();
    int total = 0;
    for (final refeicoes in _refeicoesClientes.values) {
      total += refeicoes
          .where(
            (r) =>
                r.dataHora.year == hoje.year &&
                r.dataHora.month == hoje.month &&
                r.dataHora.day == hoje.day,
          )
          .length;
    }
    return total;
  }

  // ─── Refeições dos clientes ────────────────────────────────────────────────

  List<RefeicaoModel> refeicoesDeCliente(String userId) {
    return _refeicoesClientes[userId] ?? [];
  }

  Future<void> carregarRefeicoesCliente(String userId) async {
    final refeicoes = await _local.carregarRefeicoes(userId);
    _refeicoesClientes[userId] = refeicoes;
    notifyListeners();
  }

  /// Carrega refeições de todos os clientes (usado pelo dashboard).
  Future<void> carregarTodasRefeicoes() async {
    for (final cliente in _clientes) {
      final refeicoes = await _local.carregarRefeicoes(cliente.uid);
      _refeicoesClientes[cliente.uid] = refeicoes;
    }
    notifyListeners();
  }

  /// Atividade recente: últimas 10 refeições de todos os clientes.
  List<Map<String, dynamic>> get atividadeRecente {
    final lista = <Map<String, dynamic>>[];
    for (final cliente in _clientes) {
      final refeicoes = _refeicoesClientes[cliente.uid] ?? [];
      for (final r in refeicoes) {
        lista.add({'cliente': cliente, 'refeicao': r});
      }
    }
    lista.sort((a, b) {
      final ra = a['refeicao'] as RefeicaoModel;
      final rb = b['refeicao'] as RefeicaoModel;
      return rb.dataHora.compareTo(ra.dataHora);
    });
    return lista.take(10).toList();
  }

  // ─── Comentários ───────────────────────────────────────────────────────────

  Future<void> salvarComentario(
    String userId,
    String mealId,
    String comentario,
  ) async {
    await _local.atualizarComentarioRefeicao(userId, mealId, comentario);
    await carregarRefeicoesCliente(userId);
  }

  // ─── Plano Alimentar ───────────────────────────────────────────────────────

  PlanoAlimentarModel? planoDeCliente(String userId) {
    return _planosClientes[userId];
  }

  Future<void> carregarPlanoCliente(String userId) async {
    final plano = await _local.carregarPlanoAlimentar(userId);
    if (plano != null) {
      _planosClientes[userId] = plano;
      notifyListeners();
    }
  }

  Future<void> salvarPlano(PlanoAlimentarModel plano) async {
    await _local.salvarPlanoAlimentar(plano);
    _planosClientes[plano.userId] = plano;
    notifyListeners();
  }
}
