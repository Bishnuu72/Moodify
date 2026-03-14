import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'patient_detail_screen.dart';

class TherapistSessionsScreen extends StatefulWidget {
  const TherapistSessionsScreen({super.key});

  @override
  State<TherapistSessionsScreen> createState() => _TherapistSessionsScreenState();
}

class _TherapistSessionsScreenState extends State<TherapistSessionsScreen> {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = false;
  String _error = '';
  
  // Statistics
  int _todayCount = 0;
  int _weekCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        setState(() {
          _error = 'Please login to view schedules';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getTherapistSchedules(currentUser.uid);

      if (response['success']) {
        final allSchedules = List<Map<String, dynamic>>.from(response['data']);
        
        // Sort by scheduledDate (earliest/soonest first) and then by scheduledTime (earliest first)
        // This shows upcoming sessions at the top
        allSchedules.sort((a, b) {
          final dateA = DateTime.parse(a['scheduledDate']);
          final dateB = DateTime.parse(b['scheduledDate']);
          
          // Compare dates first
          int dateComparison = dateA.compareTo(dateB); // Ascending (earliest first)
          
          // If dates are the same, compare times
          if (dateComparison == 0) {
            final timeA = a['scheduledTime'] ?? '00:00';
            final timeB = b['scheduledTime'] ?? '00:00';
            return timeA.compareTo(timeB); // Ascending (earliest time first)
          }
          
          return dateComparison;
        });
        
        // Calculate statistics
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final weekFromNow = today.add(const Duration(days: 7));

        _todayCount = 0;
        _weekCount = 0;
        _pendingCount = 0;

        for (var schedule in allSchedules) {
          final scheduledDate = DateTime.parse(schedule['scheduledDate']);
          final status = schedule['status'];

          // Count today's appointments
          if (scheduledDate.year == today.year &&
              scheduledDate.month == today.month &&
              scheduledDate.day == today.day) {
            _todayCount++;
          }

          // Count this week's appointments
          if (scheduledDate.isBefore(weekFromNow) && scheduledDate.isAfter(today.subtract(const Duration(days: 1)))) {
            _weekCount++;
          }

          // Count pending (scheduled or confirmed)
          if (status == 'scheduled' || status == 'confirmed') {
            _pendingCount++;
          }
        }

        setState(() {
          _schedules = allSchedules;
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load schedules');
      }
    } catch (e) {
      print('Error loading schedules: $e');
      setState(() {
        _error = e.toString().contains('No schedules found') 
            ? 'No scheduled appointments yet'
            : 'Failed to load schedules';
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorState()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: FadeInDown(
                              child: _buildStatCard(
                                'Today',
                                _todayCount.toString(),
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
                                _weekCount.toString(),
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
                                _pendingCount.toString(),
                                Icons.pending_actions,
                                Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _schedules.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _schedules.length,
                              itemBuilder: (context, index) {
                                final schedule = _schedules[index];
                                return FadeInUp(
                                  delay: Duration(milliseconds: 100 * index),
                                  child: _buildScheduleCard(schedule),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
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
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No scheduled appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Schedule appointments with your patients from the Patients tab',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
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
            offset: const Offset(0, 2),
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

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final patientName = schedule['patientName'] ?? 'Unknown';
    final scheduledDate = DateTime.parse(schedule['scheduledDate']);
    final scheduledTime = schedule['scheduledTime'] ?? '';
    final appointmentType = schedule['appointmentType'] ?? 'video_call';
    final status = schedule['status'] ?? 'scheduled';
    final photoUrl = schedule['patientPhotoUrl'] as String?;
    final scheduleId = schedule['_id'] ?? schedule['id'];
    
    // Format date and time
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(scheduledDate);
    final formattedTime = scheduledTime.isNotEmpty 
        ? TimeOfDay(hour: int.parse(scheduledTime.split(':')[0]), minute: int.parse(scheduledTime.split(':')[1])).format(context)
        : '';

    // Determine status color and icon
    Color statusColor;
    String statusText;
    IconData typeIcon;
    
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Scheduled';
    }

    if (appointmentType == 'video_call') {
      typeIcon = Icons.videocam;
    } else {
      typeIcon = Icons.phone;
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to patient details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailScreen(
                  userId: schedule['patientId'],
                  displayName: patientName,
                  photoUrl: photoUrl,
                  email: schedule['patientEmail'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(typeIcon, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            appointmentType == 'video_call' ? 'Video Call' : 'Voice Call',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showOptionsMenu(context, schedule),
                      tooltip: 'Options',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Map<String, dynamic> schedule) {
    final status = schedule['status'] ?? 'scheduled';
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // Join Meeting (only for active appointments)
            if (!isCompleted && !isCancelled)
              ListTile(
                leading: const Icon(Icons.video_call, color: AppColors.primary),
                title: const Text('Join Meeting'),
                onTap: () {
                  Navigator.pop(context);
                  _joinMeeting(schedule);
                },
              ),
            // Edit Appointment
            if (!isCompleted && !isCancelled)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Edit Appointment'),
                onTap: () {
                  Navigator.pop(context);
                  _editAppointment(schedule);
                },
              ),
            // Delete Appointment
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Appointment'),
              onTap: () {
                Navigator.pop(context);
                _deleteAppointment(schedule);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _joinMeeting(Map<String, dynamic> schedule) {
    final patientName = schedule['patientName'] ?? 'Patient';
    final appointmentType = schedule['appointmentType'] ?? 'video_call';
    
    // Show meeting dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              appointmentType == 'video_call' ? Icons.videocam : Icons.phone,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appointmentType == 'video_call' ? 'Video Call' : 'Voice Call',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Starting session with $patientName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meeting Link:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'https://meet.moodify.com/session/${schedule['_id']}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // In a real app, this would open the actual meeting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Connecting to ${appointmentType == 'video_call' ? 'video' : 'voice'} call...'),
                  backgroundColor: AppColors.primary,
                ),
              );
              Navigator.pop(context);
            },
            icon: Icon(appointmentType == 'video_call' ? Icons.videocam : Icons.phone),
            label: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> schedule) {
    final patientName = schedule['patientName'] ?? 'Patient';
    final scheduledDate = DateTime.parse(schedule['scheduledDate']);
    final scheduledTime = schedule['scheduledTime'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editing appointment with $patientName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, MMMM d, y').format(scheduledDate)),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(scheduledTime.isNotEmpty ? scheduledTime : 'Not set'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to edit screen or show edit form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality - Open scheduling screen with pre-filled data'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _deleteAppointment(Map<String, dynamic> schedule) {
    final patientName = schedule['patientName'] ?? 'Patient';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete the appointment with $patientName?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final scheduleId = schedule['_id'] ?? schedule['id'];
                
                // Call delete API
                final response = await ApiService.deleteSchedule(scheduleId);
                
                if (response['success']) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the list
                    _loadSchedules();
                  }
                } else {
                  throw Exception(response['message'] ?? 'Failed to delete');
                }
              } catch (e) {
                print('Error deleting appointment: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}