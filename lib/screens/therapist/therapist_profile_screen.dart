import'dart:io';
import'package:flutter/material.dart';
import'package:image_picker/image_picker.dart';
import'package:provider/provider.dart';
import'package:animate_do/animate_do.dart';
import'../../services/auth_service.dart';
import'../../services/api_service.dart';
import'../../services/cloudinary_service.dart';
import'../../constants/colors.dart';
import'../auth/login_screen.dart';
import'therapist_verification_screen.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  
  bool _isEditing = false;
  String? _profileImage;
  String? _currentImageUrl;
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic>? _therapistData;
  
  // Verification status tracking
  bool _isVerified = false;           // true if approved
  String? _verificationStatus;        // 'pending', 'approved', 'rejected', or null
  
  // Store original values to detect changes
  String? _originalName;
  String? _originalEmail;
  String? _originalPhone;
  String? _originalSpecialization;
  String? _originalExperience;
  String? _originalBio;
  String? _originalLicense;
  String? _originalEducation;
  String? _originalPhotoUrl;
  
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  @override
  void initState() {
    super.initState();
    _loadTherapistProfile();
    
    // Listen for verification status changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check verification status on app start
      print('🔍 Initial verification status check');
    });
  }
  
  Future<void> _loadTherapistProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get AuthService from Provider to ensure we use the same instance
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      print('📊 Loading therapist profile...');
      print('👤 Auth current user: ${currentUser?.uid ?? "NULL"}');
      
      // If no user, wait a bit for auth to initialize
      if (currentUser == null) {
        print('⏳ No user found, waiting 1 second for auth...');
        await Future.delayed(Duration(seconds: 1));
        
        final retryUser = authService.currentUser;
        print('👤 Retry auth check: ${retryUser?.uid ?? "NULL"}');
        
        if (retryUser == null) {
          throw Exception('Please log in to access your profile');
        }
        
        // Use the retried user
        return _loadProfileForUser(retryUser);
      }
      
      // User is ready, load profile
      return _loadProfileForUser(currentUser);
    } catch (e) {
      print('❌ Error loading therapist profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }
  
  Future<void> _handleRefresh() async {
    print('🔄 Pull-to-refresh triggered');
    await _loadTherapistProfile();
  }
  
  Future<void> _loadProfileForUser(dynamic currentUser) async {
    try {
      print('📊 Fetching therapist profile for user: ${currentUser.uid}');
      final response = await ApiService.getUserProfile(currentUser.uid);
      
      if (response['success']) {
        final userData = response['data'];
        
        setState(() {
          _therapistData = userData;
          
          // Check if user is verified
          _isVerified = userData['isVerified'] == true;  
          _verificationStatus = userData['verificationStatus'];  // 'pending', 'approved', 'rejected', or null
          
          print('📊 Verification status:');
          print('   - isVerified: ${_isVerified}');
          print('   - verificationStatus: $_verificationStatus');
          
          if (_isVerified && _verificationStatus == 'verified') {
            print('   ✓ Account is VERIFIED');
          } else if (_verificationStatus == 'pending') {
            print('   ⏳ Account verification is PENDING');
          } else if (_verificationStatus == 'rejected') {
            print('   ✗ Account verification was REJECTED');
          } else {
            print('   → Account not verified yet (can submit)');
          }
          
          // Load data into controllers
          _nameController.text = userData['displayName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _specializationController.text = userData['specialization'] ?? 'General Therapy';
          _experienceController.text = userData['experience'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _licenseController.text = userData['licenseNumber'] ?? '';
          _educationController.text = userData['education'] ?? '';
          
          // Keep network URL separate from local file
          _currentImageUrl = userData['photoUrl'];  // This is a network URL
          _profileImage = null;  // Clear local file - only set when user picks new image
          
          // Store original values
          _originalName = userData['displayName'] ?? '';
          _originalEmail = userData['email'] ?? '';
          _originalPhone = userData['phone'] ?? '';
          _originalSpecialization = userData['specialization'] ?? 'General Therapy';
          _originalExperience = userData['experience'] ?? '';
          _originalBio = userData['bio'] ?? '';
          _originalLicense = userData['licenseNumber'] ?? '';
          _originalEducation = userData['education'] ?? '';
          _originalPhotoUrl = userData['photoUrl'];
          
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      print('❌ Error loading therapist profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }
  
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
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }
  
  Future<void> _uploadProfileImage() async {
    if (_profileImage == null || !_profileImage!.endsWith('.jpg') && !_profileImage!.endsWith('.png')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid image file')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final imageFile = File(_profileImage!);
      final uploadedUrl = await _cloudinaryService.uploadProfilePhoto(imageFile);
      
      if (uploadedUrl != null) {
        setState(() {
          _currentImageUrl = uploadedUrl;
          _profileImage = null; // Clear local file after upload
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
  
  Future<void> _saveChanges() async {
    try {
      // Get AuthService from Provider to ensure we use the same instance
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      print('📊 Checking auth state before save...');
      print('👤 Current user: ${currentUser?.uid ?? "NULL"}');
      
      // Wait briefly if user is null (auth still initializing)
      if (currentUser == null) {
        print('⏳ Auth state not ready, waiting 500ms...');
        await Future.delayed(Duration(milliseconds: 500));
        
        // Check again
        final retryUser = authService.currentUser;
        if (retryUser == null) {
          throw Exception('User authentication not ready. Please try again in a moment.');
        }
        // Use the retried user
        return _saveChangesWithUser(retryUser);
      }
      
      // User is ready, proceed with save
      return _saveChangesWithUser(currentUser);
    } catch (e) {
      print('❌ Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _saveChangesWithUser(dynamic currentUser) async {
    try {
      // Build updates object with only changed fields
      final Map<String, dynamic> updates = {};
      
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newSpecialization = _specializationController.text.trim();
      final newExperience = _experienceController.text.trim();
      final newBio = _bioController.text.trim();
      final newLicense = _licenseController.text.trim();
      final newEducation = _educationController.text.trim();
      
      // Check what changed
      if (newName != _originalName) updates['displayName'] = newName;
      if (newEmail != _originalEmail && newEmail.isNotEmpty) updates['email'] = newEmail;
      if (newPhone != _originalPhone) updates['phone'] = newPhone;
      if (newSpecialization != _originalSpecialization) updates['specialization'] = newSpecialization;
      if (newExperience != _originalExperience) updates['experience'] = newExperience;
      if (newBio != _originalBio) updates['bio'] = newBio;
      if (newLicense != _originalLicense) updates['licenseNumber'] = newLicense;
      if (newEducation != _originalEducation) updates['education'] = newEducation;
      
      // Upload new photo if selected (just like admin profile)
      String? newPhotoUrl;
      if (_profileImage != null) {
        print('☁️ Uploading new profile photo...');
        final imageFile = File(_profileImage!);
        newPhotoUrl = await _cloudinaryService.uploadProfilePhoto(imageFile);
        if (newPhotoUrl != null) {
          updates['photoUrl'] = newPhotoUrl;
          print('✅ Photo uploaded to Cloudinary: $newPhotoUrl');
        }
      } else if (_currentImageUrl != _originalPhotoUrl) {
        // If URL changed (from local preview), use it
        updates['photoUrl'] = _currentImageUrl;
      }
      
      if (updates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save')),
        );
        return;
      }
      
      print('💾 Saving therapist profile updates: $updates');
      final response = await ApiService.updateUserProfile(currentUser.uid, updates);
      
      if (response['success']) {
        if (mounted) {
          // Update original values to new values FIRST
          setState(() {
            _originalName = newName;
            _originalEmail = newEmail;
            _originalPhone = newPhone;
            _originalSpecialization = newSpecialization;
            _originalExperience = newExperience;
            _originalBio = newBio;
            _originalLicense = newLicense;
            _originalEducation = newEducation;
            if (newPhotoUrl != null) {
              _currentImageUrl = newPhotoUrl;
              _profileImage = null; // Clear local file
            }
            _originalPhotoUrl = _currentImageUrl;
            _isEditing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          print('✅ Profile saved successfully, clearing cache and reloading fresh data...');
          
          // Clear cache to force fresh fetch
          ApiService.clearUserCache(currentUser.uid);
          
          // Reload fresh data from MongoDB to ensure UI reflects database state
          await _loadTherapistProfile();
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
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
   if (_isLoading) {
     return Scaffold(
       backgroundColor: AppColors.background,
       appBar: AppBar(
         backgroundColor: Colors.transparent,
         elevation: 0,
         foregroundColor: AppColors.textPrimary,
       ),
       body: const Center(child: CircularProgressIndicator()),
     );
   }
   
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
        if (_isEditing) ...[
          IconButton(
            icon: _isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            onPressed: _isUploading ? null : _saveChanges,
            tooltip: 'Save Changes',
          ),
          const SizedBox(width: 8),
        ],
       IconButton(
        icon: Icon(_isEditing ? Icons.close : Icons.edit),
        onPressed: () {
         setState(() {
           _isEditing = !_isEditing;
         });
       },
      ),
     ],
    ),
  body: RefreshIndicator(
    onRefresh: _handleRefresh,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
            : _currentImageUrl != null
              ? NetworkImage(_currentImageUrl!) as ImageProvider
              : null,
          child: _profileImage == null && _currentImageUrl == null
            ? Text(
               (_nameController.text.isNotEmpty ? _nameController.text[0] : 'T').toUpperCase(),
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
            color: _isUploading ? Colors.grey : Colors.teal,
             shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
           ),
           padding: const EdgeInsets.all(8),
           child: _isUploading 
               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
               : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
         ),
       ],
      ),
     ),
    ),
    SizedBox(height: 10),
    if (_isEditing && _profileImage != null) ...[
      ElevatedButton.icon(
        onPressed: _uploadProfileImage,
        icon: Icon(_isUploading ? Icons.cloud_upload : Icons.check),
        label: Text(_isUploading ? 'Uploading...' : 'Upload New Photo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      SizedBox(height: 20),
    ],
   const SizedBox(height: 8),
     FadeInDown(
   delay: const Duration(milliseconds: 100),
     child: ValueListenableBuilder<TextEditingValue>(
       valueListenable: _nameController,
       builder: (context, value, _) {
         return Text(
           value.text.isEmpty ? 'Loading...' : value.text,
           style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
           ),
         );
       },
     ),
    ),
  const SizedBox(height:4),
    FadeInDown(
   delay: const Duration(milliseconds: 200),
     child: ValueListenableBuilder<TextEditingValue>(
       valueListenable: _specializationController,
       builder: (context, value, _) {
         return Text(
           value.text.isEmpty ? 'Therapist' : value.text,
           style: TextStyle(
              fontSize: 16,
            color: AppColors.textSecondary,
           ),
         );
       },
     ),
    ),
  const SizedBox(height:16),
  
  // Verification Status Display
  FadeInUp(
    delay: const Duration(milliseconds: 300),
    child: SizedBox(
      width: double.infinity,
      child: _buildVerificationWidget(),
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
       ],  // Container children
      ),   // Column in Container
     ),    // Container in FadeInUp
    ),     // FadeInUp in Column
   ],      // RefreshIndicator's SingleChildScrollView Column children
  ),       // Column
 ),        // SingleChildScrollView
),         // RefreshIndicator
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

Widget _buildVerificationWidget() {
  // State 1: VERIFIED - Show green badge
  if (_isVerified && _verificationStatus == 'verified') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            '✓ Verified',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
  
  // State 2: PENDING - Show submitted message
  if (_verificationStatus == 'pending') {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⏳ Submitted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'Your verification is pending admin review',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // State 3: REJECTED - Show rejected with reapply button
  if (_verificationStatus == 'rejected') {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cancel,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '✗ Rejected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TherapistVerificationScreen(),
              ),
            );
          },
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text(
            'Re-submit Verification',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
  
  // State 4: NOT SUBMITTED - Show verify account button
  return ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TherapistVerificationScreen(),
        ),
      );
    },
    icon: const Icon(Icons.verified_user, size: 20),
    label: const Text(
      'Verify Account',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
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
  _licenseController.dispose();
  _educationController.dispose();
  super.dispose();
}
}
