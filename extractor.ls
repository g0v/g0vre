require! <[ request readabilitySAX cheerio ]>
Parser = require 'htmlparser2/lib/Parser.js'

trim = -> it.replace(/&nbsp;/g," ").replace(/^\s+/, "").replace(/\s+$/,"")

extract = !(url, cb) ->

  _err, _res, page <- request url
  reader = new readabilitySAX.Readability pageURL: url
  parser = new Parser reader, { lowerCaseTags: true }
  article = null
  skipLevel = 0

  do
    reader.setSkipLevel skipLevel if skipLevel != 0
    parser.parseComplete(page);
    article = reader.getArticle!
    skipLevel += 1
  while article.textLength < 250 and skipLevel < 4

  delete article.score
  delete article.textLength
  delete article.nextPage


  article.text = trim reader.getText!
  $ = cheerio.load page
  article.links = $("a").map -> { url: (@attr \href), text: @text! }
  cb(article)

export extract: extract
