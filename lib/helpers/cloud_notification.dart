import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FCMNotificationHelper {
  FCMNotificationHelper._();
  static final FCMNotificationHelper fCMNotificationHelper =
      FCMNotificationHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> fetchFMCToken() async {
    String? token = await firebaseMessaging.getToken();
    return token;
  }

  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString(
          'assets/chatter-p-firebase-adminsdk-uasdw-8260beec6c.json'),
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  Future<void> sendFCM({
    required String title,
    required String body,
    required String tokan,
  }) async {
    try {
      final String accessToken = await getAccessToken();

      // Update your project ID correctly
      const String fcmUrl =
          'https://fcm.googleapis.com/v1/projects/chatter-p/messages:send';

      // Prepare the notification body
      final Map<String, dynamic> myBody = {
        'message': {
          'token': tokan,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      };

      // Make the POST request to FCM
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(myBody),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('-------------------');
        print('Notification sent successfully');
        print('-------------------');
      } else {
        print('-------------------');
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('-------------------');
      }
    } catch (e) {
      // Handle exceptions like network issues, invalid tokens, etc.
      print('Error sending FCM notification: $e');
    }
  }
}
