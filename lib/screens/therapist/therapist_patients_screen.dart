import'package:flutter/material.dart';
import'package:animate_do/animate_do.dart';
import'../../constants/colors.dart';

class TherapistPatientsScreen extends StatelessWidget {
  const TherapistPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy patient data
   final List<Map<String, dynamic>> patients = [
      {
        'name': 'John Doe',
        'age': 32,
        'lastSession': '2 days ago',
        'status': 'Active',
        'avatar': 'JD',
      },
      {
        'name': 'Jane Smith',
        'age': 28,
        'lastSession': '1 week ago',
        'status': 'Active',
        'avatar': 'JS',
      },
      {
        'name': 'Mike Johnson',
        'age': 45,
        'lastSession': '3 weeks ago',
        'status': 'Inactive',
        'avatar': 'MJ',
      },
      {
        'name': 'Emily Brown',
        'age': 35,
        'lastSession': 'Yesterday',
        'status': 'Active',
        'avatar': 'EB',
      },
    ];

    return Scaffold(
     backgroundColor: AppColors.background,
      appBar: AppBar(
       title: const Text(
          'My Patients',
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
           icon: const Icon(Icons.search),
           onPressed: () {
             // TODO: Search patients
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
                   'Total',
                   '24',
                   Icons.people,
                   Colors.blue,
                 ),
               ),
             ),
           const SizedBox(width: 16),
             Expanded(
               child: FadeInDown(
               delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(
                   'Active',
                   '18',
                   Icons.check_circle,
                   Colors.green,
                 ),
               ),
             ),
           const SizedBox(width: 16),
             Expanded(
               child: FadeInDown(
               delay: const Duration(milliseconds: 200),
                  child: _buildStatCard(
                   'New',
                   '6',
                   Icons.star,
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
            itemCount: patients.length,
           itemBuilder: (context, index) {
            final patient = patients[index];
             return FadeInUp(
             delay: Duration(milliseconds: 100 * index),
                child: _buildPatientCard(patient),
             );
           },
         ),
        ),
      ],
     ),
     floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        // TODO: Add new patient
      },
      backgroundColor: Colors.teal,
      icon: const Icon(Icons.person_add),
      label: const Text('Add Patient'),
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
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
       leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.teal.withOpacity(0.1),
        child: Text(
          patient['avatar'],
        style: const TextStyle(
           fontSize: 18,
           fontWeight: FontWeight.bold,
         color: Colors.teal,
         ),
       ),
     ),
     title: Text(
       patient['name'],
     style: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
       color: AppColors.textPrimary,
       ),
     ),
     subtitle: Padding(
      padding: const EdgeInsets.only(top: 8),
       child: Row(
        children: [
         Text(
           '${patient['age']} years',
         style: const TextStyle(
             fontSize: 14,
           color: AppColors.textSecondary,
           ),
         ),
        const SizedBox(width: 16),
         Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
         decoration: BoxDecoration(
           color: patient['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
           borderRadius: BorderRadius.circular(12),
          ),
           child: Text(
            patient['status'],
           style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            color: patient['status'] == 'Active' ? Colors.green : Colors.grey,
            ),
          ),
         ),
        ],
       ),
     ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
       children: [
       const Text(
         'Last session',
        style: TextStyle(
           fontSize: 12,
         color: AppColors.textSecondary,
         ),
       ),
       const SizedBox(height: 4),
         Text(
          patient['lastSession'],
         style: const TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.w600,
           color: AppColors.textPrimary,
           ),
         ),
       ],
     ),
     onTap: () {
       // TODO: Navigate to patient details
     },
   ),
 );
}
}
