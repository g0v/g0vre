require! [ \http, \readabilitySAX ]

trim = -> it.replace(/&nbsp;/g," ").replace(/^\s+/, "").replace(/\s+$/,"")

extract = !(url, cb) ->
  stream = new readabilitySAX.WritableStream {
    pageURL: url,
    type: \text
  }, ->
    it.text = trim it.text
    cb it

  http.get url, (res) ->
    res.setEncoding \utf8
    res.pipe(stream)


export extract: extract
