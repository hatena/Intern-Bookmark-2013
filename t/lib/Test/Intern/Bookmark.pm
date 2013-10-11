package Test::Intern::Bookmark;

use strict;
use warnings;
use utf8;

use Path::Class;
use lib file(__FILE__)->dir->subdir('../../../../lib')->stringify;
use lib glob file(__FILE__)->dir->subdir('../../../../modules/*/lib')->stringify;

use Intern::Bookmark::DBI::Factory;

use String::Random qw(random_regex);
use DateTime;
use DateTime::Format::MySQL;

BEGIN {
    $ENV{INTERN_BOOKMARK_ENV} = 'test';
    $ENV{PLACK_ENV} = 'test';
    $ENV{DBI_REWRITE_DSN} ||= 1;
}

use DBIx::RewriteDSN -rules => q<
    ^(.*?;mysql_socket=.*)$ $1
    ^.*?:dbname=([^;]+?)(?:_test)?(?:;.*)?$ dbi:mysql:dbname=$1_test;host=localhost
    ^(DBI:Sponge:)$ $1
    ^(.*)$ dsn:unsafe:got=$1
>;

sub import {
    my $class = shift;
    my $code = q[
        use Test::More;
        use encoding 'utf8';
        binmode Test::More->builder->output, ":utf8";
        binmode Test::More->builder->failure_output, ":utf8";
        binmode Test::More->builder->todo_output, ":utf8";
    ];
    eval $code;
    die $@ if $@;
}

1;
