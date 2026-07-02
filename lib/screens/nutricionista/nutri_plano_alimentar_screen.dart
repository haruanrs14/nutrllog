import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario_model.dart';
import '../../models/plano_alimentar_model.dart';
import '../../providers/nutri_provider.dart';

/// Editor de plano alimentar do nutricionista (Tela 06 do painel admin).
/// Permite definir recomendações por tipo de refeição para cada cliente.
class NutriPlanoAlimentarScreen extends StatefulWidget {
  const NutriPlanoAlimentarScreen({super.key});

  @override
  State<NutriPlanoAlimentarScreen> createState() =>
      _NutriPlanoAlimentarScreenState();
}

class _NutriPlanoAlimentarScreenState
    extends State<NutriPlanoAlimentarScreen> {
  final _cafeController = TextEditingController();
  final _almocoController = TextEditingController();
  final _lancheController = TextEditingController();
  final _jantarController = TextEditingController();
  bool _salvando = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;

    final cliente =
        ModalRoute.of(context)!.settings.arguments as UsuarioModel;
    final nutri = context.read<NutriProvider>();
    final plano = nutri.planoDeCliente(cliente.uid);

    if (plano != null) {
      _cafeController.text = plano.cafe ?? '';
      _almocoController.text = plano.almoco ?? '';
      _lancheController.text = plano.lanche ?? '';
      _jantarController.text = plano.jantar ?? '';
    }
  }

  @override
  void dispose() {
    _cafeController.dispose();
    _almocoController.dispose();
    _lancheController.dispose();
    _jantarController.dispose();
    super.dispose();
  }

  Future<void> _salvarPlano(UsuarioModel cliente) async {
    setState(() => _salvando = true);

    final nutri = context.read<NutriProvider>();
    final plano = PlanoAlimentarModel(
      userId: cliente.uid,
      cafe: _cafeController.text.trim().isEmpty
          ? null
          : _cafeController.text.trim(),
      almoco: _almocoController.text.trim().isEmpty
          ? null
          : _almocoController.text.trim(),
      lanche: _lancheController.text.trim().isEmpty
          ? null
          : _lancheController.text.trim(),
      jantar: _jantarController.text.trim().isEmpty
          ? null
          : _jantarController.text.trim(),
      atualizadoEm: DateTime.now(),
    );

    await nutri.salvarPlano(plano);
    setState(() => _salvando = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plano de ${cliente.primeiroNome} salvo! ✅'),
        backgroundColor: const Color(0xFF2DDDA0).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cliente =
        ModalRoute.of(context)!.settings.arguments as UsuarioModel;

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Plano — ${cliente.primeiroNome}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Defina as recomendações para cada refeição do dia de ${cliente.primeiroNome}.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _BlocoRefeicao(
              emoji: '🍳',
              label: 'Café da manhã',
              controller: _cafeController,
              placeholder: 'Ex: Aveia com frutas e 2 ovos mexidos. Sem açúcar.',
            ),
            _BlocoRefeicao(
              emoji: '🥗',
              label: 'Almoço',
              controller: _almocoController,
              placeholder:
                  'Ex: Arroz integral, feijão, frango grelhado e salada verde.',
            ),
            _BlocoRefeicao(
              emoji: '🍎',
              label: 'Lanche da tarde',
              controller: _lancheController,
              placeholder: 'Ex: 1 fruta + iogurte natural sem açúcar.',
            ),
            _BlocoRefeicao(
              emoji: '🌙',
              label: 'Jantar',
              controller: _jantarController,
              placeholder: 'Ex: Sopa de legumes com frango desfiado.',
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvando ? null : () => _salvarPlano(cliente),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4080FF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF4080FF).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _salvando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Salvar plano alimentar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BlocoRefeicao extends StatelessWidget {
  final String emoji;
  final String label;
  final TextEditingController controller;
  final String placeholder;

  const _BlocoRefeicao({
    required this.emoji,
    required this.label,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22223A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                height: 1.5,
              ),
              filled: true,
              fillColor: const Color(0xFF07070F),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF22223A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF22223A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF4080FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
