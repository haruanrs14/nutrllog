import 'package:flutter/material.dart';
import '../utils/validadores.dart';

/// Widget que exibe os requisitos da senha em tempo real,
/// colorindo cada item de verde quando atendido.
class SenhaRequisitos extends StatelessWidget {
  final String senha;

  const SenhaRequisitos({super.key, required this.senha});

  @override
  Widget build(BuildContext context) {
    final requisitos = Validadores.requisitos(senha);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF171726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF22223A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REQUISITOS DA SENHA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ...requisitos.map((r) => _RequisitoItem(requisito: r)),
        ],
      ),
    );
  }
}

class _RequisitoItem extends StatelessWidget {
  final RequisitoSenha requisito;

  const _RequisitoItem({required this.requisito});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            requisito.atendido ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: requisito.atendido
                ? const Color(0xFF2DDDA0)
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            requisito.descricao,
            style: TextStyle(
              fontSize: 12,
              color: requisito.atendido
                  ? const Color(0xFF2DDDA0)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
