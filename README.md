# g0vre

## 原能會輻射監測

將 http://www.trmc.aec.gov.tw/ 的內容轉成 JSON

用法：

    curl http://gugod.g0vre.jit.su/aec

URL 上另可加上 `?pretty=1` 以產生有縮排的 JSON。

## 各核電廠輻射監測

資料來源：台電網站

- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/001s/intime_graph_1.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/002s/intime_graph_2.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/003s/intime_graph_3.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/004s/intime_graph_4.asp
- http://wapp4.taipower.com.tw/nsis/web/new_screen_page/005l/intime_graph_5.asp

用法

    curl http://gugod.g0vre.jit.su/taipower

## generic gov.tw URL extractor

A generic reader/extractor for *.gov.tw URLs. Currently running at http://gugod.g0vre.jit.su

Usage:

    curl 'http://gugod.g0vre.jit.su/read?url=http%3A%2F%2Fwww.gov.tw%2Fnewscenter%2Fpages%2Fdetail.aspx%3Fpage%3D52e41ec5-283a-4095-91ad-f3ad3cfd4be9.aspx'

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


