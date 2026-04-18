import 'package:flutter/material.dart';
import '../../core/currency_provider.dart';

class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final isUsd = CurrencyProvider().isUsd;
        
        return GestureDetector(
          onTap: () => CurrencyProvider().toggle(),
          child: Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(
              children: [
                // Sliding indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: isUsd ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 40,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4472B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE4472B).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Labels
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'THB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUsd ? Color(0xFF999999) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'USD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUsd ? Colors.white : Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
