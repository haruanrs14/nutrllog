import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/refeicao_provider.dart';
import '../routes.dart';

/// Tela de perfil 
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _picker = ImagePicker();
  bool _trocandoFoto = false;

  Future<void> _escolherFoto(ImageSource source) async {
    final foto = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (foto == null) return;
    setState(() => _trocandoFoto = true);
    await context.read<AuthProvider>().atualizarFotoPerfil(foto.path);
    setState(() => _trocandoFoto = false);
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171726),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF4080FF)),
              title: const Text('Tirar foto',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _escolherFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF4080FF)),
              title: const Text('Escolher da galeria',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _escolherFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF171726),
        title: const Text('Sair', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja sair da conta?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final refeicaoProvider = context.watch<RefeicaoProvider>();
    final usuario = authProvider.usuarioAtual;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final totalRefeicoes = refeicaoProvider.refeicoes.length;
    final streak = refeicaoProvider.streak;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Perfil',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // ── Foto de perfil 
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _mostrarOpcoesFoto,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFF4080FF),
                    backgroundImage: usuario?.fotoPerfil != null
                        ? FileImage(File(usuario!.fotoPerfil!))
                        : null,
                    child: _trocandoFoto
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : (usuario?.fotoPerfil == null
                            ? Text(
                                primeiroNome.isNotEmpty
                                    ? primeiroNome[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null),
                  ),
                ),
                GestureDetector(
                  onTap: _mostrarOpcoesFoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4080FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              usuario?.nome ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.email ?? '',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4080FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                usuario?.tipo.name == 'nutricionista'
                    ? 'Nutricionista'
                    : 'Cliente',
                style: const TextStyle(
                  color: Color(0xFF6FA3FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Estatísticas 
            const SizedBox(height: 28),
            Row(
              children: [
                _StatCard(
                  icone: '🍽️',
                  valor: totalRefeicoes.toString(),
                  label: 'Refeições\nregistradas',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icone: '🔥',
                  valor: streak.toString(),
                  label: 'Dias\nconsecutivos',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icone: '📅',
                  valor: refeicaoProvider.refeicoes.isEmpty
                      ? '–'
                      : _diasAtivos(refeicaoProvider.refeicoes).toString(),
                  label: 'Dias\nativos',
                ),
              ],
            ),

            // ── Informações
            const SizedBox(height: 28),
            _InfoTile(
              icone: Icons.person_rounded,
              titulo: 'Nome',
              valor: usuario?.nome ?? '–',
            ),
            _InfoTile(
              icone: Icons.email_rounded,
              titulo: 'E-mail',
              valor: usuario?.email ?? '–',
            ),
            _InfoTile(
              icone: Icons.badge_rounded,
              titulo: 'Tipo de acesso',
              valor: usuario?.tipo.name == 'nutricionista'
                  ? 'Nutricionista'
                  : 'Cliente',
            ),

            // ── Sair 
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 18),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  int _diasAtivos(List refeicoes) {
    final datas = refeicoes
        .map((r) => '${r.dataHora.year}-${r.dataHora.month}-${r.dataHora.day}')
        .toSet();
    return datas.length;
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Column(
          children: [
            Text(icone, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
