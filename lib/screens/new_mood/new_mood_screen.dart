import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class NewMoodScreen extends StatefulWidget {
  const NewMoodScreen({super.key});

  @override
  State<NewMoodScreen> createState() => _NewMoodScreenState();
}

class _NewMoodScreenState extends State<NewMoodScreen> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  String selectedMood = '';
  String selectedEmoji = '';
  int intensity = 5;
  List<String> tags = [];
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  
  final List<Map<String, String>> moodOptions = [
    {'mood': 'Happy', 'emoji': '😊'},
    {'mood': 'Excited', 'emoji': '🤩'},
    {'mood': 'Calm', 'emoji': '😌'},
    {'mood': 'Neutral', 'emoji': '😐'},
    {'mood': 'Tired', 'emoji': '😴'},
    {'mood': 'Sad', 'emoji': '😔'},
    {'mood': 'Anxious', 'emoji': '😰'},
    {'mood': 'Angry', 'emoji': '😡'},
    {'mood': 'Stressed', 'emoji': '😫'},
    {'mood': 'Confused', 'emoji': '😕'},
  ];

  @override
  void dispose() {
    _journalController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagsController.text.trim().isNotEmpty) {
      setState(() {
        tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      tags.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'New Mood Entry',
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
            // Mood Selection
            FadeInDown(
              child: const Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: moodOptions.map((option) {
                  final isSelected = selectedMood == option['mood'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = option['mood']!;
                        selectedEmoji = option['emoji']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
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
                        children: [
                          Text(
                            option['emoji']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['mood']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
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

            // Intensity Slider
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Intensity Level',
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
                            activeColor: AppColors.primary,
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Journal Entry
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Journal Entry (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                      child: TextField(
                        controller: _journalController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Write down your thoughts...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Tags
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                hintText: 'Add tags...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addTag,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.asMap().entries.map((entry) {
                          int index = entry.key;
                          String tag = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeTag(index),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Anonymous Toggle
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isAnonymous = !_isAnonymous;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Post Anonymously',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isAnonymous 
                                    ? 'Your name will not be shown'
                                    : 'Your name will be displayed',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Submit Button
            if (selectedMood.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitMoodEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Mood Entry',
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

  void _submitMoodEntry() async {
    if (selectedMood.isEmpty) return;

    // Get current user
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to save mood entries'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('🔵 Submitting mood entry with isAnonymous: $_isAnonymous');
      
      // Save to MongoDB via API
      final result = await ApiService.createMood(
        userId: user.uid,
        mood: selectedMood,
        emotionScore: intensity,
        note: _journalController.text.trim().isNotEmpty 
            ? _journalController.text.trim() 
            : null,
        tags: tags.isNotEmpty ? tags : null,
        isAnonymous: _isAnonymous,
      );

      print('📊 API Response: $result');

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mood entry saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save mood');
      }
    } catch (e) {
      print('Error saving mood: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}