import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_event.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_state.dart';
import 'package:midnight_v1/models/chat_history.dart';
import 'package:midnight_v1/models/chat_message.dart';
import 'package:midnight_v1/pages/chats_page/widgets/chat_drawer.dart';
import 'package:midnight_v1/pages/chats_page/widgets/chat_message_widget.dart';
import 'package:midnight_v1/pages/chats_page/widgets/message_input_bar.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? _selectedChatId;

  @override
  void initState() {
    super.initState();
    context.read<ChatHistoryBloc>().add(LoadChatHistories());
  }

  void _onChatSelected(String chatId) {
    setState(() {
      _selectedChatId = chatId;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  void _onNewChat() {
    final newChat = ChatHistory(
      id: const Uuid().v4(),
      title: 'New Chat',
    );
    context.read<ChatHistoryBloc>().add(AddChatHistory(newChat));
    setState(() {
      _selectedChatId = newChat.id;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  void _onSend(String message, List<File> files) {
    if (_selectedChatId == null) return;

    // TODO: Handle file uploads and model interaction
    final userMessage = ChatMessage(role: MessageRole.user, message: message);
    final currentHistory = (context.read<ChatHistoryBloc>().state as ChatHistoryLoadSuccess)
        .chatHistories[_selectedChatId]!;
    final updatedHistory = currentHistory.copyWith(
      messages: [...currentHistory.messages, userMessage],
    );
    context.read<ChatHistoryBloc>().add(UpdateChatHistory(updatedHistory));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
          builder: (context, state) {
            if (state is ChatHistoryLoadSuccess && _selectedChatId != null) {
              final chat = state.chatHistories[_selectedChatId];
              return Text(chat?.title ?? 'Chat');
            }
            return const Text('Chat');
          },
        ),
        actions: [
          // Placeholder for model switching
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'gemini-pro',
                child: Text('Gemini Pro'),
              ),
              const PopupMenuItem<String>(
                value: 'gemini-pro-vision',
                child: Text('Gemini Pro Vision'),
              ),
            ],
          ),
        ],
      ),
      drawer: ChatDrawer(
        onChatSelected: _onChatSelected,
        onNewChat: _onNewChat,
      ),
      body: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
        builder: (context, state) {
          if (state is ChatHistoryLoadSuccess) {
            final chat = state.chatHistories[_selectedChatId];
            return Column(
              children: [
                Expanded(
                  child: chat == null
                      ? const Center(child: Text('Select a chat or start a new one.'))
                      : ListView.builder(
                          itemCount: chat.messages.length,
                          itemBuilder: (context, index) {
                            return ChatMessageWidget(message: chat.messages[index]);
                          },
                        ),
                ),
                MessageInputBar(
                  isSending: false, // TODO: Implement sending state
                  onSend: _onSend,
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
