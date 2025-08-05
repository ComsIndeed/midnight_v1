import 'package:equatable/equatable.dart';
import 'package:midnight_v1/models/chat_message.dart';

import '../../models/chat_history.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadChatHistories extends ChatHistoryEvent {}

class AddChatHistory extends ChatHistoryEvent {
  final ChatHistory chatHistory;

  const AddChatHistory(this.chatHistory);

  @override
  List<Object> get props => [chatHistory];
}

class UpdateChatHistory extends ChatHistoryEvent {
  final ChatHistory chatHistory;

  const UpdateChatHistory(this.chatHistory);

  @override
  List<Object> get props => [chatHistory];
}

class DeleteChatHistory extends ChatHistoryEvent {
  final String chatHistoryId;

  const DeleteChatHistory(this.chatHistoryId);

  @override
  List<Object> get props => [chatHistoryId];
}

class SendMessage extends ChatHistoryEvent {
  final String chatId;
  final ChatMessage message;

  const SendMessage(this.chatId, this.message);

  @override
  List<Object> get props => [chatId, message];
}
