package t::Intern::Bookmark::Engine::API;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use JSON::XS qw(decode_json);
use String::Random qw(random_regex);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use Intern::Bookmark::Model::User;

sub _bookmarks : Tests {
    subtest 'guestアクセス' => sub {
        my $mech = create_mech;
        $mech->get('/api/bookmarks');
        is $mech->res->code, 401, 'ログインが必要なので401が返る';
    };

    subtest 'login状態でアクセス' => sub {
        my $user = create_user;
        my $mech = create_mech(user => $user);
        $mech->get_ok('/api/bookmarks');
        is $mech->res->code, 200, '200が返る';

        my $res = decode_json $mech->res->content;
        ok $res, 'JSONが返っている';
    };

    subtest '正しいJSONの内容が返ること' => sub {
        my $user = create_user;

        my $bookmarks = [];
        for (0..30) {
            my $bookmark = create_bookmark(user => $user);
            push @$bookmarks, $bookmark;
        }

        my $mech = create_mech(user => $user);

        subtest '最初のページ' => sub {
            $mech->get_ok('/api/bookmarks');

            my $res = decode_json $mech->res->content;
            ok $res;

            is_deeply $res, {
                bookmarks => [ reverse map { $_->json_hash } @$bookmarks[11..30] ],
                per_page => 20,
                next_page => 2,
            }, '内容が正しい';
        };

        subtest '2ページ目' => sub {
            $mech->get_ok('/api/bookmarks?page=2');

            my $res = decode_json $mech->res->content;
            ok $res;

            is_deeply $res, {
                bookmarks => [ reverse map { $_->json_hash } @$bookmarks[0..10] ],
                per_page => 20,
                next_page => 3,
            }, '内容が正しい';
        };

        subtest 'per_pageを指定したときの2ページ目' => sub {
            $mech->get_ok('/api/bookmarks?per_page=10&page=2');

            my $res = decode_json $mech->res->content;
            ok $res;

            is_deeply $res, {
                bookmarks => [ reverse map { $_->json_hash } @$bookmarks[11..20] ],
                per_page => 10,
                next_page => 3,
            }, '内容が正しい';
        };
    };
}

sub _bookmark_post : Tests {
    subtest 'guestアクセス' => sub {
        my $mech = create_mech;
        $mech->post('/api/bookmark');
        is $mech->res->code, 401, 'ログインが必要なので401が返る';
    };

    subtest 'login状態でアクセスするけど要素が足りないとき' => sub {
        my $user = create_user;
        my $mech = create_mech(user => $user);
        $mech->post('/api/bookmark?comment=test');
        is $mech->res->code, 400, 'urlないとき400が返る';
    };

    subtest 'ブックマークできること' => sub {
        my $user = create_user;
        my $mech = create_mech(user => $user);

        my $url = 'http://' . random_regex('\w{15}') . '.com/';

        $mech->post("/api/bookmark?url=$url");
        is $mech->res->code, 200;

        my $res = decode_json $mech->res->content;
        ok $res;

        my $db = Intern::Bookmark::DBI::Factory->new;
        my $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($db, {
            url => $url,
        });

        my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($db, {
            user => $user,
            entry => $entry,
        });
        ok $bookmark, 'bookmarkができている';

        $bookmark->user($user);
        $bookmark->entry($entry);

        is_deeply $res, {
            bookmark => $bookmark->json_hash,
        }, 'responseの内容が正しい';
    };
}

__PACKAGE__->runtests;

1;
