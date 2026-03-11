import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../constants/colors.dart';

class MoodTrackerWidget extends StatefulWidget {
  const MoodTrackerWidget({super.key});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _moodStats;
  List<dynamic> _recentMoods = [];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        // Load mood statistics
        final statsResponse = await ApiService.getMoodStats(user.uid);
        if (statsResponse['success'] == true) {
          setState(() {
            _moodStats = statsResponse['data'];
          });
        }

        // Load recent moods
        final moodsResponse = await ApiService.getUserMoods(user.uid, limit: 5);
        if (moodsResponse['success'] == true) {
          setState(() {
            _recentMoods = moodsResponse['data'];
          });
        }
      }
    } catch (e) {
      print('Error loading mood data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load mood data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics Cards
        if (_moodStats != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                '${_moodStats!['totalMoods']}',
                'Total Moods',
                Icons.mood,
              ),
              _buildStatCard(
                _moodStats!['avgEmotionScore'].toStringAsFixed(1),
                'Avg Score',
                Icons.analytics,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Recent Moods
        const Text(
          'Recent Moods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_recentMoods.isEmpty)
          const Center(
            child: Text('No moods recorded yet'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentMoods.length,
            itemBuilder: (context, index) {
              final mood = _recentMoods[index];
              return _buildMoodTile(mood);
            },
          ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
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
          Icon(icon, color: AppColors.primary, size: 32),
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

  Widget _buildMoodTile(Map<String, dynamic> mood) {
    String emoji;
    Color color;

    switch (mood['mood']) {
      case 'Happy':
        emoji = '😊';
        color = Colors.green;
        break;
      case 'Sad':
        emoji = '😔';
        color = Colors.blue;
        break;
      case 'Angry':
        emoji = '😡';
        color = Colors.red;
        break;
      case 'Anxious':
        emoji = '😰';
        color = Colors.orange;
        break;
      case 'Tired':
        emoji = '😴';
        color = Colors.purple;
        break;
      default:
        emoji = '😐';
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood['mood'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (mood['note'] != null && mood['note'].isNotEmpty)
                  Text(
                    mood['note'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatDate(mood['createdAt']),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      }
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }
}
