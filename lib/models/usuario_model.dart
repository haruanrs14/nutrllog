/// Representa o usuário autenticado no NutriLog.
///
/// O app possui dois perfis de acesso (cliente e nutricionista), por isso
/// guardamos o [tipo] junto com os dados básicos do usuário.
class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final TipoUsuario tipo;
<<<<<<< HEAD:lib/models/usuario_model.dart
  final String? fotoPerfil; // caminho local da foto de perfil
=======
  final String? fotoPerfil;
>>>>>>> cbf2329e27b38bd5df4a57120e5f326e5f7666a8:nutrilog/lib/models/usuario_model.dart

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

  /// Converte o usuário em um Map para salvar no Firestore ou SharedPreferences.
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
