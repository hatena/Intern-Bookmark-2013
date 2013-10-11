package Test::Intern::Bookmark::Mechanize;

use strict;
use warnings;
use utf8;

use parent qw(Test::WWW::Mechanize::PSGI);

use Test::More ();

use Exporter::Lite;
our @EXPORT = qw(create_mech);

use Intern::Bookmark;

my $app = Intern::Bookmark->as_psgi;

sub create_mech (;%) {
    return __PACKAGE__->new(@_);
}

sub new {
    my ($class, %opts) = @_;

    my $user = delete $opts{user};

    my $user_mw = sub {
        my $app = shift;
        sub {
            my $env = shift;
            $env->{'hatena.user'} = $user ? $user->name : '';
            $app->($env);
        };
    };

    my $self = $class->SUPER::new(
        app     => $user_mw->($app),
        %opts,
    );

    return $self;
}

1;
