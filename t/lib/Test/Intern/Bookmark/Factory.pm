package Test::Intern::Bookmark::Factory;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw(
    create_user
    create_entry
    create_bookmark
);

use String::Random qw(random_regex);
use DateTime;
use DateTime::Format::MySQL;

use Intern::Bookmark::Service::User;
use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Service::Bookmark;

sub create_user {
    my %args = @_;
    my $name = $args{name} // random_regex('test_user_\w{15}');
    my $created = $args{created} // DateTime->now;

    my $db = Intern::Bookmark::DBI::Factory->new;
    my $dbh = $db->dbh('intern_bookmark');
    $dbh->query(q[
        INSERT INTO user
          SET name = :name,
              created = :created
    ], {
        name    => $name,
        created => DateTime::Format::MySQL->format_datetime($created),
    });

    return Intern::Bookmark::Service::User->find_user_by_name($db, { name => $name });
}

sub create_entry {
    my %args = @_;
    my $url      = $args{url} // 'http://' . random_regex('\w{15}') . '.com/';
    my $title    = $args{title} // random_regex('\w{50}');
    my $created  = $args{created} // DateTime->now;
    my $updated  = $args{updated} // DateTime->now;

    my $db = Intern::Bookmark::DBI::Factory->new;
    my $dbh = $db->dbh('intern_bookmark');
    $dbh->query(q[
        INSERT INTO entry
          SET url     = :url,
              title   = :title,
              created = :created,
              updated = :updated
    ], {
        url     => $url,
        title   => $title,
        created => DateTime::Format::MySQL->format_datetime($created),
        updated => DateTime::Format::MySQL->format_datetime($updated),
    });

    return Intern::Bookmark::Service::Entry->find_entry_by_url($db, { url => $url });
}

sub create_bookmark {
    my %args = @_;
    my $user    = $args{user}    // create_user();
    my $entry   = $args{entry}   // create_entry();
    my $comment = $args{comment} // random_regex('\w{50}');
    my $created = $args{created} // DateTime->now;
    my $updated = $args{updated} // DateTime->now;

    my $db = Intern::Bookmark::DBI::Factory->new;
    my $dbh = $db->dbh('intern_bookmark');
    $dbh->query(q[
        INSERT INTO bookmark
          SET user_id  = :user_id,
              entry_id = :entry_id,
              comment  = :comment,
              created  = :created,
              updated  = :updated
    ], {
        user_id  => $user->user_id,
        entry_id => $entry->entry_id,
        comment  => $comment,
        created  => DateTime::Format::MySQL->format_datetime($created),
        updated  => DateTime::Format::MySQL->format_datetime($updated),
    });

    my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry(
        $db,
        { user => $user, entry => $entry},
    );
    $bookmark->entry($entry);
    $bookmark->user($user);
    return $bookmark;
}

1;
