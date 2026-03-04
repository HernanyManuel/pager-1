import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OneToOneChatProvider extends ChangeNotifier {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  // List<Map> conversations = [];

  List<Map<String, dynamic>> conversations = [];
  OneToOneChatProvider() {
    _listenConversations();
  }

  /// Listen all conversations of current user in real-time
  void _listenConversations() {
    db.child('conversation').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        conversations = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final map = Map<String, dynamic>.from(data as Map);
      final convList = map.entries
          .map((e) {
            final conv = Map<String, dynamic>.from(e.value);
            conv['id'] = e.key;
            return conv;
          })
          // .where((conv) => (conv['members'] as Map).containsKey(currentUserId))
          .where((conv) {
            final members = Map<String, dynamic>.from(conv['members'] ?? {});
            return members.containsKey(currentUserId);
          })
          .toList();

      // convList.sort(
      //   (a, b) => (b['lastMessageTimestamp'] ?? 0).compareTo(
      //     a['lastMessageTimestamp'] ?? 0,
      //   ),
      // );
      convList.sort((a, b) {
        int getTimestamp(dynamic value) {
          if (value is int) return value;
          if (value is String) return int.tryParse(value) ?? 0;
          return 0; // null or ServerValue map
        }

        final t1 = getTimestamp(b['lastMessageTimestamp']);
        final t2 = getTimestamp(a['lastMessageTimestamp']);

        return t1.compareTo(t2);
      });

      conversations = convList;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String otherUserId,
  }) async {
    final message = text.trim();
    if (message.isEmpty) return;

    try {
      /// Firebase server timestamp
      final timestamp = ServerValue.timestamp;

      /// 1️⃣ Create message reference
      final messageRef = db.child('messages').child(conversationId).push();

      /// 2️⃣ Save message
      await messageRef.set({
        "id": messageRef.key, // helpful later (delete/reply)
        "senderId": currentUserId,
        "text": message,
        "type": "text", // future support (image, audio etc)
        "timestamp": timestamp,
      });

      /// 3️⃣ Update conversation (WhatsApp style)
      await db.child('conversation').child(conversationId).update({
        "conversationId": conversationId,
        "lastMessage": message,
        "lastMessageSenderId": currentUserId,
        "lastMessageType": "text",
        "lastMessageTimestamp": timestamp,

        /// members required for conversation list filtering
        "members": {currentUserId: true, otherUserId: true},
      });
    } catch (e) {
      debugPrint("Send message error: $e");
    }
  }

  /// Create or get a deterministic conversation ID for one-to-one chat
  Future<String> createOrGetPrivateConversation(String otherUserId) async {
    final ids = [currentUserId, otherUserId]..sort();
    final conversationId = "${ids[0]}_${ids[1]}";

    final ref = db.child("conversation/$conversationId");
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        "isGroup": false,
        "members": {currentUserId: true, otherUserId: true},
        "lastMessage": "",
        "lastMessageSenderId": "",
        "lastMessageTimestamp": 0,
        "createdAt": ServerValue.timestamp,
      });
    }

    return conversationId;
  }

  /// DELETE MESSAGE
  Future<void> deleteMessage(String conversationId, String messageKey) async {
    await db.child('messages/$conversationId/$messageKey').remove();
  }

  /// EDIT MESSAGE
  Future<void> editMessage(
    String conversationId,
    String messageKey,
    String newText,
  ) async {
    await db.child('messages/$conversationId/$messageKey').update({
      "text": newText,
      "edited": true,
    });
  }

  /// DELETE WHOLE CONVERSATION
  Future<void> deleteConversation(String conversationId) async {
    try {
      /// delete all messages
      await db.child('messages/$conversationId').remove();

      /// delete conversation node
      await db.child('conversation/$conversationId').remove();
    } catch (e) {
      debugPrint("Delete Conversation Error: $e");
    }
  }
}
