//
// Bot command for parsing and interpreting Haxe expressions
// Uses hscript library
//

package;

// Custom interp class with ungraceful kill
class Interp extends hscript.Interp {
	public function kill() {
		locals = null;
		variables = null;
	}
}

class Hs {
	public static function execHS( str: String, src: String ) {
		var outstr = "";
		var trcstr = "";

		// setup hscript interpreter
		var hsInterp = new Interp();
		hsInterp.variables.set( "Math", Math );
		hsInterp.variables.set( "randf", Math.random );
		hsInterp.variables.set( "Std", Std );
		hsInterp.variables.set( "rand", Std.random );
		hsInterp.variables.set( "String", String );
		hsInterp.variables.set( "Int", Int );
		hsInterp.variables.set( "Float", Float );
		hsInterp.variables.set( "Bool", Bool );
		hsInterp.variables.set( "Array", Array );
		hsInterp.variables.set( "Date", Date );
		hsInterp.variables.set( "Map", Map );
		hsInterp.variables.set( "List", List );
		hsInterp.variables.set( "EReg", EReg );
		hsInterp.variables.set( "time", haxe.Timer.stamp );
		hsInterp.variables.set( "trace", function( v: Dynamic ) { trcstr += Std.string( v ); } );
		hsInterp.variables.set( "print", hsInterp.variables.get( "trace" ) );

		// parse
		var hsParser = new hscript.Parser();

		var running = true, killed = false;

		// if execute hasn't finished in time, force kill it
		haxe.Timer.delay( function() {
			if ( running == true ) { hsInterp.kill(); killed = true; }
		}, 3000 );

		try {
			var hsProgram = hsParser.parseString( str );
			outstr = hsInterp.execute( hsProgram );
			running = false;
		} catch ( e: Dynamic ) { outstr = "Error: " + Std.string( e ); }

		if ( killed ) outstr = "Error: Execution time exceeded limit";

		if ( outstr == null && trcstr == "" ) outstr = "-- No Output --";
		if ( trcstr != "" ) outstr = ((outstr == null) ? trcstr : (outstr + " :: " + trcstr));

		Bot.send( "PRIVMSG " + src + " :> " + outstr );
	}
}

