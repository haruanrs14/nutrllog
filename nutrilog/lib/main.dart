import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';
import 'providers/refeicao_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
