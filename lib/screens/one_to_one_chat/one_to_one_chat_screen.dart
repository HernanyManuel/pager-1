import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/one_to_one_chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

class OneToOneChatScreen extends StatefulWidget {
  final String conversationId;

  const OneToOneChatScreen({super.key, required this.conversationId});

  @override
  State<OneToOneChatScreen> createState() => _OneToOneChatScreenState();
}

class _OneToOneChatScreenState extends State<OneToOneChatScreen> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List messages = [];
  late String currentUserId;

  @override
  void initState() {
    super.initState();

    currentUserId = context.read<OneToOneChatProvider>().currentUserId;

    /// REALTIME LISTENER
    db.child("messages/${widget.conversationId}").onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) return;

      final map = Map<dynamic, dynamic>.from(data as Map);

      final loadedMessages = map.entries.map((e) {
        final msg = Map<String, dynamic>.from(e.value);
        msg['key'] = e.key; // ⭐ IMPORTANT
        return msg;
      }).toList()..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

      setState(() => messages = loadedMessages);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context.read<OneToOneChatProvider>().sendMessage(
      conversationId: widget.conversationId,
      text: text,
      otherUserId: "",
    );

    controller.clear();
  }

  /// MESSAGE OPTIONS
  void _showMessageOptions(Map msg) {
    bool isMe = msg['senderId'] == currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                _editDialog(msg);
              },
            ),
          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<OneToOneChatProvider>().deleteMessage(
                  widget.conversationId,
                  msg['key'],
                );
              },
            ),
        ],
      ),
    );
  }

  /// EDIT DIALOG
  void _editDialog(Map msg) {
    final editController = TextEditingController(text: msg['text']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () async {
              await context.read<OneToOneChatProvider>().editMessage(
                widget.conversationId,
                msg['key'],
                editController.text.trim(),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// MESSAGE BUBBLE
  Widget messageBubble(Map msg) {
    bool isMe = msg['senderId'] == currentUserId;

    final time = DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] ?? 0);
    final formatted = DateFormat('hh:mm a').format(time);

    return GestureDetector(
      onLongPress: () => _showMessageOptions(msg),
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 10,
          right: isMe ? 10 : 60,
          top: 4,
          bottom: 4,
        ),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xffDCF8C6) // WhatsApp green
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// MESSAGE TEXT
                Text(
                  msg['text'] ?? "",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),

                const SizedBox(height: 4),

                /// TIME + EDITED
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (msg['edited'] == true)
                      const Text(
                        "edited  ",
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    Text(
                      formatted,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff075E54),
        titleSpacing: 0,
        title: Row(
          children: const [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/profile.png"),
            ),
            SizedBox(width: 10),
            Text("Chat"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/chat_bg.png"), // optional
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: messages.length,
                itemBuilder: (_, i) => messageBubble(messages[i]),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey.shade100,
            child: SafeArea(
              child: Row(
                children: [
                  /// TEXT FIELD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// SEND BUTTON
                  CircleAvatar(
                    backgroundColor: const Color(0xff25D366),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
