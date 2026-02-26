import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../chat_logic.dart';

class SetBackgroundImageLogic extends GetxController {
  // final chatLogic = Get.find<ChatLogic>();
  final chatLogic = Get.find<ChatLogic>(tag: GetTags.chat);
  String path = '';
  void selectPicture() {
    if (path.isNotEmpty) {
      chatLogic.changeBackground(path);
      Get.back();
    } else {
      IMViews.showToast(StrRes.selectAssetsFirst);
    }
  }

  void onTapAlbum() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,
        pickerConfig:
            AssetPickerConfig(maxAssets: 1, requestType: RequestType.image));
    if (null != assets) {
      for (var asset in assets) {
        _handleAssets(asset);
      }
    }
  }

  /// 打开相机
  void onTapCamera() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      Get.context!,
      locale: Get.locale,
      pickerConfig: CameraPickerConfig(
        enableAudio: false,
        enableRecording: false,
        enableScaledPreview: true,
        resolutionPreset: ResolutionPreset.medium,
        lockCaptureOrientation: DeviceOrientation.portraitUp,
      ),
    );
    _handleAssets(entity);
  }

  void _handleAssets(AssetEntity? asset) async {
    if (null != asset) {
      Logger.print('--------assets type-----${asset.type}');
      var result = (await asset.file)!.path;
      Logger.print('--------assets path-----$path');
      switch (asset.type) {
        case AssetType.image:
          path = result;
          break;
        default:
          break;
      }

      selectPicture();
    }
  }

  recover() {
    chatLogic.clearBackground();
    Get.back();
  }
}
