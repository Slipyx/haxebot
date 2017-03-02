package;

import haxe.MainLoop;

typedef BotConfig = {
	var nick: String;
	var user: String;
	var realName: String;

	var server: String;
	var channels: Array<String>;
}

class Bot {
	static var sock: sys.ssl.Socket;

	static var cfg: BotConfig;

	// The MainEvent received from the MainLoop.
	// Used for delaying and stopping the loop.
	static var mLoopEvt: MainEvent;

	static function main() {
		// default config
		cfg = {
			nick: "haxebot", user: "hxbot", realName: "Me Mow",
			server: "irc.zandronum.com", channels: ["#ganymede"]
		};

		if ( sys.FileSystem.exists( "./cfg.json" ) )
			cfg = haxe.Json.parse( sys.io.File.getContent( "./cfg.json" ) );

		sock = new sys.ssl.Socket();

		sock.verifyCert = false;
		sock.connect( new sys.net.Host( cfg.server ), 6697 );
		sock.setBlocking( false );

		send( "NICK " + cfg.nick );
		send( "USER " + cfg.user + " 0 * :" + cfg.realName );

		haxe.Timer.delay( meowFunc, 60 * 1000 );

		// Add function for reading socket to MainLoop
		mLoopEvt = MainLoop.add( function() {
			var r = sys.net.Socket.select( [sock], null, null, 0 );

			// check if socket has incoming data and read each line in turn until EOF
			if ( r.read.length > 0 )
				for ( s in r.read )
					// loop will break when readLine throws EOF
					while ( true )
						try { handleMsg( s.input.readLine() ); }
						catch ( e: Dynamic ) { break; }

			// dont loop faster than 10 times per second
			mLoopEvt.delay( 0.1 );
		} );

		// grace please
		//sock.shutdown( true, true );
		//sock.close();
	}

	static var meowTimer: haxe.Timer;
	static function meowFunc() {
		for ( c in cfg.channels )
			send( "PRIVMSG " + c + " :meeow" );
	}

	public static function send( str: String ) {
		Sys.println( ">> " + str );
		sock.output.writeString( str + "\r\n" );
		sock.output.flush();
	}

	static function handleMsg( msg: String ) {
		// Chop up the message for easier parsing.
		var ix = msg.indexOf( ":", 1 );
		var words = msg.substr( 0, ix ).split( " " );
		msg = msg.substr( ix + 1 );
		if ( words[1] == "004" || words[1] == "005" ) return; // ugly

		if ( words[0] == "PING" )
			send( "PONG :" + msg );
		else if ( words[1] == "001" )
			for ( c in cfg.channels ) {
				send( "JOIN " + c );
				send( "PRIVMSG " + c + " :meow" );
			}
		else if ( words[1] == "PRIVMSG" ) {
			var src = words[2];
			var nick = words[0];
			var cix = msg.indexOf( " " );
			var cmd = msg.substr( 0, cix );
			msg = msg.substr( cix + 1 );
			Sys.println( "<" + nick + "> " + cmd + ", " + msg );
			if ( cmd == ";hs" ) {
				MainLoop.addThread( function() {
					Hs.execHS( msg, src );
				} );
			}
		} else
			Sys.println( words + " | " + msg );
	}
}

