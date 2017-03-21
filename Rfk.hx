package;

class Rfk {
	static public function find( src: String, nick: String ) {
		if ( Std.random( 20 ) == Std.random( 20 ) ) {
			Bot.send( 'PRIVMSG ${src} :${nick}: You found kitten! Good job!' );
			return;
		}

		var nkiFile = sys.io.File.read( "./vanilla.nki", false );
		var nkis = [];

		while ( true ) {
			try { var nki = nkiFile.readLine(); nkis.push( nki ); }
			catch ( e: Dynamic ) break;
		}

		nkiFile.close();

		Bot.send( 'PRIVMSG ${src} :${nick}: ${nkis[Std.random( nkis.length )]}' );
	}
}

