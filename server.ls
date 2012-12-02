require! <[ ./extractor http request url cheerio iso8601 ]>

Iconv = require \iconv .Iconv

write-json-response = (res, obj, opts) ->
  res.write JSON.stringify obj, \utf8, (opts.pretty and 4 or 0)
  res.end!                   

read-the-url = (url, opts, respond) ->
  extractor.extract url, opts, ->
    respond it

get-aec-radiations = (respond) ->
  trim = -> it.replace /(^\s+|\s+$)/g, ""  
  _err, _res, page <- request { url: 'http://www.trmc.aec.gov.tw/utf8/showmap/taiwan_out.php', encoding: null }
  radiations = []
  $ = cheerio.load (new Iconv 'Big5', 'UTF-8').convert(page)
  $("a").each ->
    radiations.push {
      location: trim @text!
      time: iso8601.fromDate new Date Date.parse trim(@parent!parent!parent!next!find(\span)text!) + " GMT+0800"
      value: @parent!.parent!.next!.text!
    }
  respond radiations

port = process.env.PORT || 19000
http.createServer !(req, res) ->
  link = url.parse req.url, true
  if link.pathname == \/read and link.query.url
    data <- read-the-url link.query.url, link.query
    write-json-response res, data, link.query

  else if link.pathname == \/aec
    data <- get-aec-radiations
    write-json-response res, data, link.query

  else
    res.writeHead(404)
    res.end!
.listen port

console.log('> http server has started on port #port');
