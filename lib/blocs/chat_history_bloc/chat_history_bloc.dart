import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/chat_history_repository.dart';
import 'chat_history_event.dart';
import 'chat_history_state.dart';

class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  final ChatHistoryRepository _chatHistoryRepository;

  ChatHistoryBloc({required ChatHistoryRepository chatHistoryRepository})
    : _chatHistoryRepository = chatHistoryRepository,
      super(ChatHistoryInitial()) {
    on<LoadChatHistories>(_onLoadChatHistories);
    on<AddChatHistory>(_onAddChatHistory);
    on<UpdateChatHistory>(_onUpdateChatHistory);
    on<DeleteChatHistory>(_onDeleteChatHistory);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadChatHistories(
    LoadChatHistories event,
    Emitter<ChatHistoryState> emit,
  ) async {
    emit(ChatHistoryLoadInProgress());
    try {
      final chatHistories = await _chatHistoryRepository.loadChatHistories();
      emit(ChatHistoryLoadSuccess(chatHistories));
    } catch (e) {
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onAddChatHistory(
    AddChatHistory event,
    Emitter<ChatHistoryState> emit,
  ) async {
    if (state is ChatHistoryLoadSuccess) {
      final currentState = state as ChatHistoryLoadSuccess;
      final newChatHistories = {
        ...currentState.chatHistories,
        event.chatHistory.id: event.chatHistory,
      };
      emit(ChatHistoryLoadSuccess(newChatHistories));
      await _chatHistoryRepository.saveChatHistories(newChatHistories);
    }
  }

  Future<void> _onUpdateChatHistory(
    UpdateChatHistory event,
    Emitter<ChatHistoryState> emit,
  ) async {
    if (state is ChatHistoryLoadSuccess) {
      final currentState = state as ChatHistoryLoadSuccess;
      final newChatHistories = {
        ...currentState.chatHistories,
        event.chatHistory.id: event.chatHistory,
      };
      emit(ChatHistoryLoadSuccess(newChatHistories));
      await _chatHistoryRepository.saveChatHistories(newChatHistories);
    }
  }

  Future<void> _onDeleteChatHistory(
    DeleteChatHistory event,
    Emitter<ChatHistoryState> emit,
  ) async {
    if (state is ChatHistoryLoadSuccess) {
      final currentState = state as ChatHistoryLoadSuccess;
      final newChatHistories = {...currentState.chatHistories}
        ..remove(event.chatHistoryId);
      emit(ChatHistoryLoadSuccess(newChatHistories));
      await _chatHistoryRepository.saveChatHistories(newChatHistories);
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatHistoryState> emit,
  ) async {
    if (state is ChatHistoryLoadSuccess) {
      final currentState = state as ChatHistoryLoadSuccess;
      // TODO: GET MODEL GENERATION RUNNING
    }
  }
}
