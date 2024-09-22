// import 'package:chatter_plus/helpers/cloud_notification.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../helpers/auth_helper.dart';
//
// class LoginPage extends StatefulWidget {
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   Future<void> showSignUpDialog(BuildContext context) async {
//     final TextEditingController signUpEmailController = TextEditingController();
//     final TextEditingController signUpPasswordController =
//         TextEditingController();
//
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Sign Up'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: [
//                 TextField(
//                   controller: signUpEmailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     prefixIcon: const Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20.0),
//                 TextField(
//                   controller: signUpPasswordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     prefixIcon: const Icon(Icons.lock),
//                   ),
//                   obscureText: true,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Sign Up'),
//               onPressed: () async {
//                 Map<String, dynamic>? res =
//                     await AuthHelper.authHelper.signUpUserWithEmailAndPassword(
//                   email: signUpEmailController.text,
//                   password: signUpPasswordController.text,
//                 );
//
//                 if (res['user'] != null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       behavior: SnackBarBehavior.floating,
//                       backgroundColor: Colors.green,
//                       content: Text("Sign Up Successful"),
//                     ),
//                   );
//
//                   User? user = res['user'];
//
//                   if (user != null && user.email != null) {
//                     // FirestoreHelper.firestoreHelper
//                     //     .addAuthenticatedUser(email: user.email!);
//
//                     Navigator.pushReplacementNamed(context, "/",
//                         arguments: user); // Then navigate
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       behavior: SnackBarBehavior.floating,
//                       backgroundColor: Colors.red,
//                       content: Text("Sign Up Failed"),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> getToken() async {
//     await CloudNotification.cloudNotification.fetchToken();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     requsetPermission();
//     getToken();
//   }
//
//   Future<void> requsetPermission() async {
//     PermissionStatus notificationPermissionStatus =
//         await Permission.notification.request();
//     PermissionStatus sheduleExactAlarmPermissionStatus =
//         await Permission.notification.request();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Welcome Back!',
//                 style: TextStyle(
//                   fontSize: 28.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 40.0),
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   prefixIcon: const Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   final RegExp emailRegex =
//                       RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$');
//                   if (!emailRegex.hasMatch(val)) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20.0),
//               TextFormField(
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   prefixIcon: const Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return 'Please enter your password';
//                   } else if (val.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 40.0),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   onPressed: () async {
//                     if (formKey.currentState!.validate()) {
//                       Map<String, dynamic>? res = await AuthHelper.authHelper
//                           .signInUserWithEmailAndPassword(
//                         email: emailController.text,
//                         password: passwordController.text,
//                       );
//
//                       if (res['user'] != null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             backgroundColor: Colors.green,
//                             content: Text("Sign In successfully.."),
//                           ),
//                         );
//
//                         User? user = res['user'];
//                         Navigator.pushReplacementNamed(context, "/",
//                             arguments: user);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             backgroundColor: Colors.red,
//                             content: Text("Sign In Failed"),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   child: const Text('Sign In'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   onPressed: () async {
//                     Map<String, dynamic>? res =
//                         await AuthHelper.authHelper.signInWithGoogle();
//                     if (res['user'] != null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Login with Google successful"),
//                           behavior: SnackBarBehavior.floating,
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                       User? user = res['user'];
//
//                       if (user != null && user.email != null) {
//                         // FirestoreHelper.firestoreHelper
//                         //     .addAuthenticatedUser(email: user.email!);
//                         // Navigator.pushReplacementNamed(context, "/",
//                         //     arguments: user);
//                       }
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           backgroundColor: Colors.red,
//                           content: Text("${res['error']}"),
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     }
//                   },
//                   child: const Text(
//                     'Login with Google',
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account?"),
//                   TextButton(
//                     onPressed: () async {
//                       showSignUpDialog(context);
//                     },
//                     child: const Text(
//                       'Sign Up',
//                       style: TextStyle(color: Colors.blueAccent),
//                     ),
//                   ),
//                   const Text(":"),
//                   TextButton(
//                     onPressed: () async {
//                       Map<String, dynamic>? res =
//                           await AuthHelper.authHelper.signInGuestUser();
//                       if (res['user'] != null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Login successfully"),
//                             behavior: SnackBarBehavior.floating,
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                         Navigator.pushReplacementNamed(context, "/",
//                             arguments: res['user']);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             backgroundColor: Colors.red,
//                             content: Text("${res?['error']}"),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text(
//                       'Guest',
//                       style: TextStyle(color: Colors.blueAccent),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
