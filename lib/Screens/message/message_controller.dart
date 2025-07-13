import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageControllerProvider =
    StateNotifierProvider<MessageController, MessageState>((ref) {
      return MessageController();
    });

class MessageState {
  // You can expand this state with message list, filters, etc.
  final String? title;

  MessageState({this.title = ""});

  MessageState copyWith({String? title}) {
    return MessageState(title: title ?? this.title);
  }
}

class MessageController extends StateNotifier<MessageState> {
  MessageController() : super(MessageState());

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
  }
}
