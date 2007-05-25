use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Finance::Bank::Smile',
    AUTHOR              => 'Richard Panman <rpanman@cpan.org>',
    VERSION_FROM        => 'lib/Finance/Bank/Smile.pm',
    ABSTRACT_FROM       => 'lib/Finance/Bank/Smile.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'WWW::Mechanize' => 0,
        'HTML::TableExtract' =>0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Finance-Bank-Smile-*' },
);
