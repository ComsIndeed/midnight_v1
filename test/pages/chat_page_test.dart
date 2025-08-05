import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:midnight_v1/blocs/chat_history_bloc/chat_history_state.dart';
import 'package:midnight_v1/models/chat_history.dart';
import 'package:midnight_v1/models/chat_message.dart';
import 'package:midnight_v1/pages/chats_page/chat_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_page_test.mocks.dart';

@GenerateMocks([ChatHistoryBloc])
void main() {
  group('ChatPage', () {
    late MockChatHistoryBloc mockChatHistoryBloc;

    setUp(() {
      mockChatHistoryBloc = MockChatHistoryBloc();
    });

    final tChatHistory = ChatHistory(
      id: '1',
      title: 'Test Chat',
      messages: [ChatMessage(role: MessageRole.user, message: 'Hello')],
    );
    final tChatHistories = {'1': tChatHistory};

    testWidgets('renders a list of chats in the drawer', (WidgetTester tester) async {
      when(mockChatHistoryBloc.state).thenReturn(ChatHistoryLoadSuccess(tChatHistories));
      when(mockChatHistoryBloc.stream).thenAnswer((_) => Stream.value(ChatHistoryLoadSuccess(tChatHistories)));

      await tester.pumpWidget(
        BlocProvider<ChatHistoryBloc>.value(
          value: mockChatHistoryBloc,
          child: MaterialApp(home: ChatPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Test Chat'), findsOneWidget);
    });
  });
}
