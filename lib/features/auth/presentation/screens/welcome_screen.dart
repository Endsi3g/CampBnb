import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1504851149312-7a075b496cc7?w=800',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Logo Section
              Column(
                children: [
                  Icon(Icons.outdoor_grill, size: 64, color: AppColors.neutral),
                  const SizedBox(height: 16),
                  Text(
                    'Campbnb Québec',
                    style: AppTextStyles.h1.copyWith(color: AppColors.neutral),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre aventure commence ici.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.neutral.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Button Group
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Inscription',
                      onPressed: () => context.push('/signup'),
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Connexion',
                      onPressed: () => context.push('/login'),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      textColor: Colors.white,
                      borderColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
