#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";
use Pod::Usage; # for pod2usage()
use Encode;
use Encode::Locale;

use Intern::Bookmark::Config;
use Intern::Bookmark::DBI::Factory;
use Intern::Bookmark::Service::Bookmark;
use Intern::Bookmark::Service::User;

binmode STDOUT, ':encoding(console_out)';

my %HANDLERS = (
    add    => \&add_bookmark,
    list   => \&list_bookmarks,
    delete => \&delete_bookmark,
);

my $command = shift @ARGV || 'list';

$ENV{INTERN_BOOKMARK_ENV} = 'local';
my $db = Intern::Bookmark::DBI::Factory->new;

my $name = $ENV{USER};
my $user = Intern::Bookmark::Service::User->find_user_by_name($db, +{ name => $name });
unless ($user) {
    $user = Intern::Bookmark::Service::User->create($db, +{ name => $name });
}

my $handler = $HANDLERS{ $command } or pod2usage;

$handler->($user, @ARGV);

exit 0;

sub add_bookmark {
    my ($user, $url, $comment) = @_;

    die 'url required' unless defined $url;

    my $bookmark = Intern::Bookmark::Service::Bookmark->add_bookmark($db, +{
        user    => $user,
        url     => $url,
        comment => decode_utf8 $comment,
    });

    print 'Bookmarked ' . $bookmark->{entry}->url . ' ' . $bookmark->comment . "\n";
}

sub list_bookmarks {
    my ($user) = @_;

    printf "--- %s's Bookmarks ---\n", $user->name;

    my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($db, +{
        user => $user,
    });
    $bookmarks = Intern::Bookmark::Service::Bookmark->load_entry_info($db, $bookmarks);

    foreach my $bookmark (@$bookmarks) {
        print $bookmark->{entry}->url . ' ' . $bookmark->comment . "\n";
    }
}

sub delete_bookmark {
    my ($user, $url) = @_;

    die 'url required' unless defined $url;

    my $bookmark = Intern::Bookmark::Service::Bookmark->delete_bookmark_by_url($db, +{
        user => $user,
        url  => $url,
    });

    print "Deleted \n";
}

__END__

=head1 NAME

bookmark.pl - my bookmark

=head1 SYNOPSIS

  bookmark.pl add url [comment]

  bookmark.pl list

  bookmark.pl delete url

=cut
