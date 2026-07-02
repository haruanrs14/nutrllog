import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/usuario_model.dart';
import '../../models/refeicao_model.dart';
import '../../providers/nutri_provider.dart';
import '../../routes.dart';

/// Perfil do cliente visto pelo nutricionista (Tela 04 do painel admin).
/// Exibe estatísticas, grade de refeições e plano alimentar em abas.
class NutriClientePerfilScreen extends StatefulWidget {
  const NutriClientePerfilScreen({super.key});

  @override
  State<NutriClientePerfilScreen> createState() =>
      _NutriClientePerfilScreenState();
}

class _NutriClientePerfilScreenState extends State<NutriClientePerfilScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _diasAtivos(List<RefeicaoModel> refeicoes) {
    final datas = refeicoes
        .map((r) => '${r.dataHora.year}-${r.dataHora.month}-${r.dataHora.day}')
        .toSet();
    return datas.length;
  }

  bool _ativoHoje(List<RefeicaoModel> refeicoes) {
    final hoje = DateTime.now();
    return refeicoes.any(
      (r) =>
          r.dataHora.year == hoje.year &&
          r.dataHora.month == hoje.month &&
          r.dataHora.day == hoje.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = ModalRoute.of(context)!.settings.arguments as UsuarioModel;
    final nutri = context.watch<NutriProvider>();
    final refeicoes = nutri.refeicoesDeCliente(cliente.uid);
    final plano = nutri.planoDeCliente(cliente.uid);
    final ativo = _ativoHoje(refeicoes);

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Perfil do Cliente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Card do cliente ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF171726),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF22223A)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF4080FF),
                    backgroundImage: cliente.fotoPerfil != null
                        ? FileImage(File(cliente.fotoPerfil!))
                        : null,
                    child: cliente.fotoPerfil == null
                        ? Text(
                            cliente.primeiroNome.isNotEmpty
                                ? cliente.primeiroNome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cliente.email,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: ativo
                                    ? const Color(0xFF2DDDA0)
                                    : const Color(0xFFFFAA2C),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              ativo ? 'Ativo hoje' : 'Sem registro hoje',
                              style: TextStyle(
                                color: ativo
                                    ? const Color(0xFF2DDDA0)
                                    : const Color(0xFFFFAA2C),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Estatísticas ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                  valor: _diasAtivos(refeicoes).toString(),
                  label: 'Dias\nativos',
                ),
                const SizedBox(width: 8),
                _StatCard(
                  valor: refeicoes.length.toString(),
                  label: 'Refeições\ntotal',
                ),
                const SizedBox(width: 8),
                _StatCard(
                  valor: refeicoes.isEmpty
                      ? '–'
                      : '${((refeicoes.length / (_diasAtivos(refeicoes) * 3)) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                  label: 'Adesão\nestimada',
                ),
              ],
            ),
          ),

          // ── Abas ─────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4080FF),
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: const Color(0xFF4080FF),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: const Color(0xFF22223A),
              tabs: const [
                Tab(text: 'Refeições'),
                Tab(text: 'Plano Alimentar'),
              ],
            ),
          ),

          // ── Conteúdo das abas ─────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 1 — grade de refeições
                _AbaRefeicoes(
                  refeicoes: refeicoes,
                  cliente: cliente,
                ),
                // Aba 2 — plano alimentar
                _AbaPlano(
                  plano: plano,
                  onEditarPlano: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.nutriPlanoAlimentar,
                      arguments: cliente,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba Refeições ───────────────────────────────────────────────────────────

class _AbaRefeicoes extends StatelessWidget {
  final List<RefeicaoModel> refeicoes;
  final UsuarioModel cliente;

  const _AbaRefeicoes({required this.refeicoes, required this.cliente});

  @override
  Widget build(BuildContext context) {
    if (refeicoes.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma refeição registrada.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: refeicoes.length,
      itemBuilder: (context, i) {
        final r = refeicoes[i];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.nutriRefeicaoDetalhe,
              arguments: {'refeicao': r, 'cliente': cliente},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171726),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: r.temComentario
                    ? const Color(0xFF4080FF).withOpacity(0.5)
                    : const Color(0xFF22223A),
              ),
              image: r.fotoPath != null && File(r.fotoPath!).existsSync()
                  ? DecorationImage(
                      image: FileImage(File(r.fotoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: r.fotoPath == null || !File(r.fotoPath!).existsSync()
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        r.tipo.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM').format(r.dataHora),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      if (r.temComentario)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4080FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ── Aba Plano Alimentar ─────────────────────────────────────────────────────

class _AbaPlano extends StatelessWidget {
  final dynamic plano;
  final VoidCallback onEditarPlano;

  const _AbaPlano({required this.plano, required this.onEditarPlano});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (plano == null || !plano.temAlgumItem)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF171726),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22223A)),
              ),
              child: Column(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhum plano cadastrado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crie o plano alimentar deste cliente.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            )
          else ...[
            _ItemPlano(emoji: '🍳', label: 'Café da manhã', texto: plano.cafe),
            _ItemPlano(emoji: '🥗', label: 'Almoço', texto: plano.almoco),
            _ItemPlano(emoji: '🍎', label: 'Lanche da tarde', texto: plano.lanche),
            _ItemPlano(emoji: '🌙', label: 'Jantar', texto: plano.jantar),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onEditarPlano,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(
                plano == null || !plano.temAlgumItem
                    ? 'Criar plano alimentar'
                    : 'Editar plano alimentar',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4080FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemPlano extends StatelessWidget {
  final String emoji;
  final String label;
  final String? texto;

  const _ItemPlano({
    required this.emoji,
    required this.label,
    this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final temConteudo = texto != null && texto!.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: temConteudo
              ? const Color(0xFF4080FF).withOpacity(0.4)
              : const Color(0xFF22223A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            temConteudo ? texto! : 'Não definido',
            style: TextStyle(
              color: temConteudo ? Colors.grey.shade300 : Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String valor;
  final String label;

  const _StatCard({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                color: Color(0xFF4080FF),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 9,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
