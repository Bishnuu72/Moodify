import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String? email;

  const PatientDetailScreen({
    super.key,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.email,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Map<String, dynamic>? _patient;
  List<Map<String, dynamic>> _moodEntries = [];
  bool _isLoading = true;
  String _error = '';
  
  // Statistics
  int _totalMoods = 0;
  String _mostFrequentMood = '-';
  double _averageMoodIntensity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Fetch patient profile
      final profileResponse = await ApiService.getUserProfile(widget.userId);
      
      if (profileResponse['success']) {
        setState(() {
          _patient = profileResponse['data'];
        });
      }

      // Fetch patient's mood entries
      final moodResponse = await ApiService.getUserMoods(widget.userId);
      
      if (moodResponse['success']) {
        setState(() {
          _moodEntries = List<Map<String, dynamic>>.from(moodResponse['data']);
          _calculateStatistics();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patient details: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    if (_moodEntries.isEmpty) return;

    _totalMoods = _moodEntries.length;

    // Calculate most frequent mood
    Map<String, int> moodCounts = {};
    double totalIntensity = 0.0;

    for (var entry in _moodEntries) {
      final mood = entry['mood'] ?? 'Unknown';
      final intensity = (entry['intensity'] ?? 0).toDouble();
      
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      totalIntensity += intensity;
    }

    // Find most frequent mood
    if (moodCounts.isNotEmpty) {
      _mostFrequentMood = moodCounts.entries.reduce(
        (a, b) => a.value > b.value ? a : b
      ).key;
    }

    // Calculate average intensity
    _averageMoodIntensity = totalIntensity / _totalMoods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorState()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      _buildStatisticsSection(),
                      _buildInfoSection(),
                      _buildMoodEntriesSection(),
                    ],
                  ),
                ),
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
            'Failed to load patient details',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPatientDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                  ? NetworkImage(widget.photoUrl!)
                  : null,
              child: widget.photoUrl == null || widget.photoUrl!.isEmpty
                  ? Text(
                      widget.displayName.isNotEmpty 
                          ? widget.displayName[0].toUpperCase() 
                          : 'P',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.email != null && widget.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.email!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeaderStat(
                  icon: Icons.mood,
                  label: 'Total Moods',
                  value: _totalMoods.toString(),
                ),
                const SizedBox(width: 24),
                _buildHeaderStat(
                  icon: Icons.star,
                  label: 'Avg Intensity',
                  value: _averageMoodIntensity.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Entries',
                    _totalMoods.toString(),
                    Icons.article,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Most Frequent',
                    _mostFrequentMood,
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Average Intensity',
              _averageMoodIntensity.toStringAsFixed(1) + '/10',
              Icons.trending_up,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    if (_patient == null) return const SizedBox.shrink();

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'Display Name',
              value: _patient!['displayName'] ?? 'N/A',
            ),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: _patient!['email'] ?? 'N/A',
            ),
            if (_patient!['phone'] != null && _patient!['phone']!.isNotEmpty)
              _buildInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: _patient!['phone']!,
              ),
            if (_patient!['bio'] != null && _patient!['bio']!.isNotEmpty)
              _buildInfoTile(
                icon: Icons.description_outlined,
                label: 'Bio',
                value: _patient!['bio']!,
                isMultiline: true,
              ),
            if (_patient!['preferredMood'] != null && _patient!['preferredMood']!.isNotEmpty)
              _buildInfoTile(
                icon: Icons.favorite_outline,
                label: 'Preferred Mood',
                value: _patient!['preferredMood']!,
              ),
            if (_patient!['interests'] != null && (_patient!['interests'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 20, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_patient!['interests'] as List).map((interest) {
                    return Chip(
                      label: Text(interest),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppColors.primary),
                    );
                  }).toList(),
                ),
              ),
            const Divider(height: 1),
            _buildInfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: _formatDate(_patient!['createdAt']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntriesSection() {
    if (_moodEntries.isEmpty) {
      return FadeInUp(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No mood entries yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This patient hasn\'t posted any moods',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recent Mood Entries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _moodEntries.length,
              itemBuilder: (context, index) {
                return _buildMoodEntryCard(_moodEntries[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntryCard(Map<String, dynamic> entry, int index) {
    final mood = entry['mood'] ?? 'Unknown';
    final intensity = (entry['intensity'] ?? 0).toInt();
    final note = entry['note'] ?? '';
    final createdAt = entry['createdAt'] != null 
        ? DateTime.parse(entry['createdAt']) 
        : DateTime.now();
    
    final color = _getMoodColor(mood);

    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showMoodDetails(entry),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMoodIcon(mood),
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, y • h:mm a').format(createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$intensity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoodDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildFullMoodDetail(entry),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullMoodDetail(Map<String, dynamic> entry) {
    final mood = entry['mood'] ?? 'Unknown';
    final intensity = (entry['intensity'] ?? 0).toInt();
    final note = entry['note'] ?? '';
    final createdAt = entry['createdAt'] != null 
        ? DateTime.parse(entry['createdAt']) 
        : DateTime.now();
    final activities = entry['activities'] as List? ?? [];
    
    final color = _getMoodColor(mood);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getMoodIcon(mood),
              color: color,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            mood,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            DateFormat('EEEE, MMMM d, y • h:mm a').format(createdAt),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailSection(
          icon: Icons.bolt,
          title: 'Intensity Level',
          content: '$intensity/10',
          color: color,
        ),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailSection(
            icon: Icons.description,
            title: 'Note',
            content: note,
            color: color,
          ),
        ],
        if (activities.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailSection(
            icon: Icons.list_alt,
            title: 'Activities',
            content: activities.join(', '),
            color: color,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.orange;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.purple;
      case 'calm':
        return Colors.teal;
      case 'excited':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'anxious':
        return Icons.sentiment_dissatisfied;
      case 'calm':
        return Icons.self_improvement;
      case 'excited':
        return Icons.auto_awesome;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dateTime = date is DateTime ? date : DateTime.parse(date);
    return DateFormat('MMMM y').format(dateTime);
  }
}
