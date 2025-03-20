import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/post_model.dart';
import '../services/storage_service.dart';
import '../pages/chat_detail_page.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, show current user's profile

  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  late String _currentUserId;
  late bool _isCurrentUser;
  
  Profile? _profile;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _isEditingProfile = false;
  
  // Controllers for editing
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  
  File? _imageFile;
  
  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;
    _isCurrentUser = widget.userId == null || widget.userId == _currentUserId;
    _loadProfileData();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get profile based on whether it's current user or another user
      if (_isCurrentUser) {
        _profile = await _profileService.getCurrentProfile();
      } else {
        _profile = await _profileService.getProfileById(widget.userId!);
      }
      
      // Populate text controllers
      if (_profile != null) {
        _usernameController.text = _profile!.username ?? '';
        _fullNameController.text = _profile!.fullName ?? '';
        _bioController.text = _profile!.bio ?? '';
        _schoolController.text = _profile!.school ?? '';
      }
      
      // Get user posts
      _userPosts = await _postService.getUserPosts(
        _isCurrentUser ? _currentUserId : widget.userId!
      );
    } catch (e) {
      print('Error loading profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (_profile == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Upload image if selected
      String? avatarUrl = _profile!.avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await _storageService.uploadImage(
          _imageFile!,
          bucket: 'profile_images'
        );
      }
      
      // Update profile
      final success = await _profileService.updateProfile(
        username: _usernameController.text,
        fullName: _fullNameController.text,
        bio: _bioController.text,
        school: _schoolController.text,
        avatarUrl: avatarUrl,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'))
        );
        setState(() {
          _isEditingProfile = false;
        });
        await _loadProfileData(); // Reload data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile'))
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _likePost(String postId) async {
    try {
      final result = await _postService.toggleLike(postId);
      setState(() {
        final index = _userPosts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          _userPosts[index].isLikedByCurrentUser = result;
          if (result) {
            _userPosts[index].likeCount++;
          } else {
            _userPosts[index].likeCount = _userPosts[index].likeCount > 0 ? 
                _userPosts[index].likeCount - 1 : 0;
          }
        }
      });
    } catch (e) {
      print('Error liking post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post'))
      );
    }
  }
  
  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Logout'),
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); // Adjust route name as needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }
  
  Widget _buildProfileHeader() {
    if (_profile == null) {
      return Center(child: Text('No profile data available'));
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile image and stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _isCurrentUser && _isEditingProfile ? _pickImage : null,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.pink, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : (_profile!.avatarUrl != null
                                  ? NetworkImage(_profile!.avatarUrl!)
                                  : null),
                            backgroundColor: Colors.grey.shade100,
                            child: (_imageFile == null && _profile!.avatarUrl == null)
                                ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                                : null,
                          ),
                        ),
                      ),
                      if (_isCurrentUser && _isEditingProfile)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Profile stats
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('${_userPosts.length}', 'Posts'),
                          _buildStatColumn('0', 'Followers'),
                          _buildStatColumn('0', 'Following'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Profile info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _isEditingProfile
                  ? _buildEditProfileForm()
                  : _buildProfileInfo(),
            ),
          ),
          
          // Edit profile button (for current user only)
          if (_isCurrentUser)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isEditingProfile) {
                      _updateProfile();
                    } else {
                      setState(() {
                        _isEditingProfile = true;
                      });
                    }
                  },
                  child: Text(_isEditingProfile ? 'Save Profile' : 'Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditingProfile ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            
          if (_isEditingProfile && _isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditingProfile = false;
                      _imageFile = null;
                      
                      // Reset controllers to original values
                      _usernameController.text = _profile!.username ?? '';
                      _fullNameController.text = _profile!.fullName ?? '';
                      _bioController.text = _profile!.bio ?? '';
                      _schoolController.text = _profile!.school ?? '';
                    });
                  },
                  child: Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildProfileInfo() {
    return [
      if (_profile!.fullName != null && _profile!.fullName!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            _profile!.fullName ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      if (_profile!.username != null)
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '@${_profile!.username}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
        ),
      if (_profile!.school != null && _profile!.school!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: 16, color: Colors.blue.shade700),
                SizedBox(width: 6),
                Text(
                  _profile!.school!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      if (_profile!.bio != null && _profile!.bio!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _profile!.bio!,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
    ];
  }
  
  List<Widget> _buildEditProfileForm() {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
    
    return [
      SizedBox(height: 16),
      TextFormField(
        controller: _fullNameController,
        decoration: inputDecoration.copyWith(
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: inputDecoration.copyWith(
          labelText: 'Username',
          hintText: 'Choose a username',
          prefixIcon: Icon(Icons.alternate_email),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _schoolController,
        decoration: inputDecoration.copyWith(
          labelText: 'School',
          hintText: 'Enter your school name',
          prefixIcon: Icon(Icons.school),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _bioController,
        decoration: inputDecoration.copyWith(
          labelText: 'Bio',
          hintText: 'Tell us about yourself',
          alignLabelWithHint: true,
        ),
        maxLines: 3,
      ),
      SizedBox(height: 8),
    ];
  }
  
  Widget _buildPostsGrid() {
    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (_isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Share your first post by clicking the + button',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              if (_isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to create post page
                      Navigator.of(context).pushNamed('/create_post');
                    },
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Create Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          final post = _userPosts[index];
          return GestureDetector(
            onTap: () {
              // Show post details dialog
              _showPostDetails(post);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey.shade200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    post.imageUrl != null
                        ? Image.network(
                            post.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(Icons.article, color: Colors.grey),
                          ),
                    if (post.likeCount > 0)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, color: Colors.white, size: 14),
                              SizedBox(width: 2),
                              Text(
                                '${post.likeCount}',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showPostDetails(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with profile info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: _profile?.avatarUrl != null
                                  ? NetworkImage(_profile!.avatarUrl!)
                                  : null,
                              backgroundColor: Colors.grey.shade200,
                              child: _profile?.avatarUrl == null
                                  ? Icon(Icons.person, size: 22, color: Colors.grey.shade600)
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?.username ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_profile?.school != null)
                                  Text(
                                    _profile!.school!,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                // Show post options (delete, edit, etc.)
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Post content
                      if (post.imageUrl != null)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: Image.network(
                            post.imageUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => _likePost(post.id),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    post.isLikedByCurrentUser
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: post.isLikedByCurrentUser ? Colors.red : null,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  // Show comments
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  // Share functionality
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.share_outlined,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Likes count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '${post.likeCount} ${post.likeCount == 1 ? 'like' : 'likes'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      
                      // Caption
                      if (post.caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 15),
                              children: [
                                TextSpan(
                                  text: _profile?.username ?? 'User',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '  ${post.caption}'),
                              ],
                            ),
                          ),
                        ),
                      
                      // Date
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          _isCurrentUser
              ? 'My Profile'
              : _profile?.username != null
                  ? '@${_profile!.username}'
                  : 'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _showLogoutConfirmation,
              tooltip: 'Logout',
            ),
          if (!_isCurrentUser)
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      userId: widget.userId!,
                      username: _profile?.username ?? 'User',
                      avatarUrl: _profile?.avatarUrl,
                    ),
                  ),
                );
              },
              tooltip: 'Message',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              color: Colors.blue,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    _buildPostsGrid(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
} 