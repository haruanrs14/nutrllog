import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registrar_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/perfil_screen.dart';
<<<<<<< HEAD
import 'screens/nutricionista/nutri_scaffold.dart';
import 'screens/nutricionista/nutri_cliente_perfil_screen.dart';
import 'screens/nutricionista/nutri_refeicao_detalhe_screen.dart';
import 'screens/nutricionista/nutri_plano_alimentar_screen.dart';

/// Centraliza todos os nomes de rota da aplicação.
/// Evita strings "mágicas" espalhadas pelo código — toda navegação
/// referencia uma constante daqui (requisito de rotas nomeadas do trabalho).
=======

/// Centraliza os nomes de rota usados na navegação com rotas nomeadas
/// (requisito do trabalho). Evita strings "mágicas" espalhadas pelo
/// código — toda navegação referencia uma constante daqui.
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98
class AppRoutes {
  // ── Rotas do cliente ──────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String registrar = '/registrar';
  static const String historico = '/historico';
  static const String perfil = '/perfil';
<<<<<<< HEAD

  // ── Rotas do nutricionista ────────────────────────────────────────────────
  static const String nutriHome = '/nutri/home';
  static const String nutriClientePerfil = '/nutri/cliente/perfil';
  static const String nutriRefeicaoDetalhe = '/nutri/refeicao/detalhe';
  static const String nutriPlanoAlimentar = '/nutri/plano';

  static Map<String, WidgetBuilder> get rotas => {
        // Cliente
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        cadastro: (_) => const CadastroScreen(),
        home: (_) => const HomeScreen(),
        registrar: (_) => const RegistrarScreen(),
        historico: (_) => const HistoricoScreen(),
        perfil: (_) => const PerfilScreen(),

        // Nutricionista
        nutriHome: (_) => const NutriScaffold(),
        nutriClientePerfil: (_) => const NutriClientePerfilScreen(),
        nutriRefeicaoDetalhe: (_) => const NutriRefeicaoDetalheScreen(),
        nutriPlanoAlimentar: (_) => const NutriPlanoAlimentarScreen(),
=======

  static Map<String, WidgetBuilder> get rotas => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        cadastro: (context) => const CadastroScreen(),
        home: (context) => const HomeScreen(),
        registrar: (context) => const RegistrarScreen(),
        historico: (context) => const HistoricoScreen(),
        perfil: (context) => const PerfilScreen(),
>>>>>>> b9bb4d453ad986ded85dd560bd99a21fd56fac98
      };
}
