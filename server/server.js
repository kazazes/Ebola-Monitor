var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var outbreakDatapoint = require('./app/models/OutbreakDatapoint.js');
var cache = require('memory-cache');
var read = require('fs').readFileSync;
var https = require('https')
var mongoose = require('mongoose');

var config = require('./config.js')
var cert = read('./certs/zikatracker_io.crt', 'utf8');
var key = read('./certs/zikatracker_io.key', 'utf8');
var ca = [read('./certs/DigiCertCA.crt', 'utf8'), read('./certs/TrustedRoot.crt', 'utf8')];

app.use(bodyParser.urlencoded({
	extended: true
}));

app.use(bodyParser.json());

mongoose.connect('mongodb://' + config.mongo.user + ':' + config.mongo.password + '@localhost:' + config.mongo.PORT + '/' + config.mongo.dbName);

// ROUTES
var router = express.Router();

// catch-all middleware
router.use(function(req, res, next) {
	next();
});

router.route('/api/v1/datapoints')
	.get(function(req, res) {
		var data = retrieveOutbreakData();
		res.set({'content-length' : Buffer.byteLength(JSON.stringify(data))});
		res.json(data);
	});

var httpsOptions = {
	key: key,
	cert: cert,
	ca: ca
}

app.use('/', router);

var secureServer = https.createServer(httpsOptions, app);
secureServer.listen(config.TLSPort);

console.log('Server opened on port ' + config.TLSPort);

// Load data, refresh caches on interval
retrieveOutbreakData();
setInterval(retrieveFreshOutbreakData, 50000);

function retrieveOutbreakData(res) {
	if (cache.get('datapoints') == null || cache.get('datapoints') == undefined) {
		if (arguments.length == 1)
			retrieveFreshOutbreakData(res);
		else
			return retrieveFreshOutbreakData();
	} else {
		if (arguments.length == 1) {
			res.json(cache.get('datapoints'));
		} else {
			return cache.get('datapoints');
		}
	}
}

function retrieveFreshOutbreakData(res) {
	outbreakDatapoint.find(function(err, timeInterval) {
		cache.put('datapoints', timeInterval, 60000);
		if (arguments.length == 1) {
			res.json(cache.get('datapoints'));
		} else {
			return cache.get('datapoints');
		}
	});
}
