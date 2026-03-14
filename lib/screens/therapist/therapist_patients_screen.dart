import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'patient_detail_screen.dart';
import 'schedule_appointment_screen.dart';

class TherapistPatientsScreen extends StatefulWidget {
  const TherapistPatientsScreen({super.key});

  @override
  State<TherapistPatientsScreen> createState() => _TherapistPatientsScreenState();
}

class _TherapistPatientsScreenState extends State<TherapistPatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        setState(() {
          _error = 'Please login as therapist to view patients';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getTherapistPatients(currentUser.uid);

      if (response['success']) {
        setState(() {
          _patients = List<Map<String, dynamic>>.from(response['data']);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load patients');
      }
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _error = e.toString().contains('No patients found') 
            ? 'No patients yet. Declare users as patients from the Messages tab.'
            : 'Failed to load patients';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorState()
              : _patients.isEmpty
                  ? _buildEmptyState()
                  : _buildPatientList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPatients,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Go to Messages and declare users as your patients',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    final activeCount = _patients.where((p) => p['status'] == 'active').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: FadeInDown(
                  child: _buildStatCard(
                    'Total',
                    _patients.length.toString(),
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
                    activeCount.toString(),
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
                    _patients.take(3).length.toString(),
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
            itemCount: _patients.length,
            itemBuilder: (context, index) {
              final patient = _patients[index];
              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: _buildPatientCard(patient),
              );
            },
          ),
        ),
      ],
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
    final displayName = patient['displayName'] ?? 'Unknown';
    final photoUrl = patient['photoUrl'] as String?;
    final email = patient['email'] ?? '';
    final status = patient['status'] ?? 'active';
    final declaredAt = patient['declaredAt'] != null 
        ? DateTime.parse(patient['declaredAt'])
        : DateTime.now();
    
    // Calculate days since declared
    final daysSinceDeclared = DateTime.now().difference(declaredAt).inDays;
    final lastSessionText = daysSinceDeclared == 0 
        ? 'Today'
        : daysSinceDeclared == 1
            ? 'Yesterday'
            : '$daysSinceDeclared days ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null,
          child: photoUrl == null || photoUrl.isEmpty
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          displayName,
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
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == 'active' ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Declared $lastSessionText',
                      style: const TextStyle(
                        fontSize: 12,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleAppointmentScreen(
                      patientId: patient['userId'],
                      patientName: patient['displayName'] ?? 'Unknown',
                      patientEmail: patient['email'] ?? '',
                      patientPhotoUrl: patient['photoUrl'],
                    ),
                  ),
                );
                
                // Refresh list if appointment was scheduled
                if (result == true && mounted) {
                  _loadPatients();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                userId: patient['userId'],
                displayName: patient['displayName'] ?? 'Unknown',
                photoUrl: patient['photoUrl'],
                email: patient['email'],
              ),
            ),
          );
        },
      ),
    );
  }
}
