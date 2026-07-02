import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/refeicao_model.dart';
import '../../models/usuario_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutri_provider.dart';

/// Dashboard do nutricionista (Tela 02 do painel admin).
/// Mostra métricas do dia e atividade recente dos clientes.
class NutriDashboardScreen extends StatelessWidget {
  const NutriDashboardScreen({super.key});

  String _formatarTempo(DateTime dt) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final diaRef = DateTime(dt.year, dt.month, dt.day);

    if (diaRef == hoje) {
      return DateFormat('HH:mm').format(dt);
    } else if (diaRef == ontem) {
      return 'ontem';
    } else {
      return DateFormat("d/MM").format(dt);
    }
  }

  Color _corDot(String userId, NutriProvider nutri) {
    final hoje = DateTime.now();
    final refeicoes = nutri.refeicoesDeCliente(userId);
    final temHoje = refeicoes.any(
      (r) =>
          r.dataHora.year == hoje.year &&
          r.dataHora.month == hoje.month &&
          r.dataHora.day == hoje.day,
    );
    return temHoje ? const Color(0xFF2DDDA0) : const Color(0xFFFFAA2C);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nutri = context.watch<NutriProvider>();

    final agora = DateTime.now();
    final diaSemana = DateFormat('EEEE', 'pt_BR').format(agora);
    final diaMes = agora.day;
    final mes = DateFormat('MMMM', 'pt_BR').format(agora);
    final dataFormatada =
        '${diaSemana[0].toUpperCase()}${diaSemana.substring(1)}, $diaMes de ${mes[0].toUpperCase()}${mes.substring(1)}';

    final atividade = nutri.atividadeRecente;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4080FF),
          backgroundColor: const Color(0xFF171726),
          onRefresh: () async {
            await nutri.carregarClientes();
            await nutri.carregarTodasRefeicoes();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // ── Cabeçalho ────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, 👋',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Nutricionista',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dataFormatada,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4080FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4080FF).withOpacity(0.4),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('🩺', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 5),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Color(0xFF6FA3FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Métricas ─────────────────────────────────────────────
              const SizedBox(height: 24),
              Row(
                children: [
                  _MetricaCard(
                    valor: nutri.clientes.length.toString(),
                    label: 'Clientes',
                    cor: const Color(0xFF4080FF),
                  ),
                  const SizedBox(width: 8),
                  _MetricaCard(
                    valor: nutri.totalRefeicoesHoje.toString(),
                    label: 'Refeições\nhoje',
                    cor: const Color(0xFF2DDDA0),
                  ),
                  const SizedBox(width: 8),
                  _MetricaCard(
                    valor: nutri.totalPendentes.toString(),
                    label: 'Pendentes\nhoje',
                    cor: const Color(0xFFFFAA2C),
                  ),
                ],
              ),

              // ── Atividade recente ─────────────────────────────────────
              const SizedBox(height: 28),
              const Text(
                'Atividade recente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              if (nutri.carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: Color(0xFF4080FF),
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (atividade.isEmpty)
                _EstadoVazio(
                  mensagem: 'Nenhuma atividade recente.\nAguardando registros dos clientes.',
                )
              else
                ...atividade.map((item) {
                  final cliente = item['cliente'] as UsuarioModel;
                  final refeicao = item['refeicao'] as RefeicaoModel;
                  final cor = _corDot(cliente.uid, nutri);

                  return _AtividadeItem(
                    cor: cor,
                    texto:
                        '${cliente.primeiroNome} registrou ${refeicao.tipo.label.toLowerCase()}',
                    horario: _formatarTempo(refeicao.dataHora),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricaCard extends StatelessWidget {
  final String valor;
  final String label;
  final Color cor;

  const _MetricaCard({
    required this.valor,
    required this.label,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                color: cor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtividadeItem extends StatelessWidget {
  final Color cor;
  final String texto;
  final String horario;

  const _AtividadeItem({
    required this.cor,
    required this.texto,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF22223A)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Text(
            horario,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final String mensagem;
  const _EstadoVazio({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
    );
  }
}
