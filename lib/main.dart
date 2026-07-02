import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';
import 'providers/refeicao_provider.dart';
import 'routes.dart';

// Nota: Firebase.initializeApp() é chamado apenas quando o arquivo
// firebase_options.dart estiver presente (gerado pelo FlutterFire CLI).
// Enquanto não estiver configurado, o app funciona com armazenamento local
// via SharedPreferences.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tenta inicializar o Firebase se estiver configurado.
  // Caso contrário, o app usa armazenamento local como fallback.
  try {
    // Para ativar o Firebase: descomente as linhas abaixo e gere o
    // firebase_options.dart com: flutterfire configure
    //
    // import 'package:firebase_core/firebase_core.dart';
    // import 'firebase_options.dart';
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  } catch (_) {
    // Firebase não configurado — usa fallback local.
  }

  // Necessário para o DateFormat em português (usado na Home).
  await initializeDateFormatting('pt_BR');

  runApp(const NutriLogApp());
}

class NutriLogApp extends StatelessWidget {
  const NutriLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RefeicaoProvider()),
      ],
      child: MaterialApp(
        title: 'NutriLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF07070F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4080FF),
            brightness: Brightness.dark,
          ),
          // Chip theme para a seleção de tipo de refeição
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFF171726),
            selectedColor: const Color(0xFF4080FF),
            labelStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.rotas,
      ),
    );
  }
}
