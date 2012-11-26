(function(){
  var http, readabilitySAX, trim, extract, out$ = typeof exports != 'undefined' && exports || this;
  http = require('http');
  readabilitySAX = require('readabilitySAX');
  trim = function(it){
    return it.replace(/&nbsp;/g, " ").replace(/^\s+/, "").replace(/\s+$/, "");
  };
  extract = function(url, cb){
    var stream;
    stream = new readabilitySAX.WritableStream({
      pageURL: url,
      type: 'text'
    }, function(it){
      it.text = trim(it.text);
      return cb(it);
    });
    http.get(url, function(res){
      res.setEncoding('utf8');
      return res.pipe(stream);
    });
  };
  out$.extract = extract;
}).call(this);
