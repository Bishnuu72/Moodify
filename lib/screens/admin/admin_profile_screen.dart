import'dart:io';
import'package:flutter/material.dart';
import'package:image_picker/image_picker.dart';
import'package:provider/provider.dart';
import'package:animate_do/animate_do.dart';
import'../../services/auth_service.dart';
import'../../constants/colors.dart';
import'../auth/login_screen.dart';
import'../../services/api_service.dart';
import'../../services/cloudinary_service.dart';
import'package:flutter_image_compress/flutter_image_compress.dart';
import'package:path_provider/path_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = true;
  String? _profileImage;
  String? _currentPhotoUrl;
  File? _selectedImage;
  
  // Store original values to detect changes
  String? _originalName;
  String? _originalEmail;
  String? _originalPhone;
  
  // Cloudinary service
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }
  
  Future<void> _loadAdminProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final userId = currentUser.uid;
        final userProfile = await ApiService.getUserProfile(userId);
        
        if (userProfile['success'] == true && userProfile['data'] != null) {
          final userData = userProfile['data'];
          setState(() {
            _nameController.text = userData['displayName'] ?? 'Admin User';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _currentPhotoUrl = userData['photoUrl'];
            _profileImage = _currentPhotoUrl; // Use URL for display
            
            // Store original values to detect changes
            _originalName = userData['displayName'] ?? 'Admin User';
            _originalEmail = userData['email'] ?? '';
            _originalPhone = userData['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading admin profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        // Compress image before upload
        final compressedFile = await _compressImage(File(photo.path));
        
        setState(() {
          _selectedImage = compressedFile ?? File(photo.path);
          _profileImage = _selectedImage!.path; // Show local preview immediately
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
  
  Future<File?> _compressImage(File imageFile) async {
    try {
      final targetPath = '${(await getTemporaryDirectory()).path}/admin_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 85,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );
      
      if (result != null) {
        print('📦 Image compressed from ${await imageFile.length()} to ${await result.length()} bytes');
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('⚠️ Compression failed: $e');
      return null;
    }
  }
  
  Future<void> _saveChanges() async {
    if (!_isEditing) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user logged in');
      }
      
      final userId = currentUser.uid;
      final updates = <String, dynamic>{};
      
      // Collect changes - compare with original values
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      
      // Check if name changed
      if (newName.isNotEmpty && newName != _originalName) {
        updates['displayName'] = newName;
        print('📝 Name changed from "$_originalName" to "$newName"');
      }
      
      // Check if email changed
      if (newEmail.isNotEmpty && newEmail != _originalEmail) {
        updates['email'] = newEmail;
        print('📧 Email changed from "$_originalEmail" to "$newEmail"');
      }
      
      // Check if phone changed (compare with original, allowing empty to clear phone)
      if (newPhone != _originalPhone) {
        updates['phone'] = newPhone;
        print('📱 Phone changed from "$_originalPhone" to "$newPhone"');
      }
      
      // Upload new photo if selected
      String? newPhotoUrl;
      if (_selectedImage != null) {
        print('☁️ Uploading new profile photo...');
        newPhotoUrl = await _cloudinaryService.uploadProfilePhoto(_selectedImage!);
        updates['photoUrl'] = newPhotoUrl;
      }
      
      // Update profile if there are changes
      if (updates.isNotEmpty) {
        print('💾 Updating admin profile...');
        print('📦 Updates to send: $updates');
        final response = await ApiService.updateUserProfile(userId, updates);
        
        if (response['success'] == true) {
          if (mounted) {
            setState(() {
              _isEditing = false;
              if (newPhotoUrl != null) {
                _currentPhotoUrl = newPhotoUrl;
                _profileImage = newPhotoUrl;
              }
              _selectedImage = null;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            
            // Reload profile to ensure we have latest data
            await _loadAdminProfile();
          }
        } else {
          throw Exception(response['message'] ?? 'Failed to update profile');
        }
      } else {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No changes made')),
          );
        }
      }
    } catch (e) {
      print('❌ Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Picture
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.deepPurple, width: 3),
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? (_profileImage!.startsWith('http')
                                      ? Image.network(_profileImage!, fit: BoxFit.cover)
                                      : Image.file(File(_profileImage!), fit: BoxFit.cover))
                                  : const Icon(Icons.person, size: 60, color: Colors.deepPurple),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isEditing ? _pickImage : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isEditing ? Colors.deepPurple : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: Icon(
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
                    
                    const SizedBox(height: 24),
                    
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
                    
                    const SizedBox(height: 8),
                    
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
                    
                    const SizedBox(height: 30),
                    
                    // Edit Button
                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () {
                          if (_isEditing) {
                            _saveChanges();
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        icon: Icon(_isLoading ? Icons.hourglass_empty : (_isEditing ? Icons.check : Icons.edit)),
                        label: Text(_isLoading ? 'Saving...' : (_isEditing ? 'Save Changes' : 'Edit Profile')),
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
                      
                    const SizedBox(height: 30),
                    
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
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: Icons.phone,
                            enabled: _isEditing,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Account Actions
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _logout,
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
