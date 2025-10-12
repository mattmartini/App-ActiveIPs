use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'App::ActiveIPs',
    DISTNAME           => 'App-ActiveIPs',
    AUTHOR             => 'Matt Martini <matt@imaginarywave.com>',
    VERSION_FROM       => 'lib/App/ActiveIPs.pm',
    ABSTRACT_FROM      => 'lib/App/ActiveIPs.pm',
    LICENSE            => 'gpl_3',
    MIN_PERL_VERSION   => '5.018',
    PL_FILES           => {},
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
    EXE_FILES          => ['bin/activeips'],
    PREREQ_PM          => {
                       'Test::More'      => 0,
                       'Carp'            => 0,
                       'English'         => 0,
                       'Exporter'        => 0,
                       'Readonly'        => 0,
                       'Term::ANSIColor' => 0,
                       'Term::ReadKey'   => 0,
                       'autodie'         => 0,
                       'strict'          => 0,
                       'utf8'            => 0,
                       'version'         => 0,
                       'warnings'        => 0,
                 },
    TEST_REQUIRES => {     'English'            => 0,
                           'ExtUtils::Manifest' => 0,
                           'File::Compare'      => 0,
                           'File::Path'         => 0,
                           'FindBin'            => 0,
                           'Socket'             => 0,
                           'Test2::V0'          => 0,
                           'Test2::Tools::Ref'  => 0,
                           'Test::More'         => 0,
                     },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {   repository => {
                                    type => 'git',
                                    url => 'https://github.com/mattmartini/App-ActiveIPs.git',
                                    web => 'https://github.com/mattmartini/App-ActiveIPs'
                           },
                     }
                  },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'App-ActiveIPs-*' },
);
