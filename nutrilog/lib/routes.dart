import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registrar_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/perfil_screen.dart';


///  Evita strings "mágicas" espalhadas pelo
/// código — toda navegação referencia uma constante daqui.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String registrar = '/registrar';
  static const String historico = '/historico';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get rotas => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        cadastro: (context) => const CadastroScreen(),
        home: (context) => const HomeScreen(),
        registrar: (context) => const RegistrarScreen(),
        historico: (context) => const HistoricoScreen(),
        perfil: (context) => const PerfilScreen(),
      };
}
