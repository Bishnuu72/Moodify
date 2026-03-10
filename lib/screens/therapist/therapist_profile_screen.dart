import'dart:io';
import'package:flutter/material.dart';
import'package:image_picker/image_picker.dart';
import'package:provider/provider.dart';
import'package:animate_do/animate_do.dart';
import'../../services/auth_service.dart';
import'../../constants/colors.dart';
import'../auth/login_screen.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  final TextEditingController _nameController= TextEditingController(text: 'Dr. Sarah Wilson');
  final TextEditingController _emailController = TextEditingController(text: 'sarah@clinic.com');
  final TextEditingController _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final TextEditingController _specializationController= TextEditingController(text: 'Clinical Psychology');
  final TextEditingController _experienceController = TextEditingController(text: '10 years');
  final TextEditingController _bioController = TextEditingController(text: 'Licensed therapist specializing in anxiety and depression treatment.');
  
  bool _isEditing = false;
  String? _profileImage;

  Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _profileImage = photo.path;
       });
     }
   } catch (e) {
   if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to pick image: \$e')),
       );
     }
   }
  }

  void _logout() async {
  final confirmed = await showDialog<bool>(
    context: context,
     builder: (context) => AlertDialog(
      title: const Text('Logout'),
     content: const Text('Are you sure you want to logout?'),
      actions: [
       TextButton(
         onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
       ),
       TextButton(
        onPressed: () => Navigator.pop(context, true),
       style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text('Logout'),
       ),
     ],
    ),
   );

  if (confirmed == true && mounted) {
    await Provider.of<AuthService>(context, listen: false).signOut();
    Navigator.pushAndRemoveUntil(
     context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
   }
  }

  void _deleteAccount() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
     content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
      actions: [
       TextButton(
         onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
       ),
       TextButton(
        onPressed: () => Navigator.pop(context, true),
       style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text('Delete'),
       ),
     ],
    ),
   );

  if (confirmed == true && mounted) {
    // TODO: Implement account deletion
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Account deletion initiated')),
    );
   }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: AppColors.background,
     appBar: AppBar(
      title: const Text(
         'Profile',
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
        icon: Icon(_isEditing ? Icons.check : Icons.edit),
        onPressed: () {
         setState(() {
           _isEditing = !_isEditing;
         });
       },
      ),
     ],
    ),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.center,
     children: [
      // Profile Picture
      FadeInDown(
       child: GestureDetector(
        onTap: _isEditing ? _pickImage: null,
        child: Stack(
         children: [
          CircleAvatar(
           radius: 60,
           backgroundColor: Colors.teal.withOpacity(0.1),
          backgroundImage: _profileImage != null
             ? FileImage(File(_profileImage!))
            : null,
          child: _profileImage == null
            ? const Text(
               'SW',
             style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              color: Colors.teal,
              ),
             )
            : null,
         ),
       if (_isEditing)
         Positioned(
         bottom: 0,
          right: 0,
          child: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
             shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
           ),
           padding: const EdgeInsets.all(8),
           child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
         ),
       ],
      ),
     ),
    ),
   const SizedBox(height: 8),
     FadeInDown(
   delay: const Duration(milliseconds: 100),
     child: const Text(
       'Dr. Sarah Wilson',
     style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      ),
     ),
    ),
  const SizedBox(height:4),
    FadeInDown(
   delay: const Duration(milliseconds: 200),
     child: const Text(
       'Clinical Psychologist',
     style: TextStyle(
        fontSize: 16,
      color: AppColors.textSecondary,
      ),
     ),
    ),
  const SizedBox(height:30),

      // Profile Information
     FadeInUp(
   delay: const Duration(milliseconds: 300),
     child: _buildSection(
       'Personal Information',
       [
        _buildTextField(
        controller: _nameController,
         label: 'Full Name',
         icon: Icons.person,
        enabled: _isEditing,
       ),
       _buildTextField(
        controller: _emailController,
         label: 'Email',
         icon: Icons.email,
        enabled: _isEditing,
       ),
       _buildTextField(
        controller: _phoneController,
         label: 'Phone Number',
         icon: Icons.phone,
        enabled: _isEditing,
       ),
     ],
    ),
   ),
   
  const SizedBox(height:20),
   
     FadeInUp(
   delay: const Duration(milliseconds: 400),
     child: _buildSection(
       'Professional Information',
       [
        _buildTextField(
        controller: _specializationController,
         label: 'Specialization',
         icon: Icons.medical_services,
        enabled: _isEditing,
       ),
       _buildTextField(
        controller: _experienceController,
         label: 'Experience',
         icon: Icons.work,
        enabled: _isEditing,
       ),
       _buildTextField(
        controller: _bioController,
         label: 'Bio',
         icon: Icons.description,
        enabled: _isEditing,
        maxLines: 3,
       ),
     ],
    ),
   ),
   
  const SizedBox(height:30),
   
      // Settings Section
     FadeInUp(
   delay: const Duration(milliseconds: 500),
     child: _buildSection(
       'Settings',
       [
        _buildSettingTile(
         icon: Icons.notifications,
         title: 'Notifications',
         subtitle: 'Manage notification preferences',
         onTap: () {
           // TODO: Navigate to notifications settings
         },
       ),
       _buildSettingTile(
         icon: Icons.lock,
         title: 'Privacy',
         subtitle: 'Privacy settings and security',
        onTap: () {
          // TODO: Navigate to privacy settings
        },
       ),
       _buildSettingTile(
         icon: Icons.help,
         title: 'Help & Support',
         subtitle: 'Get help and support',
        onTap: () {
          // TODO: Navigate to help center
        },
       ),
     ],
    ),
   ),
   
  const SizedBox(height:20),
   
      // Account Actions
     FadeInUp(
   delay: const Duration(milliseconds: 600),
     child: Container(
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
          BoxShadow(
          color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0,2),
          ),
        ],
      ),
      child: Column(
        children: [
         ListTile(
          leading: const Icon(Icons.logout, color: Colors.orange),
          title: const Text('Logout'),
          subtitle: const Text('Sign out from your account'),
          onTap: _logout,
         ),
        const Divider(height: 1),
         ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Permanently delete your account'),
          onTap: _deleteAccount,
         ),
       ],
     ),
    ),
   ),
     ],
    ),
   ),
 );
}

Widget _buildSection(String title, List<Widget> children) {
 return Container(
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
    Text(
     title,
   style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    ),
   ),
  const SizedBox(height:16),
   ...children,
 ],
 ),
);
}

Widget _buildTextField({
 required TextEditingController controller,
 required String label,
 required IconData icon,
 bool enabled = true,
 int maxLines = 1,
}) {
 return Padding(
   padding: const EdgeInsets.only(bottom: 16),
   child: TextField(
   controller: controller,
   enabled: enabled,
   maxLines: maxLines,
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: enabled ? Colors.teal : Colors.grey),
   border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
    ),
   ),
 ),
);
}

Widget _buildSettingTile({
 required IconData icon,
 required String title,
 required String subtitle,
 VoidCallback? onTap,
}) {
 return ListTile(
   leading: Icon(icon, color: Colors.teal),
   title: Text(title),
   subtitle: Text(subtitle),
  trailing: const Icon(Icons.chevron_right),
   onTap: onTap,
 );
}

@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _specializationController.dispose();
  _experienceController.dispose();
  _bioController.dispose();
  super.dispose();
}
}
