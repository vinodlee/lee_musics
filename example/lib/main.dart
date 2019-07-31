import 'package:lee_musics_example/audio_samples.dart';
import 'package:lee_musics_example/declarative_button_list_components.dart';
import 'package:lee_musics_example/declarative_button_list_whole_state.dart';
import 'package:lee_musics_example/declarative_playlist_components.dart';
import 'package:lee_musics_example/imperative_button_list.dart';
import 'package:lee_musics_example/screen_welcome.dart';
import 'package:lee_musics_example/declarative_button_list_components.dart';
import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';

void main() {
//	Logger.root.level = Level.ALL;
//	Logger.root.onRecord.listen((LogRecord rec) {
//		print('${rec.level.name}: ${rec.time}: ${rec.loggerName}: ${rec.message}');
//	});
	
	runApp(new MyApp());
}

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
	int _activeTabIndex = 0;
	Widget Function() _builder;
	
	@override
	void initState() {
		super.initState();
		_builder = _buildWelcomeScreen;
	}
	
	Widget _buildWelcomeScreen() {
		return new WelcomeScreen();
	}
	
	Widget _buildA() {
		return new ImperativeButtonListScreen(
			audioUrl: audioUrls[audioUrls.length - 1],
		);
	}
	
	Widget _buildB() {
		return new DeclarativeButtonListWholeStateScreen(
			audioUrl: audioUrls[audioUrls.length - 1],
		);
	}
	
	Widget _buildC() {
		return new DeclarativeButtonListComponentsScreen(
			audioUrl: audioUrls[audioUrls.length - 1],
		);
	}

//    return new DeclarativeAudioSimpleExample(
//      audioUrl: STREAM_URL,
//    );

//    return new Audio(
////            audioUrl: 'https://api.soundcloud.com/tracks/405630381/stream?secret_token=s-tj3IS&client_id=LBCcHmRB8XSStWL6wKH2HPACspQlXg2P',
//      audioUrl: 'https://api.soundcloud.com/tracks/9540352/stream?secret_token=s-tj3IS&client_id=LBCcHmRB8XSStWL6wKH2HPACspQlXg2P',
//      playbackState: PlaybackState.playing,
//      buildMe: [
//        WatchableAudioProperties.audioPlayerState,
//      ],
//      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
//        IconData icon = Icons.music_note;
//        if (player.state == AudioPlayerState.playing) {
//          icon = Icons.pause;
//        } else if (player.state == AudioPlayerState.paused) {
//          icon = Icons.play_arrow;
//        }
//
//        Function onPressed;
//        if (player.state == AudioPlayerState.playing) {
//          onPressed = player.pause;
//        } else if (player.state == AudioPlayerState.paused) {
//          onPressed = player.play;
//        }
//
//        return new IconButton(
//          icon: new Icon(
//            icon,
//            size: 35.0,
//          ),
//          color: Colors.white,
//          onPressed: onPressed,
//        );
//      },
//    );
	
	Widget _buildD() {
		return new DeclarativePlaylistComponentsScreen(
			playlist: audioUrls,
		);
	}
	
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			theme: new ThemeData.dark(),
			home: new Scaffold(
				appBar: new AppBar(
					title: new Text('Fluttery Audio'),
				),
				body: new Center(
					child: _builder(),
				),
				bottomNavigationBar: new BottomNavigationBar(
					currentIndex: _activeTabIndex,
					type: BottomNavigationBarType.fixed,
					items: [
						new BottomNavigationBarItem(
							icon: new Icon(
								Icons.home,
							),
							title: new Text('Welcome'),
						),
						new BottomNavigationBarItem(
							icon: new Icon(
								Icons.music_note,
							),
							title: new Text('A'),
						),
						new BottomNavigationBarItem(
							icon: new Icon(
								Icons.music_note,
							),
							title: new Text('B'),
						),
						new BottomNavigationBarItem(
							icon: new Icon(
								Icons.music_note,
							),
							title: new Text('C'),
						),
						new BottomNavigationBarItem(
							icon: new Icon(
								Icons.music_note,
							),
							title: new Text('D'),
						),
					],
					onTap: (int index) {
						switch (index) {
							case 0:
								setState(() {
									_activeTabIndex = 0;
									_builder = _buildWelcomeScreen;
								});
								break;
							case 1:
								setState(() {
									_activeTabIndex = 1;
									_builder = _buildA;
								});
								break;
							case 2:
								setState(() {
									_activeTabIndex = 2;
									_builder = _buildB;
								});
								break;
							case 3:
								setState(() {
									_activeTabIndex = 3;
									_builder = _buildC;
								});
								break;
							case 4:
								setState(() {
									_activeTabIndex = 4;
									_builder = _buildD;
								});
								break;
						}
					},
				),
			),
		);
	}
}