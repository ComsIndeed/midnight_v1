import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_history.dart';

class ChatHistoryRepository {
  final SharedPreferences _prefs;

  ChatHistoryRepository({required SharedPreferences prefs}) : _prefs = prefs;

  static const _chatHistoriesKey = 'chat_histories';

  Future<Map<String, ChatHistory>> loadChatHistories() async {
    final jsonString = _prefs.getString(_chatHistoriesKey);
    if (jsonString == null) {
      return {};
    }
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map(
      (key, value) => MapEntry(
        key,
        ChatHistory.fromMap(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> saveChatHistories(Map<String, ChatHistory> chatHistories) async {
    final jsonMap = chatHistories.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    await _prefs.setString(_chatHistoriesKey, json.encode(jsonMap));
  }
}
