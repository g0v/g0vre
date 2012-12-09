#!/usr/bin/env perl
use strict;
use utf8;
use JSON qw(decode_json);
use Net::Graphite;
use LWP::UserAgent;
use DateTime::Format::ISO8601;

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
    my $response = $ua->get("http://" . ($ENV{G0VRE_HOST} || "gugod.g0vre.jit.su") . "/cwb.rainfall");
    exit -1 unless $response->is_success;
    my $datum = decode_json $response->decoded_content;
    my $metrics = [];
    for my $data (@$datum) {
        my $metric = "cwb.rainfall10." . $data->{station};
        my $t = DateTime::Format::ISO8601->parse_datetime( $data->{time} )->epoch;
        my $value = $data->{value};
        if (defined $value) {
            push @$metrics, {
                path  => $metric,
                value => $value,
                time  => $t
            }
        }
    }

    return $metrics;
}

send_metrics retrieve_from_jitsu;
