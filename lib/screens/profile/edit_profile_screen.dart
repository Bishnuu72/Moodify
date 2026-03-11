import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/api_service.dart';
import '../../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isLoading = false;
  
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    _displayNameController = TextEditingController(text: profileProvider.displayName);
    _emailController = TextEditingController(text: profileProvider.email);
    _bioController = TextEditingController(text: profileProvider.bio ?? '');
    _phoneController = TextEditingController(text: profileProvider.specialization ?? '');
    _currentPhotoUrl = profileProvider.photoUrl;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        // Compress image to ensure it's under 500KB
        final compressedFile = await _compressImage(pickedFile.path);
        
        if (compressedFile != null) {
          setState(() {
            _profileImage = compressedFile;
          });
          
          // Show file size info
          final fileSize = await compressedFile.length();
          print('✅ Image compressed to: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        }
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<File?> _compressImage(String imagePath) async {
    try {
      final targetPath = '${(await getTemporaryDirectory()).path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Compress with quality settings to target < 500KB
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 85, // Good balance between quality and size
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final fileSize = await result.length();
        print('📦 Original size: Unknown, Compressed size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        
        // If still larger than 500KB, compress more aggressively
        if (fileSize > 500 * 1024) {
          print('⚠️ File still > 500KB, compressing more...');
          final aggressiveResult = await FlutterImageCompress.compressAndGetFile(
            result.path,
            targetPath,
            quality: 60,
            minWidth: 512,
            minHeight: 512,
            format: CompressFormat.jpeg,
          );
          
          if (aggressiveResult != null) {
            final aggressiveFileSize = await aggressiveResult.length();
            print('✅ Aggressively compressed to: ${(aggressiveFileSize / 1024).toStringAsFixed(2)} KB');
            return File(aggressiveResult.path);
          }
        }
        
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      print('💾 Starting profile update...');
      print('📝 Display Name: ${_displayNameController.text.trim()}');
      print('📧 Email: ${_emailController.text.trim()}');
      print('📄 Bio: ${_bioController.text.trim()}');
      print('📱 Specialization: ${_phoneController.text.trim()}');
      
      // Prepare updates
      final updates = <String, dynamic>{
        'displayName': _displayNameController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'specialization': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      };

      // Upload image if selected
      if (_profileImage != null) {
        print('🖼️ Profile image selected, size: ${await _profileImage!.length()} bytes');
        print('☁️ Uploading image to Cloudinary...');
        
        try {
          final cloudinaryService = CloudinaryService();
          final imageUrl = await cloudinaryService.uploadProfilePhoto(_profileImage!);
          
          if (imageUrl != null) {
            updates['photoUrl'] = imageUrl;
            print('✅ Image uploaded successfully to Cloudinary: $imageUrl');
          }
        } catch (e) {
          print('❌ Image upload failed: $e');
          // Continue with other updates even if image upload fails
        }
      }

      print('🌐 Sending update request to backend...');
      
      // Call API to update profile
      final response = await ApiService.updateUserProfile(user.uid, updates);

      print('📊 API Response: $response');

      if (response['success'] == true) {
        print('✅ Profile update successful on server');
        
        // Clear the cached profile to force reload
        ApiService.clearUserProfileCache();
        
        // Reload profile data
        final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
        await profileProvider.loadUserProfile();
        
        print('✅ Profile reloaded from server');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        print('❌ Profile update failed: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _currentPhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildAvatarInitials();
                                },
                              ),
                            )
                          : _buildAvatarInitials(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Display Name Field
              _buildTextField(
                controller: _displayNameController,
                label: 'Display Name',
                hint: 'Enter your display name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bio Field
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell us about yourself',
                icon: Icons.note_alt,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Phone/Specialization Field
              _buildTextField(
                controller: _phoneController,
                label: 'Phone / Specialization',
                hint: 'Enter phone number or specialization',
                icon: Icons.phone,
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitials() {
    final displayName = _displayNameController.text;
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
