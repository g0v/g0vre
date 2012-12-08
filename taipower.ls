require! <[ request iso8601 cheerio ]>

grok = (prefix, url, respond) -->
  _err, _res, page <- request url: url
  $ = cheerio.load page
  t = iso8601.fromDate new Date Date.parse $("div.time").text! + " +0800"
  r = []
  $ "td.time" .each ->
    r.push {
        location: prefix + @prev!text!
        time: t
        value: @text!
    }
  respond(r)

stations-in-one = grok \核一廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/001s/intime_graph_1.asp

stations-in-two = grok \核二廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/002s/intime_graph_2.asp

stations-in-three = grok \核三廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/003s/intime_graph_3.asp

stations-in-longmen = grok \龍門廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/004s/intime_graph_4.asp

stations-in-lanyu = grok \蘭嶼廠 \http://wapp4.taipower.com.tw/nsis/web/new_screen_page/005l/intime_graph_5.asp

all-stations = (respond) ->
  s1 <- stations-in-one
  s2 <- stations-in-two
  s3 <- stations-in-three
  s4 <- stations-in-longmen
  s5 <- stations-in-lanyu
  respond s1 +++ s2 +++ s3 +++ s4 +++ s5

# all-stations -> console.log(it)
