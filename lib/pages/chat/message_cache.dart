import 'dart:async';
import 'dart:math' show min, max;

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';

class MessageCache {
  final List<Message> _cache = [];
  final String conversationID;
  bool _hasMore = true;
  bool _hasMoreReverse = true;
  bool _isLoading = false;
  Completer<void>? _loadingCompleter;
  Message? _lastTakeMessage;
  Message? _lastTakeMessageReverse;

  MessageCache(this.conversationID);

  void clear() {
    _cache.clear();
    _hasMore = true;
    _hasMoreReverse = true;
    _isLoading = false;
    _loadingCompleter = null;
    _lastTakeMessage = null;
    _lastTakeMessageReverse = null;
    Logger.print('MessageCache cleared for conversationID: $conversationID');
  }

  bool get hasMore => _hasMore;
  bool get hasMoreReverse => _hasMoreReverse;
  bool get isLoading => _isLoading;

  Message? get _oldestMessage => _cache.isEmpty ? null : _cache.first;
  Message? get _newestMessage => _cache.isEmpty ? null : _cache.last;

  /// Fetches the next page of messages
  /// [count] the number of messages to fetch
  /// [refresh] whether to refresh from the beginning
  /// [reverse] whether to fetch in reverse order (newest first)
  /// [fetchFromDB] whether to force fetch from database instead of cache
  Future<List<Message>> fetchMessages({
    required int count,
    bool refresh = false,
    bool reverse = false,
    bool fetchFromDB = false,
  }) async {
    Logger.print(
        '📥 fetchMessages - count: $count, refresh: $refresh, reverse: $reverse, fetchFromDB: $fetchFromDB, cache: ${_cache.length}');

    // Wait for any ongoing loading to complete
    await _waitForLoadingComplete();

    // Handle refresh
    if (refresh) {
      _handleRefresh();
    }

    final realCount = _newestMessage == null ? 4 * count : count;
    Logger.print('🔢 Using realCount: $realCount (${_newestMessage == null ? 'first load' : 'subsequent load'})');

    // Return from cache if available and not forcing DB fetch
    if (_cache.isNotEmpty && !fetchFromDB) {
      _fetchMoreInBackground(count, reverse);
      return _getMessagesFromCache(count, reverse: reverse);
    }

    // Fetch from database
    final hasMore = reverse ? _hasMoreReverse : _hasMore;
    if (hasMore && !_isLoading) {
      await _fetchMore(realCount, reverse: reverse);
      return _getMessagesFromCache(count, reverse: reverse);
    }

    return [];
  }

  /// Wait for any ongoing loading to complete
  Future<void> _waitForLoadingComplete() async {
    if (_isLoading && _loadingCompleter != null) {
      Logger.print('⏳ Waiting for previous load to complete...');
      await _loadingCompleter!.future;
      Logger.print('✅ Previous load completed');
    }
  }

  /// Handle refresh by clearing cache and resetting state
  void _handleRefresh() {
    _lastTakeMessage = null;
    _lastTakeMessageReverse = null;
    _hasMore = true;
    _hasMoreReverse = true;
    _cache.clear();
    Logger.print('🔄 Cache cleared due to refresh');
  }

  /// Fetch more messages in background if needed
  void _fetchMoreInBackground(int count, bool reverse) {
    final hasMore = reverse ? _hasMoreReverse : _hasMore;
    if (hasMore && !_isLoading) {
      _fetchMore(count, reverse: reverse);
    }
  }

  List<Message> _getMessagesFromCache(int count, {bool reverse = false}) {
    if (_cache.isEmpty) {
      Logger.print('❌ _getMessagesFromCache: Cache is empty');
      return [];
    }

    final result = reverse ? _getMessagesReverse(count) : _getMessagesNormal(count);

    Logger.print(
        result.isNotEmpty ? '✅ Fetched ${result.length} messages from cache' : 'ℹ️ No messages fetched from cache');

    return result;
  }

  /// Get messages in reverse order (newest first)
  List<Message> _getMessagesReverse(int count) {
    final lastMessage = _lastTakeMessageReverse;

    if (lastMessage == null) {
      final result = _cache.take(count).toList();
      if (result.isNotEmpty) {
        _lastTakeMessageReverse = result.last;
      }
      return result;
    }

    final lastIndex = _cache.indexOf(lastMessage);
    return _getMessagesFromIndex(
      sourceList: _cache,
      lastIndex: lastIndex,
      count: count,
      shouldReverse: true,
      onUpdate: (message) => _lastTakeMessageReverse = message,
    );
  }

  /// Get messages in normal order (oldest first, but returned reversed)
  List<Message> _getMessagesNormal(int count) {
    final reversedCache = _cache.reversed.toList();
    final lastMessage = _lastTakeMessage;

    if (lastMessage == null) {
      final result = reversedCache.take(count).toList();
      if (result.isNotEmpty) {
        _lastTakeMessage = result.last;
      }
      return result;
    }

    final lastIndex = reversedCache.indexOf(lastMessage);
    return _getMessagesFromIndex(
      sourceList: reversedCache,
      lastIndex: lastIndex,
      count: count,
      shouldReverse: false,
      onUpdate: (message) => _lastTakeMessage = message,
    );
  }

  /// Common logic for getting messages from a specific index
  List<Message> _getMessagesFromIndex({
    required List<Message> sourceList,
    required int lastIndex,
    required int count,
    required bool shouldReverse,
    required Function(Message) onUpdate,
  }) {
    Logger.print('🔙 Last taken message index: $lastIndex');

    if (lastIndex == -1) {
      Logger.print('🔄 Message not found in cache, retaking first $count messages');
      final result = sourceList.take(count).toList();
      if (result.isNotEmpty) {
        onUpdate(shouldReverse ? result.last : result.last);
      }
      return result;
    }

    if (lastIndex >= sourceList.length - 1 || lastIndex == 0) {
      Logger.print('⏹ Reached end of cache, no more messages to take');
      return [];
    }

    final start = lastIndex + 1;
    final end = min(start + count, sourceList.length);
    final result = sourceList.sublist(start, end);

    Logger.print('📥 Taking messages from index $start to ${end - 1} (${end - start} messages)');

    if (result.isNotEmpty) {
      final finalResult = shouldReverse ? result.reversed.toList() : result;
      onUpdate(shouldReverse ? finalResult.first : result.last);
      return finalResult;
    }

    return result;
  }

  /// Fetches more messages and adds them to the cache
  Future<void> _fetchMore(int count, {bool reverse = false}) async {
    if (_isLoading) {
      Logger.print('⏳ Already loading, skipping...');
      return;
    }
    if (!_hasMore && !_hasMoreReverse) {
      Logger.print('⏹ No more messages to fetch');
      return;
    }

    _isLoading = true;
    _loadingCompleter = Completer();

    try {
      late AdvancedMessage result;

      if (reverse) {
        result = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageListReverse(
          conversationID: conversationID,
          count: count,
          startMsg: _newestMessage,
        );
        _hasMoreReverse = result.isEnd != true;
      } else {
        result = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
          conversationID: conversationID,
          count: count,
          startMsg: _oldestMessage,
        );
        _hasMore = result.isEnd != true;
      }

      final newMessages = result.messageList ?? [];

      if (newMessages.isNotEmpty) {
        final beforeAdd = _cache.length;

        _cache.addAll(newMessages);

        final afterAdd = _cache.length;

        _cache.sort((a, b) => a.sendTime!.compareTo(b.sendTime!));

        Logger.print('✅ Added ${afterAdd - beforeAdd} new messages to cache (total: $afterAdd)');
      } else {
        Logger.print('ℹ️ No new messages to add to cache');
      }
    } catch (e) {
      Logger.print('Error fetching more messages: $e');
    } finally {
      _isLoading = false;
      _loadingCompleter?.complete();
      _loadingCompleter = null;
    }
  }

  List<Message> getAllMessages() {
    return List.from(_cache.reversed);
  }

  void addNewMessage(Message message) {
    if (!_cache.any((m) => m.clientMsgID == message.clientMsgID)) {
      final insertIndex = _cache.indexWhere((m) => m.sendTime! > message.sendTime!);
      if (insertIndex == -1) {
        _cache.add(message);
      } else {
        _cache.insert(insertIndex, message);
      }
      Logger.print('New message added to cache. Cache size: ${_cache.length}');
    }
  }

  void removeMessages(List<String> clientMsgIDs) {
    _cache.removeWhere((message) => clientMsgIDs.contains(message.clientMsgID));
    Logger.print('Messages removed from cache. Cache size: ${_cache.length}');
  }

  void addMessages(List<Message> messages) {
    _cache.addAll(messages);
    Logger.print('Messages added to cache. Cache size: ${_cache.length}');
  }

  void assignMessages(List<Message> messages) {
    clear();
    _cache.addAll(messages);
    _lastTakeMessage = messages.first;
    _lastTakeMessageReverse = messages.last;
    Logger.print('Messages assigned to cache. Cache size: ${_cache.length}');
  }

  void updateMessage(Message updatedMessage) {
    final index = _cache.indexWhere((msg) => msg.clientMsgID == updatedMessage.clientMsgID);
    if (index != -1) {
      _cache.removeAt(index);

      final insertIndex = _cache.indexWhere((m) => m.sendTime! > updatedMessage.sendTime!);
      if (insertIndex == -1) {
        _cache.add(updatedMessage);
      } else {
        _cache.insert(insertIndex, updatedMessage);
      }

      Logger.print('Message updated in cache: ${updatedMessage.clientMsgID}');
    }
  }
}
