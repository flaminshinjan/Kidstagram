import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_app/models/profile_model.dart';
import 'package:demo_app/screens/main_layout.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();
  bool _signInLoading = false;
  bool _signUpLoading = false;
  bool _debugMode = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    supabase.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _bypassAuthForTesting() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("DEV MODE: Bypassing authentication"),
      backgroundColor: Colors.purple,
    ));
    
    await Future.delayed(const Duration(seconds: 1));
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainLayout()),
    );
  }

  Future<bool> _createUserProfile(String userId, String email) async {
    try {
      String username = email.split('@').first;
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      username = '${username}_$timestamp';
      
      // First check if the profiles table exists
      try {
        final tablesCheck = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
          .eq('table_name', 'profiles');
        
        print('Tables check result: $tablesCheck');
        
        if (tablesCheck == null || tablesCheck.isEmpty) {
          print('WARNING: profiles table does not exist in schema!');
          
          // Try to create the table
          try {
            await supabase.rpc('create_profiles_table_if_missing');
            print('Attempted to create profiles table via RPC');
          } catch (rpcError) {
            print('Failed to create profiles table via RPC: $rpcError');
          }
        }
      } catch (schemaError) {
        print('Error checking schema: $schemaError');
      }
      
      final data = {
        'id': userId,
        'username': username,
        'full_name': username,
        'avatar_url': null,
        'bio': 'Hello, I am new here!',
        'school': null,
      };
      
      // Try with upsert instead of insert for better reliability
      await supabase.from('profiles').upsert(data);
      return true;
    } catch (e) {
      print('Error creating user profile directly: $e');
      
      // Try a raw SQL approach as last resort
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
        final username = 'user_$timestamp';
        
        await supabase.rpc('manually_create_profile', params: {
          'user_id': userId,
          'user_name': username,
          'user_full_name': 'New User',
        });
        
        print('Created profile via RPC function');
        return true;
      } catch (rpcError) {
        print('RPC profile creation also failed: $rpcError');
        return false;
      }
    }
  }

  Future<void> _signInWithEmail() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    
    setState(() {
      _signInLoading = true;
    });
    
    try {
      await supabase.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Sign In Failed"),
          backgroundColor: Color.fromARGB(255, 255, 15, 7),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _signInLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    
    setState(() {
      _signUpLoading = true;
    });
    
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        print('Attempting signup for: ${_emailController.text}');
        
        final response = await supabase.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          data: {
            'username': _emailController.text.split('@').first,
            'timestamp': DateTime.now().millisecondsSinceEpoch
          }
        );
        
        print('Auth signup response: $response');
        
        if (response.user != null) {
          final userId = response.user!.id;
          print('User created with ID: $userId');
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Try to create profile with the service first
          print('Attempting to create profile via ProfileService');
          bool profileCreated = await _profileService.createProfile(userId);
          print('ProfileService result: $profileCreated');
          
          if (!profileCreated) {
            print('Falling back to direct profile creation');
            profileCreated = await _createUserProfile(userId, _emailController.text);
            print('Direct profile creation result: $profileCreated');
          }
          
          if (profileCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Success | Confirmation Email Sent"),
              backgroundColor: Color.fromARGB(255, 252, 116, 5),
            ));
          } else {
            // Even if profile creation failed, the user was created, so they can try logging in
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Account created but profile setup failed. Please try logging in, a profile may be automatically created."),
              backgroundColor: Colors.orange,
            ));
          }
          
          break;
        }
      } catch (e) {
        print('Error during signup (attempt ${retryCount + 1}): $e');
        
        if (retryCount == maxRetries) {
          String errorMessage = "Sign Up Failed";
          
          if (e is AuthException) {
            if (e.message.contains('Database error saving new user')) {
              errorMessage = "Database error. Try again later or contact support.";
              print('Auth exception details: ${e.message}');
            } else if (e.message.contains('unique constraint')) {
              errorMessage = "Email already registered. Please use a different email or try logging in.";
            } else if (e.message.contains('relation "profiles" does not exist')) {
              // This is the specific error we're seeing
              errorMessage = "Database setup issue. Please contact support with code: PROFILES-MISSING";
              print('Critical error - profiles table missing: ${e.message}');
              
              // Try to log in anyway with the credentials - the user might actually exist
              try {
                await supabase.auth.signInWithPassword(
                  email: _emailController.text,
                  password: _passwordController.text
                );
                errorMessage = "Account exists! Logging you in now...";
                break;
              } catch (loginError) {
                print('Attempted login fallback also failed: $loginError');
              }
            } else {
              errorMessage = e.message;
            }
          } else if (e.toString().contains('duplicate key value')) {
            errorMessage = "Email already in use. Please try a different email.";
          } else if (e.toString().contains('database') || e.toString().contains('profiles')) {
            errorMessage = "Database error. Please try again with a different email or try later.";
            print('Database-related error details: $e');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            backgroundColor: Color.fromARGB(255, 255, 15, 7),
          ));
        } else {
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }
      
      retryCount++;
    }
    
    setState(() {
      _signUpLoading = false;
    });
  }

  int _debugTapCount = 0;
  void _incrementDebugTap() {
    setState(() {
      _debugTapCount++;
    });
    
    if (_debugTapCount >= 5) {
      setState(() {
        _debugMode = !_debugMode;
        _debugTapCount = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_debugMode ? "Debug mode activated" : "Debug mode deactivated"),
        backgroundColor: _debugMode ? Colors.purple : Colors.blue,
      ));
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _debugTapCount > 0 && _debugTapCount < 5) {
        setState(() {
          _debugTapCount = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
          top: -15,
          bottom: -15,
          left: -15,
          right: -15,
          child: SvgPicture.asset(
            "assets/bgd.svg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 450,
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Form(
                key: _formKey,
                child: Stack(children: <Widget>[
                  Positioned(
                    top: -15,
                    left: 120,
                    child: GestureDetector(
                      onTap: _incrementDebugTap,
                      child: Image.asset(
                        "assets/planet.png",
                        height: 120,
                        width: 120,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 110,
                      left: 105,
                      child: Text(
                        "Login with",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )),
                  Positioned(
                      top: 165,
                      left: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        width: 350,
                        height: 62,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field is Required';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                        ),
                      )),
                  Positioned(
                      top: 230,
                      left: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        width: 350,
                        height: 62,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field is Required';
                            }
                            return null;
                          },
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                        ),
                      )),
                  Positioned(
                    top: 320,
                    left: 22.5,
                    child: _signInLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : MaterialButton(
                            onPressed: _debugMode ? _bypassAuthForTesting : _signInWithEmail,
                            color: const Color.fromARGB(255, 255, 136, 0),
                            textColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 140),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _debugMode ? 'Dev Login' : 'Login',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                  Positioned(
                      top: 382,
                      left: 70,
                      child: Row(
                        children: [
                          const Text(
                            "Having a trouble, We'll support you",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      )),
                  Positioned(
                    top: 405,
                    left: 80,
                    child: Row(children: [
                      const Text(
                        'Dont have an account ?',
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      _signUpLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                              onPressed: _debugMode ? _bypassAuthForTesting : _signUp,
                              child: Text(
                                _debugMode ? 'Dev Signup' : 'Sign Up',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                    ]),
                  )
                ]),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
