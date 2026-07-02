import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nutri_provider.dart';
import 'nutri_dashboard_screen.dart';
import 'nutri_clientes_screen.dart';
import 'nutri_avisos_screen.dart';
import 'nutri_perfil_screen.dart';

/// Scaffold principal do nutricionista com barra de navegação inferior.
/// Contém 4 abas: Dashboard · Clientes · Avisos · Perfil
class NutriScaffold extends StatefulWidget {
  const NutriScaffold({super.key});

  @override
  State<NutriScaffold> createState() => _NutriScaffoldState();
}

class _NutriScaffoldState extends State<NutriScaffold> {
  int _tabAtual = 0;

  final List<Widget> _telas = const [
    NutriDashboardScreen(),
    NutriClientesScreen(),
    NutriAvisosScreen(),
    NutriPerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  Future<void> _carregarDados() async {
    final nutri = context.read<NutriProvider>();
    await nutri.carregarClientes();
    await nutri.carregarTodasRefeicoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabAtual,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D1A),
          border: Border(
            top: BorderSide(color: Colors.grey.shade900),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0D0D1A),
          selectedItemColor: const Color(0xFF4080FF),
          unselectedItemColor: Colors.grey.shade600,
          currentIndex: _tabAtual,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (i) => setState(() => _tabAtual = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Avisos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
