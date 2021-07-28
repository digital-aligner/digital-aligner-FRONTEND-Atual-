import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideos extends StatelessWidget {
  YoutubeVideos();

  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'FqKKvi5TKwo',
    params: YoutubePlayerParams(
      strictRelatedVideos: true,
      //playlist: ['FqKKvi5TKwo'], // Defining custom playlist
      startAt: Duration(seconds: 0),
      showControls: true,
      showFullscreenButton: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerIFrame(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}
