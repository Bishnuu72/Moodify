# ✅ Home Page Display Name & Mood Likes/Comments - IMPLEMENTATION PLAN

## 🎯 Issues to Fix

### 1. Display Full Name Instead of Email Prefix ✅ FIXED
**Problem:** Home page shows "Hello, [email_prefix]" instead of user's full name from MongoDB

**Solution:** 
- Updated `home_screen.dart` to use `UserProfileProvider`
- Now displays `displayName` from MongoDB
- Falls back to email prefix if displayName not available

---

## 📝 Implementation Plan for Likes & Comments

### Phase 1: Update MongoDB Schema

#### 1. Add Fields to MoodEntry Model
```javascript
// backend/models/MoodEntry.js
const moodEntrySchema = new mongoose.Schema({
  userId: { type: String, required: true },
  mood: { type: String, required: true },
  emotionScore: { type: Number, min: 0, max: 10 },
  note: { type: String },
  tags: [{ type: String }],
  
  // NEW FIELDS FOR SOCIAL FEATURES
  likes: [{
    type: String,  // Array of userIds who liked this post
  }],
  comments: [{
    userId: { type: String, required: true },
    userName: { type: String, required: true },
    text: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  }],
  likesCount: { type: Number, default: 0 },
  commentsCount: { type: Number, default: 0 },
}, {
  timestamps: true,
});
```

### Phase 2: Backend API Endpoints

#### 2.1 Like/Unlike Mood Endpoint
```javascript
// backend/controllers/moodController.js

// @desc    Toggle like on a mood entry
// @route   POST /api/moods/:id/like
const toggleLike = async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.body;

    const moodEntry = await MoodEntry.findById(id);
    
    if (!moodEntry) {
      return res.status(404).json({ success: false, message: 'Mood entry not found' });
    }

    const likeIndex = moodEntry.likes.indexOf(userId);
    
    if (likeIndex > -1) {
      // Unlike
      moodEntry.likes.splice(likeIndex, 1);
      moodEntry.likesCount = moodEntry.likes.length;
    } else {
      // Like
      moodEntry.likes.push(userId);
      moodEntry.likesCount = moodEntry.likes.length;
    }

    await moodEntry.save();

    res.json({
      success: true,
      data: moodEntry,
      message: likeIndex > -1 ? 'Unliked successfully' : 'Liked successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling like',
      error: error.message,
    });
  }
};

// @desc    Add comment to mood entry
// @route   POST /api/moods/:id/comment
const addComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { userId, userName, text } = req.body;

    if (!text || !userId) {
      return res.status(400).json({
        success: false,
        message: 'Text and userId are required',
      });
    }

    const moodEntry = await MoodEntry.findById(id);
    
    if (!moodEntry) {
      return res.status(404).json({ success: false, message: 'Mood entry not found' });
    }

    const comment = {
      userId,
      userName,
      text,
    };

    moodEntry.comments.push(comment);
    moodEntry.commentsCount = moodEntry.comments.length;

    await moodEntry.save();

    res.status(201).json({
      success: true,
      data: moodEntry,
      message: 'Comment added successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding comment',
      error: error.message,
    });
  }
};

// @desc    Delete comment from mood entry
// @route   DELETE /api/moods/:id/comments/:commentId
const deleteComment = async (req, res) => {
  try {
    const { id, commentId } = req.params;

    const moodEntry = await MoodEntry.findById(id);
    
    if (!moodEntry) {
      return res.status(404).json({ success: false, message: 'Mood entry not found' });
    }

    const comment = moodEntry.comments.id(commentId);
    
    if (!comment) {
      return res.status(404).json({ success: false, message: 'Comment not found' });
    }

    comment.deleteOne();
    moodEntry.commentsCount = moodEntry.comments.length;
    await moodEntry.save();

    res.json({
      success: true,
      message: 'Comment deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting comment',
      error: error.message,
    });
  }
};
```

#### 2.2 Update Routes
```javascript
// backend/routes/moodRoutes.js
router.post('/:id/like', toggleLike);
router.post('/:id/comment', addComment);
router.delete('/:id/comments/:commentId', deleteComment);
```

### Phase 3: Flutter API Service

```dart
// lib/services/api_service.dart

// Toggle like on a mood entry
static Future<Map<String, dynamic>> toggleLike(String moodId, String userId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/moods/$moodId/like'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle like');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

// Add comment to a mood entry
static Future<Map<String, dynamic>> addComment(
  String moodId,
  String userId,
  String userName,
  String text,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/moods/$moodId/comment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'userName': userName,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add comment');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

// Delete comment
static Future<Map<String, dynamic>> deleteComment(String moodId, String commentId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/moods/$moodId/comments/$commentId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete comment');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

### Phase 4: Update Mood Wall UI

#### 4.1 Update Mood Card Widget
```dart
// lib/screens/mood_wall/mood_wall_screen.dart

Widget _buildMoodCard(dynamic mood) {
  final bool isLiked = mood['likes']?.contains(currentUserId) ?? false;
  final int likesCount = mood['likesCount'] ?? 0;
  final List<dynamic> comments = mood['comments'] ?? [];

  return Card(
    child: Column(
      children: [
        // ... existing mood content ...
        
        // Like and Comment Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Like Button
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: () => _handleLike(mood['_id']),
            ),
            Text('$likesCount likes'),
            
            // Comment Button
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: () => _showCommentsDialog(mood),
            ),
            Text('${comments.length} comments'),
          ],
        ),
        
        // Show recent comments
        if (comments.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: comments.take(3).map((comment) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '${comment['userName']} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: comment['text']),
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ],
    ),
  );
}

void _handleLike(String moodId) async {
  try {
    final result = await ApiService.toggleLike(moodId, currentUserId);
    // Refresh mood list
    _loadAllMoods();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

void _showCommentsDialog(dynamic mood) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Comments'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: mood['comments']?.length ?? 0,
          itemBuilder: (context, index) {
            final comment = mood['comments'][index];
            return ListTile(
              title: Text(comment['userName']),
              subtitle: Text(comment['text']),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
```

---

## 🚀 Testing Steps

### Test 1: Verify Display Name
1. Register with Full Name: "John Doe"
2. Go to Home page
3. Should show: "Hello, John Doe 👋"

### Test 2: Test Like Functionality
1. Create a mood entry
2. View it in Mood Wall
3. Click heart icon
4. Count should increment
5. Heart should turn red

### Test 3: Test Comment Functionality
1. Create a mood entry
2. Click comment icon
3. Add a comment
4. Comment should appear below the post
5. Other users can see and add comments

---

## 📁 Files to Modify

### Backend:
1. `backend/models/MoodEntry.js` - Add likes and comments fields
2. `backend/controllers/moodController.js` - Add like/comment methods
3. `backend/routes/moodRoutes.js` - Add new routes

### Flutter:
4. `lib/services/api_service.dart` - Add API methods
5. `lib/screens/home/home_screen.dart` - Use display name ✅ DONE
6. `lib/screens/mood_wall/mood_wall_screen.dart` - Add like/comment UI

---

## ✨ Summary

### ✅ Completed:
1. Home page now displays user's full name from MongoDB

### 🔄 To Be Implemented:
2. Add likes functionality to mood posts
3. Add comments functionality to mood posts
4. Update MongoDB schema
5. Create backend API endpoints
6. Update Flutter UI

---

**This plan provides a complete implementation guide for adding social features to mood posts!** 🚀
