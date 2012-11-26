require! [ \http, \readabilitySAX, \cheerio ]

trim = -> it.replace(/&nbsp;/g," ").replace(/^\s+/, "").replace(/\s+$/,"")

extract = !(url, cb) ->
  stream = new readabilitySAX.WritableStream {
    pageURL: url
  }, ->
    it.text = trim cheerio(it.html).text!
    it.url  = url
    delete it.score
    delete it.textLength
    cb it

  http.get url, (res) ->
    res.setEncoding \utf8
    res.pipe(stream)


export extract: extract
