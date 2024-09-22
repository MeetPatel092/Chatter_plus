import 'dart:developer';
import 'package:chatter_plus/helpers/cloud_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreHelper {
  FirestoreHelper._();

  static final FirestoreHelper firestoreHelper = FirestoreHelper._();
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String _generateChatRoomId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort();
    return emails.join("_");
  }

  Future<void> addAuthenticatedUser({
    required String email,
    required String userName,
  }) async {
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> docData = doc.data();

      if (docData['email'] == email) {
        isUserExists = true;
      }
    });

    if (!isUserExists) {
      DocumentSnapshot<Map<String, dynamic>> ds =
          await firebaseFirestore.collection("records").doc("user").get();

      Map<String, dynamic>? data = ds.data();
      int id = data!['id'];
      int counter = data['counter'];

      id++;

      String? token = await firebaseMessaging.getToken();
      log('$token');

      await firebaseFirestore.collection("users").doc("$id").set({
        "email": email,
        "UserName": userName,
      });

      counter++;

      await firebaseFirestore
          .collection("records")
          .doc("user")
          .update({'id': id, 'counter': counter});
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsers() {
    return firebaseFirestore.collection("users").snapshots();
  }

  Future<void> deleteUser({required docId}) async {
    await firebaseFirestore.collection("users").doc(docId).delete();

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await firebaseFirestore.collection("records").doc("user").get();

    int counter = userDoc.data()!['counter'];

    counter--;

    await firebaseFirestore.collection("records").doc("user").update({
      'counter': counter,
    });
  }

  Future<void> sendMessage({
    required String receiverEmail,
    required String msg,
    required String token,
  }) async {
    String? senderEmail = FirebaseAuth.instance.currentUser?.email;
    if (senderEmail == null) {
      throw Exception('User is not authenticated');
    }

    String chatRoomId = _generateChatRoomId(senderEmail, receiverEmail);
    DocumentSnapshot<Map<String, dynamic>> chatroomSnapshot =
        await firebaseFirestore.collection("chatroom").doc(chatRoomId).get();

    bool isChatRoomExists = chatroomSnapshot.exists;

    if (!isChatRoomExists) {
      String? token =
          await FCMNotificationHelper.fCMNotificationHelper.fetchFMCToken();
      // await firebaseFirestore.collection("chatroom").doc(chatRoomId).set({
      //   "user": [senderEmail, receiverEmail],
      //   "token": token,
      // });

      await firebaseFirestore.collection("chatroom").doc(chatRoomId).update({
        "user": [senderEmail, receiverEmail],
        "token": token,
      });
    }

    await firebaseFirestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("messages")
        .add({
      "msg": msg,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "timeStamp": FieldValue.serverTimestamp(),
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchChat({
    required String receiverEmail,
  }) async {
    String senderEmail = FirebaseAuth.instance.currentUser!.email!;
    String chatRoomId = _generateChatRoomId(senderEmail, receiverEmail);

    return firebaseFirestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  Future<void> deleteChat({
    required String receiverEmail,
    required String messageId,
  }) async {
    String senderEmail = FirebaseAuth.instance.currentUser!.email!;
    String chatRoomId = _generateChatRoomId(senderEmail, receiverEmail);

    await firebaseFirestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  Future<void> updateMessage({
    required String updateMessage,
    required String receiverEmail,
    required String messageId,
  }) async {
    String senderEmail = FirebaseAuth.instance.currentUser!.email!;
    String chatRoomId = _generateChatRoomId(senderEmail, receiverEmail);

    await firebaseFirestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .update({
      "msg": updateMessage,
      "updatedTime": FieldValue.serverTimestamp(),
    });
  }

  Future<String?> fetchUsername({required String userId}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await firebaseFirestore.collection("users").doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['UserName'] as String?;
      } else {
        log("User document does not exist or has no data.");
        return null;
      }
    } catch (e) {
      log("Error fetching username: $e");
      return null; // Handle error as needed
    }
  }
}
