package Intern::Bookmark::Engine::API;

use strict;
use warnings;
use utf8;

use JSON::Types;

use Intern::Bookmark::Service::Bookmark;

sub bookmarks {
    my ($class, $c) = @_;

    my $user = $c->user;
    return $c->error(401 => 'Unauthorized') unless $user;

    my $per_page = $c->req->number_param('per_page') || 20;
    my $page = $c->req->number_param('page') || 1;

    my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($c->db, {
        user => $user,
        per_page => $per_page,
        page => $page,
        order_by => 'created DESC',
    });
    Intern::Bookmark::Service::Bookmark->load_user($c->db, $bookmarks);
    Intern::Bookmark::Service::Bookmark->load_entry_info($c->db, $bookmarks);

    $c->json({
        bookmarks => [ map { $_->json_hash } @$bookmarks ],
        per_page  => JSON::Types::number $per_page,
        next_page => JSON::Types::number $page + 1,
    });
}

sub bookmark_post {
    my ($class, $c) = @_;

    my $user = $c->user;
    return $c->error(401 => 'Unauthorized') unless $user;

    my $url = $c->req->parameters->{url} // $c->error(400 => 'url required');
    my $comment = $c->req->string_param('comment');

    my $bookmark = Intern::Bookmark::Service::Bookmark->add_bookmark($c->db, {
        user    => $user,
        url     => $url,
        comment => $comment,
    });
    Intern::Bookmark::Service::Bookmark->load_user($c->db, [ $bookmark ]);

    $c->json({
        bookmark => $bookmark->json_hash,
    });
}

1;
__END__
