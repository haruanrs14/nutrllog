import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/refeicao_model.dart';
import '../providers/auth_provider.dart';
import '../providers/refeicao_provider.dart';
import '../routes.dart';
import '../widgets/meal_card.dart';

/// Tela inicial do cliente (Tela 04). Mostra boas-vindas, data atual,
/// refeições do dia e barra de navegação inferior fixa.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabAtual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.usuarioAtual != null) {
        context.read<RefeicaoProvider>().carregar(auth.usuarioAtual!.uid);
      }
    });
  }

  void _onNavTap(int index) {
    if (index == 1) {
      // Registrar → abre câmera
      Navigator.of(context).pushNamed(AppRoutes.registrar);
      return;
    }
    setState(() => _tabAtual = index);
    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.historico);
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushNamed(AppRoutes.perfil);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final refeicaoProvider = context.watch<RefeicaoProvider>();
    final usuario = authProvider.usuarioAtual;
    final primeiroNome = (usuario?.nome ?? 'Cliente').split(' ').first;

    final agora = DateTime.now();
    final diaSemana = DateFormat('EEEE', 'pt_BR').format(agora);
    final diaMes = agora.day.toString();
    final mes = DateFormat('MMMM', 'pt_BR').format(agora);

    final refeicoesHoje = refeicaoProvider.refeicoesDeHoje;
    final streak = refeicaoProvider.streak;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Boas-vindas, 👋',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          primeiroNome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar de perfil
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.perfil),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF4080FF),
                      backgroundImage: usuario?.fotoPerfil != null
                          ? NetworkImage(usuario!.fotoPerfil!)
                          : null,
                      child: usuario?.fotoPerfil == null
                          ? Text(
                              primeiroNome.isNotEmpty
                                  ? primeiroNome[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              // ── Data ──────────────────────────────────────────────────
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    diaSemana.substring(0, 1).toUpperCase() +
                        diaSemana.substring(1),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '  ·  ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Text(
                    diaMes,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' de ',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                  Text(
                    mes.substring(0, 1).toUpperCase() + mes.substring(1),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // ── Streak ────────────────────────────────────────────────
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF171726),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF22223A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      streak == 0
                          ? 'Comece hoje!'
                          : '$streak ${streak == 1 ? 'dia seguido' : 'dias seguidos'}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Refeições ─────────────────────────────────────────────
              const SizedBox(height: 28),
              const Text(
                'Refeições de hoje',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              ...TipoRefeicao.values.map((tipo) {
                final refeicao = refeicoesHoje
                    .cast<RefeicaoModel?>()
                    .firstWhere(
                      (r) => r?.tipo == tipo,
                      orElse: () => null,
                    );
                final registrada = refeicao != null;
                final horario = registrada
                    ? DateFormat('HH:mm').format(refeicao!.dataHora)
                    : null;

                return MealCard(
                  emoji: tipo.emoji,
                  titulo: tipo.label,
                  subtitulo: registrada
                      ? 'Registrado · $horario'
                      : 'Pendente · Toque para registrar',
                  registrada: registrada,
                  onTap: registrada
                      ? null
                      : () =>
                          Navigator.of(context).pushNamed(AppRoutes.registrar),
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D0D1A),
        selectedItemColor: const Color(0xFF4080FF),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _tabAtual,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
