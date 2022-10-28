// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:chaseapp/src/shared/widgets/loaders/loading.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/player/player_video.dart';

import '../../youtube_player_flutter.dart';
import '../enums/thumbnail_quality.dart';
import '../utils/errors.dart';
import '../utils/youtube_meta_data.dart';
import '../utils/youtube_player_controller.dart';
import '../utils/youtube_player_flags.dart';
import '../widgets/widgets.dart';

/// A widget to play or stream YouTube videos using the official [YouTube IFrame Player API](https://developers.google.com/youtube/iframe_api_reference).
///
/// In order to play live videos, set `isLive` property to true in [YoutubePlayerFlags].
///
///
/// Using YoutubePlayer widget:
///
/// ```dart
/// YoutubePlayer(
///    context: context,
///    initialVideoId: "iLnmTe5Q2Qw",
///    flags: YoutubePlayerFlags(
///      autoPlay: true,
///      showVideoProgressIndicator: true,
///    ),
///    videoProgressIndicatorColor: Colors.amber,
///    progressColors: ProgressColors(
///      playedColor: Colors.amber,
///      handleColor: Colors.amberAccent,
///    ),
///    onPlayerInitialized: (controller) {
///      _controller = controller..addListener(listener);
///    },
///)
/// ```
///
class YoutubePlayer extends StatefulWidget {
  /// Creates [YoutubePlayer] widget.
  const YoutubePlayer({
    this.key,
    required this.controller,
    this.width,
    this.aspectRatio = 16 / 9,
    this.controlsTimeOut = const Duration(seconds: 3),
    this.bufferIndicator,
    Color? progressIndicatorColor,
    this.progressColors,
    this.onReady,
    this.onEnded,
    this.liveUIColor = Colors.red,
    this.topActions,
    this.bottomActions,
    this.actionsPadding = const EdgeInsets.all(8),
    this.thumbnail,
    this.showVideoProgressIndicator = false,
    this.overlayInBetween,
    this.overlayTop,
  }) :
        // progressColors =
        //           progressColors ?? ProgressBarColors(controller: controller),
        progressIndicatorColor = progressIndicatorColor ?? Colors.red;

  /// Sets [Key] as an identification to underlying web view associated to the player.
  @override
  final Key? key;

  /// A [YoutubePlayerController] to control the player.
  final YoutubePlayerController controller;

  /// {@template youtube_player_flutter.width}
  /// Defines the width of the player.
  ///
  /// Default is devices's width.
  /// {@endtemplate}
  final double? width;

  /// {@template youtube_player_flutter.aspectRatio}
  /// Defines the aspect ratio to be assigned to the player. This property along with [width] calculates the player size.
  ///
  /// Default is 16 / 9.
  /// {@endtemplate}
  final double aspectRatio;

  /// {@template youtube_player_flutter.controlsTimeOut}
  /// The duration for which controls in the player will be visible.
  ///
  /// Default is 3 seconds.
  /// {@endtemplate}
  final Duration controlsTimeOut;

  /// {@template youtube_player_flutter.bufferIndicator}
  /// Overrides the default buffering indicator for the player.
  /// {@endtemplate}
  final Widget? bufferIndicator;

  /// {@template youtube_player_flutter.progressColors}
  /// Overrides default colors of the progress bar, takes [ProgressColors].
  /// {@endtemplate}
  final ProgressBarColors? progressColors;

  /// {@template youtube_player_flutter.progressIndicatorColor}
  /// Overrides default color of progress indicator shown below the player(if enabled).
  /// {@endtemplate}
  final Color progressIndicatorColor;

  /// {@template youtube_player_flutter.onReady}
  /// Called when player is ready to perform control methods like:
  /// play(), pause(), load(), cue(), etc.
  /// {@endtemplate}
  final VoidCallback? onReady;

  /// {@template youtube_player_flutter.onEnded}
  /// Called when player had ended playing a video.
  ///
  /// Returns [YoutubeMetaData] for the video that has just ended playing.
  /// {@endtemplate}
  final void Function(YoutubeMetaData metaData)? onEnded;

  /// {@template youtube_player_flutter.liveUIColor}
  /// Overrides color of Live UI when enabled.
  /// {@endtemplate}
  final Color liveUIColor;

  /// {@template youtube_player_flutter.topActions}
  /// Adds custom top bar widgets.
  /// {@endtemplate}
  final Widget? topActions;

  /// {@template youtube_player_flutter.bottomActions}
  /// Adds custom bottom bar widgets.
  /// {@endtemplate}
  final List<Widget>? bottomActions;

  /// {@template youtube_player_flutter.actionsPadding}
  /// Defines padding for [topActions] and [bottomActions].
  ///
  /// Default is EdgeInsets.all(8.0).
  /// {@endtemplate}
  final EdgeInsetsGeometry actionsPadding;

  /// {@template youtube_player_flutter.thumbnail}
  /// Thumbnail to show when player is loading.
  ///
  /// If not set, default thumbnail of the video is shown.
  /// {@endtemplate}
  final Widget? thumbnail;

  /// {@template youtube_player_flutter.showVideoProgressIndicator}
  /// Defines whether to show or hide progress indicator below the player.
  ///
  /// Default is false.
  /// {@endtemplate}
  final bool showVideoProgressIndicator;

  /// Overlay to be placed between video stream and video controlls.
  final Widget? overlayInBetween;

  /// Overlay to be placed on top of video controls.
  final Widget? overlayTop;

  /// Converts fully qualified YouTube Url to video id.
  ///
  /// If videoId is passed as url then no conversion is done.
  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains('http') && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (final RegExp exp in [
      RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$',
      ),
      RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$',
      ),
      RegExp(r'^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$')
    ]) {
      final Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late YoutubePlayerController controller;

  // late double _aspectRatio;

  bool hasPlayed = false;

  void listenToPlayedEvents() {
    if (!hasPlayed) {
      setState(() {
        hasPlayed = controller.value.hasPlayed;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(listenToPlayedEvents);
  }

  @override
  void dispose() {
    // controller.dispose();
    controller.removeListener(listenToPlayedEvents);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: _buildPlayer(
            errorWidget: ColoredBox(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            errorString(
                              controller.value.errorCode,
                              videoId: controller.metadata.videoId.isNotEmpty
                                  ? controller.metadata.videoId
                                  : controller.initialVideoId,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Code: ${controller.value.errorCode}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: long-method
  Widget _buildPlayer({required Widget errorWidget}) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Transform.scale(
            scale: controller.value.isFullScreen
                ? (1 / widget.aspectRatio * MediaQuery.of(context).size.width) /
                    MediaQuery.of(context).size.height
                : 1,
            child: YoutubeVideoPlayerView(
              controller: controller,
              aspectRatio: widget.aspectRatio,
            ),
          ),
          if (widget.overlayInBetween != null)
            RepaintBoundary(
              child: widget.overlayInBetween!,
            ),
          if (controller.value.hasPlayed)
            RepaintBoundary(
              child: TouchShutter(
                disableDragSeek: controller.flags.disableDragSeek,
                timeOut: widget.controlsTimeOut,
                controller: controller,
              ),
            ),
          AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return !controller.value.isReady
                  ? const CircularAdaptiveProgressIndicatorWithBg()
                  : controller.value.hasPlayed ||
                          controller.value.playerState == PlayerState.buffering
                      ? const SizedBox.shrink()
                      : Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFFF0000,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  14,
                                ),
                              ),
                              fixedSize: const Size(
                                70,
                                48,
                              ),
                            ),
                            onPressed: () {
                              controller.play();
                            },
                            child: const Icon(
                              Icons.play_arrow_rounded,
                            ),
                          ),
                        );
            },
          ),
          if (controller.value.hasPlayed)
            Positioned.fill(
              child: RepaintBoundary(
                child: YoutubeVideoProgressBar(
                  actionsPadding: widget.actionsPadding,
                  controller: controller,
                  topActions: widget.topActions,
                  liveUiColor: widget.liveUIColor,
                  bottomActions: widget.bottomActions,
                  showVideoProgressIndicator: widget.showVideoProgressIndicator,
                  progressColors: widget.progressColors ??
                      ProgressBarColors(controller: controller),
                ),
              ),
            ),
          if (!controller.value.hasPlayed)
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                // shape: const CircleBorder(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final YoutubePlayerController controller;

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  void listener() {
    if (widget.controller.value.isReady && showThumbnail) {
      showThumbnail = false;
      setState(() {});
    }
  }

  late bool showThumbnail;

  /// Grabs YouTube video's thumbnail for provided video id.
  static String getThumbnail({
    required String videoId,
    String quality = ThumbnailQuality.standard,
    bool webp = true,
  }) =>
      webp
          ? 'https://i3.ytimg.com/vi_webp/$videoId/$quality.webp'
          : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showThumbnail = true;

    widget.controller.addListener(listener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.controller.removeListener(listener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (Widget? child, List<Widget> childrens) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!,
            ...childrens,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: showThumbnail
          ? Image.network(
              getThumbnail(
                videoId: widget.controller.initialVideoId,
              ),
              fit: BoxFit.cover,
              loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
                  progress == null
                      ? child
                      : const Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
              errorBuilder: (BuildContext context, _, __) =>
                  const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }
}

class YoutubeVideoProgressBar extends StatefulWidget {
  const YoutubeVideoProgressBar({
    Key? key,
    required this.controller,
    required this.showVideoProgressIndicator,
    required this.actionsPadding,
    required this.topActions,
    required this.bottomActions,
    required this.liveUiColor,
    required this.progressColors,
  }) : super(key: key);

  final YoutubePlayerController controller;
  final bool showVideoProgressIndicator;
  final ProgressBarColors progressColors;
  final Color liveUiColor;
  final Widget? topActions;
  final List<Widget>? bottomActions;
  final EdgeInsetsGeometry? actionsPadding;

  @override
  State<YoutubeVideoProgressBar> createState() =>
      _YoutubeVideoProgressBarState();
}

class _YoutubeVideoProgressBarState extends State<YoutubeVideoProgressBar> {
  late final YoutubePlayerController controller;
  bool showControlls = false;

  void listener() {
    final bool newValue = controller.value.isControlsVisible;
    if (showControlls != newValue) {
      if (mounted) {
        setState(() {
          showControlls = newValue;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = widget.controller;
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !showControlls
        ? const SizedBox.shrink()
        : Column(
            children: [
              if (widget.topActions != null) widget.topActions!,
              const Spacer(),
              PlayPauseButton(
                controller: controller,
              ),
              const Spacer(),
              if (controller.flags.isLive)
                LiveBottomBar(
                  controller: controller,
                  liveUIColor: widget.liveUiColor,
                  showLiveFullscreenButton:
                      controller.flags.showLiveFullscreenButton,
                )
              else
                Padding(
                  padding: widget.actionsPadding == null
                      ? const EdgeInsets.all(0)
                      : widget.actionsPadding!,
                  child: Row(
                    children: widget.bottomActions ??
                        [
                          const SizedBox(width: 14),
                          CurrentPosition(controller),
                          const SizedBox(width: 8),
                          ProgressBar(
                            isExpanded: true,
                            colors: widget.progressColors,
                            controller: controller,
                          ),
                          RemainingDuration(controller),
                          // PlaybackSpeedButton(
                          //   controller: controller,
                          // ),
                          FullScreenButton(
                            controller: controller,
                          ),
                        ],
                  ),
                ),
            ],
          );

    //  !widget.controller.value.isFullScreen &&
    //         !widget.controller.flags.hideControls &&
    //         widget.controller.value.position >
    //             const Duration(milliseconds: 100) &&
    //         !widget.controller.value.isControlsVisible &&
    //         widget.showVideoProgressIndicator &&
    //         !widget.controller.flags.isLive
    //     ? ProgressBar(
    //         colors: widget.progressColors.copyWith(
    //           handleColor: Colors.transparent,
    //         ),
    //       )
    //     : ProgressBar(
    //         colors: widget.progressColors.copyWith(
    //           handleColor: Colors.transparent,
    //         ),
    //       );
  }
}
