import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/ChatVideoContainer.dart';
import 'package:driver/model/conversation_model.dart';
import 'package:driver/model/inbox_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/chat_screen/FullScreenImageViewer.dart';
import 'package:driver/ui/chat_screen/FullScreenVideoViewer.dart';
import 'package:driver/ui/dashboard_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class ChatScreens extends StatefulWidget {
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final String? customerProfileImage;
  final String? driverId;
  final String? driverName;
  final String? driverProfileImage;
  final String? token;

  const ChatScreens({super.key, this.orderId, this.customerId, this.customerName, this.driverName, this.driverId, this.customerProfileImage, this.driverProfileImage, this.token});

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setSeen();
  }

  void setSeen() {
    FireStoreUtils.setCustomerChatSeen(orderId: widget.orderId ?? '', customerId: widget.customerId ?? '');
  }

  @override
  void dispose() {
    FireStoreUtils.stopCustomerSeenListener();
    super.dispose();
  }

  Future<void> startRecording() async {
    if (await record?.hasPermission() == true) {
      final dir = await getTemporaryDirectory();
      recordedFilePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await record?.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
            numChannels: 1,
          ),
          path: recordedFilePath!);
    }
  }

  AudioRecorder? record = AudioRecorder();
  bool isStartRecording = false;
  String? recordedFilePath;

  Future<String?> stopRecording() async {
    return await record?.stop();
  }

  final player = AudioPlayer();
  Future<void> playVoice(String url) async {
    await player.setUrl(url);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.lightprimary,
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                height: 40,
                width: 40,
                imageUrl: widget.customerProfileImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem(), strokeWidth: 2),
                errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder, height: 40, width: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName ?? "Chat",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                 /* Text(
                    "#${widget.orderId}",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w400),
                  ),*/
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Get.offAll(DashBoardScreen()),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(CollectionName.chat).doc(widget.orderId).collection("thread").orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Constant.loader(isDarkTheme: themeChange.getThem());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return SizedBox();
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                          reverse: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            ConversationModel inboxModel = ConversationModel.fromJson(docs[index].data() as Map<String, dynamic>);
                            return chatItemView(inboxModel.senderId == FireStoreUtils.getCurrentUid(), inboxModel);
                          });
                    }),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeChange.getThem() ? AppColors.darkBackground : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                   /* IconButton(
                      onPressed: _onCameraClick,
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary,
                        size: 28,
                      ),
                    ),*/
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darkTextField : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isStartRecording ? (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary,
                          decoration: InputDecoration(
                            hintText: isStartRecording ? 'Recording...'.tr : 'Type a message...'.tr,
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                              fontWeight: isStartRecording ? FontWeight.bold : FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: InputBorder.none,
                            /*suffixIcon: GestureDetector(
                              onLongPress: () async {
                                setState(() => isStartRecording = true);
                                await startRecording();
                              },
                              onLongPressUp: () async {
                                final path = await stopRecording();
                                if (path != null) {
                                  ShowToastDialog.showLoader("Please wait".tr);
                                  String? url = await Constant().uploadVoiceMessage(path);
                                  final duration = await player.setFilePath(path);
                                  _sendMessage(_messageController.text, Url(url: url), '', 'voice', voiceTimer: duration?.inSeconds);
                                  ShowToastDialog.closeLoader();
                                  _messageController.clear();
                                  setState(() {
                                    isStartRecording = false;
                                  });
                                }
                              },
                              child: Icon(
                                Icons.mic_none_rounded,
                                color: isStartRecording
                                    ? (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary)
                                    : Colors.grey[600],
                              ),
                            ),*/
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _sendMessage(value, null, '', 'text');
                              _messageController.clear();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessage(_messageController.text, null, '', 'text');
                          _messageController.clear();
                          setState(() {});
                        } else {
                          ShowToastDialog.showToast("Please enter text".tr);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatItemView(bool isMe, ConversationModel data) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      height: 30,
                      width: 30,
                      imageUrl: widget.customerProfileImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem(), strokeWidth: 2),
                      errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder, height: 30, width: 30),
                    ),
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isMe
                            ? (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary)
                            : (themeChange.getThem() ? AppColors.darkTextField : Colors.grey[200]),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: data.messageType == "text" ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) : EdgeInsets.zero,
                      child: _buildMessageContent(data, isMe, themeChange),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Constant.dateAndTimeFormatTimestamp(data.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            data.seen == true ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 14,
                            color: data.seen == true
                                ? (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary)
                                : Colors.grey[400],
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      height: 30,
                      width: 30,
                      imageUrl: widget.driverProfileImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem(), strokeWidth: 2),
                      errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder, height: 30, width: 30),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ConversationModel data, bool isMe, DarkThemeProvider themeChange) {
    if (data.messageType == "text") {
      return Text(
        data.message.toString(),
        style: GoogleFonts.poppins(
          color: isMe ? Colors.white : (themeChange.getThem() ? Colors.white : Colors.black87),
          fontSize: 14,
        ),
      );
    } else if (data.messageType == "image") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => Get.to(FullScreenImageViewer(imageUrl: data.url!.url)),
          child: Hero(
            tag: data.url!.url,
            child: CachedNetworkImage(
              imageUrl: data.url!.url,
              placeholder: (context, url) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Constant.loader(isDarkTheme: themeChange.getThem()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 200,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      );
    } else if (data.messageType == "voice") {
      return VoiceBubble(
        url: data.url!.url,
        durationSec: data.recordingTimer ?? 0,
        isme: isMe,
      );
    } else if (data.messageType == "video") {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: data.videoThumbnail ?? '',
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 150,
                color: Colors.black12,
                child: const Icon(Icons.videocam_off_rounded),
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.3),
            child: IconButton(
              onPressed: () {
                Get.to(FullScreenVideoViewer(
                  heroTag: data.id.toString(),
                  videoUrl: data.url!.url,
                ));
              },
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _sendMessage(String message, Url? url, String videoThumbnail, String messageType, {int? voiceTimer}) async {
    log("Chat ::");
    List<String> senderReceiverId = [widget.driverId!, widget.customerId!];
    InboxModel inboxModel = InboxModel(
        senderReceiverId: senderReceiverId,
        lastSenderId: widget.driverId,
        senderId: widget.driverId,
        receiverId: widget.customerId,
        createdAt: Timestamp.now(),
        orderId: widget.orderId,
        lastMessage: _messageController.text,
        lastMessageType: messageType,
        type: 'userchat');

    await FireStoreUtils.addInBox(inboxModel);

    ConversationModel conversationModel = ConversationModel(
        id: const Uuid().v4(),
        message: message,
        senderId: FireStoreUtils.getCurrentUid(),
        receiverId: widget.customerId,
        createdAt: Timestamp.now(),
        url: url,
        orderId: widget.orderId,
        messageType: messageType,
        videoThumbnail: videoThumbnail,
        recordingTimer: voiceTimer,
        seen: false);

    if (url != null) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent an image";
      } else if (url.mime.contains('video')) {
        conversationModel.message = "sent an Video";
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "Sent a voice message";
      } else if (messageType == 'voice') {
        conversationModel.message = "Sent a voice message";
      }
    }

    await FireStoreUtils.addChat(conversationModel);

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "chat",
      "driverId": widget.driverId,
      "customerId": widget.customerId,
      "orderId": widget.orderId,
    };

    SendNotification.sendOneNotification(
        title:
            "${widget.driverName} ${messageType == "image" ? messageType == "video" ? messageType == "voice" ? "sent voice record to you" : "sent video to you" : "sent image to you" : "sent message to you"}",
        body: conversationModel.message.toString(),
        token: widget.token.toString(),
        payload: playLoad);
  }

  final ImagePicker _imagePicker = ImagePicker();

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Media'.tr,
        style: GoogleFonts.poppins(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Choose image from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(galleryVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed".tr);
              }
            }
          },
          child: Text("Choose video from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Take a Photo".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(recordedVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed".tr);
              }
            }
          },
          child: Text("Record video".tr),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel'.tr,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}

class VoiceBubble extends StatefulWidget {
  final bool? isme;
  final String url;
  final int durationSec;
  const VoiceBubble({super.key, required this.isme, required this.url, required this.durationSec});

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  final player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenAudio();
  }

  void _listenAudio() {
    player.playerStateStream.listen((state) {
      final processingState = state.processingState;
      setState(() => isPlaying = state.playing);
      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        setState(() => isLoading = true);
      }
      if (processingState == ProcessingState.ready) {
        setState(() {
          isLoading = false;
          isPlaying = true;
        });
      }
      if (processingState == ProcessingState.completed) {
        setState(() {
          isLoading = false;
          isPlaying = false;
        });
      }

      log("IsPlaying :: $isPlaying");
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              if (isPlaying) {
                await player.pause();
                setState(() {
                  isPlaying = false;
                });
              } else {
                await player.setUrl(widget.url);
                await player.play();
              }
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isme == true ? Colors.white24 : (themeChange.getThem() ? Colors.white12 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.isme == true ? Colors.white : (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary)),
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: widget.isme == true ? Colors.white : (themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary),
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  color: widget.isme == true ? Colors.white38 : Colors.grey[400],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Constant().formatDuration(widget.durationSec),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: widget.isme == true ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
