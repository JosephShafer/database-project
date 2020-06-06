var express = require('express');
var app = express();
const path = require('path');
const client = require('./db');
//require('bootstrap')

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static('public')); // allows express to look in public folder for files
app.use(express.static(__dirname + '/node_modules/bootstrap/dist'));
app.use(express.static(__dirname + '/node_modules/jquery/dist'));
app.use(express.static(__dirname + '/node_modules/nouislider/distribute'));
app.use(express.static(__dirname + '/node_modules/jspdf/dist'))
app.use(express.static(__dirname + '/node_modules/html2canvas/dist'))

app.use(require('./pageRedirects'));
app.use(require('./calendarPageBackend'));
app.use(require('./revenuebackend'));
app.use(require('./calendarReportQueries'));

// reminder check if you can use the client object here still


app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
