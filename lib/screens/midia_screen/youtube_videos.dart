import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideos extends StatelessWidget {
  String videosId = '';

  YoutubeVideos({this.videosId = ''});

  Widget _initializeVideoPlayer() {
    final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videosId,
      params: YoutubePlayerParams(
        strictRelatedVideos: true,
        //playlist: ['FqKKvi5TKwo'], // Defining custom playlist
        startAt: Duration(seconds: 0),
        showControls: true,
        showFullscreenButton: false,
      ),
    );

    final yt = YoutubePlayerIFrame(
      controller: _controller,
      aspectRatio: 16 / 9,
    );

    return yt;
  }

  @override
  Widget build(BuildContext context) {
    return _initializeVideoPlayer();
  }
}
