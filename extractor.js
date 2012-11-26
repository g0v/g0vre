(function(){
  var http, readabilitySAX, cheerio, trim, extract, out$ = typeof exports != 'undefined' && exports || this;
  http = require('http');
  readabilitySAX = require('readabilitySAX');
  cheerio = require('cheerio');
  trim = function(it){
    return it.replace(/&nbsp;/g, " ").replace(/^\s+/, "").replace(/\s+$/, "");
  };
  extract = function(url, cb){
    var stream;
    stream = new readabilitySAX.WritableStream({
      pageURL: url
    }, function(it){
      it.text = trim(cheerio(it.html).text());
      it.url = url;
      delete it.score;
      delete it.textLength;
      return cb(it);
    });
    http.get(url, function(res){
      res.setEncoding('utf8');
      return res.pipe(stream);
    });
  };
  out$.extract = extract;
}).call(this);
