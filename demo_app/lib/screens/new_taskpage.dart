import 'dart:io';
import 'package:demo_app/models/post_model.dart';
import 'package:demo_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class NewTaskPage extends StatefulWidget {
  final Function? onPostCreated;
  
  const NewTaskPage({Key? key, this.onPostCreated}) : super(key: key);
  
  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;
  File? _selectedImage;
  
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      // Only request permissions on mobile platforms
      await [
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      
      // Get image with source parameter
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 70, // Reduce quality to save storage
      );
      
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image. Please check app permissions in device settings.')),
      );
    }
  }
  
  Future<void> _createPost() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a caption')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadImage(_selectedImage!);
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }
      
      // Create post
      final post = await _postService.createPost(
        _captionController.text.trim(),
        imageUrl,
      );
      
      if (post != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully')),
        );
        
        // Notify parent that post was created
        if (widget.onPostCreated != null) {
          widget.onPostCreated!();
        }
        
        // Go back to home
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
        // Adjust the value as needed
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : MaterialButton(
                    onPressed: _createPost,
                    minWidth: 65, // Adjust the minimum width
                    height: 35, // Adjust the height
                    color: const Color.fromARGB(255, 255, 136, 0),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Share Now',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: TextField(
                        controller: _captionController,
                        decoration: InputDecoration(
                          hintText: "What's happening?",
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                      ),
                    ),
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  left: 1,
                  bottom: 1,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: _showImageSourceDialog,
                      ),
                      IconButton(
                        icon: Icon(Icons.video_call),
                        onPressed: () {
                          // Handle video call button press
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.location_on),
                        onPressed: () {
                          // Handle location button press
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: MaterialButton(
                    onPressed: () {},
                    minWidth: 50, // Adjust the minimum width
                    height: 35, // Adjust the height
                    color: Color.fromARGB(255, 245, 205, 160),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Everyone can view & reply',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 133, 2),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
