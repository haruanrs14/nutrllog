import 'package:flutter/material.dart';

/// Card que representa uma refeição na lista da Home e do Histórico.
class MealCard extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String subtitulo;
  final bool registrada;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.subtitulo,
    required this.registrada,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF171726),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22223A)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: registrada
                    ? const Color(0xFF4080FF).withOpacity(0.15)
                    : const Color(0xFF282840),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (registrada)
              const Icon(Icons.check_circle, color: Color(0xFF2DDDA0), size: 22)
            else
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF4080FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
