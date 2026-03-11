import'package:flutter/material.dart';
import'../../constants/colors.dart';
import'../home/home_screen.dart';
import'../mood_wall/mood_wall_screen.dart';
import'../new_mood/new_mood_screen.dart';
import'../profile/profile_screen.dart';
import'../wellness/wellness_screen.dart';
import'../music/music_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
   const HomeScreen(),
   const MoodWallScreen(),
   // const NewMoodScreen(),
   const WellnessScreen(),
   const MusicScreen(),
   const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: _screens[_currentIndex],
     bottomNavigationBar: Container(
       decoration: BoxDecoration(
         boxShadow: [
            BoxShadow(
             color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: AppColors.primary,
           unselectedItemColor: AppColors.textSecondary,
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
           unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Mood Wall',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.add_circle_outline),
              //   activeIcon: Icon(Icons.add_circle),
              //   label: 'New Mood',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.self_improvement_outlined),
                activeIcon: Icon(Icons.self_improvement),
                label: 'Wellness',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note_outlined),
                activeIcon: Icon(Icons.music_note),
                label: 'Music',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
