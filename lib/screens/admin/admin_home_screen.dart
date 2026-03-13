import'package:flutter/material.dart';
import'../../constants/colors.dart';
import'package:animate_do/animate_do.dart';
import'admin_verification_review_screen.dart';
import'../../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> _pendingVerifications = [];
  bool _isLoadingVerifications = false;
  
  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }
  
  Future<void> _loadPendingVerifications() async {
    setState(() {
      _isLoadingVerifications = true;
    });
    
    try {
      print('📡 Fetching pending verifications from API...');
      final response = await ApiService.getPendingVerifications();
      
      print('📊 Response status: ${response['success']}');
      print('📦 Count: ${response['count']}');
      print('📄 Data: ${response['data']}');
      
      if (response['success']) {
        setState(() {
          _pendingVerifications = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoadingVerifications = false;
          print('✅ Loaded ${_pendingVerifications.length} pending verifications');
          for (var i = 0; i < _pendingVerifications.length; i++) {
            final therapist = _pendingVerifications[i];
            print('👤 Therapist #$i: ${therapist['displayName']} | ${therapist['specialization']} | Photo: ${therapist['photoUrl']}');
          }
        });
      } else {
        print('❌ Failed to load verifications: ${response['message']}');
        setState(() => _isLoadingVerifications = false);
      }
    } catch (e) {
      print('❌ Error loading pending verifications: $e');
      setState(() => _isLoadingVerifications = false);
    }
  }

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
              
              // Verification Requests Section
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Verification Requests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (!_isLoadingVerifications)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_pendingVerifications.length} Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoadingVerifications
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _pendingVerifications.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'No pending verification requests',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _pendingVerifications.length,
                                  itemBuilder: (context, index) {
                                    final therapist = _pendingVerifications[index];
                                    print('📋 Pending therapist #$index: ${therapist['displayName']}');
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index < _pendingVerifications.length - 1 ? 12 : 0,
                                      ),
                                      child: _buildPendingVerification(
                                        therapist['displayName'] ?? 'Unknown Therapist',
                                        therapist['specialization'] ?? 'Therapist',
                                        'Submitted recently',
                                        therapist['photoUrl'] ?? '',
                                        () {
                                          print('👆 Clicked on: ${therapist['displayName']}');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminVerificationReviewScreen(
                                                therapist: therapist,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
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
          mainAxisSize: MainAxisSize.min,
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
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
           const SizedBox(height:8),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                 color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
           const SizedBox(height:2),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                 color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  
  Widget _buildPendingVerification(
    String name,
    String specialization,
    String timeAgo,
    String photoUrl,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: photoUrl.startsWith('http')
                  ? NetworkImage(photoUrl)
                  : null,
              child: !photoUrl.startsWith('http')
                  ? Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specialization,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
