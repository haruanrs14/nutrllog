import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/refeicao_model.dart';
import '../providers/auth_provider.dart';
import '../providers/refeicao_provider.dart';
import '../routes.dart';
import '../widgets/meal_card.dart';

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

  // FIX: navegação real para cada aba
  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _tabAtual = 0);
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushNamed(AppRoutes.registrar).then((_) {
        // Recarrega refeições ao voltar do registrar
        final auth = context.read<AuthProvider>();
        if (auth.usuarioAtual != null) {
          context.read<RefeicaoProvider>().carregar(auth.usuarioAtual!.uid);
        }
        setState(() => _tabAtual = 0);
      });
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.historico).then((_) {
        setState(() => _tabAtual = 0);
      });
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushNamed(AppRoutes.perfil).then((_) {
        setState(() => _tabAtual = 0);
      });
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
              // ── Cabeçalho ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Boas-vindas, 👋',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(primeiroNome,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  // FIX: avatar usa FileImage quando há foto local
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.perfil)
                        .then((_) => setState(() {})),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF4080FF),
                      backgroundImage: (usuario?.fotoPerfil != null &&
                              File(usuario!.fotoPerfil!).existsSync())
                          ? FileImage(File(usuario.fotoPerfil!))
                          : null,
                      child: (usuario?.fotoPerfil == null ||
                              !File(usuario?.fotoPerfil ?? '').existsSync())
                          ? Text(
                              primeiroNome.isNotEmpty
                                  ? primeiroNome[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.logout_rounded,
                        color: Colors.grey.shade500, size: 22),
                    tooltip: 'Sair',
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.login);
                      }
                    },
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
                        fontWeight: FontWeight.w500),
                  ),
                  Text('  ·  ',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                  Text(diaMes,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  Text(' de ',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13)),
                  Text(
                    mes.substring(0, 1).toUpperCase() + mes.substring(1),
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              // ── Streak ────────────────────────────────────────────────
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
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
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Refeições de hoje ─────────────────────────────────────
              const SizedBox(height: 28),
              const Text('Refeições de hoje',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),

              // FIX: onTap real para cada card de refeição
              ...TipoRefeicao.values.map((tipo) {
                final refeicao = refeicoesHoje
                    .cast<RefeicaoModel?>()
                    .firstWhere((r) => r?.tipo == tipo, orElse: () => null);
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
                  // FIX: onTap vai para Registrar passando o tipo pré-selecionado
                  onTap: registrada
                      ? () => _mostrarDetalheRefeicao(context, refeicao!)
                      : () => Navigator.of(context)
                          .pushNamed(AppRoutes.registrar,
                              arguments: {'tipoPreSelecionado': tipo})
                          .then((_) {
                            final auth = context.read<AuthProvider>();
                            if (auth.usuarioAtual != null) {
                              context
                                  .read<RefeicaoProvider>()
                                  .carregar(auth.usuarioAtual!.uid);
                            }
                          }),
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
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded), label: 'Registrar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: 'Histórico'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }

  void _mostrarDetalheRefeicao(BuildContext context, RefeicaoModel r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171726),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('${r.tipo.emoji}  ${r.tipo.label}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                'Registrado às ${DateFormat('HH:mm').format(r.dataHora)}',
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            if (r.descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(r.descricao,
                  style: TextStyle(
                      color: Colors.grey.shade300, fontSize: 13)),
            ],
            if (r.localizacaoNome != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(r.localizacaoNome!,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
            if (r.comentarioNutricionista != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DDDA0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF2DDDA0).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🩺 ',
                        style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Consideração do nutricionista',
                              style: TextStyle(
                                  color: Color(0xFF2DDDA0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(r.comentarioNutricionista!,
                              style: TextStyle(
                                  color: Colors.grey.shade200,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
