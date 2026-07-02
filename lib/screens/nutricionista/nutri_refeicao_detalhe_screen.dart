import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/refeicao_model.dart';
import '../../models/usuario_model.dart';
import '../../providers/nutri_provider.dart';

/// Detalhe de uma refeição do cliente visto pelo nutricionista (Tela 05 admin).
/// Permite visualizar a foto, dados e registrar feedback/comentário.
class NutriRefeicaoDetalheScreen extends StatefulWidget {
  const NutriRefeicaoDetalheScreen({super.key});

  @override
  State<NutriRefeicaoDetalheScreen> createState() =>
      _NutriRefeicaoDetalheScreenState();
}

class _NutriRefeicaoDetalheScreenState
    extends State<NutriRefeicaoDetalheScreen> {
  final _comentarioController = TextEditingController();
  bool _salvando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final refeicao = args['refeicao'] as RefeicaoModel;
    // Pré-popula o campo com comentário existente
    if (refeicao.comentarioNutricionista != null &&
        _comentarioController.text.isEmpty) {
      _comentarioController.text = refeicao.comentarioNutricionista!;
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarFeedback(
    NutriProvider nutri,
    String userId,
    String mealId,
  ) async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Escreva um comentário antes de enviar.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    await nutri.salvarComentario(userId, mealId, texto);
    setState(() => _salvando = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feedback enviado com sucesso! ✅'),
        backgroundColor: const Color(0xFF2DDDA0).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final refeicao = args['refeicao'] as RefeicaoModel;
    final cliente = args['cliente'] as UsuarioModel;
    final nutri = context.read<NutriProvider>();

    final horario = DateFormat('HH:mm').format(refeicao.dataHora);
    final hoje = DateTime.now();
    final ehHoje = refeicao.dataHora.year == hoje.year &&
        refeicao.dataHora.month == hoje.month &&
        refeicao.dataHora.day == hoje.day;
    final dataLabel = ehHoje ? 'Hoje' : DateFormat("d 'de' MMMM", 'pt_BR').format(refeicao.dataHora);

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: Column(
        children: [
          // ── Foto de capa ─────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                // Foto ou placeholder
                Container(
                  width: double.infinity,
                  height: 220,
                  color: const Color(0xFF151D3A),
                  child: refeicao.fotoPath != null &&
                          File(refeicao.fotoPath!).existsSync()
                      ? Image.file(
                          File(refeicao.fotoPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Center(
                          child: Text(
                            refeicao.tipo.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                ),
                // Gradiente inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF07070F).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botão voltar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge de tipo · cliente
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4080FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${refeicao.tipo.label} · ${cliente.primeiroNome}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Corpo ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    refeicao.descricao.isNotEmpty
                        ? refeicao.descricao
                        : refeicao.tipo.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '$horario · $dataLabel',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      if (refeicao.localizacaoNome != null) ...[
                        const SizedBox(width: 8),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.shade600, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            refeicao.localizacaoNome!,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Divider
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade800, height: 1),
                  const SizedBox(height: 20),

                  // ── Comentário do nutricionista ───────────────────────
                  const Text(
                    'COMENTÁRIO PARA O CLIENTE',
                    style: TextStyle(
                      color: Color(0xFF6FA3FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText:
                          'Ex: Ótima escolha! Reduza o molho na próxima vez. 👍',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF171726),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4080FF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4080FF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF4080FF), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _comentarioController.clear(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade400,
                            side: BorderSide(color: Colors.grey.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Limpar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _salvando
                              ? null
                              : () => _enviarFeedback(
                                    nutri,
                                    cliente.uid,
                                    refeicao.id,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4080FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Enviar feedback',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),

                  // ── Ação adicional ────────────────────────────────────
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Refeição salva como referência no plano!',
                          ),
                          backgroundColor: const Color(0xFF2DDDA0).withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171726),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF22223A)),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Salvar como referência no plano',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
