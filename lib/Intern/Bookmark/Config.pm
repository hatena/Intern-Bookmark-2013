package Intern::Bookmark::Config;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Config::Route;

use Config::ENV 'INTERN_BOOKMARK_ENV', export => 'config';
use Path::Class qw(file);

my $Router = Intern::Bookmark::Config::Route->make_router;
my $Root = file(__FILE__)->dir->parent->parent->parent->absolute;

sub router { $Router }
sub root { $Root }

common {
};

$ENV{SERVER_PORT} ||= 3000;
config default => {
    origin => "http://localhost:$ENV{SERVER_PORT}",
};

config production => {
};

config local => {
    parent('default'),
    db => {
        intern_bookmark => {
            user     => 'intern',
            password => 'intern',
            dsn      => 'dbi:mysql:dbname=intern_bookmark;host=localhost',
        },
    },
    db_timezone => 'UTC',
};

config test => {
    parent('default'),

    db => {
        intern_bookmark => {
            user     => 'intern',
            password => 'intern',
            dsn      => 'dbi:mysql:dbname=intern_bookmark_test;host=localhost',
        },
    },
    db_timezone => 'UTC',
};

1;
