package t::Intern::Bookmark::Model::Bookmark;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use Intern::Bookmark::Model::Entry;
use Intern::Bookmark::Model::User;

use DateTime;
use DateTime::Format::MySQL;

use Encode;

use JSON::XS;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Model::Bookmark';
}

sub _accessor : Test(6) {
    my $now = DateTime->now;
    my $bookmark = Intern::Bookmark::Model::Bookmark->new(
        bookmark_id => 1,
        user_id     => 1,
        comment     => 'Commented',
        created     => DateTime::Format::MySQL->format_datetime($now),
        updated     => DateTime::Format::MySQL->format_datetime($now),
    );
    is $bookmark->bookmark_id, 1;
    is $bookmark->bookmark_id, 1;
    is $bookmark->user_id, 1;
    is $bookmark->comment, 'Commented';
    is $bookmark->created->epoch, $now->epoch;
    is $bookmark->updated->epoch, $now->epoch;
}

sub _json_hash : Test(1) {
    my $now = DateTime->now;
    my $bookmark = Intern::Bookmark::Model::Bookmark->new(
        bookmark_id => 1,
        user_id     => 1,
        comment     => encode_utf8 'コメント',
        created     => DateTime::Format::MySQL->format_datetime($now),
        updated     => DateTime::Format::MySQL->format_datetime($now),
    );
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => DateTime::Format::MySQL->format_datetime($now),
        updated  => DateTime::Format::MySQL->format_datetime($now),
    );
    $bookmark->entry($entry);
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name    => 'user_name',
        created => DateTime::Format::MySQL->format_datetime($now),
    );
    $bookmark->user($user);

    my $json = JSON::XS->new;

    my $json_string = $json->encode($bookmark->json_hash);

    is_deeply $json->decode($json_string), {
        bookmark_id => 1,
        comment     => 'コメント',
        created     => DateTime::Format::MySQL->format_datetime($now).q(),
        updated     => DateTime::Format::MySQL->format_datetime($now).q(),
        user        => {
            user_id => 1,
            name    => 'user_name',
            created => DateTime::Format::MySQL->format_datetime($now).q(),
        },
        entry       => {
            entry_id => 1,
            url      => 'http://www.google.com/',
            title    => 'Google',
            created  => DateTime::Format::MySQL->format_datetime($now).q(),
            updated  => DateTime::Format::MySQL->format_datetime($now).q(),
        },
    };
}

__PACKAGE__->runtests;

1;
