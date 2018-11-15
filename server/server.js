// server.js

// BASE

var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var outbreakDatapoint = require('./app/models/OutbreakDatapoint.js');
var cache = require('memory-cache');

// use body parser
app.use(bodyParser.urlencoded({
	extended: true
}));

app.use(bodyParser.json());

var port = process.env.PORT || 9000;
var mongoose = require('mongoose');

var mongoPassword = process.env.EBOLA_MONGO_PASSWORD;
mongoose.connect('mongodb://ebola:' + mongoPassword + '@server.com:10188/ebola');

// ROUTES
var router = express.Router();

// catch-all middleware
router.use(function(req, res, next) {
	next();
});

router.route('/api/v1/datapoints')
	.get(function(req, res) {
		res.set({'content-length' : Buffer.byteLength(JSON.stringify(retrieveOutbreakData()))});
		res.json(retrieveOutbreakData());
	});

app.use('/', router);

app.listen(port);
console.log('Server opened on port ' + port);

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
