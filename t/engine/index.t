package t::Intern::Bookmark::Engine::Index;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use Intern::Bookmark::Model::User;

sub _get : Test(2) {
    subtest 'guestアクセス' => sub {
        my $mech = create_mech;
        $mech->get_ok('/');
        $mech->title_is('Intern::Bookmark::Top');
        $mech->content_contains('/login');
    };

    subtest 'login状態でアクセス' => sub {
        my $user = create_user;
        my $mech = create_mech(user => $user);
        $mech->get_ok('/');
    };
}

__PACKAGE__->runtests;

1;
