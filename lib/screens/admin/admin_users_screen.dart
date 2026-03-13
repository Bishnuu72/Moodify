import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getAllUsers();
      if (response['success'] == true) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) {
      return users;
    }
    
    return users.where((user) {
      final name = (user['displayName'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _handleDeleteUser(String userId, String userEmail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userEmail? This action cannot be undone.'),
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

    if (confirmed == true) {
      try {
        final response = await ApiService.deleteUser(userId);
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User deleted successfully')),
            );
            fetchUsers();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleSuspendUser(String userId, String userEmail, bool isCurrentlySuspended) async {
    if (isCurrentlySuspended) {
      // Unuspend user
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsuspend User'),
          content: Text('Do you want to unsuspend $userEmail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Unsuspend'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final response = await ApiService.unsuspendUser(userId);
          if (response['success'] == true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User unsuspended successfully')),
              );
              fetchUsers();
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to unsuspend user: $e')),
            );
          }
        }
      }
    } else {
      // Suspend user - show dialog
      await showDialog(
        context: context,
        builder: (context) => SuspendUserDialog(
          userId: userId,
          userEmail: userEmail,
          onSuspended: () {
            fetchUsers();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  void _handleEditUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            
            // User List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeInUp(
                      child: filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No users found'
                                        : 'No users match your search',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _buildUserCard(user);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['userId'] ?? '';
    final displayName = user['displayName'] ?? 'No Name';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'user';
    final isSuspended = user['isSuspended'] ?? false;
    final suspendedUntil = user['suspendedUntil'] != null 
        ? DateTime.parse(user['suspendedUntil']) 
        : null;
    
    // Check if suspension has expired
    final isCurrentlySuspended = isSuspended && 
        (suspendedUntil == null || suspendedUntil.isAfter(DateTime.now()));
    
    // Get verification status for therapists
    final isVerified = user['isVerified'] ?? false;
    final verificationStatus = user['verificationStatus']; // 'pending', 'approved', 'rejected', or null

    Color roleColor;
    switch (role) {
      case 'admin':
        roleColor = Colors.deepPurple;
        break;
      case 'therapist':
        roleColor = Colors.teal;
        break;
      default:
        roleColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: roleColor.withOpacity(0.1),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
        ),
        title: Text(
          displayName.isEmpty ? 'No Name' : displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                // Show verification status for therapists
                if (role == 'therapist')
                  const SizedBox(width: 8),
                if (role == 'therapist')
                  Flexible(
                    child: _buildVerificationBadge(isVerified, verificationStatus),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _handleEditUser(user);
                break;
              case 'suspend':
                _handleSuspendUser(userId, email, isCurrentlySuspended);
                break;
              case 'delete':
                _handleDeleteUser(userId, email);
                break;
            }
          },
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'suspend', 
              child: Text(isCurrentlySuspended ? 'Unsuspend' : 'Suspend'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVerificationBadge(bool isVerified, String? verificationStatus) {
    // Verified therapists
    if (isVerified && verificationStatus == 'verified') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 12,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }
    
    // Pending verification
    if (verificationStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 12,
              color: Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
    
    // Not verified (no status or rejected)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 12,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            'Unverified',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Suspend User Dialog
class SuspendUserDialog extends StatefulWidget {
  final String userId;
  final String userEmail;
  final VoidCallback onSuspended;

  const SuspendUserDialog({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.onSuspended,
  });

  @override
  State<SuspendUserDialog> createState() => _SuspendUserDialogState();
}

class _SuspendUserDialogState extends State<SuspendUserDialog> {
  DateTime? _selectedDate;
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _suspendUser() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for suspension')),
      );
      return;
    }

    try {
      final response = await ApiService.suspendUser(
        widget.userId,
        suspendedUntil: _selectedDate,
        reason: _reasonController.text.trim(),
      );
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User suspended successfully')),
          );
          widget.onSuspended();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to suspend user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suspend User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suspending: ${widget.userEmail}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for suspension',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Suspension End Date (optional):'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'No end date (indefinite)',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _suspendUser,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Suspend'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

// Edit User Dialog
class EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['displayName'] ?? '';
    _emailController.text = widget.user['email'] ?? '';
    _selectedRole = widget.user['role'] ?? 'user';
  }

  Future<void> _saveChanges() async {
    try {
      final updates = <String, dynamic>{};
      
      if (_nameController.text.trim().isNotEmpty) {
        updates['displayName'] = _nameController.text.trim();
      }
      
      if (_emailController.text.trim().isNotEmpty && 
          _emailController.text.trim() != widget.user['email']) {
        updates['email'] = _emailController.text.trim();
      }
      
      if (_selectedRole.isNotEmpty && _selectedRole != widget.user['role']) {
        updates['role'] = _selectedRole;
      }

      if (updates.isNotEmpty) {
        final response = await ApiService.updateUserProfile(
          widget.user['userId'],
          updates,
        );
        
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')),
            );
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Text('Role:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'therapist', child: Text('Therapist')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
