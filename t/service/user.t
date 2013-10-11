package t::Intern::Bookmark::Service::User;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;
use Test::Deep;
use Test::Exception;

use String::Random qw(random_regex);

use Intern::Bookmark::DBI::Factory;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Service::User';
}

sub find_user_by_name : Test(4) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'nameないとき失敗する' => sub {
        dies_ok {
            my $user = Intern::Bookmark::Service::User->find_user_by_name($db, {
            });
        };
    };

    subtest 'user見つかる' => sub {
        my $created_user = create_user;

        my $user = Intern::Bookmark::Service::User->find_user_by_name($db, {
            name => $created_user->name,
        });

        ok $user, 'userが引ける';
        isa_ok $user, 'Intern::Bookmark::Model::User', 'blessされている';
        is $user->name, $created_user->name, 'nameが一致する';
    };
}

sub find_users_by_user_ids : Test(5) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'user_idsないとき失敗する' => sub {
        dies_ok {
            my $user = Intern::Bookmark::Service::User->find_users_by_user_ids($db, {
            });
        };
    };

    subtest 'ひとりのとき' => sub {
        my $user_1 = create_user;

        my $users = Intern::Bookmark::Service::User->find_users_by_user_ids($db, {
            user_ids => [$user_1->user_id],
        });

        is scalar @$users, 1, 'userがひとり';
        cmp_deeply $users, [$user_1], '内容が一致';
    };

    subtest 'ふたりのとき' => sub {
        my $user_1 = create_user;
        my $user_2 = create_user;

        my $users = Intern::Bookmark::Service::User->find_users_by_user_ids($db, {
            user_ids => [$user_1->user_id, $user_2->user_id],
        });

        is scalar @$users, 2, 'userがふたり';
        cmp_deeply $users, [$user_1, $user_2], '内容が一致';
    };
}

sub create : Test(3) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'ユーザー名わたさないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::User->create($db, {
            });
        };
    };

    subtest 'ユーザー作成できる' => sub {
        my $name = random_regex('test_user_\w{15}');
        Intern::Bookmark::Service::User->create($db, {
            name => $name,
        });

        my $dbh = $db->dbh('intern_bookmark');
        my $user = $dbh->select_row(q[
            SELECT * FROM user
              WHERE
                name = :name
        ], {
            name => $name,
        });

        ok $user, 'ユーザーできている';
        is $user->{name}, $name, 'nameが一致する';
    };
}

__PACKAGE__->runtests;

1;
