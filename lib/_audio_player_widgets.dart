import 'package:flutter/widgets.dart';
import 'package:lee_musics/lee_musics.dart';
import 'package:lee_musics/_audio_player.dart';
import 'package:lee_logging/lee_logging.dart';
//import 'package:meta/meta.dart';

final _log = new Logger('AudioPlayerWidget');

class Audio extends StatefulWidget {
	static AudioPlayer of(BuildContext context) {
		_AudioState state = context.ancestorStateOfType(new TypeMatcher<_AudioState>());
		return state?._player;
	}
	
	final String audioUrl;
	final PlaybackState playbackState;
	final List<WatchableAudioProperties> callMe;
	final Widget Function(BuildContext, AudioPlayer) playerCallback;
	final List<WatchableAudioProperties> buildMe;
	final Widget Function(BuildContext, AudioPlayer, Widget child) playerBuilder;
	final Widget child;
	
	Audio({
		this.audioUrl,
		this.playbackState = PlaybackState.paused,
		this.callMe = const [],
		this.playerCallback,
		this.buildMe = const [],
		this.playerBuilder,
		this.child,
	});
	
	@override
	_AudioState createState() => new _AudioState();
}

class _AudioState extends State<Audio> implements AudioPlayerListener {
	AudioPlayer _player;
	String _audioUrl;
	PlaybackState _playbackState;
	
	@override
	void initState() {
		super.initState();
		
		// TODO: player ID
		_player = FlutteryAudio.audioPlayer();
		_player.addListener(this);
		
		_setAudioUrl(widget.audioUrl);
		_playbackState = widget.playbackState;
	}
	
	@override
	void didUpdateWidget(Widget oldWidget) {
		super.didUpdateWidget(oldWidget);
		_log.fine('Widget changed. Updating Audio Widget state.');
		_synchronizeStateWithWidget();
	}
	
	/// reassemble is overridden so that hot reload can be used to play with
	/// audio playback.
	@override
	void reassemble() {
		super.reassemble();
		_log.fine('reassemble()');
		_synchronizeStateWithWidget();
	}
	
	void _synchronizeStateWithWidget() {
		_setAudioUrl(widget.audioUrl);
		
		if (widget.playbackState != _playbackState) {
			_log.fine('The desired audio playback state has changed to: ${widget.playbackState}');
			_playbackState = widget.playbackState;
			if (_playbackState == PlaybackState.playing) {
				_player.play();
			} else if (_playbackState == PlaybackState.paused) {
				_player.pause();
			}
		}
	}
	
	_setAudioUrl(String url) {
		// If the url has changed then we need to switch audio sources.
		if (url != _audioUrl) {
			_audioUrl = url;
			_player.loadMedia(Uri.parse(_audioUrl));
		}
	}
	
	@override
	void dispose() {
		_player.removeListener(this);
		_player.dispose();
		super.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		_log.fine('building');
		if (widget.playerBuilder != null) {
			return widget.playerBuilder(context, _player, widget.child);
		} else if (widget.child != null) {
			return widget.child;
		} else {
			return new Container();
		}
	}
	
	@override
	onAudioLengthChanged(Duration length) {}
	
	@override
	onAudioLoading() {}
	
	@override
	onAudioReady() {
		_log.fine('on audio ready');
		if (_playbackState == PlaybackState.playing) {
			_player.play();
			_log.fine('playing automatically');
		} else if (_playbackState == PlaybackState.paused) {
			_log.fine('not playing because client doesn\'t want it');
		}
		
		if (widget.callMe.contains(WatchableAudioProperties.audioLength)) {
			widget.playerCallback(context, _player);
		}
		if (widget.buildMe.contains(WatchableAudioProperties.audioLength)) {
			setState(() {});
		}
	}
	
	@override
	onAudioStateChanged(AudioPlayerState audioState) {
		_log.fine('on state changed: $audioState');
		if (widget.callMe.contains(WatchableAudioProperties.audioPlayerState)) {
			widget.playerCallback(context, _player);
		}
		if (widget.buildMe.contains(WatchableAudioProperties.audioPlayerState)) {
			setState(() {});
		}
	}
	
	@override
	onBufferingUpdate(int percent) {
		    _log.fine('on buffering update: $percent');
		if (widget.callMe.contains(WatchableAudioProperties.audioBuffering)) {
			widget.playerCallback(context, _player);
		}
		if (widget.buildMe.contains(WatchableAudioProperties.audioBuffering)) {
			setState(() {});
		}
	}
	
	@override
	onPlayerCompleted() {}
	
	@override
	onPlayerPaused() {}
	
	@override
	onPlayerPlaying() {}
	
	@override
	onPlayerPositionChanged(Duration position) {
		    _log.fine('on playback update: $position');
		if (widget.callMe.contains(WatchableAudioProperties.audioPlayhead)) {
			widget.playerCallback(context, _player);
		}
		if (widget.buildMe.contains(WatchableAudioProperties.audioPlayhead)) {
			setState(() {});
		}
	}
	
	@override
	onPlayerStopped() {}
	
	@override
	onSeekCompleted() {
		_onSeekingChanged(false);
	}
	
	@override
	onSeekStarted() {
		_onSeekingChanged(true);
	}
	
	void _onSeekingChanged(bool isSeeking) {
		_log.fine('on seeking changed: $isSeeking');
		if (widget.callMe.contains(WatchableAudioProperties.audioSeeking)) {
			widget.playerCallback(context, _player);
		}
		if (widget.buildMe.contains(WatchableAudioProperties.audioSeeking)) {
			setState(() {});
		}
	}
}

enum WatchableAudioProperties {
	audioPlayerState,
	audioLength,
	audioBuffering,
	audioPlayhead,
	audioSeeking,
}

enum PlaybackState {
	playing,
	paused,
}

class AudioComponent extends StatefulWidget {
	final List<WatchableAudioProperties> updateMe;
	final Widget Function(BuildContext, AudioPlayer, Widget child) playerBuilder;
	final Widget child;
	
	AudioComponent({
		this.updateMe = const [],
		@required this.playerBuilder,
		this.child,
	});
	
	@override
	_AudioComponentState createState() => new _AudioComponentState();
}

class _AudioComponentState extends State<AudioComponent> implements AudioPlayerListener {
	AudioPlayer _player;
	
	@override
	void initState() {
		super.initState();
		
		_player = Audio.of(context);
		if (_player == null) {
			throw new StateError('AudioComponent could not find an Audio ancestor.');
		}
		_player.addListener(this);
	}
	
	@override
	void dispose() {
		_player.removeListener(this);
		_player = null;
		super.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		return widget.playerBuilder != null ? widget.playerBuilder(context, _player, widget.child) : widget.child;
	}
	
	@override
	onAudioLengthChanged(Duration length) {
		// TODO: implement onAudioLengthChanged
	}
	
	@override
	onAudioLoading() {
		// TODO: implement onAudioLoading
	}
	
	@override
	onAudioReady() {
		if (widget.updateMe.contains(WatchableAudioProperties.audioLength)) {
			setState(() {});
		}
	}
	
	@override
	onAudioStateChanged(AudioPlayerState audioState) {
		_log.fine('onStateChanged: $audioState');
		if (widget.updateMe.contains(WatchableAudioProperties.audioPlayerState)) {
			setState(() {});
		}
	}
	
	@override
	onBufferingUpdate(int percent) {
		if (widget.updateMe.contains(WatchableAudioProperties.audioBuffering)) {
			setState(() {});
		}
	}
	
	@override
	onPlayerCompleted() {}
	
	@override
	onPlayerPaused() {}
	
	@override
	onPlayerPlaying() {}
	
	@override
	onPlayerPositionChanged(Duration position) {
		if (widget.updateMe.contains(WatchableAudioProperties.audioPlayhead)) {
			setState(() {});
		}
	}
	
	@override
	onPlayerStopped() {}
	
	@override
	onSeekCompleted() {
		_onSeekingChanged(false);
	}
	
	@override
	onSeekStarted() {
		_onSeekingChanged(true);
	}
	
	void _onSeekingChanged(bool isSeeking) {
		_log.fine('onSeekingChanged: $isSeeking');
		if (widget.updateMe.contains(WatchableAudioProperties.audioSeeking)) {
			setState(() {});
		}
	}
}