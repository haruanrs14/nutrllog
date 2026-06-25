import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import 'local_storage_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local = LocalStorageService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UsuarioModel> login(String email, String senha) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final uid = credencial.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'usuario-sem-perfil',
          message: 'Usuário autenticado, mas sem dados de perfil no Firestore.',
        );
      }
      return UsuarioModel.fromMap(doc.data()!, uid);
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      // Fallback local
      final usuario = await _local.loginLocal(email.trim(), senha);
      if (usuario == null) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'E-mail ou senha incorretos.',
        );
      }
      return usuario;
    }
  }

  Future<UsuarioModel> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final uid = credencial.user!.uid;
      final usuario = UsuarioModel(
        uid: uid,
        nome: nome.trim(),
        email: email.trim(),
        tipo: TipoUsuario.cliente,
      );
      await _firestore.collection('usuarios').doc(uid).set(usuario.toMap());
      return usuario;
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      // Fallback local
      final jaExiste = await _local.emailJaCadastrado(email.trim());
      if (jaExiste) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Esse e-mail já está cadastrado.',
        );
      }
      await _local.cadastrarUsuarioLocal(
        nome: nome.trim(),
        email: email.trim(),
        senha: senha,
      );
      final usuario = await _local.loginLocal(email.trim(), senha);
      return usuario!;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  String mensagemDeErro(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com esse e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Esse e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'usuario-sem-perfil':
        return erro.message ?? 'Erro ao carregar o perfil do usuário.';
      default:
        return 'Erro ao autenticar: ${erro.message}';
    }
  }
}
