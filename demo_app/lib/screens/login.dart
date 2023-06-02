import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;
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
                    child: Image.asset(
                      "assets/planet.png",
                      height: 120,
                      width: 120,
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
                            onPressed: () async {
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Sign In Failed"),
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 15, 7),
                                ));
                                setState(() {
                                  _signInLoading = false;
                                });
                              }
                            },
                            color: const Color.fromARGB(255, 255, 136, 0),
                            textColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 140),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Login',
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
                              onPressed: () async {
                                final isValid =
                                    _formKey.currentState?.validate();
                                if (isValid != true) {
                                  return;
                                }
                                setState(() {
                                  _signUpLoading = true;
                                });
                                try {
                                  await supabase.auth.signUp(
                                      email: _emailController.text,
                                      password: _passwordController.text);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "Success | Confirmation Email Sent",
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 252, 116, 5),
                                  ));
                                  setState(() {
                                    _signUpLoading = false;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Sign Up Failed"),
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 15, 7),
                                  ));
                                  setState(() {
                                    _signUpLoading = false;
                                  });
                                }
                              },
                              child: const Text(
                                'Sign Up',
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
