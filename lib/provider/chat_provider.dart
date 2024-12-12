import 'package:flutter/material.dart';
import 'package:ChatMcp/dao/chat.dart';
import 'package:ChatMcp/dao/chat_message.dart';
import 'package:logging/logging.dart';
import 'package:ChatMcp/llm/model.dart' as llmModel;
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider extends ChangeNotifier {
  static final ChatProvider _instance = ChatProvider._internal();
  factory ChatProvider() => _instance;
  ChatProvider._internal() {
    _loadSavedModel();
  }

  Chat? _activeChat;
  List<Chat> _chats = [];

  Chat? get activeChat => _activeChat;
  List<Chat> get chats => _chats;

  static const String _modelKey = 'current_model';
  String _currentModel = "gpt-4o-mini";

  String get currentModel => _currentModel;

  Future<void> _loadSavedModel() async {
    final prefs = await SharedPreferences.getInstance();
    _currentModel = prefs.getString(_modelKey) ?? "gpt-4o-mini";
    notifyListeners();
  }

  Future<void> setModel(String model) async {
    _currentModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, model);
    notifyListeners();
  }

  Future<void> loadChats() async {
    final chatDao = ChatDao();
    _chats = await chatDao.query(
      orderBy: 'updatedAt DESC',
    );
    notifyListeners();
  }

  Future<void> setActiveChat(Chat chat) async {
    _activeChat = chat;
    notifyListeners();
  }

  Future<void> createChat(
      Chat chat, List<llmModel.ChatMessage> messages) async {
    final chatDao = ChatDao();
    final id = await chatDao.insert(chat);
    await loadChats();
    final newChat = await chatDao.queryById(id.toString());
    await addChatMessage(newChat!.id!, messages);
    setActiveChat(newChat);
  }

  Future<void> updateChat(Chat chat) async {
    final chatDao = ChatDao();
    Logger.root.info('updateChat: ${chat.toJson()}');
    await chatDao.update(chat, chat.id!.toString());
    await loadChats();
    if (_activeChat?.id == chat.id) {
      setActiveChat(chat);
    }
  }

  Future<void> deleteChat(int chatId) async {
    final chatDao = ChatDao();
    await chatDao.delete(chatId.toString());
    await loadChats();
    if (_activeChat?.id == chatId) {
      _activeChat = null;
    }
    notifyListeners();
  }

  Future<void> clearActiveChat() async {
    _activeChat = null;
    notifyListeners();
  }

  Future<void> addChatMessage(
      int chatId, List<llmModel.ChatMessage> messages) async {
    final chatMessageDao = ChatMessageDao();
    for (var message in messages) {
      await chatMessageDao.insert(ChatMessage(
        chatId: chatId,
        body: message.toString(),
      ));
    }
    notifyListeners();
  }
}