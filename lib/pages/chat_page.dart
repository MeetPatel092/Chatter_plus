import 'package:chatter_plus/helpers/auth_helper.dart';
import 'package:chatter_plus/helpers/cloud_notification.dart';
import 'package:chatter_plus/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController msgController = TextEditingController();
  bool isButtonActive = false;

  List<Map<String, Color>> themes = [
    {'primaryColor': Colors.blueAccent, 'secondaryColor': Colors.lightBlue},
    {'primaryColor': Colors.purpleAccent, 'secondaryColor': Colors.deepPurple},
    {'primaryColor': Colors.redAccent, 'secondaryColor': Colors.red},
    {'primaryColor': Colors.greenAccent, 'secondaryColor': Colors.green},
  ];

  int selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    msgController.addListener(() {
      setState(() {
        isButtonActive = msgController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receiver =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var currentTheme = themes[selectedThemeIndex];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: currentTheme['primaryColor'],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: currentTheme['primaryColor']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                receiver['email'] == AuthHelper.firebaseAuth.currentUser!.email
                    ? "You (Me)"
                    : receiver['email'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int index) {
              setState(() {
                selectedThemeIndex = index;
              });
            },
            icon: const Icon(Icons.color_lens_outlined),
            itemBuilder: (context) {
              return List.generate(themes.length, (index) {
                var theme = themes[index];
                return PopupMenuItem(
                  value: index,
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: theme['primaryColor'], radius: 10),
                      const SizedBox(width: 10),
                      Text('Theme ${index + 1}'),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: FirestoreHelper.firestoreHelper
                  .fetchChat(receiverEmail: receiver['email']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error : ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream =
                      snapshot.data;

                  return StreamBuilder(
                    stream: dataStream,
                    builder: (context, ss) {
                      if (ss.hasError) {
                        return Center(child: Text("Error : ${ss.error}"));
                      } else if (ss.hasData && ss.data != null) {
                        QuerySnapshot<Map<String, dynamic>>? data = ss.data;

                        List<QueryDocumentSnapshot<Map<String, dynamic>>>
                            allMessage = data!.docs;

                        if (allMessage.isEmpty) {
                          return const Center(
                            child: Text('No messages yet...',
                                style: TextStyle(color: Colors.white)),
                          );
                        }

                        return ListView.builder(
                          reverse: true,
                          itemCount: allMessage.length,
                          itemBuilder: (context, i) {
                            bool isSender =
                                AuthHelper.firebaseAuth.currentUser!.email ==
                                    allMessage[i].data()['senderEmail'];

                            return Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: GestureDetector(
                                onLongPress: isSender
                                    ? () {
                                        Align(
                                          alignment: isSender
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: isSender
                                                  ? currentTheme[
                                                          'primaryColor']!
                                                      .withOpacity(0.9)
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Message text
                                                Expanded(
                                                  child: Text(
                                                    "${allMessage[i].data()['msg']}",
                                                    style: TextStyle(
                                                      color: isSender
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                // DropdownButton for options
                                                DropdownButton<String>(
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors
                                                          .black), // Icon for dropdown
                                                  underline:
                                                      Container(), // Remove underline
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue == "Update") {
                                                      // Implement update functionality here
                                                      print("Update tapped");
                                                    } else if (newValue ==
                                                        "Delete") {
                                                      FirestoreHelper
                                                          .firestoreHelper
                                                          .deleteChat(
                                                        receiverEmail:
                                                            receiver['email'],
                                                        messageId:
                                                            allMessage[i].id,
                                                      );
                                                      // Optionally show a confirmation message
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Message deleted')),
                                                      );
                                                    }
                                                  },
                                                  items: <String>[
                                                    "Update",
                                                    "Delete"
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? currentTheme['primaryColor']!
                                            .withOpacity(0.9)
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${allMessage[i].data()['msg']}",
                                    style: TextStyle(
                                      color: isSender
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        currentTheme['primaryColor']!,
                        currentTheme['secondaryColor']!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: isButtonActive
                        ? () async {
                            String mes = msgController.text;
                            String? token =
                                await FirebaseMessaging.instance.getToken();

                            // Send the message
                            FirestoreHelper.firestoreHelper.sendMessage(
                              receiverEmail: receiver['email'],
                              msg: mes,
                              token: token!,
                            );

                            msgController.clear();

                            // Send FCM notification
                            await FCMNotificationHelper.fCMNotificationHelper
                                .sendFCM(
                              title: mes,
                              body: AuthHelper.firebaseAuth.currentUser!.email!,
                              tokan: receiver['token'],
                            )
                                .then((_) {
                              print('Message sent successfully');
                              msgController.clear();
                            }).catchError((error) {
                              print('Error sending message: $error');
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
