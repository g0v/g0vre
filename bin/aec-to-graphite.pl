use v5.14;
use strict;
use utf8;
use JSON;
use Encode qw(decode);
use IO::String;
use Net::Graphite;
use LWP::UserAgent;
use DateTime::Format::ISO8601;
use DateTime::Format::HTTP;
use Text::CSV;

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
        utf8::encode($metric->{path});
        utf8::encode($metric->{value});
        utf8::encode($metric->{time});

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

        push @$metrics, {
            path  => $metric,
            value => $value,
            time  => $t
        }
    }

    return $metrics;
}

sub retrieve_from_aec {
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get("http://www.aec.gov.tw/open/gammamonitor.csv");
    exit -1 unless $response->is_success;
    my $csv_decoder = Text::CSV->new({ binary => 1 });
    my $io = IO::String->new( decode "big5" => $response->content );
    $io->getline; # strip header

    my $metrics = [];
    while (my $row = $csv_decoder->getline($io)) {
        push @$metrics, {
            path  => "aec.radiation.$location_name_to_pinyin->{ $row->[0] }",
            value => $row->[2],
            time  => DateTime::Format::HTTP->parse_datetime($row->[3], "Asia/Taipei")->epoch,
        }
    }
    return $metrics;
}

send_metrics retrieve_from_jitsu;
# say encode_json retrieve_from_jitsu;
# say encode_json retrieve_from_aec;

