#!/usr/bin/perl
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use List::Util;

# get options
my %opts;
Getopt::Long::GetOptions(\%opts, qw( d=s n=s ) );
my $domain = $opts{'d'};
my $nameserver_list = $opts{'n'};

if ($domain eq '' && $nameserver_list eq '') {
    # print usage
    pod2usage(verbose => 0);
} else {
    # dig ns
    my $dig_res = `dig $domain ns`;
    my @dig_res_lines = split(/\n/, $dig_res);
    my @dig_nss;
    for my $dig_res_line(@dig_res_lines) {
        if ($dig_res_line=~ /NS(\s+)(\S+)/) {
            push @dig_nss, $2;
        }
    }
    # check
    my $error = '';
    my @nameservers = split(/,/, $nameserver_list);
    for my $nameserver (@nameservers) {
        unless ( List::Util::first{$_ eq $nameserver} @dig_nss ) {
            $error .= "\"$nameserver\" ";
        }
    }
    for my $dig_ns (@dig_nss) {
        unless ( List::Util::first{$_ eq $dig_ns} @nameservers ) {
            $error .= "\"$dig_ns\" ";
        }
    }
    # print
    if ($error eq '') {
        printf "OK - $nameserver_list\n";
        exit 0
    } else {
        $error .= "does not match nameserver.";

        printf "Critical - $error\n";
        exit 2;
    }

}

=head1 NAME

check_nameserver.pl - Nagios Plugin to Check Nameserver.

=head1 SYNOPSIS

check_nameserver.pl -d "<domain>" -n "<nameserver1>,<nameserver2>,<nameserver3>"

=head1 AUTHOR

Contributed by Takeshi Yako
https://github.com/takeshiyako2

=head1 LICENSE

MIT

=cut

