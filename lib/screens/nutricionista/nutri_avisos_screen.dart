import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/refeicao_model.dart';
import '../../models/usuario_model.dart';
import '../../providers/nutri_provider.dart';
import '../../routes.dart';

/// Tela de avisos/notificações do nutricionista (Tela 07 do painel admin).
/// Mostra atividade recente dos clientes com badges de novo/lido.
class NutriAvisosScreen extends StatelessWidget {
  const NutriAvisosScreen({super.key});

  String _formatarTempo(DateTime dt) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final diaRef = DateTime(dt.year, dt.month, dt.day);

    if (diaRef == hoje) {
      return '${DateFormat('HH:mm').format(dt)} · hoje';
    } else if (diaRef == ontem) {
      return 'ontem';
    } else {
      return DateFormat("d/MM").format(dt);
    }
  }

  bool _ehRecente(DateTime dt) {
    return DateTime.now().difference(dt).inHours < 6;
  }

  bool _clientePendente(UsuarioModel c, NutriProvider nutri) {
    final hoje = DateTime.now();
    final refeicoes = nutri.refeicoesDeCliente(c.uid);
    return !refeicoes.any(
      (r) =>
          r.dataHora.year == hoje.year &&
          r.dataHora.month == hoje.month &&
          r.dataHora.day == hoje.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutri = context.watch<NutriProvider>();
    final atividade = nutri.atividadeRecente;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Avisos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF4080FF),
                backgroundColor: const Color(0xFF171726),
                onRefresh: () async {
                  await nutri.carregarClientes();
                  await nutri.carregarTodasRefeicoes();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // ── Clientes pendentes ────────────────────────────────
                    ...nutri.clientes
                        .where((c) => _clientePendente(c, nutri))
                        .map(
                          (c) => _AvisoItem(
                            emoji: '⚠️',
                            nome: c.nome,
                            mensagem: 'Sem registros hoje. Plano aguardando.',
                            tempo: 'hoje',
                            isNovo: true,
                            corBadge: const Color(0xFFFFAA2C),
                            labelBadge: 'pendente',
                            onTap: () async {
                              await nutri.carregarRefeicoesCliente(c.uid);
                              await nutri.carregarPlanoCliente(c.uid);
                              if (context.mounted) {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.nutriClientePerfil,
                                  arguments: c,
                                );
                              }
                            },
                          ),
                        ),

                    // ── Atividades recentes ───────────────────────────────
                    ...atividade.map((item) {
                      final cliente = item['cliente'] as UsuarioModel;
                      final refeicao = item['refeicao'] as RefeicaoModel;
                      final recente = _ehRecente(refeicao.dataHora);

                      return _AvisoItem(
                        emoji: refeicao.tipo.emoji,
                        nome: cliente.nome,
                        mensagem:
                            'Registrou ${refeicao.tipo.label.toLowerCase()}${refeicao.fotoPath != null ? ' com foto' : ''}.',
                        tempo: _formatarTempo(refeicao.dataHora),
                        isNovo: recente,
                        corBadge: recente
                            ? const Color(0xFF4080FF)
                            : Colors.grey.shade700,
                        labelBadge: recente ? 'novo' : 'lido',
                        onTap: () async {
                          await nutri.carregarRefeicoesCliente(cliente.uid);
                          if (context.mounted) {
                            Navigator.of(context).pushNamed(
                              AppRoutes.nutriRefeicaoDetalhe,
                              arguments: {
                                'refeicao': refeicao,
                                'cliente': cliente,
                              },
                            );
                          }
                        },
                      );
                    }),

                    if (atividade.isEmpty &&
                        nutri.clientes.every((c) => !_clientePendente(c, nutri)))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Nenhum aviso no momento.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoItem extends StatelessWidget {
  final String emoji;
  final String nome;
  final String mensagem;
  final String tempo;
  final bool isNovo;
  final Color corBadge;
  final String labelBadge;
  final VoidCallback onTap;

  const _AvisoItem({
    required this.emoji,
    required this.nome,
    required this.mensagem,
    required this.tempo,
    required this.isNovo,
    required this.corBadge,
    required this.labelBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNovo
                ? corBadge.withOpacity(0.3)
                : const Color(0xFF22223A),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF282840),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mensagem,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tempo,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: corBadge.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: corBadge.withOpacity(0.5)),
              ),
              child: Text(
                labelBadge,
                style: TextStyle(
                  color: corBadge,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
