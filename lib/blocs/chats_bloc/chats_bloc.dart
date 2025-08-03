import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/chats_bloc/chats_event.dart';
import 'package:midnight_v1/blocs/chats_bloc/chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsState(prefsKey: 'chats'));
}
