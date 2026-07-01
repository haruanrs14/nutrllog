import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';

<<<<<<< HEAD:lib/routes.dart
/// Centraliza os nomes de rota usados na navegação com rotas nomeadas
/// (requisito do trabalho). Evita strings "mágicas" espalhadas pelo
/// código — toda navegação referencia uma constante daqui.
=======
/// Centraliza os nomes de rota usados na navegação com rotas nomeadas.
/// Evita strings espalhadas pelo código — toda navegação referencia uma constante daqui.
>>>>>>> cbf2329e27b38bd5df4a57120e5f326e5f7666a8:nutrilog/lib/routes.dart
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
