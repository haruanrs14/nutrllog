/// Plano alimentar elaborado pelo nutricionista para um cliente específico.
class PlanoAlimentarModel {
  final String userId;
  final String? cafe;
  final String? almoco;
  final String? lanche;
  final String? jantar;
  final DateTime atualizadoEm;

  PlanoAlimentarModel({
    required this.userId,
    this.cafe,
    this.almoco,
    this.lanche,
    this.jantar,
    required this.atualizadoEm,
  });

  bool get temAlgumItem =>
      (cafe?.isNotEmpty ?? false) ||
      (almoco?.isNotEmpty ?? false) ||
      (lanche?.isNotEmpty ?? false) ||
      (jantar?.isNotEmpty ?? false);

  factory PlanoAlimentarModel.fromMap(Map<String, dynamic> map) {
    return PlanoAlimentarModel(
      userId: map['userId'] ?? '',
      cafe: map['cafe'] as String?,
      almoco: map['almoco'] as String?,
      lanche: map['lanche'] as String?,
      jantar: map['jantar'] as String?,
      atualizadoEm: DateTime.fromMillisecondsSinceEpoch(
        map['atualizadoEm'] ?? 0,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      if (cafe != null) 'cafe': cafe,
      if (almoco != null) 'almoco': almoco,
      if (lanche != null) 'lanche': lanche,
      if (jantar != null) 'jantar': jantar,
      'atualizadoEm': atualizadoEm.millisecondsSinceEpoch,
    };
  }

  PlanoAlimentarModel copyWith({
    String? cafe,
    String? almoco,
    String? lanche,
    String? jantar,
  }) {
    return PlanoAlimentarModel(
      userId: userId,
      cafe: cafe ?? this.cafe,
      almoco: almoco ?? this.almoco,
      lanche: lanche ?? this.lanche,
      jantar: jantar ?? this.jantar,
      atualizadoEm: DateTime.now(),
    );
  }
}
