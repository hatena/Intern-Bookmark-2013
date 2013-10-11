package t::Intern::Bookmark::DBI;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent 'Test::Class';

use Test::Intern::Bookmark;
use Test::More;

sub _use : Test(1) {
    use_ok 'Intern::Bookmark::DBI';
}

__PACKAGE__->runtests;

1;
