require! <[ request iso8601 cheerio ]>
Iconv = require \iconv .Iconv

stations =
  * location: "後壁湖"
    longitude: 120.743372222222
    latitude: 21.9445444444444
  * location: "大光"
    longitude: 120.740483333333
    latitude: 21.9513611111111
  * location: "墾丁"
    longitude: 120.801327777778
    latitude: 21.9451333333333
  * location: "蘭嶼"
    longitude: 121.512433333333
    latitude: 22.0493083333333
  * location: "恆春"
    longitude: 120.746752777778
    latitude: 22.0037555555556
  * location: "龍泉"
    longitude: 120.729744444444
    latitude: 21.9805416666667
  * location: "新竹"
    longitude: 120.993005555556
    latitude: 24.7841361111111
  * location: "貢寮"
    longitude: 121.919752777778
    latitude: 25.0107916666667
  * location: "龍潭"
    longitude: 121.240263888889
    latitude: 24.8400111111111
  * location: "三港"
    longitude: 121.880530555556
    latitude: 25.0536944444444
  * location: "台北"
    longitude: 121.573869444444
    latitude: 25.0790777777778
  * location: "澳底"
    longitude: 121.923811111111
    latitude: 25.047575
  * location: "板橋"
    longitude: 121.442547222222
    latitude: 24.9978722222222
  * location: "陽明山"
    longitude: 121.544430555556
    latitude: 25.1623583333333
  * location: "馬祖"
    longitude: 119.923233333333
    latitude: 26.1693222222222
  * location: "石門"
    longitude: 121.562358333333
    latitude: 25.2911777777778
  * location: "金山"
    longitude: 121.635447222222
    latitude: 25.2209083333333
  * location: "三芝"
    longitude: 121.515852777778
    latitude: 25.2337611111111
  * location: "基隆"
    longitude: 121.715061111111
    latitude: 25.13955
  * location: "茂林"
    longitude: 121.591097222222
    latitude: 25.2700611111111
  * location: "石崩山"
    longitude: 121.565547222222
    latitude: 25.26285
  * location: "龍門"
    longitude: 121.928683333333
    latitude: 25.0305638888889
  * location: "雙溪"
    longitude: 121.862819444444
    latitude: 25.0353083333333
  * location: "台中"
    longitude: 120.684036111111
    latitude: 24.1459472222222
  * location: "宜蘭"
    longitude: 121.756094444444
    latitude: 24.7637388888889
  * location: "野柳"
    longitude: 121.689113888889
    latitude: 25.206275
  * location: "金門"
    longitude: 118.289272222222
    latitude: 24.4090444444444
  * location: "萬里"
    longitude: 121.689947222222
    latitude: 25.1794
  * location: "阿里山"
    longitude: 120.813191666667
    latitude: 23.5081777777778
  * location: "大鵬"
    longitude: 121.651561111111
    latitude: 25.2081222222222
  * location: "大坪"
    longitude: 121.6386
    latitude: 25.1679861111111
  * location: "花蓮"
    longitude: 121.613172222222
    latitude: 23.9776194444444
  * location: "台東"
    longitude: 121.155247222222
    latitude: 22.7524138888889
  * location: "台南"
    longitude: 120.236730555556
    latitude: 23.0379583333333
  * location: "澎湖"
    longitude: 119.563225
    latitude: 23.5653194444444
  * location: "高雄"
    longitude: 120.346897222222
    latitude: 22.6505888888889
  * location: "滿州"
    longitude: 120.817175
    latitude: 22.0060416666667
  * location: "屏東市"
    longitude: 120.489072222222
    latitude: 22.6928666666667

radiations = (respond) ->
  trim = -> it.replace /(^\s+|\s+$)/g, ""
  _err, _res, page <- request { url: 'http://www.trmc.aec.gov.tw/utf8/showmap/taiwan_out.php', encoding: null }
  radiations = []
  $ = cheerio.load (new Iconv 'Big5', 'UTF-8').convert(page)
  $("a").each ->
    radiations.push {
      location: trim @text!
      time: iso8601.fromDate new Date Date.parse trim(@parent!parent!parent!next!find(\span)text!) + " GMT+0800"
      value: @parent!.parent!.next!.text!
    }
  respond radiations

export radiations, stations
