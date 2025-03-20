import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_app/screens/main_layout.dart';
import 'package:demo_app/models/profile_model.dart';

/// A development utility to bypass the login screen and work directly in the app
/// This helps continue development while fixing Supabase auth issues
class DevBypass extends StatefulWidget {
  const DevBypass({Key? key}) : super(key: key);

  @override
  State<DevBypass> createState() => _DevBypassState();
}

class _DevBypassState extends State<DevBypass> {
  bool _isLoading = true;
  String _statusMessage = "Preparing development environment...";
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _setupDevEnvironment();
  }

  Future<void> _setupDevEnvironment() async {
    try {
      setState(() {
        _statusMessage = "Setting up a development session...";
      });

      // Check current auth state
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser != null) {
        // User is already logged in, just proceed
        setState(() {
          _statusMessage = "Using existing user session";
        });
        
        // Create a profile if it doesn't exist
        await _ensureProfile(currentUser.id);
        
        _proceedToApp();
        return;
      }
      
      // Try to log in with dev credentials or create a new user
      await _createOrSignInDevUser();
      
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e\n\nTap to try again.";
        _isLoading = false;
      });
    }
  }
  
  Future<void> _createOrSignInDevUser() async {
    // Try to sign in with dev credentials
    try {
      setState(() {
        _statusMessage = "Trying to sign in with dev account...";
      });
      
      // Try to sign in with test account
      final result = await _supabase.auth.signInWithPassword(
        email: 'dev@example.com',
        password: 'devpassword123',
      );
      
      if (result.user != null) {
        setState(() {
          _statusMessage = "Signed in with dev account";
        });
        
        // Ensure profile exists
        await _ensureProfile(result.user!.id);
        
        _proceedToApp();
        return;
      }
    } catch (e) {
      // Sign in failed, try to create dev account
      setState(() {
        _statusMessage = "Creating development account...";
      });
    }
    
    // Try to create a dev user
    try {
      final result = await _supabase.auth.signUp(
        email: 'dev@example.com',
        password: 'devpassword123',
      );
      
      if (result.user != null) {
        setState(() {
          _statusMessage = "Created new dev account";
        });
        
        // Create profile 
        await _ensureProfile(result.user!.id);
        
        _proceedToApp();
        return;
      }
    } catch (e) {
      // Could not create user
      setState(() {
        _statusMessage = "Could not create dev account: $e\n\nTap to try again.";
        _isLoading = false;
      });
    }
  }
  
  Future<void> _ensureProfile(String userId) async {
    setState(() {
      _statusMessage = "Setting up user profile...";
    });
    
    try {
      // First try with ProfileService
      final success = await _profileService.createProfile(userId);
      
      if (!success) {
        // Try direct insert with core fields first
        await _supabase.from('profiles').upsert({
          'id': userId,
          'username': 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
          'full_name': 'Development User',
          'bio': 'Test account for development',
          'created_at': DateTime.now().toIso8601String(),
        });
        
        // Then try to set school separately
        try {
          await _supabase.from('profiles')
              .update({'school': 'Dev Academy'})
              .eq('id', userId);
        } catch (schoolError) {
          // Ignore error if school column doesn't exist
          print('Warning: Could not set school field: $schoolError');
        }
      }
    } catch (e) {
      print('Warning: Could not ensure profile: $e');
      // Continue anyway
    }
  }
  
  void _proceedToApp() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: Center(
        child: GestureDetector(
          onTap: _isLoading ? null : _setupDevEnvironment,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ],
            ),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Dev Mode",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  )
                else
                  ElevatedButton(
                    onPressed: _setupDevEnvironment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Try Again"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 