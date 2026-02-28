import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../models/mood_entry.dart';

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({super.key});

  @override
  State<EmotionDetectionScreen> createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  String selectedMood = '';
  String selectedEmoji = '';
  int intensity = 5;
  double moodPosition = 0.5; // 0.0 to 1.0 for slider position

  final List<Map<String, dynamic>> moodOptions = [
    {
      'mood': 'Happy',
      'emoji': '😊',
      'color': AppColors.success,
      'position': 0.0,
    },
    {
      'mood': 'Excited',
      'emoji': '🤩',
      'color': Colors.orange,
      'position': 0.1,
    },
    {
      'mood': 'Calm',
      'emoji': '😌',
      'color': Colors.teal,
      'position': 0.2,
    },
    {
      'mood': 'Neutral',
      'emoji': '😐',
      'color': AppColors.textSecondary,
      'position': 0.3,
    },
    {
      'mood': 'Tired',
      'emoji': '😴',
      'color': Colors.purple,
      'position': 0.4,
    },
    {
      'mood': 'Sad',
      'emoji': '😔',
      'color': Colors.blue,
      'position': 0.6,
    },
    {
      'mood': 'Anxious',
      'emoji': '😰',
      'color': Colors.orange,
      'position': 0.7,
    },
    {
      'mood': 'Angry',
      'emoji': '😡',
      'color': AppColors.error,
      'position': 0.8,
    },
    {
      'mood': 'Stressed',
      'emoji': '😫',
      'color': Colors.red,
      'position': 0.9,
    },
    {
      'mood': 'Confused',
      'emoji': '😕',
      'color': Colors.grey,
      'position': 1.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Emotion Detection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            FadeInDown(
              child: const Text(
                'How are you feeling right now?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                'Select your current emotion or use the slider below',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Mood Slider
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Text(
                'Slide to express your mood',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                    // Mood Emoji Display
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        selectedEmoji.isEmpty ? '🤔' : selectedEmoji,
                        key: ValueKey(selectedEmoji),
                        style: const TextStyle(
                          fontSize: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mood Name Display
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        selectedMood.isEmpty ? 'Select your mood' : selectedMood,
                        key: ValueKey(selectedMood),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: selectedMood.isEmpty 
                              ? AppColors.textSecondary 
                              : _getMoodColor(selectedMood),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Custom Slider
                    _buildMoodSlider(),
                    const SizedBox(height: 20),

                    // Mood Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMoodLabel('😊', 'Happy', 0.0),
                        _buildMoodLabel('😐', 'Neutral', 0.3),
                        _buildMoodLabel('😔', 'Sad', 0.6),
                        _buildMoodLabel('😡', 'Angry', 1.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Intensity Selection
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How intense is this feeling?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Low', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: intensity.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: _getMoodColor(selectedMood),
                            inactiveColor: AppColors.textSecondary.withOpacity(0.3),
                            onChanged: (value) {
                              setState(() {
                                intensity = value.toInt();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('High', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                    Center(
                      child: Text(
                        intensity.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getMoodColor(selectedMood),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Quick Mood Selection
            FadeInUp(
              delay: const Duration(milliseconds: 1000),
              child: const Text(
                'Or select directly',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 1200),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: moodOptions.map((option) {
                  final isSelected = selectedMood == option['mood'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = option['mood'];
                        selectedEmoji = option['emoji'];
                        moodPosition = option['position'];
                        // Set default intensity to 5 for direct selection
                        intensity = 5;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? option['color'] 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? option['color'] 
                              : AppColors.textSecondary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option['emoji'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['mood'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // Action Button
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 1400),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveEmotion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getMoodColor(selectedMood),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save My Mood',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  AppColors.success, // Happy side
                  Colors.orange,
                  AppColors.textSecondary, // Neutral
                  Colors.orange,
                  AppColors.error, // Angry side
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
          
          // Slider Thumb
          Positioned(
            left: (MediaQuery.of(context).size.width - 80) * moodPosition,
            top: 5,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final position = details.globalPosition.dx - renderBox.localToGlobal(Offset.zero).dx;
                  moodPosition = (position / (renderBox.size.width - 80)).clamp(0.0, 1.0);
                  
                  // Find closest mood based on position
                  final closestMood = moodOptions.reduce((a, b) {
                    return (a['position'] - moodPosition).abs() < 
                           (b['position'] - moodPosition).abs() ? a : b;
                  });
                  
                  selectedMood = closestMood['mood'];
                  selectedEmoji = closestMood['emoji'];
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLabel(String emoji, String label, double position) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
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

  Color _getMoodColor(String mood) {
    final moodData = moodOptions.firstWhere(
      (option) => option['mood'] == mood,
      orElse: () => moodOptions[3], // Default to neutral
    );
    return moodData['color'];
  }

  void _saveEmotion() {
    if (selectedMood.isEmpty) return;

    // Create mood entry
    final moodEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      mood: selectedMood,
      emoji: selectedEmoji,
      intensity: intensity,
      createdAt: DateTime.now(),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood recorded: $selectedMood (Intensity: $intensity)'),
        backgroundColor: _getMoodColor(selectedMood),
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }
}