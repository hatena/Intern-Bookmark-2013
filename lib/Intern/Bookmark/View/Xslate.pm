package Intern::Bookmark::View::Xslate;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Config;

use Text::Xslate qw(mark_raw html_escape);

our $tx = Text::Xslate->new(
    path      => [ config->root->subdir('templates') ],
    cache     => 0,
    cache_dir => config->root->subdir(qw(tmp xslate)),
    syntax    => 'TTerse',
    module    => [ qw(Text::Xslate::Bridge::TT2Like) ],
    function  => {
        cm => sub { # class method
            my ($class, $method, @args) = @_;
            return $class->$method(@args);
        },
    }
);

sub render_file {
    my ($class, $file, $args) = @_;
    my $content = $tx->render($file, $args);
    $content =~ s/^\s+$//mg;
    $content =~ s/>\n+/>\n/g;
    return $content;
}

1;
