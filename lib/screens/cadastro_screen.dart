import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../utils/validadores.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/senha_requisitos.dart';

/// Tela de cadastro (Tela 03). Cria nova conta de cliente com validação
/// de senha robusta (maiúscula, número, caractere especial, mínimo 6 dígitos).
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  String _senhaAtual = '';
  bool _mostrarRequisitos = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final sucesso = await authProvider.cadastrar(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Comece sua jornada alimentar hoje',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  label: 'Nome completo',
                  placeholder: 'Seu nome e sobrenome',
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  validator: Validadores.nomeCompleto,
                ),
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
                  placeholder: 'Ex: Nutri@2026',
                  controller: _senhaController,
                  isSenha: true,
                  textInputAction: TextInputAction.next,
                  onChanged: (v) {
                    setState(() {
                      _senhaAtual = v;
                      _mostrarRequisitos = v.isNotEmpty;
                    });
                  },
                  validator: Validadores.senha,
                ),

                // Requisitos de senha em tempo real
                if (_mostrarRequisitos)
                  SenhaRequisitos(senha: _senhaAtual),

                CustomTextField(
                  label: 'Confirmar senha',
                  placeholder: '••••••••',
                  controller: _confirmarSenhaController,
                  isSenha: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validadores.confirmarSenha(v, _senhaController.text),
                ),

                const SizedBox(height: 4),
                PrimaryButton(
                  texto: 'Criar conta',
                  carregando: carregando,
                  onPressed: () => _cadastrar(authProvider),
                ),

                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(text: 'Já tenho conta. '),
                          TextSpan(
                            text: 'Fazer login',
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
