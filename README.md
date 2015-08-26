# g0vre

API 網址

    https://g0vre.herokuapp.com

## 原能會輻射監測 /aec

資料來源：原能會網站

- http://www.trmc.aec.gov.tw/

用法：

    curl https://g0vre.herokuapp.com/aec

URL 上另可加上 `?pretty=1` 以產生有縮排的 JSON。

## 各核電廠輻射監測 /taipower

資料來源：台電網站

- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/001s/intime_graph_1.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/002s/intime_graph_2.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/003s/intime_graph_3.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/004s/intime_graph_4.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/005l/intime_graph_5.asp

用法

    curl https://g0vre.herokuapp.com/taipower

## 雨量 /cwb.rains

資料來源：氣象局網站

- http://www.cwb.gov.tw/V7/observe/rainfall/A136.htm

用法 

    curl https://g0vre.herokuapp.com/cwb.rains

輸出範例：

    [
        {
           "values" : [
              null,
              1,
              1,
              1,
              76,
              null,
              364.5,
              388.5,
              389.5
           ],
           "time" : "2015-08-08T12:10:00Z",
           "station" : "A1AC8"
        },
        ...
    ]

`values` 所對應之值分別為雨量表示各欄的數值，所對應之時間區間為：10分鐘、1小時、3小時、6小時、12小時、24小時、本日、前一日、前二日。

## 十分鐘雨量 /cwb.rainfall

資料來源：氣象局網站

- http://www.cwb.gov.tw/V7/observe/rainfall/A136.htm

用法

    curl https://g0vre.herokuapp.com/cwb.rainfall


## generic gov.tw URL extractor. /read

A generic reader/extractor for *.gov.tw URLs. Currently running at https://g0vre.herokuapp.com

Usage:

    curl 'https://g0vre.herokuapp.com/read?url=http%3A%2F%2Fwww.gov.tw%2Fnewscenter%2Fpages%2Fdetail.aspx%3Fpage%3D52e41ec5-283a-4095-91ad-f3ad3cfd4be9.aspx'

Params:

- url *required*
- pretty=1
- full=1

The is a hash with these keys:

- title
- text
- html
- links
- images

These values are extracted with `readabilitySAX` and contains only the content part of the page.
`links` and `images` are array of hashes with `url`, `text` or `alt` keys.

The following extra key-values would be included only if `full=1` is in the URL querystring:

- full_text
- full_text_untrimed
- full_html
- full_links
- full_images

The `full_*` part are un-extracted results from the whole page html.

`full_text` is trimed by default since generally web pagse contains a lot of whitespaces.
`full_text_untrimed` keeps those whitespace just in case.

## Generic RSS generator: /links2rss

Turns any webpage into a RSS feed of the links found it the page. Useful when a
website is not providing feeds.

Required parameters

- url

Example:

    curl https://g0vre.herokuapp.com/links2rss?url=http://www.gov.tw
