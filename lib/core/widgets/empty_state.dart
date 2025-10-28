// lib/core/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone animado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, delay: 1000.ms)
                .shake(hz: 2, curve: Curves.easeInOutCubic, duration: 1000.ms),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 12),
            
            // Mensagem
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.search),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),
            ],
          ],
        ),
      ),
    );
  }
}
