import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
 title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
 onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: user.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user.fullName[0].toUpperCase(),
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Menu Items
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
 title: 'Mon profil',
 onTap: () => context.push('/profile/edit'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.book_online,
 title: 'Mes réservations',
 onTap: () => context.push('/reservations'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite,
 title: 'Favoris',
 onTap: () => context.push('/favorites'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
 title: 'Devenir hôte',
 onTap: () => context.push('/host/dashboard'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
 title: 'Aide et support',
 onTap: () => context.push('/help'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
 title: 'Paramètres',
 onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 32),
                  // Logout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
 context.go('/welcome');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
 child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

