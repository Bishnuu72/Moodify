import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class AdminVerificationReviewScreen extends StatefulWidget {
  final Map<String, dynamic> therapist;
  
  const AdminVerificationReviewScreen({
    super.key,
    required this.therapist,
  });

  @override
  State<AdminVerificationReviewScreen> createState() => _AdminVerificationReviewScreenState();
}

class _AdminVerificationReviewScreenState extends State<AdminVerificationReviewScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _verificationData;
  
  @override
  void initState() {
    super.initState();
    _loadVerificationDetails();
  }
  
  Future<void> _loadVerificationDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('📊 Loading verification for therapist: ${widget.therapist['displayName']}');
      print('🆔 User ID: ${widget.therapist['userId']}');
      
      // Fetch verification data from MongoDB
      final response = await ApiService.getVerificationStatus(widget.therapist['userId']);
      
      print('📡 API Response: $response');
      
      if (response['success']) {
        setState(() {
          _verificationData = response['data'];
          print('✅ Verification loaded successfully');
          print('📄 Documents: ${_verificationData?['documents']}');
          _isLoading = false;
        });
      } else {
        print('❌ Failed to load verification: ${response['message']}');
        throw Exception('Failed to load verification details');
      }
    } catch (e) {
      print('❌ Error loading verification details: $e');
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
        title: const Text(
          'Verification Review',
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
                  // Therapist Info Card
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: widget.therapist['photoUrl'] != null
                                ? NetworkImage(widget.therapist['photoUrl'])
                                : null,
                            child: widget.therapist['photoUrl'] == null
                                ? Text(
                                    (widget.therapist['displayName'] ?? 'T')[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.therapist['displayName'] ?? 'Therapist',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.therapist['specialization'] ?? 'Therapist',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.therapist['email'] ?? '',
                                  style: const TextStyle(
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
                  ),
                  const SizedBox(height: 24),
                  
                  // Instructions
                  FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Review Documents',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Carefully review all documents before approving or rejecting.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
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
                  
                  // Document Sections
                  const Text(
                    'Submitted Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDocumentCard(
                    'National ID Card',
                    _verificationData?['documents']?['nationalId'],
                    Icons.badge,
                    true,
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentCard(
                    '+2 Certificate',
                    _verificationData?['documents']?['plusTwo'],
                    Icons.school,
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentCard(
                    'Undergraduate Certificate',
                    _verificationData?['documents']?['undergraduate'],
                    Icons.menu_book,
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentCard(
                    'Postgraduate Certificate',
                    _verificationData?['documents']?['postgraduate'],
                    Icons.menu_book,
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentCard(
                    'PhD Certificate',
                    _verificationData?['documents']?['phd'],
                    Icons.psychology,
                    false,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleVerification(false),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleVerification(true),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
    );
  }
  
  Widget _buildDocumentCard(String title, String? imageUrl, IconData icon, bool isRequired) {
    return FadeInUp(
      child: GestureDetector(
        onTap: imageUrl != null ? () => _viewDocument(title, imageUrl) : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: imageUrl != null 
                  ? AppColors.success.withOpacity(0.3)
                  : Colors.grey.shade300,
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
                  color: imageUrl != null 
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  imageUrl != null ? Icons.check_circle : icon,
                  color: imageUrl != null ? AppColors.success : Colors.grey,
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
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 9,
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
                      imageUrl != null ? 'Tap to view' : 'Not submitted',
                      style: TextStyle(
                        fontSize: 12,
                        color: imageUrl != null ? AppColors.success : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                imageUrl != null ? Icons.visibility : Icons.lock,
                color: imageUrl != null ? AppColors.primary : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _viewDocument(String title, String imageUrl) {
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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
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
  
  void _handleVerification(bool approved) async {
    String? rejectionReason;
    
    // If rejecting, ask for reason
    if (!approved) {
      final reasonController = TextEditingController();
      
      final reasonGiven = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rejection Reason'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for rejecting this verification:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g., Document is unclear, expired, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      
      if (reasonGiven != true) return;
      rejectionReason = reasonController.text.trim();
      
      if (rejectionReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a rejection reason'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    
    // Confirm action
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approved ? 'Approve Verification' : 'Reject Verification'),
        content: Text(
          approved
              ? 'Are you sure you want to approve this therapist\'s verification?'
              : 'Are you sure you want to reject this therapist\'s verification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: approved ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(approved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update verification status in MongoDB
      final response = await ApiService.reviewVerification(
        widget.therapist['userId'],
        approved,
        rejectionReason,
      );
      
      if (response['success']) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(approved ? 'Approved!' : 'Rejected'),
              content: Text(
                approved
                    ? 'Therapist has been verified successfully.'
                    : 'Verification has been rejected.${rejectionReason != null ? '\nReason: $rejectionReason' : ''}',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to admin home
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to review verification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
}
