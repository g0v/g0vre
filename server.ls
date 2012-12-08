require! <[ ./extractor ./aec ./taipower http request url cheerio iso8601 ]>

write-json-response = (res, obj, opts) ->
  res.write JSON.stringify obj, \utf8, (opts.pretty and 4 or 0)
  res.end!                   

read-the-url = (url, opts, respond) ->
  extractor.extract url, opts, ->
    respond it

port = process.env.PORT || 19000
http.createServer !(req, res) ->
  link = url.parse req.url, true
  if link.pathname == \/read and link.query.url
    data <- read-the-url link.query.url, link.query
    write-json-response res, data, link.query

  else if link.pathname == \/aec
    data <- aec.radiations
    write-json-response res, data, link.query

  else if link.pathname == \/taipower
    data <- taipower.radiations
    write-json-response res, data, link.query

  else
    res.writeHead(404)
    res.end!
.listen port

console.log "> http server has started on port #port";
