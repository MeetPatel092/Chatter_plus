import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:permission_handler/permission_handler.dart';
import '../helpers/auth_helper.dart';
import '../helpers/firestore_helper.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool rememberMe = false;
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(); // Create GoogleSignIn instance

  Future<void> requestPermission() async {
    // Request permissions
    PermissionStatus notificationPermissionStatus =
        await Permission.notification.request();
    PermissionStatus scheduleExactAlarmPermissionStatus =
        await Permission.notification.request();

    log("==============================");
    log("$notificationPermissionStatus");
    log("==============================");
    log("==============================");
    log("$scheduleExactAlarmPermissionStatus");
    log("==============================");
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> _signInWithGoogle() async {
    Map<String, dynamic>? res = await AuthHelper.authHelper.signInWithGoogle();
    if (res['user'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login with Google successful"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      User? user = res['user'];

      if (user != null && user.email != null) {
        FirestoreHelper.firestoreHelper.addAuthenticatedUser(
            email: user.email!, userName: user.displayName!);
        Navigator.pushReplacementNamed(context, "/", arguments: user);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("${res['error']}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed("splash_page");
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Email Input
                              _buildInputField(
                                hint: 'Email',
                                icon: Icons.email,
                                controller: emailController,
                                isPassword: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!RegExp(
                                          r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password Input
                              _buildInputField(
                                hint: 'Password',
                                icon: Icons.lock,
                                controller: passwordController,
                                isPassword: true,
                                showPassword: showPassword,
                                onTogglePassword: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              // Remember me and Forgot password row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: Colors.white,
                                        checkColor: Colors.black,
                                      ),
                                      const Text('Remember me',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      Map<String, dynamic>? res =
                                          await AuthHelper.authHelper
                                              .signInUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );

                                      if (res['user'] != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.green,
                                            content:
                                                Text("Sign In successfully."),
                                          ),
                                        );

                                        User? user = res['user'];
                                        Navigator.pushReplacementNamed(
                                            context, "/",
                                            arguments: user);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text("Sign In Failed"),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                        0xFF1E88E5), // Primary color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                    ),
                                    shadowColor: Colors.black38,
                                    elevation: 8,
                                  ),
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Google Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _signInWithGoogle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .white, // White background for Google button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                    ),
                                    shadowColor: Colors.black38,
                                    elevation: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/google.jpeg',
                                        height: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.black, // Black text color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed("signUp_page");
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(color: Colors.white70),
                                      children: [
                                        TextSpan(
                                          text: " Sign up ",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isPassword,
    bool showPassword = false,
    Function? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  if (onTogglePassword != null) onTogglePassword();
                },
              )
            : null,
      ),
      validator: validator,
    );
  }
}
