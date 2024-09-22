import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helpers/auth_helper.dart';
import '../helpers/firestore_helper.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? fullName, email, password, confirmPassword;

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
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed('splash_page');
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name Field
                            _buildTextField(
                              controller: fullNameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person,
                              onSave: (value) => fullName = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Email Field
                            _buildTextField(
                              controller: emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email,
                              onSave: (value) => email = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password Field
                            _buildPasswordField(
                              controller: passwordController,
                              hintText: 'Password',
                              showPassword: showPassword,
                              toggleVisibility: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              onSave: (value) => password = value,
                            ),
                            const SizedBox(height: 16),

                            _buildPasswordField(
                              controller: TextEditingController(),
                              hintText: 'Confirm Password',
                              showPassword: showConfirmPassword,
                              toggleVisibility: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Sign Up Button
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  Map<String, dynamic>? res = await AuthHelper
                                      .authHelper
                                      .signUpUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  if (res['user'] != null) {
                                    User? user = res['user'];
                                    if (user != null && user.email != null) {
                                      FirestoreHelper.firestoreHelper
                                          .addAuthenticatedUser(
                                        userName: fullName!,
                                        email: user.email!,
                                      );
                                      Navigator.pushReplacementNamed(
                                        context,
                                        "/",
                                        arguments: user,
                                      );
                                    }
                                  } else {
                                    _showSnackBar('Sign Up Failed', false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadowColor: Colors.black45,
                                elevation: 10,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Center(
                              child: Text(
                                "OR",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 30),
                            OutlinedButton(
                              onPressed: () async {
                                Map<String, dynamic>? res = await AuthHelper
                                    .authHelper
                                    .signInWithGoogle();
                                if (res['user'] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Login with Google successful"),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  User? user = res['user'];

                                  if (user != null && user.email != null) {
                                    FirestoreHelper.firestoreHelper
                                        .addAuthenticatedUser(
                                            email: user.email!,
                                            userName: user.displayName!);
                                    Navigator.pushReplacementNamed(context, "/",
                                        arguments: user);
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
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                // backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadowColor: Colors.black45,
                                elevation: 10,
                              ),
                              child: const Text(
                                'Sign In with Google',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed("signIn_page");
                                },
                                child: RichText(
                                  text: const TextSpan(
                                    text: "have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                    children: [
                                      TextSpan(
                                        text: " Sign In ",
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSave,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white60),
      ),
      style: TextStyle(color: Colors.white),
      validator: validator,
      onSaved: onSave,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback toggleVisibility,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSave,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onSaved: onSave,
    );
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
