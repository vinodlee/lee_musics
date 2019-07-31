import 'package:flutter/material.dart';
import 'package:lee_musics/lee_musics.dart';
import 'package:meta/meta.dart';

class DeclarativePlaylistComponentsScreen extends StatefulWidget {
	
	final List<String> playlist;
	
	DeclarativePlaylistComponentsScreen({
		@required this.playlist,
	});
	
	@override
	_DeclarativePlaylistComponentsScreenState createState() => new _DeclarativePlaylistComponentsScreenState();
}

class _DeclarativePlaylistComponentsScreenState extends State<DeclarativePlaylistComponentsScreen> {
	
	int _activeIndex = 0;
	PlaybackState _playbackState = PlaybackState.paused;
	
	@override
	Widget build(BuildContext context) {
		return new AudioPlaylist(
			playlist: widget.playlist,
			startPlayingFromIndex: _activeIndex,
			playbackState: _playbackState,
			playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
				return new Center(
					child: new Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							// Row of button controls.
							new Row(
								children: <Widget>[
									new Expanded(child: new Container()),
									new IconButton(
										icon: new Icon(
											Icons.skip_previous,
											size: 35.0,
										),
										onPressed: () {
											playlist.previous();
										},
									),
									new Padding(
										padding: const EdgeInsets.only(left: 24.0, right: 24.0),
										child: new AudioComponent(
											updateMe: [
												WatchableAudioProperties.audioPlayerState,
											],
											playerBuilder: (BuildContext context, AudioPlayer audioPlayer, Widget child) {
												IconData playPauseIcon = Icons.music_note;
												Function onPressed;
												if (audioPlayer.state == AudioPlayerState.paused
													|| audioPlayer.state == AudioPlayerState.completed) {
													playPauseIcon = Icons.play_arrow;
													onPressed = audioPlayer.play;
												} else if (audioPlayer.state == AudioPlayerState.playing) {
													playPauseIcon = Icons.pause;
													onPressed = audioPlayer.pause;
												}
												
												return new IconButton(
													icon: new Icon(
														playPauseIcon,
														size: 35.0,
													),
													onPressed: onPressed,
												);
											},
										),
									),
									new IconButton(
										icon: new Icon(
											Icons.skip_next,
											size: 35.0,
										),
										onPressed: () {
											playlist.next();
										},
									),
									new Expanded(child: new Container()),
								],
							),
							
							// Playhead slider
							new AudioComponent(
								updateMe: [
									WatchableAudioProperties.audioLength,
									WatchableAudioProperties.audioPlayhead,
								],
								playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
									return new Slider(
										value: player.position == null || player.audioLength == null ? 0.0 : player.position.inMilliseconds.toDouble(),
										max: player.position == null || player.audioLength == null ? 1.0 : player.audioLength.inMilliseconds.toDouble(),
										onChanged: null,
									);
								},
							),
						],
					),
				);
			},
		);
	}
}