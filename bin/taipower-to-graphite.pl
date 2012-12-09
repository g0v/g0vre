#!/usr/bin/env perl
use strict;
use utf8;
use JSON qw(decode_json);
use Net::Graphite;
use LWP::UserAgent;
use DateTime::Format::ISO8601;

# use Lingua::Han::PinYin;
# use Encode;
# my $h2p = Lingua::Han::PinYin->new;
my $h2p = {
    核一廠乾華民宅     => "HeYiChangGanHuaMinZhai",
    核一廠放射試驗室旁 => "HeYiChangFangSheShiYanShiPang",
    核一廠生水池前站   => "HeYiChangShengShuiChiQianZhan",
    核一廠生水池後站   => "HeYiChangShengShuiChiHouZhan",
    核一廠茂林社區     => "HeYiChangMaoLinSheQu",
    核三廠入水口       => "HeSanChangRuShuiKou",
    核三廠大光分隊旁   => "HeSanChangDaGuangFenDuiPang",
    核三廠宿舍區       => "HeSanChangSuSheQu",
    核三廠核三工作隊   => "HeSanChangHeSanGongZuoDui",
    核三廠舊墓地       => "HeSanChangJiuMuDe",
    核二廠二廠大修宿舍 => "HeErChangErChangDaXiuSuShe",
    核二廠仁和宮       => "HeErChangRenHeGong",
    核二廠保警隊部     => "HeErChangBaoJingDuiBu",
    核二廠入水口       => "HeErChangRuShuiKou",
    核二廠油槽         => "HeErChangYouCao",
    蘭嶼廠大門口       => "LanYuChangDaMenKou",
    蘭嶼廠後門口       => "LanYuChangHouMenKou",
    蘭嶼廠行政大樓側   => "LanYuChangXingZhengDaLouCe",
    龍門廠仁和宮       => "LongMenChangRenHeGong",
    龍門廠南側民宅     => "LongMenChangNanCeMinZhai",
    龍門廠昭惠廟       => "LongMenChangZhaoHuiMiao",
    龍門廠水返港       => "LongMenChangShuiFanGang",
    龍門廠環廠道路     => "LongMenChangHuanChangDaoLu",
};
sub han2pinyin {
    # join "" => map { ucfirst } $h2p->han2pinyin(Encode::encode_utf8($_[0]));
    return $h2p->{$_[0]};
}

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
    my $response = $ua->get("http://" . ($ENV{G0VRE_HOST} || "gugod.g0vre.jit.su") . "/taipower");
    exit -1 unless $response->is_success;
    my $datum = decode_json $response->decoded_content;
    my $metrics = [];
    for my $data (@$datum) {
        my $metric = "taipower.radiation." . han2pinyin($data->{location});
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

send_metrics retrieve_from_jitsu;
