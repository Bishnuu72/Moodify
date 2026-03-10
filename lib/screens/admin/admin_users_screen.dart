import'package:flutter/material.dart';
import'../../constants/colors.dart';
import'package:animate_do/animate_do.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
     appBar: AppBar(
        title: const Text('User Management'),
       centerTitle: true,
        elevation: 0,
      ),
     body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                   hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                   ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            
            // User List
            Expanded(
              child: FadeInUp(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount:10,
                  itemBuilder: (context, index) {
                    return _buildUserCard(
                      'User ${index +1}',
                      'user${index + 1}@example.com',
                      'Active',
                     index % 3 == 0 ? 'Admin' : index % 3 == 1 ? 'Therapist' : 'User',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
     floatingActionButton: FloatingActionButton.extended(
       onPressed: () {
         // Add user action
       },
      backgroundColor: Colors.deepPurple,
      icon: const Icon(Icons.person_add),
      label: const Text('Add User'),
     ),
    );
  }
  
  Widget _buildUserCard(String name, String email, String status, String role) {
    Color statusColor;
   switch (status) {
      case 'Active':
       statusColor = Colors.green;
       break;
      case 'Inactive':
       statusColor = Colors.grey;
       break;
     default:
       statusColor = Colors.orange;
    }
    
    Color roleColor;
   switch (role) {
      case 'Admin':
       roleColor = Colors.deepPurple;
       break;
      case 'Therapist':
       roleColor = Colors.teal;
       break;
     default:
       roleColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
      contentPadding: const EdgeInsets.all(16),
       leading: CircleAvatar(
         radius: 24,
        backgroundColor: roleColor.withOpacity(0.1),
         child: Text(
           name[0],
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
           color: roleColor,
           ),
         ),
       ),
       title: Text(
         name,
         style: const TextStyle(
           fontSize: 16,
           fontWeight: FontWeight.w600,
         color: AppColors.textPrimary,
         ),
       ),
       subtitle: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
         const SizedBox(height: 4),
          Text(
           email,
           style: const TextStyle(
             fontSize: 14,
           color: AppColors.textSecondary,
           ),
          ),
         const SizedBox(height: 8),
          Row(
           children: [
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(6),
               ),
               child: Text(
                 role,
                 style: TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.w600,
                 color: roleColor,
                 ),
               ),
             ),
           const SizedBox(width: 8),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(6),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Container(
                     width: 6,
                     height: 6,
                     decoration: BoxDecoration(
                      color: statusColor,
                       shape: BoxShape.circle,
                     ),
                   ),
                 const SizedBox(width: 4),
                   Text(
                     status,
                     style: TextStyle(
                       fontSize: 12,
                       fontWeight: FontWeight.w600,
                     color: statusColor,
                     ),
                   ),
                 ],
               ),
             ),
           ],
          ),
         ],
       ),
       trailing: PopupMenuButton<String>(
        onSelected: (value) {
           // Handle actions
         },
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => const [
           PopupMenuItem(value: 'edit', child: Text('Edit')),
           PopupMenuItem(value: 'suspend', child: Text('Suspend')),
           PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
       ),
      ),
    );
  }
}
