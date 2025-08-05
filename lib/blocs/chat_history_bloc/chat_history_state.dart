import 'package:equatable/equatable.dart';

import '../../models/chat_history.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoadInProgress extends ChatHistoryState {}

class ChatHistoryLoadSuccess extends ChatHistoryState {
  final Map<String, ChatHistory> chatHistories;

  const ChatHistoryLoadSuccess(this.chatHistories);

  @override
  List<Object> get props => [chatHistories];
}

class ChatHistoryLoadFailure extends ChatHistoryState {
  final String error;

  const ChatHistoryLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
