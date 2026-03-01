import 'package:flutter/material.dart';
import '../models/breathing_mode.dart';
import '../theme/app_colors.dart';
import 'breathing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color comes from the global theme (AppColors.background)
      appBar: AppBar(
        title: const Text('CalmCircle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a Breathing Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a pattern to begin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),

            // Box Breathing button
            _buildModeButton(
              context,
              label: 'Box Breathing',
              subtitle: '4 – 4 – 4 – 4',
              mode: boxBreathing,
            ),
            const SizedBox(height: 16),

            // 4-7-8 Breathing button
            _buildModeButton(
              context,
              label: '4-7-8 Breathing',
              subtitle: '4 – 7 – 8',
              mode: relaxing478,
            ),
            const SizedBox(height: 16),

            // Resonant Breathing button
            _buildModeButton(
              context,
              label: 'Resonant Breathing',
              subtitle: '4 - 4',
              mode: resonantBreathing,
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable button builder — avoids repeating the same styling code.
  /// In React, this is like extracting a small helper component or render function.
  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required BreathingMode mode,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BreathingScreen(mode: mode),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
