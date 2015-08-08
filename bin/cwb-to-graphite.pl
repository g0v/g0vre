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
    my $response = $ua->get("http://" . ($ENV{G0VRE_HOST} || "g0vre.herokuapp.com") . "/cwb.rains");
    exit -1 unless $response->is_success;
    my $datum = decode_json $response->decoded_content;
    my $metrics = [];
    my @fields = ("10","60","180","360","720","1800","today","previous-day","last-two-days");
    for my $data (@$datum) {
        for my $i (0..$#fields) {
            my $field_name = $fields[$i];
            my $metric_name = "cwb.rainfall.${field_name}." . $data->{station};
            if (defined(my $metric_value = $data->{values}[$i])) {
                my $t = DateTime::Format::ISO8601->parse_datetime( $data->{time} )->epoch;
                push @$metrics, {
                    path  => $metric_name,
                    value => $metric_value,
                    time  => $t
                }
            }
        }
    }

    return $metrics;
}

send_metrics retrieve_from_jitsu;
