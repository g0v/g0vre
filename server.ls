require! [ "./extractor", \http, \url ]

port = process.env.PORT || 19000;

read-the-url = (url, res) ->
  extractor.extract url, ->
    res.write( JSON.stringify({title: it.title, text: it.text }), "utf8" )
    res.end!

http.createServer !(req, res) ->
  link = url.parse req.url, true
  if link.pathname == "/read" && link.query.url
    read-the-url(link.query.url, res)
  else
    res.writeHead(404)
    res.end!
.listen(port)

process.stdout.write("Server started at http://localhost:" + port + "\n")
