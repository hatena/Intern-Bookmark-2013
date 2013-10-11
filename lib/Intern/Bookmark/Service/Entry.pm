package Intern::Bookmark::Service::Entry;

use strict;
use warnings;
use utf8;

use Carp;
use DateTime;
use Encode;

use LWP::UserAgent;

sub find_entry_by_url {
    my ($class, $db, $args) = @_;

    my $url = $args->{url} // croak 'url required';

    $db->dbh('intern_bookmark')->select_row_as(q[
        SELECT * FROM entry
          WHERE
            url = :url
    ], +{
        url => $url
    }, 'Intern::Bookmark::Model::Entry');
}

sub find_entries_by_ids {
    my ($class, $db, $args) = @_;

    my $entry_ids = $args->{entry_ids} // croak 'entry_ids required';

    $db->dbh('intern_bookmark')->select_all_as(q[
        SELECT * FROM entry
          WHERE
            entry_id IN (:entry_ids)
    ], +{
        entry_ids => $entry_ids,
    }, 'Intern::Bookmark::Model::Entry');
}

sub find_entry_by_id {
    my ($class, $db, $args) = @_;
    my $entry_id = $args->{entry_id} // croak 'entry_id required';

    return $class->find_entries_by_ids($db, {
        entry_ids => [$entry_id],
    })->[0];
}

sub create {
    my ($class, $db, $args) = @_;

    my $url = $args->{url} // croak 'url required';
    my $title = $args->{title} // '';

    my $now = DateTime->now;

    $db->dbh('intern_bookmark')->query(q[
        INSERT INTO entry
          SET
            url     = :url,
            title   = :title,
            created = :created,
            updated = :updated
    ], {
        url     => $url,
        title   => encode_utf8 $title,
        created => $now,
        updated => $now,
    });
}

sub find_or_create_entry_by_url {
    my ($class, $db, $args) = @_;

    my $url = $args->{url} // croak 'url required';

    my $entry = $class->find_entry_by_url($db, +{ url => $url });
    unless ($entry) {
        my $title = $class->fetch_title_by_url($url);
        $class->create($db, +{
            url   => $url,
            title => $title
        });
        $entry = $class->find_entry_by_url($db, +{ url => $url });
    }
}

sub fetch_title_by_url {
    my ($class, $url) = @_;

    my $ua = LWP::UserAgent->new;
    my $res = $ua->get($url);
    if ($res->is_error) {
        warn sprintf '%s: %s', $url, $res->status_line;
        return;
    }

    my ($title) = $res->decoded_content =~ m{<title>(.+?)</title>}s;
    return $title;
}

1;
