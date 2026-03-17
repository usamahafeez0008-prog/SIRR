import 'package:driver/constant/zego_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCallScreen extends StatelessWidget {
  final String callId;
  final ZegoUIKitUser localUser;
  final List<ZegoUIKitUser> invitees;
  final bool isVideoCall;

  const ZegoCallScreen({
    super.key,
    required this.callId,
    required this.localUser,
    required this.invitees,
    this.isVideoCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: localUser.id,
      userName: localUser.name,
      callID: callId,
      config: (isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()),
    );
  }
}
