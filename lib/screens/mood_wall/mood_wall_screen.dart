import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class MoodWallScreen extends StatefulWidget {
  const MoodWallScreen({super.key});

  @override
  State<MoodWallScreen> createState() => _MoodWallScreenState();
}

class _MoodWallScreenState extends State<MoodWallScreen> {
  bool _isLoading = true;
  List<dynamic> _allMoods = [];
  Map<String, String> _userDisplayNames = {}; // Cache for user display names

  @override
  void initState() {
    super.initState();
    _loadAllMoods();
  }

  Future<void> _loadAllMoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all moods from MongoDB (no userId filter = get all)
      // For now, we'll fetch a large limit to get all users' moods
      final response = await ApiService.getUserMoods('all', limit: 100);
      
      if (response['success'] == true) {
        // Fetch user display names for all unique user IDs
        final userIds = response['data']
            .map((mood) => mood['userId'] as String)
            .toSet();
        
        for (String userId in userIds) {
          if (!_userDisplayNames.containsKey(userId)) {
            try {
              final userProfile = await ApiService.getUserProfile(userId);
              if (userProfile['success'] == true) {
                final userData = userProfile['data'];
                _userDisplayNames[userId] = 
                    userData['displayName']?.isNotEmpty == true 
                        ? userData['displayName'] 
                        : userData['email']?.split('@').first ?? 'Anonymous';
              } else {
                print('⚠️ No profile found for user: $userId');
                _userDisplayNames[userId] = 'Anonymous User';
              }
            } catch (e) {
              print('⚠️ Could not fetch profile for $userId: $e');
              _userDisplayNames[userId] = 'Anonymous User';
            }
          }
        }
        
        setState(() {
          _allMoods = response['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load moods');
      }
    } catch (e) {
      print('Error loading moods: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load moods: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mood Wall',
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
            onPressed: _loadAllMoods,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Stats
                  FadeInDown(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            _allMoods.length.toString(),
                            'Entries',
                            Icons.auto_graph,
                          ),
                          _buildStatItem(
                            _getMostUsedEmotion(),
                            'Emotion',
                            Icons.emoji_emotions,
                          ),
                          _buildStatItem(
                            _getUniqueUsers().toString(),
                            'Users',
                            Icons.people,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Mood Entries List
                  const Text(
                    'Recent Entries',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _allMoods.isEmpty
                        ? const Center(
                            child: Text(
                              'No mood entries yet.\nBe the first to share your mood!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _allMoods.length,
                            itemBuilder: (context, index) {
                              final entry = _allMoods[index];
                              return FadeInUp(
                                delay: Duration(milliseconds: 100 * index),
                                child: _buildMoodCard(entry),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildMoodCard(dynamic entry) {
    // Get mood emoji based on mood type
    String emoji;
    Color moodColor;
    
    // Debug log to check isAnonymous value
    print('🔍 Mood Entry - isAnonymous: ${entry['isAnonymous']}, userId: ${entry['userId']}, mood: ${entry['mood']}');
    
    switch (entry['mood']) {
      case 'Happy':
        emoji = '😊';
        moodColor = Colors.green;
        break;
      case 'Sad':
        emoji = '😔';
        moodColor = Colors.blue;
        break;
      case 'Angry':
        emoji = '😡';
        moodColor = Colors.red;
        break;
      case 'Anxious':
        emoji = '😰';
        moodColor = Colors.orange;
        break;
      case 'Tired':
        emoji = '😴';
        moodColor = Colors.purple;
        break;
      default:
        emoji = '😐';
        moodColor = Colors.grey;
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emoji and date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show username or Anonymous based on isAnonymous flag
                      Row(
                        children: [
                          Text(
                            // If isAnonymous is true or 'true', show "Anonymous", otherwise show user's display name
                            (entry['isAnonymous'] == true || entry['isAnonymous'] == 'true' || entry['isAnonymous'] == false)
                                ? ((entry['isAnonymous'] == true || entry['isAnonymous'] == 'true') 
                                    ? 'Anonymous' 
                                    : (_userDisplayNames[entry['userId']] ?? 'User'))
                                : 'Anonymous', // Default to anonymous if field is missing/null
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (entry['isAnonymous'] == true || entry['isAnonymous'] == 'true')
                            const SizedBox(width: 6),
                          if (entry['isAnonymous'] == true || entry['isAnonymous'] == 'true')
                            Icon(
                              Icons.visibility_off,
                              size: 14,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry['mood'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(entry['createdAt']),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Intensity indicator
                Column(
                  children: [
                    const Text(
                      'Intensity',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (entry['emotionScore'] ?? 5) / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getIntensityColor(entry['emotionScore'] ?? 5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Journal entry
            if (entry['note'] != null && entry['note'].isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry['note'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            if (entry['note'] != null && entry['note'].isNotEmpty)
              const SizedBox(height: 12),

            // Tags
            if (entry['tags'] != null && (entry['tags'] as List).isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (entry['tags'] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: moodColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity >= 8) return AppColors.success;
    if (intensity >= 6) return Colors.orange;
    if (intensity >= 4) return Colors.yellow;
    return AppColors.error;
  }

  double _calculateAverageMood() {
    if (_allMoods.isEmpty) return 0.0;
    
    double total = 0;
    for (var mood in _allMoods) {
      total += (mood['emotionScore'] ?? 5);
    }
    return total / _allMoods.length;
  }

  int _getUniqueUsers() {
    Set<String> userIds = Set();
    for (var mood in _allMoods) {
      userIds.add(mood['userId'] ?? '');
    }
    return userIds.length;
  }

  String _getMostUsedEmotion() {
    if (_allMoods.isEmpty) return '😐';
    
    Map<String, int> moodCounts = {};
    
    // Count each mood type
    for (var mood in _allMoods) {
      final moodType = mood['mood'] as String?;
      if (moodType != null) {
        moodCounts[moodType] = (moodCounts[moodType] ?? 0) + 1;
      }
    }
    
    // Find most common mood
    String? mostUsedMood;
    int maxCount = 0;
    
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        mostUsedMood = mood;
        maxCount = count;
      }
    });
    
    if (mostUsedMood == null) return '😐';
    
    // Return emoji for most used mood
    return _getMoodEmoji(mostUsedMood!);
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toUpperCase()) {
      case 'HAPPY':
        return '😊';
      case 'EXCITED':
        return '🤩';
      case 'CALM':
        return '😌';
      case 'NEUTRAL':
        return '😐';
      case 'TIRED':
        return '😴';
      case 'SAD':
        return '😢';
      case 'ANXIOUS':
        return '😰';
      case 'ANGRY':
        return '😠';
      case 'STRESSED':
        return '😫';
      case 'CONFUSED':
        return '😕';
      default:
        return '😐';
    }
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
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}