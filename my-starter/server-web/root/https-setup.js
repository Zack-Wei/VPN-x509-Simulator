//an https example 

var https = require('https');
var fs = require('fs');

var options = {
  key: fs.readFileSync('/root/ca/server.key.pem'),
  cert: fs.readFileSync('/root/ca/server.cert.pem'),
  passphrase: 'pass' //an example pwd during viva
};

https.createServer(options, function(req, res) {
  res.writeHead(200);
  res.end("HTTPS Works!\n");
}).listen(443, function(){
  console.log('Open URL: https://web.2229437.cyber22.test');
});