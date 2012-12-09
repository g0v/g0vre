require! <[ ./extractor ./aec ./taipower ./cwbtw http request url cheerio iso8601 ]>

write-json-response = (res, obj, opts) ->
  res.write JSON.stringify obj, \utf8, (opts.pretty and 4 or 0)
  res.end!                   

read-the-url = (url, opts, respond) -->
  extractor.extract url, opts, -> respond it

get-cwb-rainfall = (respond) ->
  data <- cwbtw.fetch_rain
  raw_time, res <- cwbtw.parse_rain data
  time = iso8601.fromDate new Date Date.parse(raw_time + " GMT+0800")
  respond res.map -> { time: time, station: it[0], value: parseFloat(if it[1] == \- then 0 else it[1]) }

port = process.env.PORT || 19000
http.createServer !(req, res) ->
  link = url.parse req.url, true
  f = null
  if link.pathname == \/read and link.query.url
    f = read-the-url link.query.url, link.query

  else if link.pathname == \/aec
    f = aec.radiations

  else if link.pathname == \/taipower
    f = taipower.radiations

  else if link.pathname == \/cwb.rainfall
    f = get-cwb-rainfall

  if f == null
    res.writeHead(404)
    res.end!    
  else
    data <- f
    write-json-response res, data, link.query

.listen port

console.log "> http server has started on port #port";
