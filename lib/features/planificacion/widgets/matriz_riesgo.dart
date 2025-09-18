import 'package:flutter/material.dart';

class MatrizRiesgo extends StatelessWidget {
  const MatrizRiesgo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFD4D4D4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matriz 5×5 (Referencia)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riesgo = Frecuencia × Severidad',
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
              children: const [
                TextSpan(text: 'Si el producto es mayor a 6: '),
                TextSpan(
                  text: 'Aceptable',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
              children: const [
                TextSpan(text: 'Si es 6 o menor: '),
                TextSpan(
                  text: 'No Aceptable',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}