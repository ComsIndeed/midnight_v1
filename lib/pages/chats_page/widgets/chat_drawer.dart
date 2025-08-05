import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_event.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_state.dart';
import 'package:midnight_v1/models/chat_history.dart';

class ChatDrawer extends StatelessWidget {
  final Function(String) onChatSelected;
  final Function() onNewChat;

  const ChatDrawer({
    super.key,
    required this.onChatSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('Chats', style: TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
              builder: (context, state) {
                if (state is ChatHistoryLoadSuccess) {
                  final histories = state.chatHistories.values.toList();
                  return ListView.builder(
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return ListTile(
                        title: Text(history.title),
                        onTap: () => onChatSelected(history.id),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showRenameDialog(context, history),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(context, history.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat'),
            onTap: onNewChat,
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, ChatHistory history) async {
    final controller = TextEditingController(text: history.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      if (!context.mounted) return;
      context.read<ChatHistoryBloc>().add(
            UpdateChatHistory(history.copyWith(title: newTitle)),
          );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, String historyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      context.read<ChatHistoryBloc>().add(DeleteChatHistory(historyId));
    }
  }
}
