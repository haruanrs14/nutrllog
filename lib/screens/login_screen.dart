import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../utils/validadores.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

/// Tela de login (Tela 02). Permite autenticação com e-mail e senha
/// com validação de formato de e-mail e requisitos de senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    final sucesso = await authProvider.login(email, senha);

    if (sucesso && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (mounted && authProvider.mensagemErro != null) {
      _mostrarErro(authProvider.mensagemErro!);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final carregando = authProvider.status == AuthStatus.carregando;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4080FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🥗', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Nutri'),
                          TextSpan(
                            text: 'Log',
                            style: TextStyle(color: Color(0xFF4080FF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                const Text(
                  'Bem-vindo de volta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Entre com suas credenciais para continuar',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: 'E-mail',
                  placeholder: 'seuemail@email.com',
                  controller: _emailController,
                  tipoTeclado: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validadores.email,
                ),
                CustomTextField(
                  label: 'Senha',
                  placeholder: '••••••••',
                  controller: _senhaController,
                  isSenha: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'A senha é obrigatória.';
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Color(0xFF6FA3FF), fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                PrimaryButton(
                  texto: 'Entrar',
                  carregando: carregando,
                  onPressed: () => _entrar(authProvider),
                ),

                const SizedBox(height: 28),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.cadastro),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(text: 'Não tem conta? '),
                          TextSpan(
                            text: 'Criar conta',
                            style: TextStyle(
                              color: Color(0xFF6FA3FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
