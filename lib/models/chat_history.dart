import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class ChatHistory extends Equatable {
  final String id;
  final String title;
  final List<ChatMessage> messages;

  const ChatHistory({
    required this.id,
    required this.title,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [id, title, messages];

  ChatHistory copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
  }) {
    return ChatHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory ChatHistory.fromMap(Map<String, dynamic> map) {
    return ChatHistory(
      id: map['id'] as String,
      title: map['title'] as String,
      messages: List<ChatMessage>.from(
        (map['messages'] as List<dynamic>).map<ChatMessage>(
          (x) => ChatMessage.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
