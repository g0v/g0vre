# g0vre

A generic reader/extractor for *.gov.tw URLs. Currently running at http://gugod.g0vre.jit.su

Usage:

    curl 'http://gugod.g0vre.jit.su/read?url=http%3A%2F%2Fwww.gov.tw%2Fnewscenter%2Fpages%2Fdetail.aspx%3Fpage%3D52e41ec5-283a-4095-91ad-f3ad3cfd4be9.aspx'

Params:

- url
- pretty=1

The is a hash with these keys:

- title
- text
- html
- links
- images
- full_text
- full_text_untrimed
- full_html
- full_links
- full_images

The `full_*` part are un-extracted results from the whole page html. While others are processed
with `readibilitySAX` npm to produce content part in the page.

`full_text` is trimed by default since generally web pagse contains a lot of whitespaces.
`full_text_untrimed` keeps those whitespace just in case.

`links` and `images` are array of hashes with `url`, `text` or `alt` keys.

