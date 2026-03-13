import'package:flutter/material.dart';
import'../../constants/colors.dart';
import'package:animate_do/animate_do.dart';
import'admin_wellness_screen.dart';

class AdminToolsScreen extends StatelessWidget {
  const AdminToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
     appBar: AppBar(
        title: const Text('Admin Tools'),
       centerTitle: true,
        elevation: 0,
      ),
    body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'System Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  ),
                ),
              ),
              
            const SizedBox(height:10),
              
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Manage wellness tools, games, and system settings',
                  style: TextStyle(
                    fontSize: 16,
                  color: AppColors.textSecondary,
                  ),
                ),
              ),
              
            const SizedBox(height:30),
              
              // System Tools Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildToolCard(
                    'Wellness Tools',
                    Icons.self_improvement_outlined,
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminWellnessScreen()),
                      );
                    },
                  ),
                  _buildToolCard(
                    'Mind Games',
                    Icons.games_outlined,
                    Colors.purple,
                    () {
                      // Navigate to mind games management
                    },
                  ),
                  _buildToolCard(
                    'Music Therapy',
                    Icons.music_note_outlined,
                    Colors.blue,
                    () {
                      // Navigate to music therapy management
                    },
                  ),
                  _buildToolCard(
                    'Analytics',
                    Icons.analytics_outlined,
                    Colors.orange,
                    () {
                      // Navigate to analytics
                    },
                  ),
                  _buildToolCard(
                    'Notifications',
                    Icons.notifications_outlined,
                    Colors.red,
                    () {
                      // Navigate to notifications
                    },
                  ),
                  _buildToolCard(
                    'Backup & Restore',
                    Icons.backup_table_outlined,
                    Colors.green,
                    () {
                      // Navigate to backup & restore
                    },
                  ),
                ],
              ),
              
            const SizedBox(height:30),
              
              // Advanced Settings
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Advanced Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  ),
                ),
              ),
              
            const SizedBox(height:15),
              
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildSettingCard(
                  'Database Configuration',
                  Icons.storage,
                  Colors.teal,
                  () {},
                ),
              ),
              
            const SizedBox(height:12),
              
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildSettingCard(
                  'Email Templates',
                  Icons.email_outlined,
                  Colors.indigo,
                  () {},
                ),
              ),
              
            const SizedBox(height:12),
              
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _buildSettingCard(
                  'Security Settings',
                  Icons.security,
                  Colors.red,
                  () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildToolCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: color.withOpacity(0.1),
               shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
          const SizedBox(height:12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  ),
                ),
              ),
            const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
