/// Representa o usuário autenticado no NutriLog.
///
/// O app possui dois perfis de acesso (cliente e nutricionista).
class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final TipoUsuario tipo;
<<<<<<< HEAD
  final String? fotoPerfil;
=======
  final String? fotoPerfil; // caminho local da foto de perfil
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    this.tipo = TipoUsuario.cliente,
    this.fotoPerfil,
  });

  String get primeiroNome => nome.split(' ').first;

  bool get ehNutricionista => tipo == TipoUsuario.nutricionista;

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
