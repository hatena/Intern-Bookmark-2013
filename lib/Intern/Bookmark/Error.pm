package Intern::Bookmark::Error;

use strict;
use warnings;
use utf8;

sub throw {
    my ($class, $code, $message, %opts) = @_;
    die $class->new(
        code    => $code,
        message => $message,
        %opts,
    );
}

sub new {
    my ($class, %opts) = @_;
    bless \%opts, $class;
}

1;
