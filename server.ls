require! [ \http, \url ]

port = process.env.PORT || 19000;

read-the-url = (query, res) ->
  res.writeHead(200)
  console.log(query)

http.createServer !(req, res) ->
  link = url.parse req.url, true
  if link.pathname == "/read"
    read-the-url(link.query, res)
    res.end!
  else
    res.writeHead(404)
    res.end!
.listen(port)
