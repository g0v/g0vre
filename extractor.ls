require! <[ request readabilitySAX cheerio xml-writer htmlparser2 ]>
Url = require \url

trim = -> it.replace(/&nbsp;/g," ").replace(/^\s+/, "").replace(/\s+$/,"")

extract = !(url, opts, cb) ->
  _err, _res, page <- request url
  article = null
  reader = new readabilitySAX.Readability pageURL: url, resolvePaths: true
  parser = new htmlparser2.Parser reader, { lowerCaseTags: true }
  skipLevel = 2

  do
    reader.setSkipLevel skipLevel if skipLevel != 0
    parser.parseComplete page
    article = reader.getArticle!
    skipLevel += 1
  while article.textLength < 250 and skipLevel < 6

  article.text = trim reader.getText!
  delete article<[ score textLength nextPage ]>

  take_links  = ($) -> $("a[href]") .map -> { url: Url.resolve(url, @attr \href), text: @text! }
  take_images = ($) -> $("img[src]").map -> { url: Url.resolve(url, @attr \src),  alt: (@attr \alt) }

  $ = cheerio.load article.html
  article.links = take_links $
  article.images = take_images $

  if opts.full
    $ = cheerio.load article.full_html  = page.replace /^\s*/, ""
    $("script,style").remove!
    article.full_links  = take_links $
    article.full_images = take_images $
    article.full_text_untrimed = $("html").text!
    article.full_text   = trim article.full_text_untrimed.replace(/[ \t\n\r]+/g, " ")
  cb(article)

links-as-rss = !(url, cb) ->
  article <- extract url, full: true
  xw = new xmlWriter!
  xw.start-document!start-element(\rss).write-attribute(\version, \2.0)
  xw.start-element(\channel)
    .write-element(\title, article.title)
    .write-element(\link, url)
  article.full_links.map ->
    xw.start-element(\item)
      .write-element \link, it.url
      .write-element \title, trim it.text.replace(/[ \t\n\r]+/g, " ")
      .end-element!
  xw.end-document!
  cb xw.to-string!

export extract, links-as-rss
