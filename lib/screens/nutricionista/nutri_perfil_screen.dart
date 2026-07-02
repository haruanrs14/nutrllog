import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutri_provider.dart';
import '../../routes.dart';

/// Perfil do nutricionista (Tela 08 do painel admin).
/// Mostra dados da conta, resumo geral e opção de logout.
class NutriPerfilScreen extends StatelessWidget {
  const NutriPerfilScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF171726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sair do painel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Tem certeza que deseja sair da conta do nutricionista?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nutri = context.watch<NutriProvider>();
    final usuario = auth.usuarioAtual;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Avatar ────────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF4080FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4080FF).withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🩺', style: TextStyle(fontSize: 38)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nutricionista',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usuario?.email ?? 'nutricionista@gmail.com',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4080FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4080FF).withOpacity(0.4),
                  ),
                ),
                child: const Text(
                  '🩺  Acesso Profissional · Admin',
                  style: TextStyle(
                    color: Color(0xFF6FA3FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ── Métricas gerais ───────────────────────────────────────
              const SizedBox(height: 28),
              Row(
                children: [
                  _StatCard(
                    icone: '👥',
                    valor: nutri.clientes.length.toString(),
                    label: 'Clientes\nativoss',
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icone: '🍽️',
                    valor: nutri.totalRefeicoesHoje.toString(),
                    label: 'Refeições\nhoje',
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icone: '⏳',
                    valor: nutri.totalPendentes.toString(),
                    label: 'Pendentes\nhoje',
                  ),
                ],
              ),

              // ── Informações ───────────────────────────────────────────
              const SizedBox(height: 28),
              _InfoTile(
                icone: Icons.badge_rounded,
                titulo: 'Perfil',
                valor: 'Nutricionista (Admin)',
              ),
              _InfoTile(
                icone: Icons.email_rounded,
                titulo: 'E-mail de acesso',
                valor: usuario?.email ?? 'nutricionista@gmail.com',
              ),
              _InfoTile(
                icone: Icons.lock_rounded,
                titulo: 'Tipo de autenticação',
                valor: 'Conta fixa — local',
              ),

              // ── Sobre ─────────────────────────────────────────────────
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'NutriLog',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                      'Aplicativo de acompanhamento alimentar.\n'
                      'Desenvolvido para IFSC Tubarão — ADS\n'
                      'Disciplina: Desenvolvimento para Dispositivos Móveis\n\n'
                      'Integrantes: Haruan Rechia · Gabriel Campos · Raul Nandi',
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171726),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22223A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4080FF),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Sobre o NutriLog',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Logout ────────────────────────────────────────────────
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Sair do painel',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icone;
  final String valor;
  final String label;

  const _StatCard({
    required this.icone,
    required this.valor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Column(
          children: [
            Text(icone, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
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

class _InfoTile extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _InfoTile({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22223A)),
      ),
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFF4080FF), size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style:
                    const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
