import 'package:chatter_plus/components/drawer.dart';
import 'package:chatter_plus/helpers/auth_helper.dart';
import 'package:chatter_plus/helpers/firestore_helper.dart';
import 'package:chatter_plus/helpers/local_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notification feature
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: Drawers(user: user!),
      body: StreamBuilder(
        stream: FirestoreHelper.firestoreHelper.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDoc =
                data?.docs ?? [];

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView.separated(
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 15),
                    itemCount: allDoc.length,
                    itemBuilder: (context, i) {
                      String email = allDoc[i].data()['email'];
                      bool isAdmin =
                          AuthHelper.firebaseAuth.currentUser!.email ==
                              'meetflutter29@gmail.com';

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: constraints.maxWidth < 600 ? 20 : 30,
                          ),
                          leading: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 30),
                          ),
                          title: Text(
                            (AuthHelper.firebaseAuth.currentUser!.email ==
                                    email)
                                ? "You ($email)"
                                : email,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: constraints.maxWidth < 600 ? 16 : 20,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: isAdmin
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDeleteDialog(
                                        context, allDoc[i].id, email);
                                  },
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).pushNamed("chat_page",
                                arguments: allDoc[i].data());
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const Center(child: Text("No users found."));
        },
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String docId, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 10),
              Text("Delete User"),
            ],
          ),
          content: Text(
              "Are you sure you want to delete the user '$email'? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirestoreHelper.firestoreHelper.deleteUser(docId: docId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
