import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/providers/one_to_one_chat_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../one_to_one_chat/one_to_one_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ConversationListScreen extends StatelessWidget {
  final bool useFab;
  const ConversationListScreen({super.key, this.useFab = true});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference db = FirebaseDatabase.instance.ref();

    return Scaffold(
      // appBar: AppBar(title: const Text("Chats")),
      body: Consumer<OneToOneChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.conversations.isEmpty) {
            return const Center(child: Text("No conversations"));
          }

          return ListView.builder(
            itemCount: chatProvider.conversations.length,
            itemBuilder: (context, index) {
              final conv = chatProvider.conversations[index];
              // final members = Map<String, dynamic>.from(conv['members']);
              final members = Map<String, dynamic>.from(conv['members'] ?? {});
              final otherUserId = members.keys.firstWhere(
                (id) => id != currentUserId,
                orElse: () => currentUserId,
              );

              return FutureBuilder<DataSnapshot>(
                future: db.child('users/$otherUserId').get(),
                builder: (context, snapshot) {
                  String userName = otherUserId;
                  if (snapshot.hasData && snapshot.data!.value != null) {
                    final userMap = Map<String, dynamic>.from(
                      snapshot.data!.value as Map,
                    );
                    userName = userMap['name'] ?? otherUserId;
                  }
                  // Safe timestamp conversion
                  int timestamp = 0;
                  if (conv['lastMessageTimestamp'] != null) {
                    timestamp = conv['lastMessageTimestamp'] is int
                        ? conv['lastMessageTimestamp']
                        : int.tryParse(
                                conv['lastMessageTimestamp'].toString(),
                              ) ??
                              0;
                  }

                  return InkWell(
                    onLongPress: () {
                      _showConversationOptions(context, conv['id'], userName);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OneToOneChatScreen(conversationId: conv['id']),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          /// PROFILE IMAGE
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.green.shade200,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// NAME + LAST MESSAGE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// USER NAME
                                Consumer(
                                  builder: (context, value, child) {
                                    return Text(
                                      userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color:
                                            context
                                                .watch<ThemeProvider>()
                                                .isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 4.h),

                                /// LAST MESSAGE
                                Text(
                                  _buildLastMessage(conv, currentUserId),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// TIME
                          if (timestamp > 0)
                            Text(
                              DateFormat('hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(timestamp),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _buildLastMessage(Map<String, dynamic> conv, String currentUserId) {
    final lastMessage = (conv['lastMessage'] ?? '').toString().trim();

    final senderId = (conv['lastMessageSenderId'] ?? '').toString();

    if (lastMessage.isEmpty) {
      return "No messages yet";
    }

    if (senderId == currentUserId) {
      return "You: $lastMessage";
    }

    return lastMessage;
  }

  void _showConversationOptions(
    BuildContext context,
    String conversationId,
    String userName,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              "Delete chat with $userName",
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);

              /// confirm dialog
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Conversation"),
                  content: const Text(
                    "Are you sure you want to delete this chat?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await context.read<OneToOneChatProvider>().deleteConversation(
                  conversationId,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
