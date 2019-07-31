import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
	@override
	WelcomeScreenState createState() {
		return new WelcomeScreenState();
	}
}

class WelcomeScreenState extends State<WelcomeScreen> {
	
	String welcome = '';
	
	@override
	void initState() {
		super.initState();
		
		_loadWelcomeMessage();
	}
	
	void _loadWelcomeMessage() async {
		welcome = await rootBundle.loadString('assets/welcome.txt', cache: true);
		setState(() {});
	}
	
	@override
	Widget build(BuildContext context) {
		return new SingleChildScrollView(
			child: new Padding(
				padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
				child: new Text(
					welcome,
					style: new TextStyle(
						fontSize: 18.0,
					),
				),
			),
		);
	}
}