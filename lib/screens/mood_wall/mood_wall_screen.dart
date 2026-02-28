import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../models/mood_entry.dart';

class MoodWallScreen extends StatelessWidget {
  const MoodWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final List<MoodEntry> moodEntries = [
      MoodEntry(
        id: '1',
        userId: 'user1',
        mood: 'Happy',
        emoji: '😊',
        intensity: 8,
        journalEntry: 'Had a great day at work!',
        tags: ['work', 'happy'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MoodEntry(
        id: '2',
        userId: 'user1',
        mood: 'Calm',
        emoji: '😌',
        intensity: 7,
        journalEntry: 'Meditation session went well',
        tags: ['meditation', 'calm'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MoodEntry(
        id: '3',
        userId: 'user1',
        mood: 'Anxious',
        emoji: '😰',
        intensity: 4,
        journalEntry: 'Feeling stressed about upcoming presentation',
        tags: ['work', 'anxious'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Padding(
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
                    _buildStatItem('12', 'Entries', Icons.auto_graph),
                    _buildStatItem('7.2', 'Avg', Icons.mood),
                    _buildStatItem('5', 'Days', Icons.calendar_today),
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
              child: ListView.builder(
                itemCount: moodEntries.length,
                itemBuilder: (context, index) {
                  final entry = moodEntries[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 200 * index),
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

  Widget _buildMoodCard(MoodEntry entry) {
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
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    entry.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.mood,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
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
                        widthFactor: entry.intensity / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getIntensityColor(entry.intensity),
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
            if (entry.journalEntry != null && entry.journalEntry!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.journalEntry!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            if (entry.journalEntry != null && entry.journalEntry!.isNotEmpty)
              const SizedBox(height: 12),

            // Tags
            if (entry.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
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
}