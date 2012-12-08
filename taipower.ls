require! <[ request iso8601 cheerio async ]>
global <<< require \prelude-ls

grok = (prefix, url, respond) -->
  _err, _res, page <- request url: url
  $ = cheerio.load page
  t = iso8601.fromDate new Date Date.parse $(".time").first!text! + " +0800"
  r = []
  $ "td.time" .each ->
    r.push {
        location: prefix + @prev!text!
        time: t
        value: @text!
    }
  respond(_err, r)

stations-in-one = grok \核一廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/001s/intime_graph_1.asp

stations-in-two = grok \核二廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/002s/intime_graph_2.asp

stations-in-three = grok \核三廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/003s/intime_graph_3.asp

stations-in-longmen = grok \龍門廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/004s/intime_graph_4.asp

stations-in-lanyu = grok \蘭嶼廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/005l/intime_graph_5.asp

radiations = (respond) ->
  _err, results <- async.parallel [
    stations-in-one
    stations-in-two
    stations-in-three
    stations-in-longmen
    stations-in-lanyu
  ]
  respond( concat results )

export radiations

