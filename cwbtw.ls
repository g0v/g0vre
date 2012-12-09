cwbspec = require \./cwb-spec

fetch = (args, cb) -->
    error, {statusCode}, body <- (require \request) args
    throw error if error
    throw 'got response '+statusCode unless statusCode === 200
    cb body

### rain meters

fetch_rain = fetch url: \http://www.cwb.gov.tw/V7/observe/rainfall/A136.htm

parse_rain = (data, cb) -->
    res = []
    $ = require \cheerio .load(data)
    [...,time] = $('table.description td').last!html!split(/ : /)
    $('table#tableData tbody tr').each ->
        try [_area, station, rain] = @find \td .map -> @text!
        [,station_name,station_id] = station.match /(\S+)\s*\((\S+)\)/
        [,town,area] = _area.match /(...)(.*)/
        res.push [station_id, rain, town, area, station_name]
    cb time, res

### 72hr forecast

fetch_forecast_by_town = (id, cb) -->
    console.log "http://www.cwb.gov.tw/township/XML/#{id}_72hr_EN.xml?_=#{ new Date!getTime! }"
    fetch {
        url: "http://www.cwb.gov.tw/township/XML/#{id}_72hr_EN.xml?_=#{ new Date!getTime! }"
        headers: {\Referer: \http://www.cwb.gov.tw/township/enhtml/index.htm}
    }, cb

get_frames = (Value, layout, timeslice) ->
    i = 0
    [{ts: timeslice[layout][i++]} <<< frame \
        for { '@':{layout:fl} }:frame in Value when fl is layout]
    .map ->
        delete it[\@]
        it.WindDir?.=[\@].abbre
        it

parse_area = (Value, timeslice) ->
    [curr, ...frames12] = get_frames Value, \12, timeslice
    for frame in get_frames Value, \3, timeslice
        if frame.ts.getTime() == frames12[0].ts.getTime()
            curr := frames12.shift! 
        break unless frames12.length
        {} <<< curr <<< frame

parse_forecast_72hr = (data, cb) -->
    parser = new (require \xml2js).Parser
    tmpslice = {}

    (err, {ForecastData:result}) <- parser.parseString data
    [ { '@':slice12, FcstTime:tmpslice[\12] },
      { '@':slice3,  FcstTime:tmpslice[\3 ] } ] = result.Metadata.Time

    timeslice = {[key, ts.map expand_time] for key, ts of tmpslice}
        where expand_time = -> new Date(if typeof it is \object => it[\#] else it)

    cb new Date(result.IssueTime),
    {[areaid, parse_area Value, timeslice] for {'@':{AreaID:areaid}, Value} in result.County.Area}

# typhoon

fetch_typhoon = (cb) -->
    fetch {
        url: \http://www.cwb.gov.tw/V7/prevent/typhoon/Data/PTA_NEW/pta_index_eng.htm
        headers: Referer: \http://www.cwb.gov.tw/V7/prevent/typhoon/Data/PTA_NEW/index_eng.htm
    }, cb

parse_typhoon = (data, cb) -->
    $ = require \cheerio .load(data)

    res = []
    for x in $('div[id^="effect-"]')get!map $ when x.attr(\id)match /effect-\d-b/
        $$ = $.load(x.html!)
        name = $$('.DataTabletitle')text! - /^\s*/g - /\s*$/gm - /Typhoon /
        [current, forecast] = $$(\.DataTableContent)get!.map -> $(it)text!
        date = current.split("\r\n").shift!
        [,lat,lon] = current.match /Center Location\s+([\d\.]+)N\s+([\d\.]+)E/;

        [,swind] = current == /Maximum Wind Speed (\d+) m\/s/
        lat = parseFloat lat
        lon = parseFloat lon
        swind *= 2
        windr = []
        re = /Radius of (\d+)m\/s\s*(\d+)km/
        while current.match re
            current .= replace re, (,wr,r) ->
                wr *= 2
                r /= 1.852
                windr.unshift { wr, ne: r, sw: r, nw: r, se: r }
                ''

        lines = forecast.split("\r\n")
        f = []
        for line in lines
            if matched = line == /(\d+) hours valid/ => f.push time: parseFloat(matched[1])
            if matched = line == /Center Position\s+([\d\.]+)N\s+([\d\.]+)E/ => f[*-1] <<< {lat:parseFloat(matched[1]),lon:parseFloat(matched[2])}

        f.unshift { lat, lon, time: \T0, swind, windr }
        res.push { lat, lon, date, name, forecasts: f }
    cb res

module.exports = {
    cwbspec,
    fetch_rain,
    parse_rain,
    fetch_forecast_by_town,
    parse_forecast_72hr,
    fetch_typhoon,
    parse_typhoon,
}
