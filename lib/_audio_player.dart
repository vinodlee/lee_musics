import 'dart:ui' show VoidCallback;

import 'package:flutter/services.dart';
//import 'package:logging/logging.dart';

//final _log = new Logger('AudioPlayer');

class AudioPlayer {
	final String playerId;
	final MethodChannel channel;
	
	final Set<AudioPlayerListener> _listeners = Set();
	
	AudioPlayerState _state;
	Duration _audioLength;
	int _bufferedPercent;
	Duration _position;
	bool _isSeeking = false;
	
	AudioPlayer({
		this.playerId,
		this.channel,
	}) {
		// TODO: ask channel for initial state so that Flutter can connect to
		// TODO: existing AudioPlayers
		_setState(AudioPlayerState.idle);
		
		channel.setMethodCallHandler((MethodCall call) {
//			_log.fine('Received channel message: ${call.method}');
			switch (call.method) {
				case "onFftVisualization":
//					_log.fine('FFT Visualization:');
//					_log.fine('${call.arguments['fft'].runtimeType}');
					break;
				case "onAudioLoading":
//					_log.fine('onAudioLoading');
					
					// If new audio is loading then we have no playhead position and we
					// don't know the audio length.
					_setAudioLength(null);
					_setPosition(null);
					
					_setState(AudioPlayerState.loading);
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onAudioLoading();
					}
					break;
				case "onBufferingUpdate":
//					_log.fine('onBufferingUpdate');
					
					final percent = call.arguments['percent'];
					_setBufferedPercent(percent);
					
					break;
				case "onAudioReady":
//					_log.fine('onAudioReady, audioLength: ${call.arguments['audioLength']}');
					
					// When audio is ready then we get passed the length of the clip.
					final audioLengthInMillis = call.arguments['audioLength'];
					_setAudioLength(new Duration(milliseconds: audioLengthInMillis));
					
					// When audio is ready then the playhead is at zero.
					_setPosition(const Duration(milliseconds: 0));
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onAudioReady();
					}
					break;
				case "onPlayerPlaying":
//					_log.fine('onPlayerPlaying');
					
					_setState(AudioPlayerState.playing);
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onPlayerPlaying();
					}
					break;
				case "onPlayerPlaybackUpdate":
//					_log.fine('onPlayerPlaybackUpdate, position: ${call.arguments['position']}');
					
					// The playhead has moved, update our playhead position reference.
					_setPosition(new Duration(milliseconds: call.arguments['position']));
					break;
				case "onPlayerPaused":
//					_log.fine('onPlayerPaused');
					
					_setState(AudioPlayerState.paused);
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onPlayerPaused();
					}
					break;
				case "onPlayerStopped":
//					_log.fine('onPlayerStopped');
					
					// When we are stopped it means more than just paused. The audio will
					// have to be reloaded. Therefore, we no longer have a playhead
					// position or audio length.
					_setAudioLength(null);
					_setPosition(null);
					
					_setState(AudioPlayerState.stopped);
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onPlayerStopped();
					}
					break;
				case "onPlayerCompleted":
//					_log.fine('onPlayerCompleted');
					
					_setState(AudioPlayerState.completed);
					
					for (AudioPlayerListener listener in _listeners) {
						listener.onPlayerCompleted();
					}
					break;
				case "onSeekStarted":
					_setIsSeeking(true);
					break;
				case "onSeekCompleted":
					_setPosition(new Duration(milliseconds: call.arguments['position']));
					_setIsSeeking(false);
					break;
			}
		});
		
		channel.invokeMethod('audioplayer/$playerId/activate_visualizer');
	}
	
	void dispose() {
		_listeners.clear();
	}
	
	AudioPlayerState get state => _state;
	
	_setState(AudioPlayerState state) {
		_state = state;
		
		for (AudioPlayerListener listener in _listeners) {
			listener.onAudioStateChanged(state);
		}
	}
	
	/// Length of the loaded audio clip.
	///
	/// Accessing [audioLength] is only valid after the [AudioPlayer] has loaded
	/// an audio clip and before the [AudioPlayer] is stopped.
	Duration get audioLength => _audioLength;
	
	_setAudioLength(Duration audioLength) {
		_audioLength = audioLength;
		
		for (AudioPlayerListener listener in _listeners) {
			listener.onAudioLengthChanged(_audioLength);
		}
	}
	
	int get bufferedPercent => _bufferedPercent;
	
	_setBufferedPercent(int percent) {
		_bufferedPercent = percent;
		
		for (AudioPlayerListener listener in _listeners) {
			listener.onBufferingUpdate(_bufferedPercent);
		}
	}
	
	/// Current playhead position of the [AudioPlayer].
	///
	/// Accessing [position] is only valid after the [AudioPlayer] has loaded
	/// an audio clip and before the [AudioPlayer] is stopped.
	Duration get position => _position;
	
	_setPosition(Duration position) {
		_position = position;
		
		for (AudioPlayerListener listener in _listeners) {
			listener.onPlayerPositionChanged(position);
		}
	}
	
	bool get isSeeking => _isSeeking;
	
	_setIsSeeking(bool isSeeking) {
		if (isSeeking == _isSeeking) {
			return;
		}
		
		_isSeeking = isSeeking;
		
		if (_isSeeking) {
			for (AudioPlayerListener listener in _listeners) {
				listener.onSeekStarted();
			}
		} else {
			for (AudioPlayerListener listener in _listeners) {
				listener.onSeekCompleted();
			}
		}
	}
	
	void addListener(AudioPlayerListener listener) {
		_listeners.add(listener);
	}
	
	void removeListener(AudioPlayerListener listener) {
		_listeners.remove(listener);
	}
	
	void loadMedia(Uri uri) {
//		_log.fine('loadMedia()');
		// TODO: how to represent media
		channel.invokeMethod(
			'audioplayer/$playerId/load',
			{'audioUrl': uri.toString()},
		);
	}
	
	void play() {
//		_log.fine('play()');
		channel.invokeMethod('audioplayer/$playerId/play');
	}
	
	void pause() {
//		_log.fine('pause()');
		channel.invokeMethod('audioplayer/$playerId/pause');
	}
	
	void seek(Duration duration) {
//		_log.fine('seek(): $duration');
		
		// We optimistically set isSeeking to true because waiting for the channel
		// to report back makes it very difficult for the UI to rely on AudioPlayer's
		// isSeeking property for UI purposes. Even a tiny gap in time will
		// probably result in a seek bar jumping from the new seek position back to
		// the play position and then jump again to the new seek position.
		// TODO: what are the failure cases for seeking and how do we recover?
		_setIsSeeking(true);
		
		channel.invokeMethod(
			'audioplayer/$playerId/seek',
			{
				'seekPosition': duration.inMilliseconds,
			},
		);
	}
	
	void stop() {
//		_log.fine('stop()');
		channel.invokeMethod('audioplayer/$playerId/stop');
	}
}

class AudioPlayerListener {
	AudioPlayerListener({
		Function(AudioPlayerState) onAudioStateChanged,
		VoidCallback onAudioLoading,
		Function(int) onBufferingUpdate,
		VoidCallback onAudioReady,
		Function(Duration) onAudioLengthChanged,
		Function(Duration) onPlayerPositionChanged,
		VoidCallback onPlayerPlaying,
		VoidCallback onPlayerPaused,
		VoidCallback onPlayerStopped,
		VoidCallback onPlayerCompleted,
		VoidCallback onSeekStarted,
		VoidCallback onSeekCompleted,
	})  : _onAudioStateChanged = onAudioStateChanged,
			_onAudioLoading = onAudioLoading,
			_onBufferingUpdate = onBufferingUpdate,
			_onAudioReady = onAudioReady,
			_onAudioLengthChanged = onAudioLengthChanged,
			_onPlayerPositionChanged = onPlayerPositionChanged,
			_onPlayerPlaying = onPlayerPlaying,
			_onPlayerPaused = onPlayerPaused,
			_onPlayerStopped = onPlayerStopped,
			_onPlayerCompleted = onPlayerCompleted,
			_onSeekStarted = onSeekStarted,
			_onSeekCompleted = onSeekCompleted;
	
	final Function(AudioPlayerState) _onAudioStateChanged;
	final VoidCallback _onAudioLoading;
	final Function(int) _onBufferingUpdate;
	final VoidCallback _onAudioReady;
	final Function(Duration) _onAudioLengthChanged;
	final Function(Duration) _onPlayerPositionChanged;
	final VoidCallback _onPlayerPlaying;
	final VoidCallback _onPlayerPaused;
	final VoidCallback _onPlayerStopped;
	final VoidCallback _onPlayerCompleted;
	final VoidCallback _onSeekStarted;
	final VoidCallback _onSeekCompleted;
	
	onAudioStateChanged(AudioPlayerState audioState) {
		if (_onAudioStateChanged != null) {
			_onAudioStateChanged(audioState);
		}
	}
	
	onAudioLoading() {
		if (_onAudioLoading != null) {
			_onAudioLoading();
		}
	}
	
	onBufferingUpdate(int percent) {
		if (_onBufferingUpdate != null) {
			_onBufferingUpdate(percent);
		}
	}
	
	onAudioReady() {
		if (_onAudioReady != null) {
			_onAudioReady();
		}
	}
	
	onAudioLengthChanged(Duration length) {
		if (_onAudioLengthChanged != null) {
			_onAudioLengthChanged(length);
		}
	}
	
	onPlayerPositionChanged(Duration position) {
		if (_onPlayerPositionChanged != null) {
			_onPlayerPositionChanged(position);
		}
	}
	
	onPlayerPlaying() {
		if (_onPlayerPlaying != null) {
			_onPlayerPlaying();
		}
	}
	
	onPlayerPaused() {
		if (_onPlayerPaused != null) {
			_onPlayerPaused();
		}
	}
	
	onPlayerStopped() {
		if (_onPlayerStopped != null) {
			_onPlayerStopped();
		}
	}
	
	onPlayerCompleted() {
		if (_onPlayerCompleted != null) {
			_onPlayerCompleted();
		}
	}
	
	onSeekStarted() {
		if (_onSeekStarted != null) {
			_onSeekStarted();
		}
	}
	
	onSeekCompleted() {
		if (_onSeekCompleted != null) {
			_onSeekCompleted();
		}
	}
}

enum AudioPlayerState {
	idle,
	loading,
	playing,
	paused,
	stopped,
	completed,
}