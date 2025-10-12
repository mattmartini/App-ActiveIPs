#!/usr/bin/env perl

################################################################################
##  get_switch_ver.pl -   poll switches and ask for version info              ##
##                                                                            ##
##  Author:    Matt Martini (matt@invision.net)                               ##
##                                                                            ##
##  Created:   2000/11/01   v.1.0                                             ##
##                                                                            ##
##  Copyright © 2000-2024  Matt Martini <matt.martini@imaginarywave.com>      ##
##                                                                            ##
################################################################################

########################################
#      Requirements and Packages       #
########################################

use MERM::Base::Syntax;

use Time::Piece;
use Net::IP;
use Net::Telnet::Cisco;
use FindBin;

use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };

Readonly my $PROGRAM => 'get_switch_ver.pl';
Readonly my $VERSION => version->declare("v2.0.7");

########################################
#      Define Global Variables         #
########################################

# Default config params
my %config = (
               ping    => 1,
               debug   => 1,    # debugging
               silent  => 0,    # Do not print report on stdout
               verbose => 0,    # Generate debugging info on stderr
             );

local $OUTPUT_AUTOFLUSH = 1;

my $time = Time::Piece->new;
my $date = $time->strftime('%Y%m%d');

my $username = 'merm_util';
my $password = 'r6BRHBNGmaydasmLv5ViJQovJ';

my @switches = read_list("$FindBin::Bin/switch_list.txt");

my @ip_blks = qw (10.17.0.0/22);

my @cmd_list = (
                 'priv',
                 'inventory',
                 'version',
                 'ip arp',
                 'mac-address-table',
                 'mac address-table',
                 'vlan summary',
                 'vlan',
                 'ip interface brief',
                 'int desc',
                 'int trunk',
                 'int stats',
                 'int summary',
                 'int switching',
                 'ip route',
                 'ip traffic',
                 'ip access-lists',
                 'ip igmp groups',
                 'ip igmp interface',
                 'ip pim neighbor',
                 'ip pim interface',
                 'ip mroute',
                 'ip mroute sum',
                 'ip mroute cache',
                 'ip mroute count',
                 'ip pim rp mapping',
                 'ip pim rp active',
                 'switch detail',
                 'switch nei',
                 'cdp nei',
                 'cdp nei detail',
                 'proc',
                 'proc cpu history',
                 'etherchannel summary',
                 'spanning-tree',
                 'env all',
                 'logging',
                 'conf',
                 'running-config',
                 'tech',
                 'int',
               );

# 'tech-support unprivileged',

my ( $cs, @cmd_output );

########################################
#            Main Program              #
########################################
print $date . "\n";

SWITCH:
foreach my $switch (@switches) {
    my $sub_switch = 0;    #set to 1 to get info from sub-switches
    my $target     = '';

    next SWITCH if ( $switch =~ /^#/ );

    print "-" x 30, "\n";
    print "switch: $switch \n";

    if ( $switch =~ m|s|i ) {
        ( $target, $switch ) = split( 's', $switch );
        $sub_switch = 1;
    }

    if ( $config{ debug } ) {
        $cs = Net::Telnet::Cisco->new(
                                       Host       => $switch,
                                       Input_log  => "log.in_$switch",
                                       Output_log => "log.out_$switch",
                                       Timeout    => 15
                                     );
    }
    else {
        $cs = Net::Telnet::Cisco->new( Host    => $switch,
                                       Timeout => 15 );
    }

    next SWITCH
        unless eval { $cs->login( Name => $username, Password => $password ) };

    #    eval { $cs->enable( Password => $password ) };

    if ($sub_switch) {
        @cmd_output = $cs->cmd( String => 'telnet ' . $target,
                                Prompt => '/Username:/' );
        sleep 2;
        @cmd_output = $cs->cmd( String => $username,
                                Prompt => '/Password:/' );
        sleep 2;
        @cmd_output = $cs->cmd( String => $password );
        $switch     = $target;
    }

    # This error handler prints the errmsg and continues.
    $cs->errmode( sub { print @_, "\n" } );

    # Turn off paging
    @cmd_output = $cs->cmd('terminal length 0');

    ping_ip_blocks( { ip_blocks => \@ip_blks } ) if $config{ ping };

    foreach my $cmd (@cmd_list) {
        my @cmd_out = ();
        print "Sending command -> show " . $cmd . "\n";

        ( my $nosp_cmd = $cmd ) =~ s{\s+}{_}g;

        @cmd_out = $cs->cmd( String  => 'show ' . $cmd,
                             Timeout => 60 );
        unless ( $cs->errmsg ) {
            p @cmd_out if $config{ debug };

            my $filename = sprintf "switch_%s-%s-%s.txt", $switch, $nosp_cmd, $date;
            open( my $fh, '>', $filename )
                or die "Can't open file, $filename, for writing. $!\n";
            print $fh '# show ' . "$cmd\n";

            foreach my $out (@cmd_out) {
                print $fh $out;
            }
            close($fh);
        }
    }
    @cmd_output = $cs->cmd('exit');

    $cs->close;
}

exit(0);

########################################
#           Subroutines                #
########################################

#--------------------------------------------------------------------#
#  ping_ip_blocks -                       #
#--------------------------------------------------------------------#
sub ping_ip_blocks {
    my ($arg_ref) = @_;
    $arg_ref->{ protocol } ||= 'ip';    # default 'ip'
    $arg_ref->{ repeat }   ||= 2;       # default 5
    $arg_ref->{ datagram } ||= 100;     # default 100
    $arg_ref->{ timeout }  ||= '1';     # default 2
    $arg_ref->{ extended } ||= 'n';     # default 'n'
    $arg_ref->{ sweep }    ||= 'n';     # default 'n'

    foreach my $ip_blk ( @{ $arg_ref->{ ip_blocks } } ) {
        my $ip_network = Net::IP->new( $ip_blk, 4 )
            or die "Can't create IP block $!\n";

        do {
            my $ip = $ip_network->ip();
            warn "ping ip: $ip\n" if $config{ debug };

            my $ping_cmd = <<"EofPing";
ping
$arg_ref->{ protocol }
$ip
$arg_ref->{ repeat }
$arg_ref->{ datagram }
$arg_ref->{ timeout }
$arg_ref->{ extended }
$arg_ref->{ sweep }
EofPing
            @cmd_output = ();
            @cmd_output = $cs->cmd($ping_cmd);

            print "ping $ip\n";
            foreach (@cmd_output) {
                print if $config{ debug };
            }
        } while ( ++$ip_network );    # must use postfix while with Net::IP
    }
    return;
}

#--------------------------------------------------------------------#
#  read_list - read a list from an input file rtn an array of lines  #
#--------------------------------------------------------------------#
sub read_list {
    my $input_file = shift;
    my $sep        = shift || "\n";

    $sep = undef if ( !wantarray );
    local $INPUT_RECORD_SEPARATOR = $sep;

    my ( $line, @list );

    open( my $input, '<', $input_file )
        or die "can't open file, $input_file $!\n";
    while ( defined( $line = <$input> ) ) {
        chomp($line);
        push @list, $line;
    }
    close($input);

    return wantarray ? @list : $list[0];
}
