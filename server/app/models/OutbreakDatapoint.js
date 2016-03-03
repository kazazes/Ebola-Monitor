var mongoose	    = require('mongoose');
var Schema			= mongoose.Schema;

var OutbreakDatapointSchema	= new Schema({
	date: Date,
	latitude: Number,
	longitude: Number,
	country: String,
	cases: Number,
	deaths: Number,
	unconfirmed: Number,
	notes: String
}, {collection: 'outbreak_datapoints'});

module.exports = mongoose.model('OutbreakDatapoint', OutbreakDatapointSchema);
