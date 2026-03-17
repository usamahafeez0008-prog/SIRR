import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/constant/zego_config.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();

  factory ZegoCallService() {
    return _instance;
  }

  ZegoCallService._internal();

  bool _initialized = false;
  String? _currentUserId;

  Future<void> initZego(String userId, String userName) async {
    if (userId.isEmpty) return;

    if (_initialized && _currentUserId == userId) {
      debugPrint('Zego already initialized for: $userId');
      return;
    }

    if (_initialized && _currentUserId != userId) {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      _initialized = false;
      _currentUserId = null;
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "zego_call",
          channelName: "Call",
          sound: "zego_incoming",
          icon: "ic_launcher",
        ),
        iOSNotificationConfig: ZegoIOSNotificationConfig(),
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onIncomingCallReceived: (callID, inviter, type, invitees, customData) {
          debugPrint(
            'Incoming call received => callID: $callID, inviter: ${inviter.id}, type: $type',
          );
        },
        onIncomingCallDeclineButtonPressed: () {
          debugPrint('Incoming call decline pressed');
        },
        onIncomingCallAcceptButtonPressed: () {
          debugPrint('Incoming call accept pressed');
        },
        onOutgoingCallAccepted: (callID, callee) {
          debugPrint('Outgoing call accepted => $callID, callee: ${callee.id}');
        },
        onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
          ShowToastDialog.showToast("Recipient is busy");
          debugPrint('Outgoing call busy => $callID, callee: ${callee.id}');
        },
        onOutgoingCallDeclined: (callID, callee, customData) {
          ShowToastDialog.showToast("Call declined");
          debugPrint('Outgoing call declined => $callID, callee: ${callee.id}');
        },
      ),
    );

    _initialized = true;
    _currentUserId = userId;
    debugPrint('Zego initialized successfully for: $userId');
  }

  Future<void> uninitZego() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _initialized = false;
    _currentUserId = null;
    debugPrint('Zego uninitialized');
  }
}



/*
import 'package:get/get.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/constant/zego_config.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();

  factory ZegoCallService() {
    return _instance;
  }

  ZegoCallService._internal();

  void initZego(String userId, String userName) {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "zego_call",
          channelName: "Call",
          icon: "ic_launcher",
        ),
        iOSNotificationConfig: ZegoIOSNotificationConfig(
          systemCallingIconName: "ic_launcher",
        ),
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onIncomingCallReceived: (callID, inviter, type, invitees, customData) {
          // Handle incoming call if needed
        },
        onIncomingCallDeclineButtonPressed: () {},
        onIncomingCallAcceptButtonPressed: () {},
        onOutgoingCallAccepted: (callID, callee) {},
        onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
          ShowToastDialog.showToast("Recipient is busy");
        },
        onOutgoingCallDeclined: (callID, callee, customData) {
          ShowToastDialog.showToast("Call declined");
        },
      ),
    );
  }

  void uninitZego() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
*/
