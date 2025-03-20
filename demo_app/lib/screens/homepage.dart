import 'package:demo_app/models/post_model.dart';
import 'package:demo_app/models/profile_model.dart';
import 'package:demo_app/screens/eventspage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/new_taskpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../pages/profile_page.dart';

class Story {
  final String name;
  final String image;

  Story({required this.name, required this.image});
}

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();
  
  List<Post> _posts = [];
  bool _isLoading = true;
  Profile? _currentProfile;
  
  final List<Story> stories = [
    Story(name: 'Meme Club', image: 'assets/stars.jpg'),
    Story(name: 'Tech Club', image: 'assets/cars.jpg'),
    Story(name: 'Art Club', image: 'assets/art.jpg'),
    Story(name: 'Market Club', image: 'assets/tech.jpg'),
    Story(name: 'Reading Club', image: 'assets/books.jpg'),
    // Add more stories with different names and images
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPosts();
  }
  
  Future<void> _loadUserData() async {
    try {
      final profile = await _profileService.getCurrentProfile();
      setState(() {
        _currentProfile = profile;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final posts = await _postService.getPosts();
      
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _toggleLike(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index < 0) return;
    
    final isLiked = await _postService.toggleLike(postId);
    
    setState(() {
      _posts[index].isLikedByCurrentUser = isLiked;
      if (isLiked) {
        _posts[index].likeCount++;
      } else {
        _posts[index].likeCount--;
      }
    });
  }
  
  Future<void> _deletePost(String postId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmation != true) return;
    
    final success = await _postService.deletePost(postId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
      _loadPosts(); // Refresh the feed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
        // Adjust the value as needed
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(
              height: 25,
              width: 160,
              child: Image.asset(
                'assets/logo.png',
                height: 20,
                width: 190,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
          IconButton(
            icon: Icon(Icons.search_rounded),
            onPressed: () {
              // Handle search button press
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            onPressed: () {
              // Handle notifications button press
            },
          ),
          IconButton(
            icon: _currentProfile?.avatarUrl != null
                ? Image.network(
                    _currentProfile!.avatarUrl!,
                    height: 40,
                    width: 40,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/profile.png',
                      height: 40,
                      width: 40,
                    ),
                  )
                : Image.asset(
                    'assets/profile.png',
                    height: 40,
                    width: 40,
                  ),
            onPressed: () {
              // Handle profile button press
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 25),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 140, 0),
                            backgroundImage: AssetImage(stories[index].image),
                          ),
                        ),
                        Text(
                          stories[index].name,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  MaterialButton(
                    onPressed: () {},
                    minWidth: 67, // Adjust the minimum width
                    height: 23, // Adjust the height
                    color: const Color.fromARGB(255, 255, 136, 0),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Daily Posts',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                    onPressed: () {},
                    minWidth: 67, // Adjust the minimum width
                    height: 23, // Adjust the height
                    color: Color.fromARGB(255, 253, 253, 253),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Discussion and Polling',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(92, 0, 0, 0),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? Center(
                          child: Text(
                            'No posts yet. Create one!',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            final isCurrentUserPost =
                                post.userId == supabase.auth.currentUser!.id;
                            
                            return Card(
                              color: Color.fromARGB(230, 255, 255, 255),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              margin: const EdgeInsets.only(
                                  left: 10, right: 10, top: 20, bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  // Handle post tap
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          post.userAvatar != null
                                              ? CircleAvatar(
                                                  radius: 18,
                                                  backgroundImage:
                                                      NetworkImage(post.userAvatar!),
                                                  onBackgroundImageError:
                                                      (exception, stackTrace) {
                                                    // Handle error loading image
                                                  },
                                                )
                                              : Image.asset(
                                                  'assets/profile.png',
                                                  height: 35,
                                                  width: 35,
                                                ),
                                          SizedBox(width: 5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // Navigate to user profile
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ProfilePage(userId: post.userId),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  post.userName ?? "User",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                timeago.format(post.createdAt),
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(fontSize: 8),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          if (isCurrentUserPost)
                                            PopupMenuButton<String>(
                                              icon: Icon(Icons.more_horiz),
                                              onSelected: (value) {
                                                if (value == 'delete') {
                                                  _deletePost(post.id);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text('Delete Post'),
                                                ),
                                              ],
                                            )
                                          else
                                            Icon(Icons.more_horiz),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      if (post.imageUrl != null)
                                        SizedBox(
                                          height: 200,
                                          width: double.infinity,
                                          child: Image.network(
                                            post.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      Row(children: [
                                        IconButton(
                                          onPressed: () => _toggleLike(post.id),
                                          icon: post.isLikedByCurrentUser
                                              ? Image.asset(
                                                  'assets/like.png',
                                                  height: 30,
                                                  color: Colors.red,
                                                )
                                              : Image.asset(
                                                  'assets/like.png',
                                                  height: 30,
                                                ),
                                        ),
                                        if (post.likeCount > 0)
                                          Text(
                                            post.likeCount.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const SizedBox(width: 2),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Image.asset(
                                            'assets/share.png',
                                            height: 30,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Image.asset(
                                            'assets/Chat.png',
                                            height: 28,
                                          ),
                                        ),
                                      ]),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            post.caption,
                                            style: TextStyle(fontSize: 14),
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
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTaskPage(
                onPostCreated: () {
                  // Refresh feed when a new post is created
                  _loadPosts();
                },
              ),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(30), // Set the desired corner radius
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
