import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

/// Tela de abertura (Tela 01). Verifica sessão salva e redireciona
/// automaticamente para Home (se logado) ou Login (se não logado).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _verificarAutenticacao();
  }

  Future<void> _verificarAutenticacao() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final temSessao = await authProvider.tentarRestaurarSessao();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      temSessao ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4080FF),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4080FF).withOpacity(0.35),
                      blurRadius: 50,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🥗', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
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
              const SizedBox(height: 8),
              Text(
                'Acompanhamento alimentar\nconectado ao seu nutricionista',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF4080FF),
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
