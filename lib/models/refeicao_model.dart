/// Representa uma refeição registrada pelo usuário.
class RefeicaoModel {
  final String id;
  final String userId;
  final TipoRefeicao tipo;
  final String descricao;
  final DateTime dataHora;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;
  final String? localizacaoNome;
  final String? comentarioNutricionista;

  RefeicaoModel({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.descricao,
    required this.dataHora,
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.localizacaoNome,
    this.comentarioNutricionista,
  });

  bool get temComentario =>
      comentarioNutricionista != null &&
      comentarioNutricionista!.trim().isNotEmpty;

  factory RefeicaoModel.fromMap(Map<String, dynamic> map) {
    return RefeicaoModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      tipo: TipoRefeicao.values.firstWhere(
        (t) => t.name == map['tipo'],
        orElse: () => TipoRefeicao.almoco,
      ),
      descricao: map['descricao'] ?? '',
      dataHora: DateTime.fromMillisecondsSinceEpoch(map['dataHora'] ?? 0),
      fotoPath: map['fotoPath'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      localizacaoNome: map['localizacaoNome'] as String?,
      comentarioNutricionista: map['comentarioNutricionista'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tipo': tipo.name,
      'descricao': descricao,
      'dataHora': dataHora.millisecondsSinceEpoch,
      if (fotoPath != null) 'fotoPath': fotoPath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (localizacaoNome != null) 'localizacaoNome': localizacaoNome,
      if (comentarioNutricionista != null)
        'comentarioNutricionista': comentarioNutricionista,
    };
  }

  RefeicaoModel copyWith({
    String? comentarioNutricionista,
  }) {
    return RefeicaoModel(
      id: id,
      userId: userId,
      tipo: tipo,
      descricao: descricao,
      dataHora: dataHora,
      fotoPath: fotoPath,
      latitude: latitude,
      longitude: longitude,
      localizacaoNome: localizacaoNome,
      comentarioNutricionista:
          comentarioNutricionista ?? this.comentarioNutricionista,
    );
  }
}

enum TipoRefeicao {
  cafe,
  almoco,
  lanche,
  jantar;

  String get label {
    switch (this) {
      case TipoRefeicao.cafe:
        return 'Café da manhã';
      case TipoRefeicao.almoco:
        return 'Almoço';
      case TipoRefeicao.lanche:
        return 'Lanche';
      case TipoRefeicao.jantar:
        return 'Jantar';
    }
  }

  String get emoji {
    switch (this) {
      case TipoRefeicao.cafe:
        return '🍳';
      case TipoRefeicao.almoco:
        return '🥗';
      case TipoRefeicao.lanche:
        return '🍎';
      case TipoRefeicao.jantar:
        return '🌙';
    }
  }
}
