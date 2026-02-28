import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../models/music_track.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy music tracks data
    final List<MusicTrack> musicTracks = [
      MusicTrack(
        id: '1',
        title: 'Peaceful Mind',
        artist: 'Meditation Sounds',
        mood: 'Calm',
        imageUrl: 'https://placehold.co/300x300/6A5AE0/white?text=Peaceful+Mind',
        previewUrl: '',
        duration: 180,
        tags: ['meditation', 'relaxation', 'calm'],
      ),
      MusicTrack(
        id: '2',
        title: 'Happy Vibes',
        artist: 'Joyful Beats',
        mood: 'Happy',
        imageUrl: 'https://placehold.co/300x300/10B981/white?text=Happy+Vibes',
        previewUrl: '',
        duration: 210,
        tags: ['uplifting', 'energetic', 'happy'],
      ),
      MusicTrack(
        id: '3',
        title: 'Deep Focus',
        artist: 'Concentration Zone',
        mood: 'Focused',
        imageUrl: 'https://placehold.co/300x300/9087E5/white?text=Deep+Focus',
        previewUrl: '',
        duration: 300,
        tags: ['focus', 'study', 'concentration'],
      ),
      MusicTrack(
        id: '4',
        title: 'Gentle Rain',
        artist: 'Nature Sounds',
        mood: 'Relaxed',
        imageUrl: 'https://placehold.co/300x300/6B7280/white?text=Gentle+Rain',
        previewUrl: '',
        duration: 360,
        tags: ['nature', 'sleep', 'relaxation'],
      ),
    ];

    final moods = musicTracks.map((track) => track.mood).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Music Therapy',
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
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Show search
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Selection
            FadeInDown(
              child: const Text(
                'Select Your Mood',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMoodChip('All Moods', true),
                    ...moods.map((mood) => _buildMoodChip(mood, false)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Recommended For You
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Text(
                'Recommended For You',
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
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Mood Mix',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personalized playlist based on your recent moods',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Music Tracks
            const Text(
              'Popular Tracks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: musicTracks.length,
                itemBuilder: (context, index) {
                  final track = musicTracks[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 800 + (index * 100)),
                    child: _buildMusicCard(track, context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip(String mood, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Text(
          mood,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicCard(MusicTrack track, BuildContext context) {
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
        child: Row(
          children: [
            // Album Art
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: track.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(track.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: track.imageUrl.isEmpty
                  ? const Icon(
                      Icons.music_note,
                      color: AppColors.primary,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Track Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: track.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Play Button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}