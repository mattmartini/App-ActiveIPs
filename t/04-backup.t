#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::Base::Syntax;
use MERM::Base qw(::Utils ::Backup);
use File::Copy;

plan tests => 4;

#======================================#
#           Make test files            #
#======================================#

my $td = mk_temp_dir();
my $tf = mk_temp_file($td);

my $tff = $td . "/tempfile.$$.test";
open( my $tff_h, '>', $tff ) or croak "Can't open file for writing\n";
print $tff_h "Powerful Tiny Turn Related Flew";
close($tff_h);

#======================================#
#                backup                #
#======================================#

my $mtime = ( stat $tff )[9];
my ( $mday, $mon, $year ) = ( localtime($mtime) )[ 3 .. 5 ];

my $backup_file
    = sprintf( "%s_%d%02d%02d", $tff, $year + 1900, $mon + 1, $mday );

my $test_file_exists = file_exists($tff);

# create a backup file
backup($tff);
my $backup_file_exists = file_exists($backup_file);
is( $backup_file_exists, 1, 'backup file created with name: file_YYYYMMDD' );

# should not create a new backup as base file has not changed
my $second_backup_file = $backup_file . '_1';
backup($tff);
my $second_backup_file_exists = file_exists($second_backup_file);
is( $second_backup_file_exists, 0, 'second backup file should not exist' );

# change test file
open( $tff_h, '>>', $tff ) or croak "Can't open file for appending\n";
print $tff_h "universe March";
close($tff_h);

# now new backup should be created with name: file_YYYYMMDD_1
backup($tff);
$second_backup_file_exists = file_exists($second_backup_file);
is( $second_backup_file_exists, 1, 'second backup file should exist' );

# prepare dir for backup test
my $testdir = $td->dirname . '/testdir';
mkdir $testdir, oct(777);

my $testdir_exists = dir_exists($testdir);
is( $testdir_exists, 1, 'testdir created' );

move( $tff,         $testdir ) or croak "Can't move file to testdir.\n";
move( $backup_file, $testdir ) or croak "Can't move file to testdir.\n";
move( $second_backup_file, $testdir )
    or croak "Can't move file to testdir.\n";

# $testdir = '/tmp/xyzzy';
# # backup test dir
# backup($testdir);

# my $dirbackup_file
#     = sprintf( "%s_%d%02d%02d", $testdir, $year + 1900, $mon + 1, $mday );
# my $testdir_backup_file = file_exists($dirbackup_file);
# is( $testdir_backup_file, 1, 'testdir backup made' );

done_testing;
