import 'package:flutter/material.dart';
import 'package:myapp/models/app_user.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/screens/one_to_one_chat/one_to_one_chat_screen.dart';
import 'package:myapp/services/user_service.dart';
import 'package:provider/provider.dart';

class SelectUserForChatScreen extends StatelessWidget {
  const SelectUserForChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.read<UserService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Start Conversation")),

      body: StreamBuilder<List<AppUser>>(
        stream: userService.usersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;

          if (users.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.email),

                /// 👇 USER TAP
                onTap: () async {
                  final chatProvider = context.read<ChatProvider>();

                  final conversationId = await chatProvider
                      .createOrGetPrivateConversation(user.id);

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OneToOneChatScreen(conversationId: conversationId),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
