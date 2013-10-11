package t::Intern::Bookmark::DBI::Factory;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent 'Test::Class';

use Test::More;

use Test::Intern::Bookmark;

use Intern::Bookmark::Util;

sub _use : Test(1) {
    use_ok 'Intern::Bookmark::Util';
}

__PACKAGE__->runtests;

1;
