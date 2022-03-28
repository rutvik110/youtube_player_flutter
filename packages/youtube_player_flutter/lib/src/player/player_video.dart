// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/player/raw_youtube_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayerView extends StatefulWidget {
  const YoutubeVideoPlayerView({
    Key? key,
    required this.controller,
    required this.aspectRatio,
  }) : super(key: key);

  final YoutubePlayerController controller;
  final double aspectRatio;

  @override
  State<YoutubeVideoPlayerView> createState() => _YoutubeVideoPlayerViewState();
}

class _YoutubeVideoPlayerViewState extends State<YoutubeVideoPlayerView> {
  late final YoutubePlayerController controller;
  late final double aspectRatio;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    controller = widget.controller..addListener(listener);
  }

  @override
  void didUpdateWidget(YoutubeVideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(listener);
    widget.controller.addListener(listener);
  }

  void listener() async {
    if (controller.value.isReady && _initialLoad) {
      _initialLoad = false;
      if (controller.flags.autoPlay) controller.play();
      if (controller.flags.mute) controller.mute();
      // widget.onReady?.call();
      if (controller.flags.controlsVisibleAtStart) {
        controller.updateValue(
          controller.value.copyWith(isControlsVisible: true),
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawYoutubePlayer(
      key: widget.key,
      controller: controller,
      onEnded: (YoutubeMetaData metaData) {
        if (controller.flags.loop) {
          controller.load(controller.metadata.videoId,
              startAt: controller.flags.startAt, endAt: controller.flags.endAt);
        }

        // widget.onEnded?.call(metaData);
      },
    );
  }
}
