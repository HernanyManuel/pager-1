import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/chat_provider.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);

    final currentUserId = chatProvider.currentUserId;
    final groups = chatProvider.conversations.where((c) => c.isGroup).toList();

    return Scaffold(
      body: groups.isEmpty
          ? Center(child: Text('belongToGroup'.tr()))
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];

                // Safe timestamp
                int timestamp = group.lastMessageTimestamp;

                // Last message formatting
                String lastMessage = group.lastMessage;
                if (group.lastMessageSenderId == currentUserId &&
                    lastMessage.isNotEmpty) {
                  lastMessage = "You: $lastMessage";
                }

                final formattedTime = timestamp > 0
                    ? DateFormat(
                        'hh:mm a',
                      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp))
                    : '';

                return InkWell(
                  onTap: () => context.push('/chat/${group.id}'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        /// GROUP AVATAR
                        CircleAvatar(
                          radius: 26.r,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.group,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 26.r,
                          ),
                        ),
                        const SizedBox(width: 12),

                        /// NAME + LAST MESSAGE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// GROUP NAME
                              Consumer(
                                builder: (context, value, child) {
                                  return Text(
                                    group.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              context
                                                  .watch<ThemeProvider>()
                                                  .isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),

                              SizedBox(height: 4.h),

                              /// LAST MESSAGE
                              Text(
                                lastMessage.isEmpty
                                    ? 'No messages yet'
                                    : lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// TIMESTAMP + UNREAD COUNT
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (formattedTime.isNotEmpty)
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (group.unreadCount > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${group.unreadCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/groups/create'),
        tooltip: 'createGroup'.tr(),
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
