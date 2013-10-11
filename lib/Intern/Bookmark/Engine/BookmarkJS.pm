package Intern::Bookmark::Engine::BookmarkJS;

use strict;
use warnings;
use utf8;

sub default {
    my ($class, $c) = @_;
    $c->html('bookmark_js.html', {});
}

1
