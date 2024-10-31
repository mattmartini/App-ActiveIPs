#!/usr/bin/env perl
################################################################################
##  revlookup.pl - lookup name given ip address                               ##
##                                                                            ##
##                                                                            ##
##  Useage:    echo <list of IPs> | revlookup.pl                              ##
##                                                                            ##
##  Author:    Matt Martini                                                   ##
##                                                                            ##
##  Created:   20010918   v.1.0                                               ##
##                                                                            ##
##  Copyright: © 2001-2024  Matt Martini                                      ##
##                                                                            ##
################################################################################

########################################
#      Requirements and Packages       #
########################################

use 5.018;

use utf8;
use strict;
use warnings;
use Readonly;
use Socket;

Readonly my $PROGRAM => 'revlookup.pl';
Readonly my $VERSION => version->declare("v1.0.9");

my $to255_re = qr<(?:[01]?\d\d?|2[0-4]\d|25[0-5])>;
my $ip_re    = qr<^$to255_re(?:\.$to255_re){3}>;

printf ("%s\n", '┌─────┤IPV4├─────┬────┤host├────┬─────┤domain├─────┐');

while ( my $ip = <> ) {
    chomp $ip;
    my ( $host, $domain );

    if ( $ip !~ $ip_re ) {
        warn "$ip is not a valid IP address.\n";
        next;
    }

    my $name = gethostbyaddr( inet_aton($ip), AF_INET )
        or warn "Can't resolve $ip: $!\n";

    ( $host, $domain ) = $name =~ m{^([^\.]+)(.*)};

    printf( " %-18s%-15s%16s\n", $ip, $host, $domain );
}

