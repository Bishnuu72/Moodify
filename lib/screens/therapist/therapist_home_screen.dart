import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'therapist_patients_screen.dart';
import 'therapist_sessions_screen.dart';
import 'therapist_messages_screen.dart';
import 'patient_notes_screen.dart';

class TherapistHomeScreen extends StatefulWidget {
  const TherapistHomeScreen({super.key});

  @override
  State<TherapistHomeScreen> createState() => _TherapistHomeScreenState();
}

class _TherapistHomeScreenState extends State<TherapistHomeScreen> {
  String _therapistName = '';
  bool _isLoading = true;
  
  // Today's schedule statistics
  int _todaySessions = 0;
  int _pendingSessions = 0;
  int _completedSessions = 0;
  
  @override
  void initState() {
    super.initState();
    _loadTherapistName();
    _loadTodaySchedule();
  }
  
  Future<void> _loadTodaySchedule() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) return;

      final response = await ApiService.getTherapistSchedules(currentUser.uid);

      if (response['success']) {
        final allSchedules = List<Map<String, dynamic>>.from(response['data']);
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        int todayCount = 0;
        int pendingCount = 0;
        int completedCount = 0;

        for (var schedule in allSchedules) {
          final scheduledDate = DateTime.parse(schedule['scheduledDate']);
          final status = schedule['status'];

          // Count today's appointments
          if (scheduledDate.year == today.year &&
              scheduledDate.month == today.month &&
              scheduledDate.day == today.day) {
            todayCount++;
            
            // Count by status
            if (status == 'completed') {
              completedCount++;
            } else if (status == 'scheduled' || status == 'confirmed') {
              pendingCount++;
            }
          }
        }

        setState(() {
          _todaySessions = todayCount;
          _pendingSessions = pendingCount;
          _completedSessions = completedCount;
        });
      }
    } catch (e) {
      print('Error loading today schedule: $e');
    }
  }
  
  Future<void> _loadTherapistName() async {
    try {
      // Use Provider to get the shared AuthService instance
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      print('🔍 [DEBUG] Current user UID: ${currentUser?.uid ?? "NULL"}');
      
      if (currentUser != null) {
        print('📊 Fetching therapist name for user: ${currentUser.uid}');
        final response = await ApiService.getUserProfile(currentUser.uid);
        
        print('📡 API Response Success: ${response['success']}');
        print('📡 API Response Data: ${response['data']}');
        
        if (response['success'] && response['data'] != null) {
          final userData = response['data'];
          
          // Get displayName from MongoDB - it should have the full name
          String therapistDisplayName = '';
          
          // Try to get displayName field first
          if (userData.containsKey('displayName')) {
            therapistDisplayName = userData['displayName'].toString();
            print('✅ Got displayName from DB: "$therapistDisplayName"');
          }
          
          // If displayName is empty, fall back to email
          if (therapistDisplayName.isEmpty || therapistDisplayName.trim().isEmpty) {
            final email = userData['email'] ?? '';
            if (email.isNotEmpty) {
              // Use the part before @ as name
              therapistDisplayName = email.split('@').first;
              print('⚠️ displayName was empty, using email prefix: "$therapistDisplayName"');
            } else {
              therapistDisplayName = 'Therapist';
              print('❌ No displayName or email, using fallback: "Therapist"');
            }
          }
          
          // Now extract just the first name or "Title + First Name"
          setState(() {
            final nameParts = therapistDisplayName.split(' ');
            print('📝 Name parts after split: $nameParts');
            
            // Check if first part is a title (Dr., Prof., etc.)
            if (nameParts.length >= 2 && 
                (nameParts[0].toLowerCase().endsWith('.') || 
                 nameParts[0].toLowerCase() == 'dr')) {
              // Has title - use "Title Firstname"
              _therapistName = '${nameParts[0]} ${nameParts[1]}';
              print('✅ Using title + first name: "$_therapistName"');
            } else if (nameParts.isNotEmpty) {
              // No title - just use first name
              _therapistName = nameParts.first;
              print('✅ Using first name: "$_therapistName"');
            } else {
              _therapistName = therapistDisplayName;
              print('⚠️ Using full display name: "$_therapistName"');
            }
            
            _isLoading = false;
            print('🎉 FINAL RESULT - Greeting will show: "${_getGreeting()}, $_therapistName"');
          });
        } else {
          print('❌ API returned success: ${response['success']}');
          print('❌ API Error Message: ${response['message'] ?? "Unknown error"}');
          setState(() {
            _therapistName = 'Therapist';
            _isLoading = false;
          });
        }
      } else {
        print('❌ No current user found - therapist is not logged in');
        setState(() {
          _therapistName = 'Therapist';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Critical error loading therapist name: $e');
      print('❌ Stack trace: $stackTrace');
      setState(() {
        _therapistName = 'Therapist';
        _isLoading = false;
      });
    }
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: AppColors.background,
      appBar: AppBar(
       title: _isLoading
           ? const Text(
              'Therapist Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
             )
           : Text(
              '$_therapistName\'s Dashboard',
              style: const TextStyle(
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
             child: _isLoading
                 ? Container(
                     width: 200,
                     height: 32,
                     color: Colors.grey.shade300,
                   )
                 : Text(
                   _getGreeting(),
                   style: const TextStyle(
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
                       _buildScheduleStat(_todaySessions.toString(), 'Sessions', Icons.calendar_today),
                       _buildScheduleStat(_pendingSessions.toString(), 'Pending', Icons.pending),
                       _buildScheduleStat(_completedSessions.toString(), 'Completed', Icons.check_circle),
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
                    'Patients',
                    Icons.people,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TherapistPatientsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Sessions',
                    Icons.event,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TherapistSessionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Messages',
                    Icons.message,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TherapistMessagesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Patient Notes',
                    Icons.note_add,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientNotesScreen(),
                        ),
                      );
                    },
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
