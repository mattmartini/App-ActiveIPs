use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::ActiveIPs',
    AUTHOR              => 'Matt Martini <matt@imaginarywave.com>',
    VERSION_FROM        => 'lib/App/ActiveIPs.pm',
    ABSTRACT_FROM       => 'lib/App/ActiveIPs.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-ActiveIPs-*' },
);
