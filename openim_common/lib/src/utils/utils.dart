import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show DisplayFeatureType;

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:azlistview/azlistview.dart';
import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_date/dart_date.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/utils/multi_thread_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

import '../widgets/chat/chat_preview_merge_message.dart';

/// 间隔时间完成某事
class IntervalDo {
  DateTime? last;
  Timer? lastTimer;

  //call---milliseconds---call
  void run({required Function() fuc, int milliseconds = 0}) {
    DateTime now = DateTime.now();
    if (null == last || now.difference(last ?? now).inMilliseconds > milliseconds) {
      last = now;
      fuc();
    }
  }

  //---milliseconds----milliseconds....---call  在milliseconds时连续的调用会被丢弃并重置milliseconds的时间，milliseconds后才会call
  void drop({required Function() fun, int milliseconds = 0}) {
    lastTimer?.cancel();
    lastTimer = null;
    lastTimer = Timer(Duration(milliseconds: milliseconds), () {
      lastTimer!.cancel();
      lastTimer = null;
      fun.call();
    });
  }
}

class IMUtils {
  IMUtils._();

  static Future<CroppedFile?> uCrop(String path) {
    return ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: Styles.c_0089FF,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: '',
        ),
      ],
    );
  }

  static String getSuffix(String url) {
    if (!url.contains(".")) return "";
    return url.substring(url.lastIndexOf('.'), url.length);
  }

  static bool isGif(String url) {
    return IMUtils.getSuffix(url).contains("gif");
  }

  static void copy({required String text, bool showToast = true}) {
    Clipboard.setData(ClipboardData(text: text));

    if (showToast) {
      IMViews.showToast(StrRes.copySuccessfully);
    }
  }

  static List<ISuspensionBean> convertToAZList(List<ISuspensionBean> list) {
    for (int i = 0, length = list.length; i < length; i++) {
      setAzPinyinAndTag(list[i]);
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(list);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(list);

    // add topList.
    // contactsList.insertAll(0, topList);
    return list;
  }

  static ISuspensionBean setAzPinyinAndTag(ISuspensionBean info) {
    if (info is ISUserInfo) {
      String pinyin = PinyinHelper.getPinyinE(info.showName);
      if (pinyin.trim().isEmpty) {
        info.tagIndex = "#";
      } else {
        String tag = pinyin.substring(0, 1).toUpperCase();
        info.namePinyin = pinyin.toUpperCase();
        if (RegExp("[A-Z]").hasMatch(tag)) {
          info.tagIndex = tag;
        } else {
          info.tagIndex = "#";
        }
      }
    } else if (info is ISGroupMembersInfo) {
      String pinyin = PinyinHelper.getPinyinE(info.nickname!);
      if (pinyin.trim().isEmpty) {
        info.tagIndex = "#";
      } else {
        String tag = pinyin.substring(0, 1).toUpperCase();
        info.namePinyin = pinyin.toUpperCase();
        if (RegExp("[A-Z]").hasMatch(tag)) {
          info.tagIndex = tag;
        } else {
          info.tagIndex = "#";
        }
      }
    }
    return info;
  }

  static saveMediaToGallery(String mimeType, String cachePath) async {
    if (mimeType.contains('video') || mimeType.contains('image')) {
      await ImageGallerySaverPlus.saveFile(cachePath);
    }
  }

  static String? emptyStrToNull(String? str) => (null != str && str.trim().isEmpty) ? null : str;

  static bool isNotNullEmptyStr(String? str) => null != str && "" != str.trim();

  static bool isChinaMobile(String mobile) {
    RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    return exp.hasMatch(mobile);
  }

  static bool isMobile(String areaCode, String mobile) =>
      (areaCode == '+86' || areaCode == '86') ? isChinaMobile(mobile) : true;

  static Future<MediaInfo> getMediaInfo(String path) {
    final mediaInfo = VideoCompress.getMediaInfo(path);

    return mediaInfo;
  }

  /// Extracts a thumbnail (PNG image) from the first frame of a video file.
  ///
  /// Returns the generated thumbnail file. If extraction fails, throws an exception.
  static Future<File> getVideoThumbnail(File file) async {
    final path = file.path;
    final fileName = path.split('/').last.split('.').first; // Get base name without extension
    final tempDir = await createTempDir(dir: 'video');
    final targetPath = '$tempDir/$fileName.png';

    final targetFile = await VideoCompress.getFileThumbnail(path, quality: 80);
    final thumbnail = await targetFile.copy(targetPath);

    // Verify the thumbnail file exists
    if (!thumbnail.existsSync()) {
      Logger().printError(info: 'Thumbnail file not found at $targetPath');
      throw Exception('Thumbnail file was not created');
    }

    return thumbnail;
  }

  ///  compress video
  /// Compresses a video file and returns the resulting file.
  /// Aims for speed priority, moderate quality, and minimal file size while keeping resolution unchanged.
  static Future<File?> compressVideoAndGetFile(File file) async {
    final path = file.path;
    final fileName = path.split('/').last;
    final tempDir = await createTempDir(dir: 'video');
    final targetPath = '$tempDir/$fileName';
    final videoInfo = await getMediaInfo(path);
    final fileSize = videoInfo.filesize ?? 0;
    final mimeType = lookupMimeType(path);
    Logger.print('Original video path: ${file.path} size: ${fileSize / 1024 / 1024} MB, mimeType: $mimeType');

    const sizeThreshold = 100 * 1024 * 1024; // 100MB threshold

    if (fileSize > sizeThreshold || !allowVideoType(mimeType)) {
      // Compress video if size exceeds threshold
      final compressed = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.Res960x540Quality, // Moderate quality for smaller file size
      );

      final compressedLength = compressed?.file?.lengthSync() ?? 0;
      Logger.print('Compressed video path: ${compressed?.file?.path} size: ${compressedLength / 1024 / 1024} MB');

      return compressed?.file ?? file; // Return compressed file or original on failure
    } else {
      // Copy file directly if below threshold
      file.copySync(targetPath);

      return File(targetPath);
    }
  }

  ///  compress file and get file.
  static Future<File?> compressImageAndGetFile(File file, {int quality = 80}) async {
    var path = file.path;
    var name = path.substring(path.lastIndexOf("/") + 1).toLowerCase();

    if (name.endsWith('.gif')) {
      return file;
    }

    CompressFormat format = CompressFormat.jpeg;
    if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
      format = CompressFormat.jpeg;
    } else if (name.endsWith(".png")) {
      format = CompressFormat.png;
    } else if (name.endsWith(".heic")) {
      format = CompressFormat.heic;
    } else if (name.endsWith(".webp")) {
      format = CompressFormat.webp;
    }

    var targetDirectory = await getTempDirectory(name);

    if (file.path == targetDirectory.path) {
      targetDirectory = await getTempDirectory('compressed-$name');
    }

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetDirectory.path,
      quality: quality,
      minWidth: 1280,
      minHeight: 720,
      format: format,
    );

    return result != null ? File(result.path) : file;
  }

  static Future<String> createTempFile({
    required String dir,
    required String name,
  }) async {
    final storage = await createTempDir(dir: dir);
    File file = File('$storage/$name');
    if (!(await file.exists())) {
      await file.create();
    }
    return file.path;
  }

  static Future<String> createTempDir({
    required String dir,
  }) async {
    Directory directory = await getTempDirectory(dir);

    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  static Future<Directory> getTempDirectory(String dir) async {
    final storage = await getApplicationCacheDirectory();
    Directory directory = Directory('${storage.path}/$dir');

    return directory;
  }

  static int compareVersion(String val1, String val2) {
    var arr1 = val1.split(".");
    var arr2 = val2.split(".");
    int length = arr1.length >= arr2.length ? arr1.length : arr2.length;
    int diff = 0;
    int v1;
    int v2;
    for (int i = 0; i < length; i++) {
      v1 = i < arr1.length ? int.parse(arr1[i]) : 0;
      v2 = i < arr2.length ? int.parse(arr2[i]) : 0;
      diff = v1 - v2;
      if (diff == 0) {
        continue;
      } else {
        return diff > 0 ? 1 : -1;
      }
    }
    return diff;
  }

  static Future<int> getPlatform() async {
    if (Platform.isAndroid) {
      if (await isFoldable) {
        return 2;
      }
      return isTablet ? 8 : 2;
    } else {
      return isTablet ? 9 : 1;
    }
  }

  static Future<bool> get isFoldable async {
    final context = Get.context;

    if (context == null) {
      return false;
    }

    final mediaQuery = MediaQuery.of(context);

    final hasFoldableDisplay = mediaQuery.displayFeatures.any(
      (feature) => feature.type == DisplayFeatureType.hinge || feature.type == DisplayFeatureType.fold,
    );

    final nativeIsFoldable = await FoldableDetector.isFoldable;

    Logger.print(
        'Determine if it is a foldable screen, hasFoldableDisplay: $hasFoldableDisplay, nativeIsFoldable: $nativeIsFoldable');

    return hasFoldableDisplay || nativeIsFoldable;
  }

  static bool get isTablet {
    final context = Get.context;

    if (context == null) {
      return false;
    }

    return context.isTablet;
  }

  // md5 加密
  static String? generateMD5(String? data) {
    if (null == data) return null;
    var content = const Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }

  static String buildGroupApplicationID(GroupApplicationInfo info) {
    return '${info.groupID}-${info.creatorUserID}-${info.reqTime}-${info.userID}--${info.inviterUserID}';
  }

  static String buildFriendApplicationID(FriendApplicationInfo info) {
    /// 1686566803245 1686727472913
    return '${info.fromUserID}-${info.toUserID}-${info.createTime}';
  }

  static Future<String> getCacheFileDir() async {
    return (await getTemporaryDirectory()).absolute.path;
  }

  static Future<String> getDownloadFileDir() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await PathProviderPlatform.instance.getDownloadsPath();
      } catch (err, st) {
        Logger.print('failed to get downloads path: $err, $st');
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath!;
  }

  static Future<String> toFilePath(String path) async {
    var filePrefix = 'file://';
    var uriPrefix = 'content://';
    if (path.contains(filePrefix)) {
      path = path.substring(filePrefix.length);
    } else if (path.contains(uriPrefix)) {
      // Uri uri = Uri.parse(thumbnailPath); // Parsing uri string to uri
      File file = await toFile(path);
      path = file.path;
    }
    return path;
  }

  /// 消息列表超过5分钟则显示时间
  static List<Message> calChatTimeInterval(List<Message> list, {bool calculate = true}) {
    if (!calculate) return list;
    var milliseconds = list.firstOrNull?.sendTime;
    if (null == milliseconds) return list;
    list.first.exMap['showTime'] = true;
    var lastShowTimeStamp = milliseconds;
    for (var i = 0; i < list.length; i++) {
      var index = i + 1;
      if (index <= list.length - 1) {
        var cur = getDateTimeByMs(lastShowTimeStamp);
        var milliseconds = list.elementAt(index).sendTime!;
        var next = getDateTimeByMs(milliseconds);
        if (next.difference(cur).inMinutes > 5) {
          lastShowTimeStamp = milliseconds;
          list.elementAt(index).exMap['showTime'] = true;
        }
      }
    }
    return list;
  }

  static String getChatTimeline(int ms, [String formatToday = 'HH:mm']) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(ms);
    final languageCode = Get.locale?.languageCode ?? 'zh';
    final isChinese = languageCode == 'zh';
    final now = DateTime.now();
    final formatter = DateFormat(formatToday);

    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1 && difference.inSeconds >= 0) {
      return isChinese ? '刚刚' : 'Just now';
    }

    if (isSameDay(dateTime, now)) {
      return formatter.format(
        dateTime,
      );
    }

    final yesterday = now.subtract(Duration(days: 1));

    if (isSameDay(dateTime, yesterday)) {
      return isChinese ? '昨天 ${formatter.format(dateTime)}' : 'Yesterday ${formatter.format(dateTime)}';
    }

    if (isSameWeek(dateTime, now)) {
      final weekDay = DateFormat('EEEE').format(dateTime);
      final weekDayChinese = {
        'Monday': StrRes.monday,
        'Tuesday': StrRes.tuesday,
        'Wednesday': StrRes.wednesday,
        'Thursday': StrRes.thursday,
        'Friday': StrRes.friday,
        'Saturday': StrRes.saturday,
        'Sunday': StrRes.sunday,
      };
      return '${isChinese ? weekDayChinese[weekDay]! : weekDay} ${formatter.format(dateTime)}';
    }

    if (dateTime.year == now.year) {
      final dateFormat = isChinese ? 'MM月dd HH:mm' : 'MM/dd HH:mm';
      return DateFormat(dateFormat).format(dateTime);
    }

    final dateFormat = isChinese ? 'yyyy年MM月dd HH:mm' : 'yyyy/MM/dd HH:mm';
    return DateFormat(dateFormat).format(dateTime);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static bool isSameWeek(DateTime date1, DateTime date2) {
    final weekStart = date2.subtract(Duration(days: date2.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    return date1.isAfter(weekStart.subtract(Duration(days: 1))) && date1.isBefore(weekEnd.add(Duration(days: 1)));
  }

  static String getCallTimeline(int milliseconds) {
    if (DateUtil.yearIsEqualByMs(milliseconds, DateUtil.getNowDateMs())) {
      return formatDateMs(milliseconds, format: 'MM/dd');
    } else {
      return formatDateMs(milliseconds, format: 'yyyy/MM/dd');
    }
  }

  static DateTime getDateTimeByMs(int ms, {bool isUtc = false}) {
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
  }

  static String formatDateMs(int ms, {bool isUtc = false, String? format}) {
    return DateUtil.formatDateMs(ms, format: format, isUtc: isUtc);
  }

  static String seconds2HMS(int seconds) {
    int h = 0;
    int m = 0;
    int s = 0;
    int temp = seconds % 3600;
    if (seconds > 3600) {
      h = seconds ~/ 3600;
      if (temp != 0) {
        if (temp > 60) {
          m = temp ~/ 60;
          if (temp % 60 != 0) {
            s = temp % 60;
          }
        } else {
          s = temp;
        }
      }
    } else {
      m = seconds ~/ 60;
      if (seconds % 60 != 0) {
        s = seconds % 60;
      }
    }
    if (h == 0) {
      return '${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}';
    }
    return "${h < 10 ? '0$h' : h}:${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}";
  }

  /// 消息按时间线分组
  static Map<String, List<Message>> groupingMessage(List<Message> list) {
    var languageCode = Get.locale?.languageCode ?? 'zh';
    var group = <String, List<Message>>{};
    for (var message in list) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(message.sendTime!);
      String dateStr;
      if (DateUtil.isToday(message.sendTime!)) {
        // 今天
        dateStr = languageCode == 'zh' ? '今天' : 'Today';
      } else if (DateUtil.isWeek(message.sendTime!)) {
        // 本周
        dateStr = languageCode == 'zh' ? '本周' : 'This Week';
      } else if (dateTime.isThisMonth) {
        //当月
        dateStr = languageCode == 'zh' ? '这个月' : 'This Month';
      } else {
        // 按年月
        dateStr = DateUtil.formatDate(dateTime, format: 'yyyy/MM');
      }
      group[dateStr] = (group[dateStr] ?? <Message>[])..add(message);
    }
    return group;
  }

  static String mutedTime(int mss) {
    int days = mss ~/ (60 * 60 * 24);
    int hours = (mss % (60 * 60 * 24)) ~/ (60 * 60);
    int minutes = (mss % (60 * 60)) ~/ 60;
    int seconds = mss % 60;
    return "${_combTime(days, StrRes.day)}${_combTime(hours, StrRes.hours)}${_combTime(minutes, StrRes.minute)}${_combTime(seconds, StrRes.seconds)}";
  }

  static String _combTime(int value, String unit) => value > 0 ? '$value$unit' : '';

  /// 搜索聊天内容显示规则
  static String calContent({
    required String content,
    required String key,
    required TextStyle style,
    required double usedWidth,
  }) {
    var size = calculateTextSize(content, style);
    var lave = 1.sw - usedWidth;
    if (size.width < lave) {
      return content;
    }
    var index = content.indexOf(key);
    if (index == -1 || index > content.length - 1) return content;
    var start = content.substring(0, index);
    var end = content.substring(index);
    var startSize = calculateTextSize(start, style);
    var keySize = calculateTextSize(key, style);
    if (startSize.width + keySize.width > lave) {
      if (index - 4 > 0) {
        return "...${content.substring(index - 4)}";
      } else {
        return "...$end";
      }
    } else {
      return content;
    }
  }

  // Here it is!
  static Size calculateTextSize(
    String text,
    TextStyle style, {
    int maxLines = 1,
    double maxWidth = double.infinity,
  }) {
    final TextPainter textPainter =
        TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size;
  }

  static TextPainter getTextPainter(
    String text,
    TextStyle style, {
    int maxLines = 1,
    double maxWidth = double.infinity,
  }) =>
      TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: maxWidth);

  static bool isUrlValid(String? url) {
    if (null == url || url.isEmpty) {
      return false;
    }
    return url.startsWith("http://") || url.startsWith("https://");
  }

  static bool isValidUrl(String? urlString) {
    if (null == urlString || urlString.isEmpty) {
      return false;
    }
    Uri? uri = Uri.tryParse(urlString);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      return true;
    }
    return false;
  }

  static String getGroupMemberShowName(GroupMembersInfo membersInfo) {
    return membersInfo.userID == OpenIM.iMManager.userID ? StrRes.you : membersInfo.nickname!;
  }

  static String getShowName(String? userID, String? nickname) {
    return (userID == OpenIM.iMManager.userID ? OpenIM.iMManager.userInfo.nickname : nickname) ?? '';
  }

  /// 通知解析
  static String? parseNtf(
    Message message, {
    bool isConversation = false,
  }) {
    String? text;
    try {
      if (message.contentType! >= 1000) {
        final elem = message.notificationElem!;
        final map = json.decode(elem.detail!);
        switch (message.contentType) {
          case MessageType.groupCreatedNotification:
            {
              final ntf = GroupNotification.fromJson(map);
              // a 创建了群聊
              final label = StrRes.createGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.groupInfoSetNotification:
            {
              final ntf = GroupNotification.fromJson(map);
              if (ntf.group?.notification != null && ntf.group!.notification!.isNotEmpty) {
                return isConversation ? ntf.group!.notification! : null;
              }
              // a 修改了群资料
              final label = StrRes.editGroupInfoNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.memberQuitNotification:
            {
              final ntf = QuitGroupNotification.fromJson(map);
              // a 退出了群聊
              final label = StrRes.quitGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.quitUser!)]);
            }
            break;
          case MessageType.memberInvitedNotification:
            {
              final ntf = InvitedJoinGroupNotification.fromJson(map);
              // a 邀请 b 加入群聊
              final label = StrRes.invitedJoinGroupNtf;
              final b = ntf.invitedUserList?.map((e) => getGroupMemberShowName(e)).toList().join('、');
              text = sprintf(label, [getGroupMemberShowName(ntf.inviterUser ?? ntf.opUser!), b ?? '']);
            }
            break;
          case MessageType.memberKickedNotification:
            {
              final ntf = KickedGroupMemeberNotification.fromJson(map);
              // b 被 a 踢出群聊
              final label = StrRes.kickedGroupNtf;
              final b = ntf.kickedUserList!.map((e) => getGroupMemberShowName(e)).toList().join('、');
              text = sprintf(label, [b, getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.memberEnterNotification:
            {
              final ntf = EnterGroupNotification.fromJson(map);
              // a 加入了群聊
              final label = StrRes.joinGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.entrantUser!)]);
            }
            break;
          case MessageType.dismissGroupNotification:
            {
              final ntf = GroupNotification.fromJson(map);
              // a 解散了群聊
              final label = StrRes.dismissGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.groupOwnerTransferredNotification:
            {
              final ntf = GroupRightsTransferNoticication.fromJson(map);
              // a 将群转让给了 b
              final label = StrRes.transferredGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!), getGroupMemberShowName(ntf.newGroupOwner!)]);
            }
            break;
          case MessageType.groupMemberMutedNotification:
            {
              final ntf = MuteMemberNotification.fromJson(map);
              // b 被 a 禁言
              final label = StrRes.muteMemberNtf;
              final c = ntf.mutedSeconds;
              text = sprintf(
                  label, [getGroupMemberShowName(ntf.mutedUser!), getGroupMemberShowName(ntf.opUser!), mutedTime(c!)]);
            }
            break;
          case MessageType.groupMemberCancelMutedNotification:
            {
              final ntf = MuteMemberNotification.fromJson(map);
              // b 被 a 取消了禁言
              final label = StrRes.muteCancelMemberNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.mutedUser!), getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.groupMutedNotification:
            {
              final ntf = MuteMemberNotification.fromJson(map);
              // a 开起了群禁言
              final label = StrRes.muteGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.groupCancelMutedNotification:
            {
              final ntf = MuteMemberNotification.fromJson(map);
              // a 关闭了群禁言
              final label = StrRes.muteCancelGroupNtf;
              text = sprintf(label, [getGroupMemberShowName(ntf.opUser!)]);
            }
            break;
          case MessageType.friendApplicationApprovedNotification:
            {
              // 你们已成为好友
              text = StrRes.friendAddedNtf;
            }
            break;
          case MessageType.burnAfterReadingNotification:
            {
              final ntf = BurnAfterReadingNotification.fromJson(map);
              if (ntf.isPrivate == true) {
                text = StrRes.openPrivateChatNtf;
              } else {
                text = StrRes.closePrivateChatNtf;
              }
            }
            break;
          case MessageType.groupMemberInfoChangedNotification:
            final ntf = GroupMemberInfoChangedNotification.fromJson(map);
            text = sprintf(StrRes.memberInfoChangedNtf, [getGroupMemberShowName(ntf.opUser!)]);
            break;
          case MessageType.groupInfoSetAnnouncementNotification:
            if (isConversation) {
              final ntf = GroupNotification.fromJson(map);
              text = ntf.group?.notification ?? '';
            }
            break;
          case MessageType.groupInfoSetNameNotification:
            final ntf = GroupNotification.fromJson(map);
            text = sprintf(StrRes.whoModifyGroupName, [getGroupMemberShowName(ntf.opUser!), ntf.group?.groupName]);
            break;
        }
      }
    } catch (e, s) {
      Logger.print('Exception details:\n $e');
      Logger.print('Stack trace:\n $s');
    }
    return text;
  }

  static String parseMsg(
    Message message, {
    bool isConversation = false,
    bool replaceIdToNickname = false,
  }) {
    String? content;
    try {
      switch (message.contentType) {
        case MessageType.text:
          content = message.textElem!.content!;
          break;
        case MessageType.atText:
          content = message.atTextElem!.text!;
          if (replaceIdToNickname) {
            var list = message.atTextElem?.atUsersInfo;
            list?.forEach((e) {
              content = content?.replaceAll(
                '@${e.atUserID}',
                '@${getAtNickname(e.atUserID!, e.groupNickname!)}',
              );
            });
          }
          break;
        case MessageType.picture:
          content = '[${StrRes.picture}]';
          break;
        case MessageType.voice:
          content = '[${StrRes.voice}]';
          break;
        case MessageType.video:
          content = '[${StrRes.video}]';
          break;
        case MessageType.file:
          content = '[${StrRes.file}]';
          break;
        case MessageType.location:
          content = '[${StrRes.location}]';
          break;
        case MessageType.merger:
          content = '[${StrRes.chatRecord}]';
          break;
        case MessageType.card:
          content = '[${StrRes.carte}]';
          break;
        case MessageType.quote:
          content = message.quoteElem?.text ?? '';
          break;
        case MessageType.revokeMessageNotification:
          var isSelf = message.sendID == OpenIM.iMManager.userID;
          var map = json.decode(message.notificationElem!.detail!);
          var info = RevokedInfo.fromJson(map);
          if (message.isSingleChat) {
            // 单聊
            if (isSelf) {
              content = sprintf(StrRes.revokeMsg, [StrRes.you]);
            } else {
              content = sprintf(StrRes.revokeMsg, [message.senderNickname]);
            }
          } else {
            // 群聊撤回包含：撤回自己消息，群组或管理员撤回其他人消息
            if (info.revokerID == info.sourceMessageSendID) {
              if (isSelf) {
                content = sprintf(StrRes.revokeMsg, [StrRes.you]);
              } else {
                content = sprintf(StrRes.revokeMsg, [message.senderNickname]);
              }
            } else {
              late String revoker;
              late String sender;
              if (info.revokerID == OpenIM.iMManager.userID) {
                revoker = StrRes.you;
              } else {
                revoker = info.revokerNickname!;
              }
              if (info.sourceMessageSendID == OpenIM.iMManager.userID) {
                sender = StrRes.you;
              } else {
                sender = info.sourceMessageSenderNickname!;
              }

              content = sprintf(StrRes.aRevokeBMsg, [revoker, sender]);
            }
          }
          break;
        case MessageType.customFace:
          content = '[${StrRes.emoji}]';
          break;
        case MessageType.custom:
          var data = message.customElem!.data;
          var map = json.decode(data!);
          var customType = map['customType'];
          var customData = map['data'];
          switch (customType) {
            case CustomMessageType.call:
              var type = map['data']['type'];
              content = '[${type == 'video' ? StrRes.callVideo : StrRes.callVoice}]';
              break;
            case CustomMessageType.emoji:
              content = '[${StrRes.emoji}]';
              break;
            case CustomMessageType.tag:
              if (null != customData['textElem']) {
                final textElem = TextElem.fromJson(customData['textElem']);
                content = textElem.content;
              } else if (null != customData['soundElem']) {
                // final soundElem = SoundElem.fromJson(customData['soundElem']);
                content = '[${StrRes.voice}]';
              } else {
                content = '[${StrRes.unsupportedMessage}]';
              }
              break;
            case CustomMessageType.blockedByFriend:
              content = StrRes.blockedByFriendHint;
              break;
            case CustomMessageType.deletedByFriend:
              content = sprintf(
                StrRes.deletedByFriendHint,
                [''],
              );
              break;
            case CustomMessageType.removedFromGroup:
              content = StrRes.removedFromGroupHint;
              break;
            case CustomMessageType.groupDisbanded:
              content = StrRes.groupDisbanded;
              break;
            default:
              content = '[${StrRes.unsupportedMessage}]';
              break;
          }
          break;
        case MessageType.oaNotification:
          // OA通知
          String detail = message.notificationElem!.detail!;
          var oa = OANotification.fromJson(json.decode(detail));
          content = oa.text!;
          break;
        default:
          content = '[${StrRes.unsupportedMessage}]';
          break;
      }
    } catch (e, s) {
      Logger.print('Exception details:\n $e');
      Logger.print('Stack trace:\n $s');
    }
    content = content?.replaceAll("\n", " ");
    return content ?? '[${StrRes.unsupportedMessage}]';
  }

  static dynamic parseCustomMessage(Message message) {
    try {
      switch (message.contentType) {
        case MessageType.custom:
          {
            var data = message.customElem!.data;
            var map = json.decode(data!);
            var customType = map['customType'];
            switch (customType) {
              case CustomMessageType.call:
                {
                  final duration = map['data']['duration'];
                  final state = map['data']['state'];
                  final type = map['data']['type'];
                  String? content;
                  switch (state) {
                    case 'beHangup':
                    case 'hangup':
                      content = sprintf(StrRes.callDuration, [seconds2HMS(duration)]);
                      break;
                    case 'cancel':
                      content = StrRes.cancelled;
                      break;
                    case 'beCanceled':
                      content = StrRes.cancelledByCaller;
                      break;
                    case 'reject':
                      content = StrRes.rejected;
                      break;
                    case 'beRejected':
                      content = StrRes.rejectedByCaller;
                      break;
                    case 'timeout':
                      content = StrRes.callTimeout;
                      break;
                    case 'networkError':
                      content = StrRes.networkAnomaly;
                      break;
                    case 'otherAccepted':
                      content = sprintf(StrRes.otherCallHandle, [StrRes.accept]);
                      break;
                    case 'otherReject':
                      content = sprintf(StrRes.otherCallHandle, [StrRes.rejectCall]);
                      break;
                    case 'interruption':
                      content = StrRes.callingInterruption;
                      break;
                    default:
                      break;
                  }
                  if (content != null) {
                    return {
                      'viewType': CustomMessageType.call,
                      'type': type,
                      'content': content,
                    };
                  }
                }
                break;
              case CustomMessageType.emoji:
                map['data']['viewType'] = CustomMessageType.emoji;
                return map['data'];
              case CustomMessageType.tag:
                map['data']['viewType'] = CustomMessageType.tag;
                return map['data'];
              case CustomMessageType.deletedByFriend:
              case CustomMessageType.blockedByFriend:
              case CustomMessageType.removedFromGroup:
              case CustomMessageType.groupDisbanded:
                return {'viewType': customType};
            }
          }
      }
    } catch (e, s) {
      Logger.print('Exception details:\n $e');
      Logger.print('Stack trace:\n $s');
    }
    return null;
  }

  static Map<String, String> getAtMapping(
    Message message,
    Map<String, String> newMapping,
  ) {
    final mapping = <String, String>{};
    try {
      if (message.contentType == MessageType.atText) {
        final atUserIDs = message.atTextElem!.atUserList!;
        final atUserInfos = message.atTextElem!.atUsersInfo!;

        for (final userID in atUserIDs) {
          final groupNickname =
              (newMapping[userID] ?? atUserInfos.firstWhere((e) => e.atUserID == userID).groupNickname) ?? userID;
          mapping[userID] = getAtNickname(userID, groupNickname);
        }
      }
    } catch (_) {}
    return mapping;
  }

  static String getAtNickname(String atUserID, String atNickname) {
    // String nickname = atNickname;
    // if (atUserID == OpenIM.iMManager.uid) {
    //   nickname = StrRes.you;
    // } else if (atUserID == 'atAllTag') {
    //   nickname = StrRes.everyone;
    // }
    return atUserID == 'atAllTag' ? StrRes.everyone : atNickname;
  }

  static void previewUrlPicture(
    List<MediaSource> sources, {
    int currentIndex = 0,
    String? heroTag,
  }) =>
      navigator?.push(TransparentRoute(
        builder: (BuildContext context) => GestureDetector(
          onTap: () => Get.back(),
          child: ChatPicturePreview(
            currentIndex: currentIndex,
            images: sources,
            heroTag: heroTag,
            onLongPress: (url) {
              IMViews.openDownloadSheet(
                url,
                onDownload: () => saveImage(context, url),
              );
            },
          ),
        ),
      ));

  /*Get.to(
        () => ChatPicturePreview(
          currentIndex: currentIndex,
          images: urls,
          // heroTag: message.clientMsgID,
          heroTag: urls.elementAt(currentIndex),
          onLongPress: (url) {
            IMViews.openDownloadSheet(
              url,
              onDownload: () => HttpUtil.saveUrlPicture(url),
            );
          },
        ),
        // opaque: false,
        transition: Transition.cupertino,
        // popGesture: true,
        // fullscreenDialog: true,
      );*/

  static void previewCustomFace(Message message) {
    final face = message.faceElem;
    final map = json.decode(face!.data!);
    final urls = <String>[map['url']];
    // previewUrlPicture(urls);
    Get.to(
      () => ChatFacePreview(url: map['url']),
      popGesture: true,
      transition: Transition.cupertino,
    );
  }

  static void previewPicture(
    Message message, {
    List<Message> allList = const [],
  }) {
    if (allList.isEmpty) {
      // 不在使用，直接在chatview中
      previewUrlPicture(
        [
          MediaSource(
              url: message.pictureElem!.sourcePicture!.url!, thumbnail: message.pictureElem!.snapshotPicture!.url!)
        ],
        currentIndex: 0,
      );
    } else {
      final picList = allList
          .where((element) => element.contentType == MessageType.picture || element.contentType == MessageType.video)
          .toList();
      final index = picList.indexOf(message);
      final urls = picList.map((e) {
        if (e.contentType == MessageType.picture) {
          return MediaSource(url: e.pictureElem!.sourcePicture!.url!, thumbnail: e.pictureElem!.snapshotPicture!.url!);
        } else {
          return MediaSource(url: e.videoElem!.videoUrl!, thumbnail: e.videoElem!.snapshotUrl!);
        }
      }).toList();
      previewUrlPicture(urls, currentIndex: index == -1 ? 0 : index);
    }
  }

  static void previewVideo(Message message) {
    navigator!.push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ChatVideoPlayerView(
            path: message.videoElem?.videoPath,
            url: message.videoElem?.videoUrl,
            coverUrl: message.videoElem?.snapshotUrl,
            heroTag: null,
            onDownload: (url, file) {
              if (file != null) {
                HttpUtil.saveFileToGallery(file);
              } else {
                HttpUtil.saveUrlVideo(url!);
              }
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        opaque: false));
  }

// 用于存储 clientMsgID 和 cachePath 的映射关系
  static final Map<String, String> _cachePathMap = {};

  static Future<void> _initCachePathMap() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheMap = prefs.getString('cachePathMap');
    if (cacheMap != null) {
      final decodedMap = Map<String, String>.from(jsonDecode(cacheMap));
      _cachePathMap.addAll(decodedMap);
      Logger.print('Loaded cachePathMap from SP: $_cachePathMap');
    } else {
      Logger.print('No cachePathMap found in SP, starting fresh');
    }
  }

  static Future<void> _saveCachePathMap() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMap = jsonEncode(_cachePathMap);
    await prefs.setString('cachePathMap', encodedMap);
    Logger.print('Saved cachePathMap to SP: $_cachePathMap');
  }

  static Future<String> _getUniqueCachePath(String dir, String? fileName) async {
    if (fileName == null) {
      return '$dir/unnamed_${DateTime.now().millisecondsSinceEpoch}';
    }

    final nameAndExt = fileName.split('.');
    final name = nameAndExt.first;
    final ext = nameAndExt.length > 1 ? nameAndExt.last : '';

    var cachePath = '$dir/$fileName';
    var counter = 0;

    while (await isExitFile(cachePath)) {
      counter++;
      cachePath = ext.isEmpty ? '$dir/$name($counter)' : '$dir/$name($counter).$ext';
    }

    return cachePath;
  }

  static Future<void> previewFile(Message message) async {
    if (_cachePathMap.isEmpty) {
      await _initCachePathMap();
    }

    final fileElem = message.fileElem;
    if (fileElem == null) {
      Logger.print('fileElem is null, aborting');
      return;
    }

    final clientMsgID = message.clientMsgID;
    final sourcePath = fileElem.filePath;
    final url = fileElem.sourceUrl;
    final fileName = fileElem.fileName;
    final fileSize = fileElem.fileSize;

    if (clientMsgID == null) {
      Logger.print('clientMsgID is null, aborting');
      return;
    }

    Logger.print(
        'clientMsgID: $clientMsgID, sourcePath: $sourcePath, url: $url, fileName: $fileName, fileSize: $fileSize');

    final dir = await getDownloadFileDir();
    String? cachePath = _cachePathMap[clientMsgID];
    if (cachePath == null && fileName != null) {
      cachePath = '$dir/$fileName';
    }

    // 1. 检查 sourcePath
    if (sourcePath != null && await isExitFile(sourcePath)) {
      final actualSize = await File(sourcePath).length();
      Logger.print('sourcePath exists, actualSize: $actualSize, expectedSize: $fileSize');
      if (fileSize == null || actualSize == fileSize) {
        Logger.print('Using sourcePath: $sourcePath');
        _previewOrOpenFile(sourcePath, fileName, message);
        _cachePathMap[clientMsgID] = sourcePath;
        await _saveCachePathMap();
        return;
      }
    } else {
      Logger.print('sourcePath not available or doesn\'t exist');
    }

    // 2. 检查已映射的 cachePath
    if (cachePath != null && await isExitFile(cachePath)) {
      final actualSize = await File(cachePath).length();
      Logger.print('cachePath exists, actualSize: $actualSize, expectedSize: $fileSize');
      if (fileSize == null || actualSize == fileSize) {
        Logger.print('Using cachePath: $cachePath');
        _previewOrOpenFile(cachePath, fileName, message);
        return;
      }
    } else {
      Logger.print('cachePath not available or doesn\'t exist: $cachePath');
    }

    // 3. 需要下载时生成唯一路径并下载
    if (url != null && isUrlValid(url)) {
      if (Get.isRegistered<DownloadController>()) {
        final uniqueCachePath = await _getUniqueCachePath(dir, fileName);
        Logger.print('Starting download from url: $url to $uniqueCachePath');
        final controller = Get.find<DownloadController>();
        controller.clickFileMessage(
          url,
          uniqueCachePath,
          onCompleted: (sandboxPath, externalPath) async {
            // 下载完成后验证文件是否有效
            if (await isExitFile(uniqueCachePath)) {
              final actualSize = await File(uniqueCachePath).length();
              if (fileSize == null || actualSize == fileSize) {
                _cachePathMap[clientMsgID] = uniqueCachePath;
                await _saveCachePathMap();
                Logger.print('Download completed, cachePath saved: $uniqueCachePath');
              } else {
                Logger.print('Downloaded file size mismatch: actual $actualSize, expected $fileSize');
              }
            } else {
              Logger.print('Download failed, file not found at: $uniqueCachePath');
            }

            if (!Platform.isIOS) {
              final result = Platform.isAndroid ? '${StrRes.saveSuccessfully} $externalPath' : StrRes.saveSuccessfully;
              IMViews.showToast(result);
            }
          },
        );
      } else {
        Logger.print('DownloadController not registered');
      }
    } else {
      Logger.print('No valid url for download');
    }
  }

  static void _previewOrOpenFile(String path, String? fileName, Message message) {
    final mimeType = lookupMimeType(fileName ?? '');
    Logger.print('Previewing file: $path, mimeType: $mimeType');
    if (mimeType != null && (allowVideoType(mimeType) || mimeType.contains('image'))) {
      previewMediaFile(
        context: Get.context!,
        currentIndex: 0,
        mediaMessages: [message],
      );
    } else {
      openFileByOtherApp(path);
    }
  }

  static Future previewMediaFile(
      {required BuildContext context,
      required int currentIndex,
      required List<Message> mediaMessages,
      bool muted = false,
      bool Function(int)? onAutoPlay,
      ValueChanged<int>? onPageChanged,
      bool onlySave = false,
      ValueChanged<OperateType>? onOperate}) async {
    Logger.print('previewMediaFile', fileName: 'utils.dart');
    void saveVideo(BuildContext ctx, String url, {int? length}) async {
      final cachedVideoControllerService = CachedVideoControllerService(DefaultCacheManager());
      final cached = await cachedVideoControllerService.getCacheFile(url);

      if (cached != null) {
        LoadingView.singleton.show();
        await HttpUtil.saveFileToGallery(
          cached,
          name: url.split('/').last,
          isVideo: true,
        );
        LoadingView.singleton.dismiss();
      } else {
        EasyLoading.showProgress(
          0,
          status: '0%',
          dismissOnTap: true,
        );

        final downloader = MultiThreadDownloader(url: url, fileName: url.split('/').last, length: length);

        callback(EasyLoadingStatus status) {
          if (status == EasyLoadingStatus.dismiss) {
            downloader.cancel();
            EasyLoading.removeCallback(callback);
            EasyLoading.dismiss();
          }
        }

        EasyLoading.addStatusCallback(callback);

        final filePath = await downloader.start(
          onProgress: (value) {
            EasyLoading.showProgress(
              value,
              status: '${(value * 100).toStringAsFixed(2)}%',
              dismissOnTap: true,
            );
          },
        );

        if (filePath != null) {
          HttpUtil.saveFileToGallery(
            File(filePath),
            name: url.split('/').last,
            showToast: LoadingView.singleton.isProgressVisible,
            isVideo: true,
          );
        }
        EasyLoading.removeCallback(callback);
        EasyLoading.dismiss();
      }
    }

    void showBottomBar(int index) {
      if (onOperate == null && !onlySave) {
        return;
      }

      PhotoBrowserBottomBar.show(
        context,
        onlySave: onlySave,
        onPressedButton: (type) async {
          final msg = mediaMessages[index];
          switch (type) {
            case OperateType.save:
              if (msg.videoElem != null) {
                saveVideo(context, msg.videoElem!.videoUrl!, length: msg.videoElem!.videoSize);
              } else {
                final url = msg.pictureElem?.sourcePicture?.url;
                if (url?.isNotEmpty == true) {
                  saveImage(context, url!);
                }
              }
              break;
            case OperateType.forward:
              onOperate?.call(type);
              break;
          }
        },
      );
    }

    final cacheContents = (await getTemporaryDirectory()).path;

    final sources = mediaMessages.map((e) {
      final isVideo = e.isVideoType;
      String? path;

      if (isVideo) {
        path = e.videoElem?.videoPath;
      } else {
        path = e.pictureElem?.sourcePath;
      }

      if (path != null && !File(path).existsSync()) {
        final subContents = path.split(isVideo ? 'video/' : 'image/').last;
        path = '$cacheContents/${isVideo ? "video" : "image"}/$subContents';
      }

      return MediaSource(
        url: isVideo ? e.videoElem?.videoUrl : e.pictureElem?.sourcePicture?.url,
        thumbnail: (isVideo ? e.videoElem?.snapshotUrl : e.pictureElem?.snapshotPicture?.url)
                ?.adjustThumbnailAbsoluteString(960) ??
            '',
        file: path != null ? File(path) : null,
        tag: e.clientMsgID,
        isVideo: isVideo,
      );
    }).toList();

    final mb = MediaBrowser(
      sources: sources,
      initialIndex: currentIndex,
      onAutoPlay: (index) => onAutoPlay != null ? onAutoPlay(index) : false,
      muted: muted,
      onSave: (index) {
        final msg = mediaMessages[index];
        final url = msg.videoElem?.videoUrl;

        if (url != null) {
          saveVideo(context, url, length: msg.videoElem!.videoSize);
        }
      },
      onLongPress: (index) {
        showBottomBar(index);
      },
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // ignore: use_build_context_synchronously
    return Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return mb;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    )
        .then((result) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      return result;
    });
  }

  static void saveImage(BuildContext ctx, String url) async {
    EasyLoading.show(dismissOnTap: true);
    final imageFile = await getCachedImageFile(url);

    if (imageFile != null) {
      await HttpUtil.saveFileToGallery(
        imageFile,
        name: url.split('/').last,
      );

      EasyLoading.dismiss();
    } else {
      HttpUtil.saveUrlPicture(url, onCompletion: () {
        EasyLoading.dismiss();
      });
    }
  }

  static openFileByOtherApp(String path) async {
    OpenResult result = await OpenFilex.open(path);
    if (result.type == ResultType.noAppToOpen) {
      IMViews.showToast("没有可支持的应用");
    } else if (result.type == ResultType.permissionDenied) {
      IMViews.showToast("无权限访问");
    } else if (result.type == ResultType.fileNotFound) {
      IMViews.showToast("文件已失效");
    }
  }

  static void previewLocation(Message message) {
    var location = message.locationElem;
    Map detail = json.decode(location!.description!);
    Logger.print('previewLocation ${location.latitude}  ${location.longitude}');
    Get.to(
      () => MapView(
        latitude: location.latitude!,
        longitude: location.longitude!,
        address1: detail['name'],
        address2: detail['addr'],
      ),
      // () => ChatWebViewMap(
      //   mapAppKey: Config.mapKey,
      //   latitude: location?.latitude,
      //   longitude: location?.longitude,
      // ),
      transition: Transition.cupertino,
      popGesture: true,
      // fullscreenDialog: true,
    );
  }

  static void previewMergeMessage(
    Message message, {
    Function(Message)? meetingItemClick,
    Function(Message)? quoteItemClick,
  }) =>
      Get.to(
        () => ChatPreviewMergeMsgView(
          title: message.mergeElem!.title!,
          messageList: message.mergeElem!.multiMessage ?? [],
          meetingItemClick: meetingItemClick,
          quoteItemClick: quoteItemClick,
        ),
        preventDuplicates: false,
        transition: Transition.cupertino,
        popGesture: true,
      );

  static void previewCarteMessage(
    Message message,
    Function(UserInfo userInfo)? onViewUserInfo,
  ) =>
      onViewUserInfo?.call(UserInfo.fromJson(message.cardElem!.toJson()));

  /// 处理消息点击事件
  /// [messageList] 预览图片消息的时候，可用左右滑动
  static void parseClickEvent(
    Message message, {
    List<Message> messageList = const [],
    Function(UserInfo userInfo)? onViewUserInfo,
    Function(Message msg)? meetingItemClick,
    Function(Message msg)? quoteItemClick,
    VoidCallback? onForward,
    bool onlySave = false,
  }) async {
    if (message.contentType == MessageType.picture || message.contentType == MessageType.video) {
      var mediaMessages = messageList
          .where((element) => element.contentType == MessageType.picture || element.contentType == MessageType.video)
          .toList();
      var currentIndex = mediaMessages.indexOf(message);
      if (currentIndex == -1) {
        mediaMessages = [message];
        currentIndex = 0;
      }
      previewMediaFile(
        context: Get.context!,
        currentIndex: currentIndex,
        mediaMessages: mediaMessages,
        onlySave: onlySave,
        onOperate: (value) {
          if (value == OperateType.forward) {
            onForward?.call();
          }
        },
      );
    } else if (message.contentType == MessageType.file) {
      previewFile(message);
    } else if (message.contentType == MessageType.card) {
      previewCarteMessage(message, onViewUserInfo);
    } else if (message.contentType == MessageType.merger) {
      previewMergeMessage(message, meetingItemClick: meetingItemClick, quoteItemClick: quoteItemClick);
    } else if (message.contentType == MessageType.location) {
      previewLocation(message);
    } else if (message.contentType == MessageType.customFace) {
      previewCustomFace(message);
    }
  }

  static Future<bool> isExitFile(String? path) async {
    return isNotNullEmptyStr(path) ? await File(path!).exists() : false;
  }

  //fileExt 文件后缀名
  static String? getMediaType(final String filePath) {
    var fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
    var fileExt = fileName.substring(fileName.lastIndexOf("."));
    switch (fileExt.toLowerCase()) {
      case ".jpg":
      case ".jpeg":
      case ".jpe":
        return "image/jpeg";
      case ".png":
        return "image/png";
      case ".bmp":
        return "image/bmp";
      case ".gif":
        return "image/gif";
      case ".json":
        return "application/json";
      case ".svg":
      case ".svgz":
        return "image/svg+xml";
      case ".mp3":
        return "audio/mpeg";
      case ".mp4":
        return "video/mp4";
      case ".mov":
        return "video/mov";
      case ".htm":
      case ".html":
        return "text/html";
      case ".css":
        return "text/css";
      case ".csv":
        return "text/csv";
      case ".txt":
      case ".text":
      case ".conf":
      case ".def":
      case ".log":
      case ".in":
        return "text/plain";
    }
    return null;
  }

  /// 将字节数转化为MB
  static String formatBytes(int bytes) {
    int kb = 1024;
    int mb = kb * 1024;
    int gb = mb * 1024;
    if (bytes >= gb) {
      return sprintf("%.1f GB", [bytes / gb]);
    } else if (bytes >= mb) {
      double f = bytes / mb;
      return sprintf(f > 100 ? "%.0f MB" : "%.1f MB", [f]);
    } else if (bytes > kb) {
      double f = bytes / kb;
      return sprintf(f > 100 ? "%.0f KB" : "%.1f KB", [f]);
    } else {
      return sprintf("%d B", [bytes]);
    }
  }

  static bool allowImageType(String? mimeType) {
    final result = mimeType?.contains('png') == true ||
        mimeType?.contains('jpeg') == true ||
        mimeType?.contains('gif') == true ||
        mimeType?.contains('bmp') == true ||
        mimeType?.contains('webp') == true ||
        mimeType?.contains('heic') == true;

    return result;
  }

  static bool allowVideoType(String? mimeType) {
    final result = mimeType?.contains('mp4') == true ||
        mimeType?.contains('3gpp') == true ||
        mimeType?.contains('webm') == true ||
        mimeType?.contains('x-msvideo') == true ||
        mimeType?.contains('quicktime') == true;

    return result;
  }

  // static IconData fileIcon(String fileName) {
  //   var mimeType = lookupMimeType(fileName) ?? '';
  //   if (mimeType == 'application/pdf') {
  //     return FontAwesomeIcons.solidFilePdf;
  //   } else if (mimeType == 'application/msword' ||
  //       mimeType ==
  //           'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
  //     return FontAwesomeIcons.solidFileWord;
  //   } else if (mimeType == 'application/vnd.ms-excel' ||
  //       mimeType ==
  //           'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
  //     return FontAwesomeIcons.solidFileExcel;
  //   } else if (mimeType == 'application/vnd.ms-powerpoint') {
  //     return FontAwesomeIcons.solidFilePowerpoint;
  //   } else if (mimeType.startsWith('audio/')) {
  //   } else if (mimeType == 'application/zip' ||
  //       mimeType == 'application/x-rar-compressed') {
  //     return FontAwesomeIcons.solidFileZipper;
  //   } else if (mimeType.startsWith('audio/')) {
  //     return FontAwesomeIcons.solidFileAudio;
  //   } else if (mimeType.startsWith('video/')) {
  //     return FontAwesomeIcons.solidFileVideo;
  //   } else if (mimeType.startsWith('image/')) {
  //     return FontAwesomeIcons.solidFileImage;
  //   } else if (mimeType == 'text/plain') {
  //     return FontAwesomeIcons.solidFileCode;
  //   }
  //   return FontAwesomeIcons.solidFileLines;
  // }

  static String fileIcon(String fileName) {
    var mimeType = lookupMimeType(fileName) ?? '';
    if (mimeType == 'application/pdf') {
      return ImageRes.filePdf;
    } else if (mimeType == 'application/msword' ||
        mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return ImageRes.fileWord;
    } else if (mimeType == 'application/vnd.ms-excel' ||
        mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return ImageRes.fileExcel;
    } else if (mimeType == 'application/vnd.ms-powerpoint') {
      return ImageRes.filePpt;
    } else if (mimeType.startsWith('audio/')) {
    } else if (mimeType == 'application/zip' || mimeType == 'application/x-rar-compressed') {
      return ImageRes.fileZip;
    }
    /*else if (mimeType.startsWith('audio/')) {
      return FontAwesomeIcons.solidFileAudio;
    } else if (mimeType.startsWith('video/')) {
      return FontAwesomeIcons.solidFileVideo;
    } else if (mimeType.startsWith('image/')) {
      return FontAwesomeIcons.solidFileImage;
    } else if (mimeType == 'text/plain') {
      return FontAwesomeIcons.solidFileCode;
    }*/
    return ImageRes.fileUnknown;
  }

  static String createSummary(Message message) {
    return '${message.senderNickname}：${parseMsg(message, replaceIdToNickname: true)}';
  }

  static List<UserInfo>? convertSelectContactsResultToUserInfo(result) {
    if (result is Map) {
      final checkedList = <UserInfo>[];
      final values = result.values;
      for (final value in values) {
        if (value is ISUserInfo) {
          checkedList.add(UserInfo.fromJson(value.toJson()));
        } else if (value is UserFullInfo) {
          checkedList.add(UserInfo.fromJson(value.toJson()));
        } else if (value is FriendInfo) {
          checkedList.add(UserInfo.fromJson(value.toJson()));
        } else if (value is UserInfo) {
          checkedList.add(value);
        }
      }
      return checkedList;
    }
    return null;
  }

  static List<String>? convertSelectContactsResultToUserID(result) {
    if (result is Map) {
      final checkedList = <String>[];
      final values = result.values;
      for (final value in values) {
        if (value is UserInfo || value is FriendInfo || value is UserFullInfo || value is ISUserInfo) {
          checkedList.add(value.userID!);
        }
      }
      return checkedList;
    }
    return null;
  }

  static convertCheckedListToMap(List<dynamic>? checkedList) {
    if (null == checkedList) return null;
    final checkedMap = <String, dynamic>{};
    for (var item in checkedList) {
      if (item is ConversationInfo) {
        checkedMap[item.isSingleChat ? item.userID! : item.groupID!] = item;
      } else if (item is UserInfo || item is UserFullInfo || item is ISUserInfo || item is FriendInfo) {
        checkedMap[item.userID!] = item;
      } else if (item is GroupInfo) {
        checkedMap[item.groupID] = item;
      }
    }
    return checkedMap;
  }

  static List<Map<String, String?>> convertCheckedListToForwardObj(List<dynamic> checkedList) {
    final map = <Map<String, String?>>[];
    for (var item in checkedList) {
      if (item is UserInfo ||
          item is UserFullInfo ||
          item is ISUserInfo ||
          item is FriendInfo ||
          item is PublicUserInfo) {
        map.add({'nickname': item.nickname, 'faceURL': item.faceURL});
      } else if (item is GroupInfo) {
        map.add({'nickname': item.groupName, 'faceURL': item.faceURL});
      } else if (item is ConversationInfo) {
        map.add({'nickname': item.showName, 'faceURL': item.faceURL});
      }
    }
    return map;
  }

  static String? convertCheckedToUserID(dynamic info) {
    if (info is UserInfo || info is UserFullInfo || info is ISUserInfo || info is FriendInfo) {
      return info.userID;
    } else if (info is ConversationInfo) {
      return info.userID;
    }

    return null;
  }

  static String? convertCheckedToGroupID(dynamic info) {
    if (info is GroupInfo) {
      return info.groupID;
    } else if (info is ConversationInfo) {
      return info.groupID;
    }
    return null;
  }

  static List<Map<String, String?>> convertCheckedListToShare(Iterable<dynamic> checkedList) {
    final map = <Map<String, String?>>[];
    for (var item in checkedList) {
      if (item is UserInfo || item is UserFullInfo || item is ISUserInfo || item is FriendInfo) {
        map.add({'userID': item.userID, 'groupID': null});
      } else if (item is GroupInfo) {
        map.add({'userID': null, 'groupID': item.groupID});
      } else if (item is ConversationInfo) {
        map.add({'userID': item.userID, 'groupID': item.groupID});
      }
    }
    return map;
  }

  static String getWorkMomentsTimeline(int ms) {
    final locTimeMs = DateTime.now().millisecondsSinceEpoch;
    final languageCode = Get.locale?.languageCode ?? 'zh';
    final isZH = languageCode == 'zh';

    if (DateUtil.isToday(ms, locMs: locTimeMs)) {
      return isZH ? '今天' : 'Today';
    }

    if (DateUtil.isYesterdayByMs(ms, locTimeMs)) {
      return isZH ? '昨天' : 'Yesterday';
    }

    if (DateUtil.isWeek(ms, locMs: locTimeMs)) {
      return DateUtil.getWeekdayByMs(ms, languageCode: languageCode);
    }

    if (DateUtil.yearIsEqualByMs(ms, locTimeMs)) {
      return formatDateMs(ms, format: isZH ? 'MM月dd' : 'MM/dd');
    }

    return formatDateMs(ms, format: isZH ? 'yyyy年MM月dd' : 'yyyy/MM/dd');
  }

  static Future<bool> checkingBiometric(LocalAuthentication auth) => auth.authenticate(
        localizedReason: '扫描您的指纹（或面部或其他）以进行身份验证',
        options: const AuthenticationOptions(
          // stickyAuth: true,
          biometricOnly: true,
        ),
        authMessages: <AuthMessages>[
          const AndroidAuthMessages(
            cancelButton: '不，谢谢',
            biometricNotRecognized: '未能识别。 再试一次。',
            biometricHint: '验证身份',
            biometricSuccess: '成功',
            biometricRequiredTitle: '需要身份验证',
            goToSettingsDescription: "您的设备上未设置生物认证。 去设置 > 安全以添加生物识别身份验证。",
            goToSettingsButton: '前往设置',
            deviceCredentialsRequiredTitle: '需要设备凭据',
            deviceCredentialsSetupDescription: '需要设备凭据',
            signInTitle: '需要身份验证',
          ),
          const IOSAuthMessages(
            cancelButton: '不，谢谢',
            goToSettingsButton: '前往设置',
            goToSettingsDescription: '您的设备上未设置生物认证。 请启用手机上的Touch ID或Face ID。',
            lockOut: '生物认证被禁用。 请锁定和解锁您的屏幕以启用它。',
          ),
        ],
      );

  static String safeTrim(String text) {
    String pattern = '(${[regexAt, regexAtAll].join('|')})';
    RegExp regex = RegExp(pattern);
    Iterable<Match> matches = regex.allMatches(text);
    int? start;
    int? end;
    for (Match match in matches) {
      String? matchText = match.group(0);
      start ??= match.start;
      end = match.end;
      Logger.print("Matched: $matchText  start: $start  end: $end");
    }
    if (null != start && null != end) {
      final startStr = text.substring(0, start).trimLeft();
      final middleStr = text.substring(start, end);
      final endStr = text.substring(end).trimRight();
      return '$startStr$middleStr$endStr';
    }
    return text.trim();
  }

  static String getTimeFormat1() {
    bool isZh = Get.locale!.languageCode.toLowerCase().contains("zh");
    return isZh ? 'yyyy年MM月dd日' : 'yyyy/MM/dd';
  }

  static String getTimeFormat2() {
    bool isZh = Get.locale!.languageCode.toLowerCase().contains("zh");
    return isZh ? 'yyyy年MM月dd日 HH时mm分' : 'yyyy/MM/dd HH:mm';
  }

  static String getTimeFormat3() {
    bool isZh = Get.locale!.languageCode.toLowerCase().contains("zh");
    return isZh ? 'MM月dd日 HH时mm分' : 'MM/dd HH:mm';
  }

  static bool isValidPassword(String password) => RegExp(
        // r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!.])(?=.{6,20}$)',
        // r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]{6,20}$',
        // r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{6,20}$',
        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{6,20}$',
      ).hasMatch(password);

  static TextInputFormatter getPasswordFormatter() => FilteringTextInputFormatter.allow(
        // RegExp(r'[a-zA-Z0-9]'),
        RegExp(r'[a-zA-Z0-9\S]'),
      );

  /// Request permission to run in background.
  ///
  /// Android only. If platform is not android, do nothing.
  ///
  /// [title] is the title of notification.
  ///
  /// [text] is the text of notification.
  ///
  /// [isRetry] is whether this is a retry request.
  /// If [isRetry] is true, the request is retried once after 1 second.
  ///
  /// If [isRetry] is false, the request is retried once after 1 second if an error occurs.
  static Future requestBackgroundPermission({required String title, required String text, bool isRetry = false}) async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      Logger.print('[Background] requestBackgroundPermission start, isRetry: $isRetry');
      bool hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        hasPermissions = await FlutterBackground.initialize(
          androidConfig: FlutterBackgroundAndroidConfig(
              notificationTitle: title,
              notificationText: text,
              notificationImportance: AndroidNotificationImportance.high,
              notificationIcon: const AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
              shouldRequestBatteryOptimizationsOff: true,
              showBadge: false),
        );
      }
      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.enableBackgroundExecution();
        Logger.print('[Background] Background execution enabled successfully');
      } else {
        Logger.print(
            '[Background] hasPermissions: $hasPermissions, isEnabled: ${FlutterBackground.isBackgroundExecutionEnabled}');
      }
    } catch (e, s) {
      Logger.print('[Background] Error: $e, stack: $s');
      if (!isRetry) {
        return await Future<void>.delayed(
            const Duration(seconds: 1), () => requestBackgroundPermission(title: title, text: text, isRetry: true));
      }
    }
  }

  static Future<bool> disableBackgroundExecution() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Background execution is only supported on Android.');
    }

    if (!FlutterBackground.isBackgroundExecutionEnabled) {
      return false;
    }
    try {
      return await FlutterBackground.disableBackgroundExecution();
    } catch (e) {
      Logger.print('Error disabling background execution: $e');
      return false;
    }
  }

  static final Map<String, int> _voiceMessageClickMap = {};
  static const String _voiceMessageClickKey = 'voice_message_clicks';

  static Future<void> initVoiceMessageClickMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_voiceMessageClickKey);
      if (data != null) {
        final Map<String, dynamic> decoded = json.decode(data);
        _voiceMessageClickMap.addAll(Map<String, int>.from(decoded));
        Logger.print('Loaded voice message click map: $_voiceMessageClickMap');
      }
    } catch (e) {
      Logger.print('Error loading voice message click map: $e');
    }
  }

  static Future<void> _saveVoiceMessageClickMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_voiceMessageClickKey, json.encode(_voiceMessageClickMap));
    } catch (e) {
      Logger.print('Error saving voice message click map: $e');
    }
  }

  static void recordVoiceMessageClick(String messageId) {
    _voiceMessageClickMap[messageId] = DateTime.now().millisecondsSinceEpoch;
    _saveVoiceMessageClickMap();
  }

  static bool isVoiceMessageClicked(String messageId) {
    return _voiceMessageClickMap.containsKey(messageId);
  }

  static int? getVoiceMessageClickTime(String messageId) {
    return _voiceMessageClickMap[messageId];
  }

  static Future<void> clearAllVoiceMessageClickRecords() async {
    _voiceMessageClickMap.clear();
    await _saveVoiceMessageClickMap();
  }

  static Future<void> clearVoiceMessageClickRecord(String messageId) async {
    _voiceMessageClickMap.remove(messageId);
    await _saveVoiceMessageClickMap();
  }
}

extension PlatformExt on Platform {
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  static bool get isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}
