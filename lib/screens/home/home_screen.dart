import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../providers/user_profile_provider.dart';
import '../mood_wall/mood_wall_screen.dart';
import '../new_mood/new_mood_screen.dart';
import '../wellness/wellness_screen.dart';
import'../emotion/emotion_detection_screen.dart';
import'../therapist/therapist_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    // Load user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      profileProvider.loadUserProfile();
      // Load user stats
      _loadUserStats();
    });
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        final stats = await ApiService.getMoodStats(user.uid);
        if (stats['success'] == true) {
          setState(() {
            _userStats = stats['data'];
            _isLoadingStats = false;
          });
        } else {
          throw Exception('Failed to load stats');
        }
      } else {
        setState(() {
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        // Use display name from MongoDB, fallback to email prefix
        final displayName = profileProvider.displayName;

        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Moodify',
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Icon and Welcome Section
            FadeInDown(
              child: Row(
                children: [
                  // Profile Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: Consumer<UserProfileProvider>(
                      builder: (context, profileProvider, child) {
                        final photoUrl = profileProvider.photoUrl;
                        final displayName = profileProvider.displayName;
                        
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildAvatarInitials(displayName);
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : _buildAvatarInitials(displayName),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Welcome Text
                  Expanded(
                    child: Text(
                      'Hello, $displayName 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Mood Quick Selection
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Text(
                'Quick Mood Check',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMoodCard('😊', 'Happy', AppColors.success, context),
                    _buildMoodCard('😐', 'Neutral', AppColors.textSecondary, context),
                    _buildMoodCard('😔', 'Sad', Colors.blue, context),
                    _buildMoodCard('😡', 'Angry', AppColors.error, context),
                    _buildMoodCard('😰', 'Anxious', Colors.orange, context),
                    _buildMoodCard('😴', 'Tired', Colors.purple, context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Stats Section
            FadeInUp(
              delay: const Duration(milliseconds: 800),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoadingStats
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                _userStats?['weeklyEntries']?.toString() ?? '0',
                                'Entries',
                                Icons.edit_note,
                              ),
                              _buildStatCard(
                                _userStats?['avgEmotionScore']?.toString() ?? '0',
                                'Avg Mood',
                                Icons.mood,
                              ),
                              _buildStatCard(
                                _userStats?['currentStreak']?.toString() ?? '0',
                                'Streak',
                                Icons.local_fire_department,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Quick Actions
            FadeInUp(
              delay: const Duration(milliseconds: 1000),
              child: const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 1200),
              child: Column(
                children: [
                  _buildActionCard(
                    'Track Mood',
                    'Log your current feelings',
                    Icons.add_circle,
                    AppColors.primary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewMoodScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Mood Wall',
                    'View your mood history',
                    Icons.grid_view,
                    AppColors.secondary,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodWallScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Wellness Tools',
                    'Meditation & breathing exercises',
                    Icons.self_improvement,
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WellnessScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Emotion Detection',
                    'Advanced mood tracking with slider',
                    Icons.emoji_emotions,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmotionDetectionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height:12),
                  _buildActionCard(
                    'Find Therapist',
                    'Connect with professional help',
                    Icons.medical_services,
                    Colors.red,
                    () {
                      Navigator.push(
                       context,
                        MaterialPageRoute(
                          builder: (context) => const TherapistScreen(),
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
      },
    );
  }

  Widget _buildMoodCard(String emoji, String label, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewMoodScreen(),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
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
            fontSize: 20,
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

  Widget _buildAvatarInitials(String displayName) {
    final initials = displayName.isNotEmpty 
        ? displayName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join().toUpperCase()
        : 'U';
    
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}