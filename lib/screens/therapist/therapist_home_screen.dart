import'package:flutter/material.dart';
import'package:animate_do/animate_do.dart';
import'../../constants/colors.dart';

class TherapistHomeScreen extends StatelessWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: AppColors.background,
      appBar: AppBar(
       title: const Text(
          'Therapist Dashboard',
        style: TextStyle(
           fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
         IconButton(
           icon: const Icon(Icons.notifications_outlined),
           onPressed: () {
             // TODO: Notifications
            },
          ),
        ],
      ),
     body: SingleChildScrollView(
       padding: const EdgeInsets.all(20),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           FadeInDown(
             child: const Text(
               'Good Morning, Dr. Sarah',
               style: TextStyle(
                 fontSize: 28,
                  fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 8),
           FadeInDown(
            delay: const Duration(milliseconds: 200),
              child: const Text(
               'Ready to help your patients today?',
               style: TextStyle(
                 fontSize: 16,
                color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height:30),
           
           // Today's Overview
           FadeInUp(
            delay: const Duration(milliseconds: 400),
             child: const Text(
               'Today\'s Schedule',
               style: TextStyle(
                 fontSize: 20,
                  fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height:16),
           FadeInUp(
            delay: const Duration(milliseconds: 600),
              child: Container(
               padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                     blurRadius: 15,
                     offset: const Offset(0, 5),
                   ),
                 ],
               ),
               child: Column(
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _buildScheduleStat('3', 'Sessions', Icons.calendar_today),
                       _buildScheduleStat('1', 'Pending', Icons.pending),
                       _buildScheduleStat('2', 'Completed', Icons.check_circle),
                     ],
                   ),
                 ],
               ),
             ),
           ),
           
          const SizedBox(height:30),
           
           // Quick Actions
           FadeInUp(
            delay: const Duration(milliseconds: 800),
              child: const Text(
               'Quick Actions',
               style: TextStyle(
                 fontSize: 20,
                  fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height:16),
           FadeInUp(
            delay: const Duration(milliseconds: 900),
              child: GridView.count(
               crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                 _buildQuickActionCard(
                   'Add Patient',
                   Icons.person_add,
                   Colors.blue,
                   () {},
                 ),
                 _buildQuickActionCard(
                   'Schedule Session',
                   Icons.event,
                   Colors.green,
                   () {},
                 ),
                 _buildQuickActionCard(
                   'Patient Notes',
                   Icons.note_add,
                   Colors.orange,
                   () {},
                 ),
                 _buildQuickActionCard(
                   'Reports',
                   Icons.assessment,
                   Colors.purple,
                   () {},
                 ),
               ],
             ),
           ),
         ],
        ),
      ),
    );
  }

  Widget _buildScheduleStat(String value, String label, IconData icon) {
   return Column(
     children: [
       Icon(icon, color: Colors.teal, size: 28),
      const SizedBox(height: 8),
       Text(
         value,
        style: const TextStyle(
           fontSize: 24,
           fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
         ),
       ),
       Text(
         label,
        style: const TextStyle(
           fontSize: 12,
          color: AppColors.textSecondary,
         ),
       ),
     ],
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
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(icon, color: color, size: 28),
           ),
          const SizedBox(height: 12),
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
}
