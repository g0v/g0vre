(function(){
  var extractor, http, url, port, readTheUrl;
  extractor = require('./extractor');
  http = require('http');
  url = require('url');
  port = process.env.PORT || 19000;
  readTheUrl = function(url, res){
    return extractor.extract(url, function(it){
      res.write(JSON.stringify(it), "utf8");
      return res.end();
    });
  };
  http.createServer(function(req, res){
    var link;
    link = url.parse(req.url, true);
    if (link.pathname === "/read" && link.query.url) {
      readTheUrl(link.query.url, res);
    } else {
      res.writeHead(404);
      res.end();
    }
  }).listen(port);
  process.stdout.write("Server started at http://localhost:" + port + "\n");
}).call(this);
