import 'package:chatter_plus/helpers/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Drawers extends StatefulWidget {
  final User user;

  Drawers({required this.user});

  @override
  State<Drawers> createState() => _DrawersState();
}

class _DrawersState extends State<Drawers> {
  bool isDarkMode = false; // Track the theme mode
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user; // Initialize with the current user
  }

  Future<void> _updateUserData() async {
    await FirebaseAuth.instance.currentUser?.reload(); // Reload user data
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser; // Update local user data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: (currentUser?.isAnonymous ?? true)
                        ? AssetImage('assets/images/profile.png')
                        : (currentUser?.photoURL == null)
                            ? AssetImage('assets/images/profile.png')
                            : NetworkImage(currentUser!.photoURL!)
                                as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        currentUser?.displayName ?? 'User Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showEditUsernameDialog(),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Text(
                    currentUser?.email ?? 'user.email@example.com',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildListTile(Icons.home, 'Home', () {
              Navigator.of(context).pop();
            }),
            _buildListTile(Icons.lock, 'Change Password', () {
              showChangePasswordDialog();
            }),
            _buildListTile(Icons.settings, 'Settings', () {
              Navigator.of(context).pop();
            }),
            const Divider(color: Colors.white70),
            _buildListTile(Icons.logout, 'Logout', () {
              _showLogoutConfirmationDialog();
            }),
            const Divider(color: Colors.white70),
            _buildThemeSwitch(), // Add the theme switch here
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  // Theme switch
  Widget _buildThemeSwitch() {
    return SwitchListTile(
      title: Text(
        'Dark Mode',
        style: const TextStyle(color: Colors.white),
      ),
      value: isDarkMode,
      onChanged: (value) {
        setState(() {
          isDarkMode = value;
          // Apply the theme change
          if (isDarkMode) {
            ThemeData.dark();
          } else {
            ThemeData.light();
          }
        });
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _buildAlertDialog(
          title: 'Logout Confirmation',
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            _buildDialogButton('Cancel', () {
              Navigator.of(context).pop();
            }),
            _buildDialogButton('Logout', () async {
              AuthHelper.authHelper.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('signIn_page', (routes) => false);
            }),
          ],
        );
      },
    );
  }

  void showEditUsernameDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return _buildAlertDialog(
          title: 'Edit Username',
          content: TextField(
            style: TextStyle(color: Colors.white),
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new username',
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            _buildDialogButton('Cancel', () {
              Navigator.of(context).pop();
            }),
            _buildDialogButton('Update', () async {
              String newUsername = controller.text;
              if (newUsername.isNotEmpty) {
                await AuthHelper.authHelper.updateUsername(newUsername);
                await _updateUserData();
                Navigator.of(context).pop();
              }
            }),
          ],
        );
      },
    );
  }

  void showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return _buildAlertDialog(
          title: 'Change Password',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(oldPasswordController, 'Enter old password'),
              const SizedBox(height: 10),
              _buildPasswordField(newPasswordController, 'Enter new password'),
            ],
          ),
          actions: [
            _buildDialogButton('Cancel', () {
              Navigator.of(context).pop();
            }),
            _buildDialogButton('Update', () async {
              String oldPassword = oldPasswordController.text;
              String newPassword = newPasswordController.text;

              if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
                User? user = FirebaseAuth.instance.currentUser;
                AuthCredential credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: oldPassword,
                );

                try {
                  await user.reauthenticateWithCredential(credential);

                  bool success =
                      await AuthHelper.authHelper.updatePassword(newPassword);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update password!')),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  // Handle authentication errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Old password is incorrect!')),
                  );
                }
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        focusColor: Colors.white,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  AlertDialog _buildAlertDialog(
      {required String title,
      required Widget content,
      required List<Widget> actions}) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: content,
      actions: actions,
    );
  }

  TextButton _buildDialogButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title, style: const TextStyle(color: Colors.blue)),
    );
  }
}
