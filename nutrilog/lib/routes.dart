import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';

/// Centraliza os nomes de rota usados na navegação com rotas nomeadas.
/// Evita strings espalhadas pelo código — toda navegação referencia uma constante daqui.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get rotas => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        cadastro: (context) => const CadastroScreen(),
        home: (context) => const HomeScreen(),
      };
}
