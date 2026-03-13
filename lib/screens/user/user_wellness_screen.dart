import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class UserWellnessScreen extends StatefulWidget {
  const UserWellnessScreen({super.key});

  @override
  State<UserWellnessScreen> createState() => _UserWellnessScreenState();
}

class _UserWellnessScreenState extends State<UserWellnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'breathing';
  bool _isLoading = true;
  List<dynamic> _wellnessActivities = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadWellnessActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _getCategoryFromIndex(_tabController.index);
      });
    }
  }

  String _getCategoryFromIndex(int index) {
    switch (index) {
      case 0: return 'breathing';
      case 1: return 'meditation';
      case 2: return 'journaling';
      case 3: return 'relaxation';
      default: return 'breathing';
    }
  }

  Future<void> _loadWellnessActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWellnessActivities(category: _selectedCategory);
      
      if (response['success']) {
        setState(() {
          _wellnessActivities = response['data'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load activities: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins > 0 ? '${mins}m' : ''}';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'breathing': return AppColors.primary;
      case 'meditation': return Colors.purple;
      case 'journaling': return Colors.orange;
      case 'relaxation': return Colors.teal;
      default: return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'breathing': return Icons.air;
      case 'meditation': return Icons.self_improvement;
      case 'journaling': return Icons.edit_note;
      case 'relaxation': return Icons.spa;
      default: return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Wellness Activities',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(icon: Icon(Icons.air), text: 'Breathing'),
            Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
            Tab(icon: Icon(Icons.edit_note), text: 'Journaling'),
            Tab(icon: Icon(Icons.spa), text: 'Relaxation'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadWellnessActivities,
                        icon: Icon(Icons.refresh, color: AppColors.primary),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWellnessActivities,
                  child: _wellnessActivities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(_selectedCategory),
                                size: 80,
                                color: AppColors.textSecondary.withOpacity(0.3),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'No Activities Yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Admin hasn\'t created any ${_selectedCategory} activities yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _wellnessActivities.length,
                          itemBuilder: (context, index) {
                            final activity = _wellnessActivities[index];
                            return _buildActivityCard(activity);
                          },
                        ),
                ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    final hasMusic = activity['musicUrl'] != null && activity['musicUrl'].isNotEmpty;
    final isJournaling = activity['category'] == 'journaling';
    final hasQuestion = activity['journalQuestion'] != null && 
                        activity['journalQuestion'].toString().isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActivityDetails(activity),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and badges
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(activity['category']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(activity['category']),
                      color: _getCategoryColor(activity['category']),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            _buildBadge(
                              icon: Icons.timer_outlined,
                              label: _formatDuration(activity['duration']),
                            ),
                            if (hasMusic) ...[
                              SizedBox(width: 8),
                              _buildBadge(
                                icon: Icons.music_note,
                                label: 'Audio',
                              ),
                            ],
                            if (isJournaling && hasQuestion) ...[
                              SizedBox(width: 8),
                              _buildBadge(
                                icon: Icons.question_answer,
                                label: 'Question',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Description
              Text(
                activity['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12),

              // Footer with difficulty and instructions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDifficultyChip(activity['difficulty']),
                  if (activity['instructions'] != null && 
                      activity['instructions'].toString().isNotEmpty)
                    Text(
                      'View Instructions',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showActivityDetails(dynamic activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  children: [
                    // Title section
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(activity['category']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(activity['category']),
                            color: _getCategoryColor(activity['category']),
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              _buildDifficultyChip(activity['difficulty']),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Duration row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn(
                          icon: Icons.timer_outlined,
                          label: 'Duration',
                          value: _formatDuration(activity['duration']),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        _buildInfoColumn(
                          icon: Icons.music_note,
                          label: 'Audio',
                          value: activity['musicUrl'] != null ? 'Yes' : 'No',
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        _buildInfoColumn(
                          icon: Icons.info_outline,
                          label: 'Level',
                          value: activity['difficulty'].toUpperCase(),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Description
                    _buildSection(
                      title: 'Description',
                      content: activity['description'],
                    ),

                    // Instructions
                    if (activity['instructions'] != null && 
                        activity['instructions'].toString().isNotEmpty)
                      _buildSection(
                        title: 'Instructions',
                        content: activity['instructions'],
                      ),

                    // Journal question
                    if (activity['category'] == 'journaling' && 
                        activity['journalQuestion'] != null)
                      _buildSection(
                        title: 'Reflection Question',
                        content: activity['journalQuestion'],
                        isQuestion: true,
                      ),

                    // Music info
                    if (activity['musicUrl'] != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.music_note, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Audio Available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (activity['musicTitle'] != null) ...[
                              SizedBox(height: 8),
                              Text(
                                activity['musicTitle'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (activity['musicDuration'] != null) ...[
                              SizedBox(height: 4),
                              Text(
                                'Duration: ${activity['musicDuration']} seconds',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24),

                    // Start button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _startActivity(activity),
                        icon: Icon(Icons.play_arrow, size: 28),
                        label: Text(
                          'Start Activity',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isQuestion = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isQuestion ? Icons.question_answer : Icons.description,
                color: isQuestion ? Colors.orange : AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isQuestion 
                  ? Colors.orange.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: isQuestion ? Colors.orange.shade700 : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _startActivity(dynamic activity) {
    Navigator.pop(context); // Close details modal
    
    // Show activity start dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getCategoryIcon(activity['category']), color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text('Starting Activity')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activity['title'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${_formatDuration(activity['duration'])}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (activity['musicUrl'] != null) ...[
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Audio will play',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchActivityPlayer(activity);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Begin'),
          ),
        ],
      ),
    );
  }

  void _launchActivityPlayer(dynamic activity) {
    // TODO: Implement actual audio player when audioplayers is added back
    // For now, show a simple timer/activity screen
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button during activity
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity['category']).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(activity['category']),
                  color: _getCategoryColor(activity['category']),
                  size: 50,
                ),
              ),
              SizedBox(height: 24),
              
              Text(
                activity['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              
              Text(
                '${_formatDuration(activity['duration'])} session',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24),
              
              // Timer placeholder
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Timer: ${activity['duration']}:00',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Instructions or question
              if (activity['category'] == 'journaling' && 
                  activity['journalQuestion'] != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Reflect on:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        activity['journalQuestion'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 24),
              
              // Complete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _completeActivity(activity);
                  },
                  icon: Icon(Icons.check_circle),
                  label: Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeActivity(dynamic activity) {
    // Show completion message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Great Job!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You completed "${activity['title']}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
