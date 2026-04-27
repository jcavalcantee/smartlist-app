import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8F0BB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_basket_rounded,
                  color: Color(0xFF2E7D32),
                  size: 36,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'SmartList',
                style: textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Suas compras mensais,\norganizadas com inteligência.',
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 4),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Começar'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
