import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminWellnessScreen extends StatefulWidget {
  const AdminWellnessScreen({super.key});

  @override
  State<AdminWellnessScreen> createState() => _AdminWellnessScreenState();
}

class _AdminWellnessScreenState extends State<AdminWellnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> _wellnessActivities = [];
  bool _isLoading = true;
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadWellnessActivities();
  }
  
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _getCategoryFromIndex(_tabController.index);
      });
      _loadWellnessActivities();
    }
  }
  
  String _getCategoryFromIndex(int index) {
    switch (index) {
      case 0: return 'breathing';
      case 1: return 'meditation';
      case 2: return 'journaling';
      case 3: return 'relaxation';
      default: return 'breathing';
    }
  }
  
  Future<void> _loadWellnessActivities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final response = await ApiService.getAdminWellnessActivities(
          currentUser.uid,
          category: _selectedCategory,
        );
        
        if (response['success'] == true) {
          setState(() {
            _wellnessActivities = List<Map<String, dynamic>>.from(response['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading wellness activities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load activities: $e')),
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
  
  Future<void> _deleteActivity(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
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
        final response = await ApiService.deleteWellnessActivity(id);
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity deleted successfully')),
            );
            _loadWellnessActivities();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete activity: $e')),
          );
        }
      }
    }
  }
  
  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWellnessActivityScreen(
          category: _selectedCategory ?? 'breathing',
          onActivityCreated: _loadWellnessActivities,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wellness Tools Management'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.air), text: 'Breathing'),
            Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
            Tab(icon: Icon(Icons.edit_note), text: 'Journaling'),
            Tab(icon: Icon(Icons.spa), text: 'Relaxation'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreate,
            tooltip: 'Create New Activity',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _wellnessActivities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first ${_selectedCategory ?? ''} activity',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadWellnessActivities,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _wellnessActivities.length,
                      itemBuilder: (context, index) {
                        final activity = _wellnessActivities[index];
                        return _buildActivityCard(activity);
                      },
                    ),
                  ),
      ),
    );
  }
  
  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final hasMusic = activity['musicUrl'] != null && activity['musicUrl'].isNotEmpty;
    final isJournaling = activity['category'] == 'journaling';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Navigate to edit
                    } else if (value == 'delete') {
                      _deleteActivity(activity['_id']);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activity['description'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (activity['duration'] != null)
                  Chip(
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: Text('${activity['duration']} min'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                if (hasMusic)
                  Chip(
                    avatar: const Icon(Icons.music_note, size: 16),
                    label: const Text('Has Music'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                if (isJournaling && activity['journalQuestion'] != null)
                  Chip(
                    avatar: const Icon(Icons.question_answer, size: 16),
                    label: const Text('Has Question'),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                  ),
                Chip(
                  label: Text(activity['difficulty']?.toUpperCase() ?? 'BEGINNER'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Create Wellness Activity Screen
class CreateWellnessActivityScreen extends StatefulWidget {
  final String category;
  final VoidCallback onActivityCreated;
  
  const CreateWellnessActivityScreen({
    super.key,
    required this.category,
    required this.onActivityCreated,
  });

  @override
  State<CreateWellnessActivityScreen> createState() => _CreateWellnessActivityScreenState();
}

class _CreateWellnessActivityScreenState extends State<CreateWellnessActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '5');
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _journalQuestionController = TextEditingController();
  final TextEditingController _musicTitleController = TextEditingController();
  final TextEditingController _musicDurationController = TextEditingController();
  
  String _selectedDifficulty = 'beginner';
  File? _selectedAudioFile;
  bool _isMusicOptional = false;
  bool _isUploading = false;
  bool _isLoading = false;
  
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  Future<void> _pickAudioFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Pick from files (image_picker can handle any file type)
      final XFile? result = await picker.pickMedia(
        imageQuality: 100, // Not compressing since it's audio
      );
      
      if (result != null) {
        setState(() {
          _selectedAudioFile = File(result.path);
          if (_musicTitleController.text.isEmpty) {
            _musicTitleController.text = result.name.replaceAll('.mp3', '').replaceAll('.wav', '').replaceAll('.m4a', '');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick audio file: $e')),
        );
      }
    }
  }
  
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user logged in');
      }
      
      // Upload audio if selected
      String? musicUrl;
      int? musicDuration;
      
      if (_selectedAudioFile != null) {
        setState(() {
          _isUploading = true;
        });
        
        try {
          musicUrl = await _cloudinaryService.uploadAudioFile(
            _selectedAudioFile!,
            title: _musicTitleController.text,
          );
          
          // Get audio duration (simplified - in real app, use audio metadata)
          musicDuration = int.tryParse(_musicDurationController.text) ?? null;
        } catch (e) {
          throw Exception('Failed to upload audio: $e');
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }
      
      // Prepare activity data
      final activityData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': widget.category,
        'duration': int.tryParse(_durationController.text) ?? 5,
        'instructions': _instructionsController.text.trim(),
        'difficulty': _selectedDifficulty,
        'isMusicOptional': _isMusicOptional,
        'createdBy': currentUser.uid,
        'tags': [widget.category, 'wellness'],
      };
      
      // Add music data if uploaded
      if (musicUrl != null) {
        activityData['musicUrl'] = musicUrl;
        activityData['musicTitle'] = _musicTitleController.text.trim();
        if (musicDuration != null) {
          activityData['musicDuration'] = musicDuration;
        }
      }
      
      // Add journal question if journaling
      if (widget.category == 'journaling') {
        activityData['journalQuestion'] = _journalQuestionController.text.trim();
      }
      
      // Create activity
      final response = await ApiService.createWellnessActivity(activityData);
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity created successfully!')),
          );
          widget.onActivityCreated();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error creating activity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create activity: $e')),
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
    final isJournaling = widget.category == 'journaling';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create ${widget.category.toUpperCase()} Activity'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading || _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_isUploading ? 'Uploading audio...' : 'Creating activity...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Basic Information', [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Settings', [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (min)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDifficulty,
                              decoration: const InputDecoration(
                                labelText: 'Difficulty',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDifficulty = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Instructions',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.list),
                        ),
                        maxLines: 4,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Music/Audio (Optional)', [
                      GestureDetector(
                        onTap: _pickAudioFile,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedAudioFile != null ? Icons.audio_file : Icons.add,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedAudioFile != null
                                      ? 'Selected: ${_selectedAudioFile!.path.split('/').last}'
                                      : 'Tap to select audio file',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedAudioFile != null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _musicTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Music Title',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.music_note),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _musicDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Music Duration (seconds)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Make music optional for users'),
                          subtitle: const Text('Users can choose to skip the audio'),
                          value: _isMusicOptional,
                          onChanged: (value) {
                            setState(() {
                              _isMusicOptional = value;
                            });
                          },
                        ),
                      ],
                    ]),
                    if (isJournaling) ...[
                      const SizedBox(height: 24),
                      _buildSection('Journal Question', [
                        TextFormField(
                          controller: _journalQuestionController,
                          decoration: const InputDecoration(
                            labelText: 'Question for users to answer *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.question_answer),
                            hintText: 'e.g., What are you grateful for today?',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (isJournaling && (value == null || value.trim().isEmpty)) {
                              return 'Journal question is required';
                            }
                            return null;
                          },
                        ),
                      ]),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create Activity',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _journalQuestionController.dispose();
    _musicTitleController.dispose();
    _musicDurationController.dispose();
    super.dispose();
  }
}
