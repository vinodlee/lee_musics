import 'package:flutter/services.dart';
import 'package:lee_musics/_audio_player.dart';
import 'package:lee_musics/_audio_visualizer.dart';

export '_audio_player.dart';
export '_audio_player_widgets.dart';
export '_audio_visualizer.dart';
export '_playlist.dart';
export '_visualizer.dart';

class FlutteryAudio {
	static const MethodChannel _channel =
	const MethodChannel('fluttery_audio');
	
	static const MethodChannel _visualizerChannel =
	const MethodChannel('fluttery_audio_visualizer');
	
	static AudioPlayer audioPlayer() {
		return new AudioPlayer(
			playerId: 'demo_player',
			channel: _channel,
		);
	}
	
	static AudioVisualizer audioVisualizer() {
		return new AudioVisualizer(
			channel: _visualizerChannel,
		);
	}
}