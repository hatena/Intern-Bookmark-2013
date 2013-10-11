package Intern::Bookmark::Engine::Index;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Service::Bookmark;

sub default {
    my ($class, $c) = @_;

    my $user = $c->user;
    return $c->html('index.html') unless $user;

    my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user(
        $c->db,
        { user => $user },
    );
    Intern::Bookmark::Service::Bookmark->load_entry_info($c->db, $bookmarks);
    $c->html('index.html', {
        bookmarks => $bookmarks,
    });
}

1;
__END__
