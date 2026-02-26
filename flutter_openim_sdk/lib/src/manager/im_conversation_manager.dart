import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

class ConversationManager {
  final MethodChannel _channel;
  late OnConversationListener listener;

  ConversationManager(this._channel);

  /// 会话监听
  Future setConversationListener(OnConversationListener listener) {
    this.listener = listener;
    return _channel.invokeMethod('setConversationListener', _buildParam({}));
  }

  /// 获取所有会话
  Future<List<ConversationInfo>> getAllConversationList({String? operationID}) => _channel
      .invokeMethod(
          'getAllConversationList',
          _buildParam({
            "operationID": Utils.checkOperationID(operationID),
          }))
      .then((value) => Utils.toList(value, (map) => ConversationInfo.fromJson(map)));

  /// 分页获取会话
  /// [offset] 开始下标
  /// [count] 每页数量
  Future<List<ConversationInfo>> getConversationListSplit({
    int offset = 0,
    int count = 20,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getConversationListSplit',
              _buildParam({
                'offset': offset,
                'count': count,
                "operationID": Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toList(value, (map) => ConversationInfo.fromJson(map)));

  /// 查询会话，如果会话不存在会自动生成一个
  /// [sourceID] 如果是单聊会话传userID，如果是群聊会话传GroupID
  /// [sessionType] 参考[ConversationType]
  Future<ConversationInfo> getOneConversation({
    required String sourceID,
    required int sessionType,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getOneConversation',
              _buildParam({
                "sourceID": sourceID,
                "sessionType": sessionType,
                "operationID": Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => ConversationInfo.fromJson(map)));

  /// 根据会话id获取多个会话
  /// [conversationIDList] 会话id列表
  Future<List<ConversationInfo>> getMultipleConversation({
    required List<String> conversationIDList,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getMultipleConversation',
              _buildParam({
                "conversationIDList": conversationIDList,
                "operationID": Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toList(value, (map) => ConversationInfo.fromJson(map)));

  /// 设置会话草稿
  /// [conversationID] 会话id
  /// [draftText] 草稿
  Future setConversationDraft({
    required String conversationID,
    required String draftText,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setConversationDraft',
          _buildParam({
            "conversationID": conversationID,
            "draftText": draftText,
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 置顶会话
  /// [conversationID] 会话id
  /// [isPinned] true：置顶，false：取消置顶
  @Deprecated('use [setConversation] instead')
  Future pinConversation({
    required String conversationID,
    required bool isPinned,
    String? operationID,
  }) {
    final req = ConversationReq(isPinned: isPinned);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 隐藏会话
  /// [conversationID] 会话id
  Future hideConversation({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'hideConversation',
          _buildParam({
            "conversationID": conversationID,
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 隐藏所有会话
  Future hideAllConversations({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'hideAllConversations',
          _buildParam({
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 获取未读消息总数
  /// int.tryParse(count) ?? 0;
  Future<dynamic> getTotalUnreadMsgCount({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'getTotalUnreadMsgCount',
          _buildParam({
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 消息免打扰设置
  /// [conversationID] 会话id
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  @Deprecated('use [setConversation] instead')
  Future<dynamic> setConversationRecvMessageOpt({
    required String conversationID,
    required int status,
    String? operationID,
  }) {
    final req = ConversationReq(recvMsgOpt: status);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 阅后即焚
  /// [conversationID] 会话id
  /// [isPrivate] true：开启，false：关闭
  @Deprecated('use [setConversation] instead')
  Future<dynamic> setConversationPrivateChat({
    required String conversationID,
    required bool isPrivate,
    String? operationID,
  }) {
    final req = ConversationReq(isPrivateChat: isPrivate);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 删除本地以及服务器的会话
  /// [conversationID] 会话ID
  Future<dynamic> deleteConversationAndDeleteAllMsg({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'deleteConversationAndDeleteAllMsg',
          _buildParam({
            "conversationID": conversationID,
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 清空会话里的消息
  /// [conversationID] 会话ID
  Future<dynamic> clearConversationAndDeleteAllMsg({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'clearConversationAndDeleteAllMsg',
          _buildParam({
            "conversationID": conversationID,
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 删除所有本地会话
  @Deprecated('use hideAllConversations instead')
  Future<dynamic> deleteAllConversationFromLocal({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'deleteAllConversationFromLocal',
          _buildParam({
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 重置强提醒标识[GroupAtType]
  /// [conversationID] 会话id
  @Deprecated('use [setConversation] instead')
  Future<dynamic> resetConversationGroupAtType({
    required String conversationID,
    String? operationID,
  }) {
    final req = ConversationReq(groupAtType: 0);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 查询@所有人标识
  Future<dynamic> getAtAllTag({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'getAtAllTag',
          _buildParam({
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 查询@所有人标识
  String get atAllTag => 'AtAllTag';

  /// 设置阅后即焚时长
  /// [conversationID] 会话id
  /// [burnDuration] 时长s，默认30s
  @Deprecated('use [setConversation] instead')
  Future<dynamic> setConversationBurnDuration({
    required String conversationID,
    int burnDuration = 30,
    String? operationID,
  }) {
    final req = ConversationReq(burnDuration: burnDuration);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 标记消息已读
  /// [conversationID] 会话ID
  /// [messageIDList] 被标记的消息clientMsgID
  Future markConversationMessageAsRead({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'markConversationMessageAsRead',
          _buildParam({
            "conversationID": conversationID,
            "operationID": Utils.checkOperationID(operationID),
          }));

  /// 开启定期删除
  /// [isMsgDestruct] true 开启
  @Deprecated('use [setConversation] instead')
  Future<dynamic> setConversationIsMsgDestruct({
    required String conversationID,
    bool isMsgDestruct = true,
    String? operationID,
  }) {
    final req = ConversationReq(isMsgDestruct: isMsgDestruct);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 定期删除聊天记录
  /// [duration] 秒
  @Deprecated('use [setConversation] instead')
  Future<dynamic> setConversationMsgDestructTime({
    required String conversationID,
    int duration = 1 * 24 * 60 * 60,
    String? operationID,
  }) {
    final req = ConversationReq(msgDestructTime: duration);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// search Conversations
  Future<List<ConversationInfo>> searchConversations(
    String name, {
    String? operationID,
  }) {
    return _channel
        .invokeMethod(
            'searchConversations',
            _buildParam({
              'name': name,
              "operationID": Utils.checkOperationID(operationID),
            }))
        .then((value) => Utils.toList(value, (map) => ConversationInfo.fromJson(map)));
  }

  @Deprecated('use [setConversation] instead')
  Future setConversationEx(
    String conversationID, {
    String? ex,
    String? operationID,
  }) {
    final req = ConversationReq(ex: ex);

    return setConversation(conversationID, req, operationID: operationID);
  }

  /// 会话列表自定义排序规则。
  List<ConversationInfo> simpleSort(List<ConversationInfo> list) => list
    ..sort((a, b) {
      if ((a.isPinned == true && b.isPinned == true) || (a.isPinned != true && b.isPinned != true)) {
        int aCompare = a.draftTextTime! > a.latestMsgSendTime! ? a.draftTextTime! : a.latestMsgSendTime!;
        int bCompare = b.draftTextTime! > b.latestMsgSendTime! ? b.draftTextTime! : b.latestMsgSendTime!;
        if (aCompare > bCompare) {
          return -1;
        } else if (aCompare < bCompare) {
          return 1;
        } else {
          return 0;
        }
      } else if (a.isPinned == true && b.isPinned != true) {
        return -1;
      } else {
        return 1;
      }
    });

  Future changeInputStates({
    required String conversationID,
    required bool focus,
    String? operationID,
  }) {
    return _channel.invokeMethod(
      'changeInputStates',
      _buildParam(
        {
          'focus': focus,
          'conversationID': conversationID,
          'operationID': Utils.checkOperationID(operationID),
        },
      ),
    );
  }

  Future<List<int>?> getInputStates(
    String conversationID,
    String userID, {
    String? operationID,
  }) {
    return _channel
        .invokeMethod(
      'getInputStates',
      _buildParam(
        {
          'conversationID': conversationID,
          'userID': userID,
          'operationID': Utils.checkOperationID(operationID),
        },
      ),
    )
        .then((value) {
      print('getInputStates: $value');
      final result = Utils.toListMap(value);
      return List<int>.from(result);
    });
  }

  Future setConversation(
    String conversationID,
    ConversationReq req, {
    String? operationID,
  }) {
    return _channel.invokeMethod(
      'setConversation',
      _buildParam(
        {
          'conversationID': conversationID,
          'req': req.toJson(),
          'operationID': Utils.checkOperationID(operationID),
        },
      ),
    );
  }

  static Map _buildParam(Map<String, dynamic> param) {
    param["ManagerName"] = "conversationManager";
    param = Utils.cleanMap(param);
    log('param: $param');

    return param;
  }
}
