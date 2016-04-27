fs = require('fs')
path = require('path')

var inputFile = process.argv[2];

fs.readFile( inputFile, 'utf8', function (err,data) {
	if (err) {
		return console.log(err);
	}

	var lineDate = function ( line ) {
		return new Date( line.substring(0,28) );
	}

	var dateDiff = function ( date1, date2 ) {
		var ms = date2 - date1;
		var minutes = parseInt( ms / (1000 * 60) );
		var seconds = parseInt( (ms % (1000 * 60)) / 1000 );
		if ( seconds < 10 ) { seconds = "0" + seconds }
		return {
			duration: minutes + ":" + seconds,
			durationMS: ms
		};
	}



	var lines = data.split("\n"),
		lookingFor = "start",
		scripts = {},
		script,
		diff,
		lastLineDate;

	for ( var i = 0; i < lines.length; i++ ) {

		if ( lookingFor === "start" && lines[i].indexOf("START source") !== -1 ) {
			script = lines[i].substring( lines[i].lastIndexOf(" ") );
			scripts[script] = {};
			scripts[script].start = lineDate( lines[i] );
			lookingFor = "end";
		}
		else if ( lookingFor === "end" && lines[i].indexOf("END source") !== -1 ) {
			script = lines[i].substring( lines[i].lastIndexOf(" ") );
			scripts[script].end = lineDate( lines[i] );

			diff = dateDiff( scripts[script].start, scripts[script].end )
			scripts[script].duration = diff.duration;
			scripts[script].durationMS = diff.durationMS;

			lookingFor = "start";
			console.log( script + ": " + scripts[script].duration );
		}

		if ( lines[i].trim() ) {
			lastLineDate = lineDate( lines[i] );
		}
	}

	var firstLineDate = lineDate( lines[0] );
	var scriptLength = dateDiff( firstLineDate, lastLineDate );
	console.log( "TOTAL: " + scriptLength.duration );

});
