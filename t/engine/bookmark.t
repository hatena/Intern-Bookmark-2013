package t::Intern::Bookmark::Engine::Bookmark;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use URI;
use URI::QueryParam;

use Intern::Bookmark::Model::User;
use Intern::Bookmark::Service::Bookmark;

sub _default : Tests {
    my $user = create_user;
    my $bookmark = create_bookmark(user => $user);

    my $permalink = URI->new('/bookmark');
    $permalink->query_param(url => $bookmark->entry->url);

    my $mech = create_mech(user => $user);
    $mech->get_ok($permalink);
    $mech->content_contains(sprintf("%s - %s", $user->name, $bookmark->comment));
}

sub _add : Tests {
    my $db = Intern::Bookmark::DBI::Factory->new;

    my $user  = create_user;
    my $entry = create_entry;

    my $mech = create_mech(user => $user);

    subtest '新規作成' => sub {
        $mech->get_ok('/bookmark/add');
        $mech->submit_form_ok({
            fields => {
                url     => $entry->url,
                comment => 'bookmark comment'
            },
        });

        my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($db, {
            user  => $user,
            entry => $entry,
        });
        ok $bookmark, 'ブックマーク作成されている';
        is $bookmark->comment, 'bookmark comment';
    };

    subtest '編集' => sub {
        my $url = URI->new('/bookmark/add');
        $url->query_param(url => $entry->url);

        $mech->get_ok($url);
        $mech->submit_form_ok({
            fields => {
                url     => $entry->url,
                comment => 'bookmark comment edit'
            },
        });

        my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($db, {
            user  => $user,
            entry => $entry,
        });
        ok $bookmark, 'ブックマーク作成されている';
        is $bookmark->comment, 'bookmark comment edit';
    };
}

sub _delete : Tests {
    my $db = Intern::Bookmark::DBI::Factory->new;

    my $user  = create_user;
    my $entry = create_entry;
    my $bookmark = create_bookmark(user => $user, entry => $entry);

    my $mech = create_mech(user => $user);

    my $delete_url = URI->new('/bookmark/delete');
    $delete_url->query_param(url => $entry->url);

    $mech->get_ok($delete_url);
    $mech->submit_form_ok;

    $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($db, {
        user  => $user,
        entry => $entry,
    });
    ok !$bookmark, 'ブックマーク消えてる';
}

__PACKAGE__->runtests;

1;
