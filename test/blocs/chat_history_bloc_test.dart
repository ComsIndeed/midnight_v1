import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_event.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_state.dart';
import 'package:midnight_v1/models/chat_history.dart';
import 'package:midnight_v1/models/chat_message.dart';
import 'package:midnight_v1/repositories/chat_history_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_history_bloc_test.mocks.dart';

@GenerateMocks([ChatHistoryRepository])
void main() {
  group('ChatHistoryBloc', () {
    late ChatHistoryBloc chatHistoryBloc;
    late MockChatHistoryRepository mockChatHistoryRepository;

    setUp(() {
      mockChatHistoryRepository = MockChatHistoryRepository();
      chatHistoryBloc = ChatHistoryBloc(chatHistoryRepository: mockChatHistoryRepository);
    });

    final tChatHistory = ChatHistory(
      id: '1',
      title: 'Test Chat',
      messages: [ChatMessage(role: MessageRole.user, message: 'Hello')],
    );
    final tChatHistories = {'1': tChatHistory};

    test('initial state is ChatHistoryInitial', () {
      expect(chatHistoryBloc.state, ChatHistoryInitial());
    });

    blocTest<ChatHistoryBloc, ChatHistoryState>(
      'emits [ChatHistoryLoadInProgress, ChatHistoryLoadSuccess] when LoadChatHistories is added.',
      build: () {
        when(mockChatHistoryRepository.loadChatHistories()).thenAnswer((_) async => tChatHistories);
        return chatHistoryBloc;
      },
      act: (bloc) => bloc.add(LoadChatHistories()),
      expect: () => [
        ChatHistoryLoadInProgress(),
        ChatHistoryLoadSuccess(tChatHistories),
      ],
    );

    blocTest<ChatHistoryBloc, ChatHistoryState>(
      'emits [ChatHistoryLoadInProgress, ChatHistoryLoadFailure] when LoadChatHistories fails.',
      build: () {
        when(mockChatHistoryRepository.loadChatHistories()).thenThrow(Exception('Failed to load'));
        return chatHistoryBloc;
      },
      act: (bloc) => bloc.add(LoadChatHistories()),
      expect: () => [
        ChatHistoryLoadInProgress(),
        ChatHistoryLoadFailure('Exception: Failed to load'),
      ],
    );

    blocTest<ChatHistoryBloc, ChatHistoryState>(
      'emits [ChatHistoryLoadSuccess] when AddChatHistory is added.',
      build: () {
        when(mockChatHistoryRepository.saveChatHistories(any)).thenAnswer((_) async => {});
        return chatHistoryBloc;
      },
      seed: () => ChatHistoryLoadSuccess({}),
      act: (bloc) => bloc.add(AddChatHistory(tChatHistory)),
      expect: () => [
        ChatHistoryLoadSuccess(tChatHistories),
      ],
    );

    blocTest<ChatHistoryBloc, ChatHistoryState>(
      'emits [ChatHistoryLoadSuccess] when UpdateChatHistory is added.',
      build: () {
        when(mockChatHistoryRepository.saveChatHistories(any)).thenAnswer((_) async => {});
        return chatHistoryBloc;
      },
      seed: () => ChatHistoryLoadSuccess(tChatHistories),
      act: (bloc) => bloc.add(UpdateChatHistory(tChatHistory.copyWith(title: 'New Title'))),
      expect: () => [
        ChatHistoryLoadSuccess({'1': tChatHistory.copyWith(title: 'New Title')}),
      ],
    );

    blocTest<ChatHistoryBloc, ChatHistoryState>(
      'emits [ChatHistoryLoadSuccess] when DeleteChatHistory is added.',
      build: () {
        when(mockChatHistoryRepository.saveChatHistories(any)).thenAnswer((_) async => {});
        return chatHistoryBloc;
      },
      seed: () => ChatHistoryLoadSuccess(tChatHistories),
      act: (bloc) => bloc.add(DeleteChatHistory('1')),
      expect: () => [
        ChatHistoryLoadSuccess({}),
      ],
    );
  });
}
