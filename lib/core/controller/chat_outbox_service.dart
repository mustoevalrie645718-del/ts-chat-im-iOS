import 'dart:io';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ChatOutboxService extends GetxService {
  /// Callback to remove a message from the UI by clientMsgID
  void Function(String clientMsgID)? onTempMessageRemoved;

  /// Callback to add a new message to the UI
  void Function(Message message)? onNewMessageAdded;

  void compressAndSendVideo({
    required Message tempMessage,
    required String originalPath,
    required String thumbnailPath,
    required int duration,
    required String mimeType,
    required String conversationID,
  }) async {
    Logger.print('[ChatOutboxService] Start compressing video: $originalPath');
    File? compressedFile;
    try {
      compressedFile = await IMUtils.compressVideoAndGetFile(File(originalPath));
    } catch (e) {
      Logger.print('[ChatOutboxService] Video compression failed: $e');
    }

    final videoPath = compressedFile?.path ?? originalPath;
    Logger.print('[ChatOutboxService] Compression finished. New path: $videoPath');

    // Delete the temporary local message
    await OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(
      conversationID: conversationID,
      clientMsgID: tempMessage.clientMsgID!,
    );

    // Notify UI to remove temp message
    onTempMessageRemoved?.call(tempMessage.clientMsgID!);

    // Re-create the video message with the compressed path
    final durationSec = duration > 1000.0 ? duration / 1000.0 : duration;
    final message = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(
      videoPath: videoPath,
      videoType: mimeType,
      duration: durationSec.toInt(),
      snapshotPath: thumbnailPath,
    );

    // Restore necessary fields if needed (though createVideoMessageFromFullPath handles creation)
    // Make sure we set the correct receiver/group
    message.recvID = tempMessage.recvID;
    message.groupID = tempMessage.groupID;

    // Notify UI to add the new message
    onNewMessageAdded?.call(message);

    // Send the actual video message
    OpenIM.iMManager.messageManager
        .sendMessage(
      message: message,
      userID: tempMessage.recvID,
      groupID: tempMessage.groupID,
      offlinePushInfo: Config.offlinePushInfo,
    )
        .then((v) {
      Logger.print('[ChatOutboxService] Video sent successfully: ${v.clientMsgID}');
    }).catchError((e) {
      Logger.print('[ChatOutboxService] Failed to send video: $e');
    });
  }
}
