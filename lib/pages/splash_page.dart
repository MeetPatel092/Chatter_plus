import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            top: 100,
            right: 30,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 50,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 40,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 180),
              // Welcome Text
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Description Text
              Text(
                'Enter personal details to your\nUser account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 80),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("signIn_page");
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Use theme colors
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("signUp_page");
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
