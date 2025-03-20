import 'package:supabase_flutter/supabase_flutter.dart';

class Post {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String caption;
  final String? imageUrl;
  final DateTime createdAt;
  int likeCount;
  bool isLikedByCurrentUser;

  Post({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.caption,
    this.imageUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
  });

  factory Post.fromMap(Map<String, dynamic> map, {bool isLiked = false}) {
    return Post(
      id: map['id'],
      userId: map['user_id'],
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      caption: map['caption'] ?? '',
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      likeCount: map['like_count'] ?? 0,
      isLikedByCurrentUser: isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
    };
  }
}

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new post
  Future<Post?> createPost(String caption, String? imageUrl) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Try to get user data from profiles table
      final userData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final data = {
        'user_id': userId,
        'caption': caption,
        'image_url': imageUrl,
        'user_name': userData?['username'] ?? userId.substring(0, 8),
        'user_avatar': userData?['avatar_url'],
        'like_count': 0,
      };

      final response = await _supabase.from('posts').insert(data).select();
      if (response.isNotEmpty) {
        return Post.fromMap(response[0]);
      }
      return null;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get all posts for feed
  Future<List<Post>> getPosts() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Get all posts with basic query (not using joins for now)
      final response = await _supabase
          .from('posts')
          .select('*')
          .order('created_at', ascending: false);

      // Get likes by current user
      final likedPostsResponse = await _supabase
          .from('likes')
          .select('post_id')
          .eq('user_id', userId);
      
      final likedPostIds = likedPostsResponse.map((like) => like['post_id']).toSet();

      // Process and return posts
      return response.map<Post>((post) {
        final isLiked = likedPostIds.contains(post['id']);
        return Post.fromMap(post, isLiked: isLiked);
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  // Like or unlike a post
  Future<bool> toggleLike(String postId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Debug information
      print('Attempting to toggle like for post: $postId by user: $userId');
      
      // Check if post is already liked
      final existing = await _supabase
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId);
      
      if (existing.isEmpty) {
        // Like the post
        print('Creating new like');
        try {
          await _supabase.from('likes').insert({
            'user_id': userId,
            'post_id': postId,
          });
          
          // Increment like count
          await _supabase.rpc('increment_likes', params: {'post_id_param': postId});
          print('Like created and count incremented');
          return true;
        } catch (likeError) {
          print('Error creating like: $likeError');
          
          // Try a direct update to the post like_count as fallback
          try {
            // Use raw SQL update instead of sql() method
            await _supabase
                .from('posts')
                .update({'like_count': await _getCurrentLikeCount(postId) + 1})
                .eq('id', postId);
            print('Like count incremented directly');
            return true;
          } catch (updateError) {
            print('Error updating like count: $updateError');
            throw updateError;
          }
        }
      } else {
        // Unlike the post
        print('Removing existing like');
        try {
          await _supabase
              .from('likes')
              .delete()
              .eq('user_id', userId)
              .eq('post_id', postId);
          
          // Decrement like count
          await _supabase.rpc('decrement_likes', params: {'post_id_param': postId});
          print('Like removed and count decremented');
          return false;
        } catch (unlikeError) {
          print('Error removing like: $unlikeError');
          
          // Try a direct update to the post like_count as fallback
          try {
            final currentCount = await _getCurrentLikeCount(postId);
            final newCount = currentCount > 0 ? currentCount - 1 : 0;
            
            await _supabase
                .from('posts')
                .update({'like_count': newCount})
                .eq('id', postId);
            print('Like count decremented directly');
            return false;
          } catch (updateError) {
            print('Error updating like count: $updateError');
            throw updateError;
          }
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      // For UI feedback, return the current state
      return false;
    }
  }
  
  // Helper method to get current like count
  Future<int> _getCurrentLikeCount(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('like_count')
          .eq('id', postId)
          .single();
      
      return response['like_count'] ?? 0;
    } catch (e) {
      print('Error getting current like count: $e');
      return 0;
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Check if user owns the post
      final post = await _supabase
          .from('posts')
          .select()
          .eq('id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (post != null) {
        // Delete the post
        await _supabase.from('posts').delete().eq('id', postId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Get posts for a specific user
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      
      // Get all posts from the specified user
      final response = await _supabase
          .from('posts')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Get likes by current user
      final likedPostsResponse = await _supabase
          .from('likes')
          .select('post_id')
          .eq('user_id', currentUserId);
      
      final likedPostIds = likedPostsResponse.map((like) => like['post_id']).toSet();

      // Process and return posts
      return response.map<Post>((post) {
        final isLiked = likedPostIds.contains(post['id']);
        return Post.fromMap(post, isLiked: isLiked);
      }).toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }
} 