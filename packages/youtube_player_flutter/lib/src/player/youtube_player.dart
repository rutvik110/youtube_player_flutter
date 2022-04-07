// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/player/player_video.dart';

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
  /// Sets [Key] as an identification to underlying web view associated to the player.
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
    this.actionsPadding = const EdgeInsets.all(8.0),
    this.thumbnail,
    this.showVideoProgressIndicator = false,
    this.overlayInBetween,
    this.overlayTop,
  }) :
        // progressColors =
        //           progressColors ?? ProgressBarColors(controller: controller),
        progressIndicatorColor = progressIndicatorColor ?? Colors.red;

  /// Converts fully qualified YouTube Url to video id.
  ///
  /// If videoId is passed as url then no conversion is done.
  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

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
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late YoutubePlayerController controller;

  // late double _aspectRatio;
  final bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  // @override
  // void didUpdateWidget(YoutubePlayer oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   oldWidget.controller.removeListener(listener);
  //   widget.controller.addListener(listener);
  // }

  // void listener() async {
  //   if (controller.value.isReady && _initialLoad) {
  //     _initialLoad = false;
  //     if (controller.flags.autoPlay) controller.play();
  //     if (controller.flags.mute) controller.mute();
  //     widget.onReady?.call();
  //     if (controller.flags.controlsVisibleAtStart) {
  //       controller.updateValue(
  //         controller.value.copyWith(isControlsVisible: true),
  //       );
  //     }
  //   }
  //   if (mounted) setState(() {});
  // }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
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
                    horizontal: 40.0, vertical: 20.0),
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
                        const SizedBox(width: 5.0),
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
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
          // RepaintBoundary(
          //   child: Transform.scale(
          //     scale: controller.value.isFullScreen
          //         ? (1 / _aspectRatio * MediaQuery.of(context).size.width) /
          //             MediaQuery.of(context).size.height
          //         : 1,
          //     child: RawYoutubePlayer(
          //       key: widget.key,
          //       onEnded: (YoutubeMetaData metaData) {
          //         if (controller.flags.loop) {
          //           controller.load(controller.metadata.videoId,
          //               startAt: controller.flags.startAt,
          //               endAt: controller.flags.endAt);
          //         }

          //         widget.onEnded?.call(metaData);
          //       },
          //     ),
          //   ),
          // ),
          //   if (!controller.flags.hideThumbnail) widget.thumbnail ?? _thumbnail,
          // AnimatedOpacity(
          //   opacity: controller.value.isPlaying ? 0 : 1,
          //   duration: const Duration(milliseconds: 300),
          //   child: widget.thumbnail ?? _thumbnail,
          // ),
          // //TODO: pass the stack here
          if (widget.overlayInBetween != null) widget.overlayInBetween!,

          // Positioned(
          //   bottom: -7.0,
          //   left: -7.0,
          //   right: -7.0,
          //   child: IgnorePointer(
          //     ignoring: true,
          //     child: YoutubeVideoProgressBar(
          //       controller: controller,
          //       showVideoProgressIndicator: widget.showVideoProgressIndicator,
          //       progressColors: widget.progressColors,
          //     ),
          //   ),
          // ),
          // if (!controller.flags.hideControls) ...[
          RepaintBoundary(
            child: TouchShutter(
              disableDragSeek: controller.flags.disableDragSeek,
              timeOut: widget.controlsTimeOut,
              controller: controller,
            ),
          ),
          Positioned.fill(
            bottom: 0,
            left: 0,
            right: 0,
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
          //   Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     child: AnimatedOpacity(
          //       opacity: !controller.flags.hideControls &&
          //               controller.value.isControlsVisible
          //           ? 1
          //           : 0,
          //       duration: const Duration(milliseconds: 300),
          //       child: Padding(
          //         padding: widget.actionsPadding,
          //         child: Row(
          //           children: widget.topActions ?? [Container()],
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
          // if (!controller.flags.hideControls)
          //   Center(
          //     child: PlayPauseButton(
          //       controller: controller,
          //     ),
          //   ),
          // if (widget.overlayTop != null) widget.overlayTop!,
          // if (controller.value.hasError) errorWidget,
        ],
      ),
    );
  }

  Widget get _thumbnail => Image.network(
        YoutubePlayer.getThumbnail(
          videoId: controller.metadata.videoId.isEmpty
              ? controller.initialVideoId
              : controller.metadata.videoId,
        ),
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Container(color: Colors.black),
        errorBuilder: (context, _, __) => Image.network(
          YoutubePlayer.getThumbnail(
            videoId: controller.metadata.videoId.isEmpty
                ? controller.initialVideoId
                : controller.metadata.videoId,
            webp: false,
          ),
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : Container(color: Colors.black),
          errorBuilder: (context, _, __) => Container(),
        ),
      );
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
    final newValue = controller.value.isControlsVisible;
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    // TODO: implement dispose
    // controller.removeListener(() {});
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(showControlls.toString());
    return !showControlls
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.topActions != null) widget.topActions!,
              const Spacer(),
              PlayPauseButton(
                controller: controller,
              ),
              const Spacer(),
              controller.flags.isLive
                  ? LiveBottomBar(
                      controller: controller,
                      liveUIColor: widget.liveUiColor,
                      showLiveFullscreenButton:
                          controller.flags.showLiveFullscreenButton,
                    )
                  : Padding(
                      padding: widget.actionsPadding == null
                          ? const EdgeInsets.all(0.0)
                          : widget.actionsPadding!,
                      child: Row(
                        children: widget.bottomActions ??
                            [
                              const SizedBox(width: 14.0),
                              CurrentPosition(controller),
                              const SizedBox(width: 8.0),
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
