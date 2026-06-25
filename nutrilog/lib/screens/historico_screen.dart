import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/refeicao_model.dart';
import '../providers/auth_provider.dart';
import '../providers/refeicao_provider.dart';
import '../routes.dart';

/// Tela de histórico 
class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refeicaoProvider = context.watch<RefeicaoProvider>();
    final refeicoes = refeicaoProvider.refeicoes;

    // Agrupar por data
    final Map<String, List<RefeicaoModel>> porDia = {};
    for (final r in refeicoes) {
      final chave = DateFormat('yyyy-MM-dd').format(r.dataHora);
      porDia.putIfAbsent(chave, () => []).add(r);
    }
    final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Histórico',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: refeicoes.isEmpty
          ? _EstadoVazio()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: dias.length,
              itemBuilder: (context, i) {
                final diaStr = dias[i];
                final dia = DateTime.parse(diaStr);
                final itens = porDia[diaStr]!;
                return _GrupoDia(dia: dia, refeicoes: itens);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4080FF),
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.registrar),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _GrupoDia extends StatelessWidget {
  final DateTime dia;
  final List<RefeicaoModel> refeicoes;

  const _GrupoDia({required this.dia, required this.refeicoes});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final ehHoje = dia.year == hoje.year &&
        dia.month == hoje.month &&
        dia.day == hoje.day;
    final ehOntem = dia.year == hoje.year &&
        dia.month == hoje.month &&
        dia.day == hoje.day - 1;

    String labelDia;
    if (ehHoje) {
      labelDia = 'Hoje';
    } else if (ehOntem) {
      labelDia = 'Ontem';
    } else {
      labelDia = DateFormat("d 'de' MMMM", 'pt_BR').format(dia);
      labelDia =
          labelDia.substring(0, 1).toUpperCase() + labelDia.substring(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              Text(
                labelDia,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF171726),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${refeicoes.length} ${refeicoes.length == 1 ? 'refeição' : 'refeições'}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        ...refeicoes.map((r) => _CartaoHistorico(refeicao: r)),
      ],
    );
  }
}

class _CartaoHistorico extends StatelessWidget {
  final RefeicaoModel refeicao;

  const _CartaoHistorico({required this.refeicao});

  @override
  Widget build(BuildContext context) {
    final horario = DateFormat('HH:mm').format(refeicao.dataHora);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF22223A)),
      ),
      child: Row(
        children: [
          // Miniatura da foto
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: refeicao.fotoPath != null
                ? Image.file(
                    File(refeicao.fotoPath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _EmojiBox(refeicao.tipo.emoji),
                  )
                : _EmojiBox(refeicao.tipo.emoji),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        refeicao.tipo.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      horario,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                if (refeicao.descricao.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    refeicao.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
                if (refeicao.localizacaoNome != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.grey.shade600),
                      const SizedBox(width: 3),
                      Text(
                        refeicao.localizacaoNome!,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiBox extends StatelessWidget {
  final String emoji;
  const _EmojiBox(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFF282840),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma refeição registrada',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para registrar\nsua primeira refeição!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
