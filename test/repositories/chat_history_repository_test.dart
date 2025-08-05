import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:midnight_v1/models/chat_history.dart';
import 'package:midnight_v1/models/chat_message.dart';
import 'package:midnight_v1/repositories/chat_history_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_history_repository_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('ChatHistoryRepository', () {
    late ChatHistoryRepository repository;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = ChatHistoryRepository(prefs: mockPrefs);
    });

    final tChatHistory = ChatHistory(
      id: '1',
      title: 'Test Chat',
      messages: [ChatMessage(role: MessageRole.user, message: 'Hello')],
    );
    final tChatHistories = {'1': tChatHistory};
    final tChatHistoriesJson = json.encode(
      tChatHistories.map((key, value) => MapEntry(key, value.toMap())),
    );

    test('loadChatHistories returns a map of chat histories when prefs is not null', () async {
      when(mockPrefs.getString(any)).thenReturn(tChatHistoriesJson);

      final result = await repository.loadChatHistories();

      expect(result, tChatHistories);
      verify(mockPrefs.getString('chat_histories'));
    });

    test('loadChatHistories returns an empty map when prefs is null', () async {
      when(mockPrefs.getString(any)).thenReturn(null);

      final result = await repository.loadChatHistories();

      expect(result, {});
      verify(mockPrefs.getString('chat_histories'));
    });

    test('saveChatHistories saves a map of chat histories to prefs', () async {
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      await repository.saveChatHistories(tChatHistories);

      verify(mockPrefs.setString('chat_histories', tChatHistoriesJson));
    });
  });
}
