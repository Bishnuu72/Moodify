import'package:flutter/material.dart';
import'../../constants/colors.dart';
import'package:animate_do/animate_do.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
     body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                           color: AppColors.textPrimary,
                          ),
                        ),
                       const SizedBox(height: 5),
                        Text(
                          'Manage your platform',
                          style: TextStyle(
                            fontSize: 16,
                           color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                       color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                       color: Colors.deepPurple,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
             const SizedBox(height:30),
              
              // Statistics Cards
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      '1,234',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Therapists',
                      '89',
                      Icons.medical_services,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Admins',
                      '12',
                      Icons.security,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Reports',
                      '5',
                      Icons.report_problem,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              
             const SizedBox(height:30),
              
              // Quick Actions
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                   color: AppColors.textPrimary,
                  ),
                ),
              ),
              
             const SizedBox(height:15),
              
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildQuickActionCard(
                  'User Management',
                  Icons.manage_accounts,
                  Colors.blue,
                  () {
                    // Navigate to user management
                  },
                ),
              ),
              
             const SizedBox(height:15),
              
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActionCard(
                  'System Settings',
                  Icons.settings,
                  Colors.grey,
                  () {
                    // Navigate to settings
                  },
                ),
              ),
              
             const SizedBox(height:15),
              
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildQuickActionCard(
                  'View Reports',
                  Icons.file_present,
                  Colors.orange,
                  () {
                    // View reports
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                   color: color.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
           const SizedBox(height:12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               color: AppColors.textPrimary,
              ),
            ),
           const SizedBox(height:4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
               color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
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
