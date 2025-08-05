import 'package:equatable/equatable.dart';

enum MessageRole { user, model }

class ChatMessage extends Equatable {
  final MessageRole role;
  final String message;

  const ChatMessage({required this.role, required this.message});

  @override
  List<Object?> get props => [role, message];

  Map<String, dynamic> toMap() {
    return {
      'role': role.name,
      'message': message,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: MessageRole.values.byName(map['role']),
      message: map['message'] as String,
    );
  }
}
