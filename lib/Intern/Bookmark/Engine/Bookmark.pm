package Intern::Bookmark::Engine::Bookmark;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Service::Bookmark;
use Intern::Bookmark::Service::Entry;

sub default {
    my ($class, $c) = @_;

    my $url = $c->req->parameters->{url};

    my $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($c->db, {
        url => $url,
    });
    my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_entry(
        $c->db,
        { entry => $entry },
    );
    Intern::Bookmark::Service::Bookmark->load_user($c->db, $bookmarks);

    $c->html('bookmark.html', {
        entry     => $entry,
        bookmarks => $bookmarks,
    });
}

sub add_get {
    my ($class, $c) = @_;

    my $url = $c->req->parameters->{url};

    my ($bookmark, $entry);
    if ($url) {
        # 編集時はurlが存在
        $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($c->db, {
            url => $url,
        });
        $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($c->db, {
            user  => $c->user,
            entry => $entry,
        }) if $entry;
    }

    $c->html('bookmark/add.html', {
        bookmark => $bookmark,
        entry    => $entry,
    });
}

sub add_post {
    my ($class, $c) = @_;

    my $url = $c->req->parameters->{url};
    my $comment = $c->req->string_param('comment');

    Intern::Bookmark::Service::Bookmark->add_bookmark($c->db, {
        user    => $c->user,
        url     => $url,
        comment => $comment,
    });

    $c->res->redirect('/');
}

sub delete_get {
    my ($class, $c) = @_;

    my $url = $c->req->parameters->{url};
    return $c->res->redirect('/') unless $url;

    my $entry = Intern::Bookmark::Service::Entry->find_entry_by_url($c->db, {
        url => $url,
    });
    my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($c->db, {
        user  => $c->user,
        entry => $entry,
    }) if $entry;

    $c->html('bookmark/delete.html', {
        bookmark => $bookmark,
        entry    => $entry,
    });
}

sub delete_post {
    my ($class, $c) = @_;

    my $url = $c->req->parameters->{url};
    return $c->res->redirect('/') unless $url;

    Intern::Bookmark::Service::Bookmark->delete_bookmark_by_url($c->db, {
        user => $c->user,
        url  => $url,
    });

    $c->res->redirect('/');
}

1;
