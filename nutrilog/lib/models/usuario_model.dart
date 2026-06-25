
class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final TipoUsuario tipo;
  final String? fotoPerfil; 

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    this.tipo = TipoUsuario.cliente,
    this.fotoPerfil,
  });

  /// Cria um [UsuarioModel] a partir de um Map vindo do Firestore ou SharedPreferences.
  factory UsuarioModel.fromMap(Map<String, dynamic> map, String uid) {
    return UsuarioModel(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      tipo: map['tipo'] == 'nutricionista'
          ? TipoUsuario.nutricionista
          : TipoUsuario.cliente,
      fotoPerfil: map['fotoPerfil'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo == TipoUsuario.nutricionista ? 'nutricionista' : 'cliente',
      if (fotoPerfil != null) 'fotoPerfil': fotoPerfil,
    };
  }

  UsuarioModel copyWith({
    String? nome,
    String? email,
    TipoUsuario? tipo,
    String? fotoPerfil,
  }) {
    return UsuarioModel(
      uid: uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
    );
  }
}

enum TipoUsuario { cliente, nutricionista }
