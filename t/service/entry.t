package t::Intern::Bookmark::Service::Entry;

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
    require_ok 'Intern::Bookmark::Service::Entry';
}

sub find_entry_by_url : Test(3) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'urlがないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::Entry->find_entry_by_url($db, {
            });
        }
    };

    subtest 'urlで引ける' => sub {
        my $created_entry = create_entry;
        my $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($db, {
            url => $created_entry->url,
        });
        isa_ok $entry, 'Intern::Bookmark::Model::Entry', 'blessされている';
        cmp_deeply $entry, $created_entry, '内容が一致する';
    };
}

sub find_entries_by_ids : Test(3) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'entry_idsがないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::Entry->find_entries_by_ids($db, {
            });
        }
    };

    subtest 'entry引ける' => sub {
        my $entry_1 = create_entry;
        my $entry_2 = create_entry;

        my $entries = Intern::Bookmark::Service::Entry->find_entries_by_ids($db, {
            entry_ids => [$entry_1->entry_id, $entry_2->entry_id],
        });

        is scalar @$entries, 2, '2つある';
        cmp_deeply $entries, [$entry_1, $entry_2], '内容が一致する';
    };
}

sub find_entry_by_id : Test(2) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'entry_idがないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::Entry->find_entry_by_id($db, {
            });
        }
    };

    subtest 'entry引ける' => sub {
        my $created_entry = create_entry;

        my $entry = Intern::Bookmark::Service::Entry->find_entry_by_id($db, {
            entry_id => $created_entry->entry_id,
        });

        cmp_deeply $entry, $created_entry, '内容が一致する';
    };
}

sub create : Test(3) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'urlわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::User->create($db, {
            });
        };
    };

    subtest 'entry作成できる' => sub {
        my $url = 'http://' . random_regex('\w{15}') . '.com/';
        Intern::Bookmark::Service::Entry->create($db, {
            url => $url,
        });

        my $dbh = $db->dbh('intern_bookmark');
        my $entry = $dbh->select_row(q[
            SELECT * FROM entry
              WHERE
                url = :url
        ], {
            url => $url,
        });

        ok $entry, 'entryできている';
        is $entry->{url}, $url, 'urlが一致する';
    };
}

sub find_or_create_entry_by_url : Test(3) {
    my ($self) = @_;

    my $db = Intern::Bookmark::DBI::Factory->new;

    subtest 'urlわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Bookmark::Service::User->find_or_create_entry_by_url($db, {
            });
        };
    };

    my $url = 'http://' . random_regex('\w{15}') . '.com/';

    subtest 'まだ存在しないとき作成される' => sub {
        my $entry = Intern::Bookmark::Service::Entry->find_or_create_entry_by_url($db, {
            url => $url,
        });
        ok $entry;
    };

    subtest 'もう一回やったら値が返る' => sub {
        my $entry = Intern::Bookmark::Service::Entry->find_or_create_entry_by_url($db, {
            url => $url,
        });
        ok $entry;
    };
}

__PACKAGE__->runtests;

1;
