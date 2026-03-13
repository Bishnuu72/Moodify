import'package:flutter/material.dart';
import'package:animate_do/animate_do.dart';
import'../../constants/colors.dart';

class TherapistSessionsScreen extends StatelessWidget {
  const TherapistSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy sessions data
  final List<Map<String, dynamic>> sessions = [
      {
        'patient': 'John Doe',
        'date': 'Today',
        'time': '10:00 AM',
        'type': 'Individual Therapy',
        'status': 'Upcoming',
      },
      {
        'patient': 'Jane Smith',
        'date': 'Today',
        'time': '2:00 PM',
        'type': 'Counseling',
        'status': 'Upcoming',
      },
      {
        'patient': 'Mike Johnson',
        'date': 'Tomorrow',
        'time': '11:00 AM',
        'type': 'Family Therapy',
        'status': 'Scheduled',
      },
      {
        'patient': 'Emily Brown',
        'date': 'Mar 15',
        'time': '3:00 PM',
        'type': 'Group Therapy',
        'status': 'Scheduled',
      },
    ];

    return Scaffold(
     backgroundColor: AppColors.background,
      appBar: AppBar(
       title: const Text(
          'Sessions',
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
           icon: const Icon(Icons.calendar_today),
           onPressed: () {
             // TODO: Show calendar view
            },
          ),
        ],
      ),
    body: Column(
       children: [
        Padding(
         padding: const EdgeInsets.all(20),
          child: Row(
           children: [
             Expanded(
               child: FadeInDown(
                 child: _buildStatCard(
                   'Today',
                   '2',
                   Icons.today,
                   Colors.blue,
                 ),
               ),
             ),
          const SizedBox(width: 16),
             Expanded(
               child: FadeInDown(
              delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(
                   'This Week',
                   '8',
                   Icons.date_range,
                   Colors.green,
                 ),
               ),
             ),
          const SizedBox(width: 16),
             Expanded(
               child: FadeInDown(
              delay: const Duration(milliseconds: 200),
                  child: _buildStatCard(
                   'Pending',
                   '3',
                   Icons.pending_actions,
                   Colors.orange,
                 ),
               ),
             ),
           ],
         ),
        ),
        Expanded(
         child: ListView.builder(
           padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sessions.length,
           itemBuilder: (context, index) {
           final session = sessions[index];
             return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
                child: _buildSessionCard(session),
             );
           },
         ),
        ),
      ],
     ),
     floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        // TODO: Schedule new session
      },
      backgroundColor: Colors.teal,
      icon: const Icon(Icons.add),
      label: const Text('Schedule'),
     ),
   );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
   return Container(
     padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
         BoxShadow(
        color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0,2),
         ),
       ],
     ),
     child: Column(
       children: [
         Icon(icon, color: color, size: 24),
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
     ),
   );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
   Color statusColor;
   switch (session['status']) {
     case 'Upcoming':
      statusColor = Colors.green;
       break;
     case 'Scheduled':
      statusColor = Colors.blue;
       break;
     case 'Completed':
      statusColor = Colors.grey;
       break;
    default:
      statusColor = Colors.orange;
   }

   return Container(
     margin: const EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
         BoxShadow(
        color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0,2),
         ),
       ],
     ),
     child: ListTile(
    contentPadding: const EdgeInsets.all(16),
       leading: Container(
        width: 50,
        height:50,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
       ),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.teal),
         const SizedBox(height: 2),
           Text(
            session['date'],
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
           color: Colors.teal,
            ),
          ),
         ],
       ),
     ),
     title: Text(
       session['patient'],
    style: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
       ),
     ),
     subtitle: Padding(
      padding: const EdgeInsets.only(top: 8),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
         Row(
          children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
         const SizedBox(width: 4),
           Expanded(
             child: Text(
               session['time'],
               style: const TextStyle(
                 fontSize: 14,
                 color: AppColors.textSecondary,
               ),
               overflow: TextOverflow.ellipsis,
             ),
           ),
         const SizedBox(width: 16),
          const Icon(Icons.event_note, size: 14, color: AppColors.textSecondary),
         const SizedBox(width: 4),
           Expanded(
             child: Text(
               session['type'],
               style: const TextStyle(
                 fontSize: 14,
                 color: AppColors.textSecondary,
               ),
               overflow: TextOverflow.ellipsis,
             ),
           ),
          ],
         ),
        ],
       ),
     ),
   trailing: Container(
     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
   decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    ),
     child: Text(
      session['status'],
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
     color: statusColor,
      ),
    ),
   ),
   onTap: () {
     // TODO: Navigate to session details
   },
 ),
);
}
}
