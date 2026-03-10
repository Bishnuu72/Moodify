import'dart:io';
import'package:flutter/material.dart';
import'package:image_picker/image_picker.dart';
import'package:provider/provider.dart';
import'package:animate_do/animate_do.dart';
import'../../services/auth_service.dart';
import'../../constants/colors.dart';
import'../auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _nameController= TextEditingController(text: 'Admin User');
  final TextEditingController _emailController = TextEditingController(text: 'admin@moodify.com');
  final TextEditingController _phoneController = TextEditingController(text: '+1 (555) 999-8888');
  
  bool _isEditing = false;
  String? _profileImage;

  Future<void> _pickImage() async {
   final ImagePicker picker= ImagePicker();
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
          SnackBar(content: Text('Failed to pick image: $e')),
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
           style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
    body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            const SizedBox(height:20),
              
              // Profile Picture
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height:120,
                      decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 3),
                      ),
                     child: ClipOval(
                        child: _profileImage != null
                           ? Image.file(File(_profileImage!), fit: BoxFit.cover)
                           : const Icon(Icons.person, size: 60, color: Colors.deepPurple),
                      ),
                    ),
                    Positioned(
                     bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                          color: Colors.deepPurple,
                           shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                          color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height:24),
              
              // Name
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  ),
                ),
              ),
              
            const SizedBox(height:8),
              
              FadeInDown(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Platform Administrator',
                  style: TextStyle(
                    fontSize: 16,
                  color: AppColors.textSecondary,
                  ),
                ),
              ),
              
            const SizedBox(height:30),
              
              // Edit Button
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16),
                  ),
                 ),
                ),
              ),
              
            const SizedBox(height:30),
              
              // Personal Information Section
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildSection(
                  'Personal Information',
                  [
                    _buildTextField(
                    controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                     enabled: _isEditing,
                    ),
                  const SizedBox(height:16),
                    _buildTextField(
                    controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                     enabled: _isEditing,
                    ),
                  const SizedBox(height:16),
                    _buildTextField(
                    controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                     enabled: _isEditing,
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height:30),
              
              // Account Actions
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                       icon: const Icon(Icons.logout),
                       label: const Text('Logout'),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                       foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(16),
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
  
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
     padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
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
  }) {
    return TextField(
    controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
       labelText: label,
       prefixIcon: Icon(icon),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
       ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
  
  @override
  void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  super.dispose();
  }
}
