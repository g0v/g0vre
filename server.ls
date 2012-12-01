require! <[ ./extractor http url ]>

port = process.env.PORT || 19000;

read-the-url = (url, res, opts) ->
  extractor.extract url, opts, ->
    res.write JSON.stringify it, \utf8, (opts.pretty and 4 or 0)
    res.end!

http.createServer !(req, res) ->
  link = url.parse req.url, true
  if link.pathname == \/read and link.query.url
    read-the-url link.query.url, res, link.query
  else
    res.writeHead(404)
    res.end!
.listen(port)

process.stdout.write("Server started at http://localhost: #port\n")
