import 'package:flutter/material.dart';
import '../models/refeicao_model.dart';
import '../services/local_storage_service.dart';

/// Gerencia o estado das refeições do usuário atual.
class RefeicaoProvider extends ChangeNotifier {
  final LocalStorageService _local = LocalStorageService();

  List<RefeicaoModel> _refeicoes = [];
  bool _carregando = false;

  List<RefeicaoModel> get refeicoes => _refeicoes;
  bool get carregando => _carregando;

  /// Retorna as refeições do dia atual.
  List<RefeicaoModel> get refeicoesDeHoje {
    final hoje = DateTime.now();
    return _refeicoes.where((r) {
      return r.dataHora.year == hoje.year &&
          r.dataHora.month == hoje.month &&
          r.dataHora.day == hoje.day;
    }).toList();
  }

  /// Verifica se um tipo de refeição já foi registrado hoje.
  bool tipoRegistradoHoje(TipoRefeicao tipo) {
    return refeicoesDeHoje.any((r) => r.tipo == tipo);
  }

  /// Calcula streak de dias consecutivos com pelo menos uma refeição.
  int get streak {
    if (_refeicoes.isEmpty) return 0;
    int dias = 0;
    DateTime dia = DateTime.now();
    while (true) {
      final temNoDia = _refeicoes.any((r) =>
          r.dataHora.year == dia.year &&
          r.dataHora.month == dia.month &&
          r.dataHora.day == dia.day);
      if (!temNoDia) break;
      dias++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return dias;
  }

  Future<void> carregar(String userId) async {
    _carregando = true;
    notifyListeners();
    _refeicoes = await _local.carregarRefeicoes(userId);
    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionarRefeicao(RefeicaoModel refeicao) async {
    await _local.salvarRefeicao(refeicao);
    _refeicoes.insert(0, refeicao);
    notifyListeners();
  }
}
