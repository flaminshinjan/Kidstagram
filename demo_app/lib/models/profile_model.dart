import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? school;

  Profile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.school,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      username: map['username'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      bio: map['bio'],
      school: map['school'],
    );
  }

  // Create a default profile when none exists
  factory Profile.defaultProfile(String userId) {
    return Profile(
      id: userId,
      username: 'user_$userId'.substring(0, 10),
      fullName: 'New User',
      avatarUrl: null,
      bio: 'Hello, I am new here!',
      school: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'school': school,
    };
  }
}

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user profile
  Future<Profile?> getCurrentProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        return Profile.fromMap(data);
      }
      
      // If profile doesn't exist, create one with default values
      return await _createDefaultProfile();
      
    } catch (e) {
      print('Error getting profile: $e');
      // Try to create a default profile if retrieval fails
      return await _createDefaultProfile();
    }
  }

  // Create a default profile
  Future<Profile?> _createDefaultProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Extract username from email or use a default
      String? username = user.email?.split('@').first ?? 'user_${user.id.substring(0, 8)}';
      String? email = user.email;
      
      // Check if profile already exists to avoid conflicts
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      if (existingProfile != null) {
        return Profile.fromMap(existingProfile);
      }
      
      // Create core profile data without school
      final data = {
        'id': user.id,
        'username': username,
        'full_name': username,
        'avatar_url': null,
        'bio': 'Hello, I am new here!',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Insert new profile with core fields
      await _supabase.from('profiles').insert(data);
      
      // Try to set school separately
      try {
        await _supabase.from('profiles')
            .update({'school': null})
            .eq('id', user.id);
      } catch (schoolError) {
        // Ignore error if school column doesn't exist
        print('Warning: Could not set school field: $schoolError');
      }
      
      // For return data, include all fields
      final returnData = {
        ...data,
        'school': null
      };
      
      return Profile.fromMap(returnData);
    } catch (e) {
      print('Error creating default profile: $e');
      // Return a local default profile as fallback
      return Profile.defaultProfile(_supabase.auth.currentUser?.id ?? 'unknown');
    }
  }

  // Create a new profile explicitly
  Future<bool> createProfile(String userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Extract username from email with timestamp to ensure uniqueness
      String? baseUsername = user.email?.split('@').first;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      String username = '${baseUsername}_$timestamp';
      
      // Check if profile already exists
      final existing = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
          
      if (existing != null) {
        return true; // Profile already exists
      }
      
      // Try to create profile with core fields first (without school)
      await _supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'full_name': baseUsername,
        'avatar_url': null,
        'bio': 'Hello, I am new here!',
      });
      
      // Try to set school separately
      try {
        await _supabase.from('profiles')
            .update({'school': null})
            .eq('id', userId);
      } catch (schoolError) {
        // Ignore error if school column doesn't exist
        print('Warning: Could not set school field: $schoolError');
      }
      
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      
      // Try an alternative approach if first attempt failed
      try {
        // Use a more random username as fallback
        String randomSuffix = DateTime.now().microsecondsSinceEpoch.toString().substring(8);
        
        // Insert with core fields only
        await _supabase.from('profiles').insert({
          'id': userId,
          'username': 'user_$randomSuffix',
          'full_name': 'New User',
          'avatar_url': null,
          'bio': 'Hello, I am new here!',
        });
        
        // Try to set school separately
        try {
          await _supabase.from('profiles')
              .update({'school': null})
              .eq('id', userId);
        } catch (schoolError) {
          // Ignore school field errors
          print('Warning: Could not set school field in fallback: $schoolError');
        }
        
        return true;
      } catch (fallbackError) {
        print('Fallback profile creation also failed: $fallbackError');
        return false;
      }
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? school,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Create updates map without the school field first
      final updates = {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (bio != null) 'bio': bio,
      };
      
      // Update all fields except school first
      if (updates.isNotEmpty) {
        await _supabase
            .from('profiles')
            .update(updates)
            .eq('id', userId);
      }
      
      // Try to update school separately if provided
      if (school != null) {
        try {
          await _supabase
              .from('profiles')
              .update({'school': school})
              .eq('id', userId);
        } catch (schoolError) {
          // If school column doesn't exist in schema, log but continue
          print('Warning: Could not update school field: $schoolError');
          // We still consider the update successful since other fields updated
        }
      }
      
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Get profile by user ID
  Future<Profile?> getProfileById(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (data != null) {
        return Profile.fromMap(data);
      }
      
      // If profile doesn't exist, return a default one
      return Profile.defaultProfile(userId);
    } catch (e) {
      print('Error getting profile by ID: $e');
      return Profile.defaultProfile(userId);
    }
  }
  
  // Get user posts
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }
  
  // Get all profiles for the chat functionality
  Future<List<Profile>> getAllProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('username');
      
      return response.map<Profile>((data) => Profile.fromMap(data)).toList();
    } catch (e) {
      print('Error getting all profiles: $e');
      return [];
    }
  }
} 