import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/api_service.dart';
import '../../constants/colors.dart';

class TherapistVerificationScreen extends StatefulWidget {
  const TherapistVerificationScreen({super.key});

  @override
  State<TherapistVerificationScreen> createState() => _TherapistVerificationScreenState();
}

class _TherapistVerificationScreenState extends State<TherapistVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isSubmitting = false;
  
  // Document files
  File? _nationalIdFile;
  File? _plusTwoCertificateFile;
  File? _undergraduateCertificateFile;
  File? _postgraduateCertificateFile;
  File? _phdCertificateFile;
  
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  // Max file size: 100KB
  static const int MAX_FILE_SIZE = 100 * 1024; // 100KB in bytes
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Verify Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Document Verification',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Upload your documents for verification. All documents must be under 100KB and in JPG, PNG, or PDF format.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, 
                                  color: AppColors.primary, 
                                  size: 20
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'National ID Card is mandatory',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Other documents are optional',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Document Upload Sections
                  _buildDocumentSection(
                    'National ID Card',
                    'Required',
                    Icons.badge,
                    _nationalIdFile,
                    () => _pickDocument('national_id'),
                    () => _viewDocument('national_id'),
                    true,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    '+2 Certificate',
                    'Optional',
                    Icons.school,
                    _plusTwoCertificateFile,
                    () => _pickDocument('plus_two'),
                    () => _viewDocument('plus_two'),
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'Undergraduate Certificate',
                    'Optional',
                    Icons.menu_book,
                    _undergraduateCertificateFile,
                    () => _pickDocument('undergraduate'),
                    () => _viewDocument('undergraduate'),
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'Postgraduate Certificate',
                    'Optional',
                    Icons.menu_book,
                    _postgraduateCertificateFile,
                    () => _pickDocument('postgraduate'),
                    () => _viewDocument('postgraduate'),
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'PhD Certificate',
                    'Optional',
                    Icons.psychology,
                    _phdCertificateFile,
                    () => _pickDocument('phd'),
                    () => _viewDocument('phd'),
                    false,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit for Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
  
  Widget _buildDocumentSection(
    String title,
    String subtitle,
    IconData icon,
    File? file,
    VoidCallback onPick,
    VoidCallback onView,
    bool isRequired,
  ) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.success : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: file != null 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                file != null ? Icons.check_circle : icon,
                color: file != null ? AppColors.success : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Required',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.file_present,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Document uploaded',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                if (file == null)
                  IconButton(
                    onPressed: onPick,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  )
                else ...[
                  IconButton(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility),
                    color: AppColors.primary,
                    tooltip: 'View',
                  ),
                  IconButton(
                    onPressed: onPick,
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primary,
                    tooltip: 'Replace',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickDocument(String docType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        
        // Check file size
        if (fileSize > MAX_FILE_SIZE) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('File Too Large'),
                content: Text(
                  'The selected file is ${(fileSize / 1024).toStringAsFixed(1)}KB. '
                  'Maximum file size is ${MAX_FILE_SIZE ~/ 1024}KB.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }
        
        // Set the file
        setState(() {
          switch (docType) {
            case 'national_id':
              _nationalIdFile = file;
              break;
            case 'plus_two':
              _plusTwoCertificateFile = file;
              break;
            case 'undergraduate':
              _undergraduateCertificateFile = file;
              break;
            case 'postgraduate':
              _postgraduateCertificateFile = file;
              break;
            case 'phd':
              _phdCertificateFile = file;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _viewDocument(String docType) {
    File? file;
    String title = '';
    
    switch (docType) {
      case 'national_id':
        file = _nationalIdFile;
        title = 'National ID Card';
        break;
      case 'plus_two':
        file = _plusTwoCertificateFile;
        title = '+2 Certificate';
        break;
      case 'undergraduate':
        file = _undergraduateCertificateFile;
        title = 'Undergraduate Certificate';
        break;
      case 'postgraduate':
        file = _postgraduateCertificateFile;
        title = 'Postgraduate Certificate';
        break;
      case 'phd':
        file = _phdCertificateFile;
        title = 'PhD Certificate';
        break;
    }
    
    if (file != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file!,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  Future<void> _submitVerification() async {
    // Validate required documents
    if (_nationalIdFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Document'),
          content: const Text('Please upload your National ID Card. It is mandatory for verification.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Confirm submission
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Verification'),
        content: const Text(
          'Are you sure you want to submit your documents for verification? '
          'This will send your application to the admin for review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      print('📤 Uploading verification documents...');
      
      // Upload documents to Cloudinary
      Map<String, String> documentUrls = {};
      
      // Upload National ID (mandatory)
      if (_nationalIdFile != null) {
        print('☁️ Uploading National ID...');
        final url = await _cloudinaryService.uploadProfilePhoto(_nationalIdFile!);
        if (url != null) {
          documentUrls['nationalId'] = url;
          print('✅ National ID uploaded: $url');
        }
      }
      
      // Upload optional certificates
      if (_plusTwoCertificateFile != null) {
        print('☁️ Uploading +2 Certificate...');
        final url = await _cloudinaryService.uploadProfilePhoto(_plusTwoCertificateFile!);
        if (url != null) documentUrls['plusTwo'] = url;
      }
      
      if (_undergraduateCertificateFile != null) {
        print('☁️ Uploading Undergraduate Certificate...');
        final url = await _cloudinaryService.uploadProfilePhoto(_undergraduateCertificateFile!);
        if (url != null) documentUrls['undergraduate'] = url;
      }
      
      if (_postgraduateCertificateFile != null) {
        print('☁️ Uploading Postgraduate Certificate...');
        final url = await _cloudinaryService.uploadProfilePhoto(_postgraduateCertificateFile!);
        if (url != null) documentUrls['postgraduate'] = url;
      }
      
      if (_phdCertificateFile != null) {
        print('☁️ Uploading PhD Certificate...');
        final url = await _cloudinaryService.uploadProfilePhoto(_phdCertificateFile!);
        if (url != null) documentUrls['phd'] = url;
      }
      
      print('📦 All documents uploaded: $documentUrls');
      
      // Submit verification to MongoDB
      print('💾 Submitting verification to database...');
      final response = await ApiService.submitVerification(
        currentUser.uid,
        documentUrls,
      );
      
      if (response['success']) {
        print('✅ Verification submitted successfully');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Verification Submitted'),
              content: const Text(
                'Your verification application has been submitted successfully. '
                'The admin will review your documents and get back to you soon.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to profile
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to submit verification');
      }
    } catch (e) {
      print('❌ Error submitting verification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
