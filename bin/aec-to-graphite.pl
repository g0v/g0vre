use v5.14;
use strict;
use utf8;
use JSON;
use Net::Graphite;
use LWP::UserAgent;
use DateTime::Format::ISO8601;

my $location_name_to_pinyin = {
    "馬祖"   => "Mazu",
    "石門"   => "Shimen",
    "金山"   => "Jinshan",
    "三芝"   => "Sanzhi",
    "基隆"   => "Jilong",
    "茂林"   => "Maolin",
    "石崩山" => "Shibengshan",
    "龍門"   => "Longmen",
    "陽明山" => "Yangmingshan",
    "板橋"   => "Banqiao",
    "澳底"   => "Aodi",
    "台北"   => "Taibei",
    "三港"   => "Sangang",
    "龍潭"   => "Longtan",
    "貢寮"   => "Gongliao",
    "新竹"   => "Xinzhu",
    "雙溪"   => "Shuangxi",
    "台中"   => "Taizhong",
    "宜蘭"   => "Yilan",
    "野柳"   => "Yeliu",
    "金門"   => "Jinmen",
    "萬里"   => "Wanli",
    "阿里山" => "Alishan",
    "大鵬"   => "Daipeng",
    "大坪"   => "Daiping",
    "花蓮"   => "Hualian",
    "台東"   => "Taidong",
    "台南"   => "Tainan",
    "澎湖"   => "Penghu",
    "高雄"   => "Gaoxiong",
    "滿州"   => "Manzhou",
    "屏東市" => "Pingdongshi",
    "龍泉"   => "Longquan",
    "恆春"   => "Hengchun",
    "蘭嶼"   => "Lanyu",
    "墾丁"   => "Kending",
    "大光"   => "Daiguang",
    "後壁湖" => "Houbihu",
};

sub send_metrics {
    my $metrics = shift;
    my $ng = Net::Graphite->new();
    for my $metric (@$metrics) {
        my $plaintext = $ng->send(%$metric);
        print $plaintext;

    }
}

sub retrieve_from_jitsu {
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get("http://gugod.g0vre.jit.su/aec");
    exit -1 unless $response->is_success;
    my $datum = decode_json $response->decoded_content;
    my $metrics = [];
    for my $data (@$datum) {
        my $metric = "aec.radiation.$location_name_to_pinyin->{ $data->{location} }";
        my $t = DateTime::Format::ISO8601->parse_datetime( $data->{time} )->epoch;
        my $value = $data->{value};

        utf8::encode($metric);
        utf8::encode($value);
        utf8::encode($t);
        push @$metrics, {
            path  => $metric,
            value => $value,
            time  => $t
        }
    }

    return $metrics;
}

send_metrics retrieve_from_jitsu;
