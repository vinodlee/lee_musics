import 'package:flutter/material.dart';
import 'package:lee_musics/lee_musics.dart';
import 'package:meta/meta.dart';

class DeclarativeButtonListComponentsScreen extends StatefulWidget {
	
	final String audioUrl;
	
	DeclarativeButtonListComponentsScreen({
		@required this.audioUrl,
	});
	
	@override
	_DeclarativeButtonListComponentsScreenState createState() => new _DeclarativeButtonListComponentsScreenState();
}

class _DeclarativeButtonListComponentsScreenState extends State<DeclarativeButtonListComponentsScreen> {
	
	@override
	initState() {
		super.initState();
	}
	
	Widget _buildButton(String title, VoidCallback onPressed) {
		return new Container(
			padding: const EdgeInsets.all(8.0),
			width: double.infinity,
			child: new RaisedButton(
				child: new Text(
					title,
				),
				onPressed: onPressed,
			),
		);
	}
	
	@override
	Widget build(BuildContext context) {
		return new Audio(
			audioUrl: widget.audioUrl,
			child: new Column(
				children: <Widget>[
					new AudioComponent(
						updateMe: [
							WatchableAudioProperties.audioPlayerState,
						],
						playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
							return _buildButton('LOAD AUDIO', player.state == AudioPlayerState.idle
								|| player.state == AudioPlayerState.stopped ? () {
								player.loadMedia(Uri.parse(widget.audioUrl));
							} : null);
						},
					),
					
					new AudioComponent(
						updateMe: [
							WatchableAudioProperties.audioPlayerState,
						],
						playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
							return _buildButton('PLAY AUDIO', player.state == AudioPlayerState.paused
								|| player.state == AudioPlayerState.completed ? () {
								player.play();
							} : null);
						},
					),
					
					new AudioComponent(
						updateMe: [
							WatchableAudioProperties.audioPlayerState,
						],
						playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
							return _buildButton('PAUSE AUDIO', player.state == AudioPlayerState.playing ? () {
								player.pause();
							} : null);
						},
					),
					
					new AudioComponent(
						updateMe: [
							WatchableAudioProperties.audioPlayerState,
						],
						playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
							return _buildButton('STOP AUDIO', player.state == AudioPlayerState.playing
								|| player.state == AudioPlayerState.paused
								|| player.state == AudioPlayerState.completed ? () {
								player.stop();
							} : null);
						},
					),
					
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
	}
}