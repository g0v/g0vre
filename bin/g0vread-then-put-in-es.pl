#!/usr/bin/env perl

my $url = shift(@ARGV) || die "no url";

use v5.16;
use ElasticSearch;
use HTTP::Tiny;
use URI::Escape qw(uri_escape);
use JSON;

my $response = HTTP::Tiny->new->get('http://g0vre.herokuapp.com/read?url=' . uri_escape($url) );

die "Failed to get $url\n" unless $response->{success};

my $json_text = $response->{content};

my $data = JSON->new->utf8->decode($json_text);

my $es = ElasticSearch->new(
    transport => "httptiny",
);

my $result = $es->index(
    index => "g0vread",
    type  => "extracted",
    id   => $url,
    data => $data
);

say JSON->new->pretty->encode($result);
