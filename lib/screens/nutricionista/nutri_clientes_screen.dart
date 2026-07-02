import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario_model.dart';
import '../../models/refeicao_model.dart';
import '../../providers/nutri_provider.dart';
import '../../routes.dart';

/// Lista de clientes do nutricionista (Tela 03 do painel admin).
/// Exibe status de atividade, último registro e badge de pendência.
class NutriClientesScreen extends StatefulWidget {
  const NutriClientesScreen({super.key});

  @override
  State<NutriClientesScreen> createState() => _NutriClientesScreenState();
}

class _NutriClientesScreenState extends State<NutriClientesScreen> {
  final _buscaController = TextEditingController();
  String _termoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  bool _ativoHoje(String userId, NutriProvider nutri) {
    final hoje = DateTime.now();
    return nutri.refeicoesDeCliente(userId).any(
      (r) =>
          r.dataHora.year == hoje.year &&
          r.dataHora.month == hoje.month &&
          r.dataHora.day == hoje.day,
    );
  }

  RefeicaoModel? _ultimaRefeicao(String userId, NutriProvider nutri) {
    final lista = nutri.refeicoesDeCliente(userId);
    if (lista.isEmpty) return null;
    return lista.first;
  }

  String _labelUltimaRefeicao(RefeicaoModel? r) {
    if (r == null) return 'Sem registros';
    final hoje = DateTime.now();
    final ehHoje = r.dataHora.year == hoje.year &&
        r.dataHora.month == hoje.month &&
        r.dataHora.day == hoje.day;
    final hora =
        '${r.dataHora.hour.toString().padLeft(2, '0')}h${r.dataHora.minute.toString().padLeft(2, '0')}';
    if (ehHoje) return '${r.tipo.label} · $hora';
    return '${r.tipo.label} · ontem $hora';
  }

  Color _corAvatar(int index) {
    const cores = [
      Color(0xFF4080FF),
      Color(0xFF9B59B6),
      Color(0xFFE74C3C),
      Color(0xFF27AE60),
      Color(0xFFE67E22),
      Color(0xFF1ABC9C),
    ];
    return cores[index % cores.length];
  }

  @override
  Widget build(BuildContext context) {
    final nutri = context.watch<NutriProvider>();

    final clientesFiltrados = nutri.clientes.where((c) {
      if (_termoBusca.isEmpty) return true;
      return c.nome.toLowerCase().contains(_termoBusca.toLowerCase()) ||
          c.email.toLowerCase().contains(_termoBusca.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Meus Clientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // ── Busca ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF171726),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF22223A)),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, color: Colors.grey.shade600, size: 18),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _buscaController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Buscar cliente...',
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _termoBusca = v),
                      ),
                    ),
                    if (_termoBusca.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600, size: 16),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _termoBusca = '');
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Lista ──────────────────────────────────────────────────
            Expanded(
              child: nutri.carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4080FF),
                        strokeWidth: 2,
                      ),
                    )
                  : clientesFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👥', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 16),
                              Text(
                                _termoBusca.isEmpty
                                    ? 'Nenhum cliente cadastrado ainda.'
                                    : 'Nenhum cliente encontrado.',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF4080FF),
                          backgroundColor: const Color(0xFF171726),
                          onRefresh: () async {
                            await nutri.carregarClientes();
                            await nutri.carregarTodasRefeicoes();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: clientesFiltrados.length,
                            itemBuilder: (context, i) {
                              final cliente = clientesFiltrados[i];
                              final ativo = _ativoHoje(cliente.uid, nutri);
                              final ultima = _ultimaRefeicao(cliente.uid, nutri);

                              return _CartaoCliente(
                                cliente: cliente,
                                ativo: ativo,
                                labelUltima: _labelUltimaRefeicao(ultima),
                                corAvatar: _corAvatar(i),
                                onTap: () async {
                                  await nutri.carregarRefeicoesCliente(cliente.uid);
                                  await nutri.carregarPlanoCliente(cliente.uid);
                                  if (context.mounted) {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.nutriClientePerfil,
                                      arguments: cliente,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  final UsuarioModel cliente;
  final bool ativo;
  final String labelUltima;
  final Color corAvatar;
  final VoidCallback onTap;

  const _CartaoCliente({
    required this.cliente,
    required this.ativo,
    required this.labelUltima,
    required this.corAvatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: corAvatar,
              child: Text(
                cliente.primeiroNome.isNotEmpty
                    ? cliente.primeiroNome[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labelUltima,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ativo
                        ? const Color(0xFF2DDDA0).withOpacity(0.15)
                        : const Color(0xFFFFAA2C).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: ativo
                          ? const Color(0xFF2DDDA0)
                          : const Color(0xFFFFAA2C),
                    ),
                  ),
                  child: Text(
                    ativo ? 'ativo' : 'pendente',
                    style: TextStyle(
                      color: ativo
                          ? const Color(0xFF2DDDA0)
                          : const Color(0xFFFFAA2C),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
