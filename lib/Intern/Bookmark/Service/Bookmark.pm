package Intern::Bookmark::Service::Bookmark;

use strict;
use warnings;
use utf8;

use Carp;
use Encode;

use Intern::Bookmark::Service::Entry;

sub find_bookmark_by_user_and_entry {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $entry = $args->{entry} // croak 'entry required';

    $db->dbh('intern_bookmark')->select_row_as(q[
        SELECT * FROM bookmark
          WHERE
            user_id  = :user_id AND
            entry_id = :entry_id
    ], +{
        user_id  => $user->user_id,
        entry_id => $entry->entry_id,
    }, 'Intern::Bookmark::Model::Bookmark');
}

sub find_bookmarks_by_user {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';

    my $per_page = $args->{per_page};
    my $page = $args->{page};
    my $order_by = $args->{order_by};

    my $where = {
        user_id => $user->user_id,
    };
    my $opts = {};
    $opts->{limit} = $per_page if defined $per_page;
    $opts->{offset} = ($page - 1) * $per_page if defined $page && defined $per_page;
    $opts->{order_by} = $order_by if defined $order_by;

    my ($sql, @binds) = $db->query_builder->select('bookmark', ['*'], $where, $opts);

    $db->dbh('intern_bookmark')->select_all_as($sql, @binds, 'Intern::Bookmark::Model::Bookmark');
}

sub find_bookmarks_by_entry {
    my ($class, $db, $args) = @_;

    my $entry = $args->{entry} // croak 'entry required';

    $db->dbh('intern_bookmark')->select_all_as(q[
        SELECT * FROM bookmark
          WHERE entry_id = :entry_id
    ], {
        entry_id => $entry->entry_id,
    }, 'Intern::Bookmark::Model::Bookmark');
}

sub load_entry_info {
    my ($class, $db, $bookmarks) = @_;

    my $entry_ids = [ map { $_->entry_id } @$bookmarks ];
    my $entries = Intern::Bookmark::Service::Entry->find_entries_by_ids($db, +{ entry_ids => $entry_ids });

    my $entry_map = { map { $_->entry_id => $_ } @$entries };
    for my $bookmark (@$bookmarks) {
        $bookmark->entry($entry_map->{$bookmark->entry_id});
    }

    $bookmarks;
}

sub load_user {
    my ($class, $db, $bookmarks) = @_;

    my $user_ids = [ map { $_->user_id } @$bookmarks ];
    my $users = Intern::Bookmark::Service::User->find_users_by_user_ids($db, {
        user_ids => $user_ids,
    });

    my $user_map = { map { $_->user_id => $_ } @$users };
    for my $bookmark (@$bookmarks) {
        $bookmark->user($user_map->{$bookmark->user_id});
    }

    return $bookmarks;
}

sub create {
    my ($class, $db, $args) = @_;

    my $user_id = $args->{user_id} // croak 'user_id required';
    my $entry_id = $args->{entry_id} // croak 'entry_id required';
    my $comment = $args->{comment} // '';

    my $now = DateTime->now;

    $db->dbh('intern_bookmark')->query(q[
        INSERT INTO bookmark
          SET
            user_id  = :user_id,
            entry_id = :entry_id,
            comment  = :comment,
            created  = :created,
            updated  = :updated
    ], {
        user_id  => $user_id,
        entry_id => $entry_id,
        comment  => encode_utf8 $comment,
        created  => $now,
        updated  => $now,
    });
}

sub update {
    my ($class, $db, $args) = @_;

    my $bookmark_id = $args->{bookmark_id} // croak 'bookmark_id required';
    my $comment = $args->{comment} // '';

    $db->dbh('intern_bookmark')->query(q[
        UPDATE bookmark
          SET
            comment = :comment,
            updated = :updated
          WHERE
            bookmark_id = :bookmark_id
    ], {
        bookmark_id => $bookmark_id,
        comment     => encode_utf8 $comment,
        updated     => DateTime->now,
    });
}

sub delete_bookmark {
    my ($class, $db, $bookmark) = @_;

    $db->dbh('intern_bookmark')->query(q[
        DELETE FROM bookmark
          WHERE
            bookmark_id = :bookmark_id
    ], {
        bookmark_id => $bookmark->bookmark_id,
    });
}

sub add_bookmark {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $url = $args->{url} // croak 'url required';
    my $comment = $args->{comment}// '';

    my $entry = Intern::Bookmark::Service::Entry->find_or_create_entry_by_url($db, +{ url => $url });

    my $bookmark = $class->find_bookmark_by_user_and_entry($db, +{
        user  => $user,
        entry => $entry,
    });

    if ($bookmark) {
        $class->update($db, +{
            bookmark_id => $bookmark->bookmark_id,
            comment     => $comment,
        });
    }
    else {
        $class->create($db, +{
            user_id  => $user->user_id,
            entry_id => $entry->entry_id,
            comment  => $comment,
        });
    }

    $bookmark = $class->find_bookmark_by_user_and_entry($db, +{
        user  => $user,
        entry => $entry,
    });

    $bookmark = $class->load_entry_info($db, [$bookmark])->[0];

    return $bookmark;
}

sub delete_bookmark_by_url {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $url = $args->{url} // croak 'url required';

    my $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($db, +{
        url => $url,
    });

    return unless defined $entry;

    my $bookmark = $class->find_bookmark_by_user_and_entry($db, +{
        user  => $user,
        entry => $entry,
    });

    return unless defined $bookmark;

    $class->delete_bookmark($db, $bookmark);
}

1;
