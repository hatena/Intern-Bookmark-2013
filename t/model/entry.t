package t::Intern::Bookmark::Model::Entry;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use DateTime;
use DateTime::Format::MySQL;

use JSON::XS;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Model::Entry';
}

sub _accessor : Test(5) {
    my $now = DateTime->now;
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => DateTime::Format::MySQL->format_datetime($now),
        updated  => DateTime::Format::MySQL->format_datetime($now),
    );
    is $entry->entry_id, 1;
    is $entry->url, 'http://www.google.com/';
    is $entry->title, 'Google';
    is $entry->created->epoch, $now->epoch;
    is $entry->updated->epoch, $now->epoch;
}

sub _json_hash : Test(1) {
    my $now = DateTime->now;
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => DateTime::Format::MySQL->format_datetime($now),
        updated  => DateTime::Format::MySQL->format_datetime($now),
    );

    my $json = JSON::XS->new;

    my $json_string = $json->encode($entry->json_hash);

    is_deeply $json->decode($json_string), {
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => DateTime::Format::MySQL->format_datetime($now).q(),
        updated  => DateTime::Format::MySQL->format_datetime($now).q(),
    };
}

__PACKAGE__->runtests;

1;
