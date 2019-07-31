import 'package:flutter/material.dart';
import 'package:lee_musics/lee_musics.dart';
import 'package:meta/meta.dart';

class DeclarativeButtonListWholeStateScreen extends StatefulWidget {
	
	final String audioUrl;
	
	DeclarativeButtonListWholeStateScreen({
		@required this.audioUrl,
	});
	
	@override
	_DeclarativeButtonListWholeStateScreenState createState() => new _DeclarativeButtonListWholeStateScreenState();
}

class _DeclarativeButtonListWholeStateScreenState extends State<DeclarativeButtonListWholeStateScreen> {
	
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
	
	Widget _buildButtonsWithSlider(AudioPlayer audioPlayer) {
		return new Column(
			children: <Widget>[
				_buildButton('LOAD AUDIO', audioPlayer.state == AudioPlayerState.idle
					|| audioPlayer.state == AudioPlayerState.stopped ? () {
					audioPlayer.loadMedia(Uri.parse(widget.audioUrl));
				} : null),
				_buildButton('PLAY AUDIO', audioPlayer.state == AudioPlayerState.paused
					|| audioPlayer.state == AudioPlayerState.completed ? () {
					audioPlayer.play();
				} : null),
				_buildButton('PAUSE AUDIO', audioPlayer.state == AudioPlayerState.playing ? () {
					audioPlayer.pause();
				} : null),
				_buildButton('STOP AUDIO', audioPlayer.state == AudioPlayerState.playing
					|| audioPlayer.state == AudioPlayerState.paused
					|| audioPlayer.state == AudioPlayerState.completed ? () {
					audioPlayer.stop();
				} : null),
				new Slider(
					value: audioPlayer.position == null || audioPlayer.audioLength == null ? 0.0 : audioPlayer.position.inMilliseconds.toDouble(),
					max: audioPlayer.position == null || audioPlayer.audioLength == null ? 1.0 : audioPlayer.audioLength.inMilliseconds.toDouble(),
					onChanged: null,
				),
			],
		);
	}
	
	@override
	Widget build(BuildContext context) {
		return new Audio(
			audioUrl: widget.audioUrl,
			buildMe: [
				WatchableAudioProperties.audioPlayerState,
				WatchableAudioProperties.audioLength,
				WatchableAudioProperties.audioPlayhead,
			],
			playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
				return _buildButtonsWithSlider(player);
			},
			child: null,
		);
	}
}