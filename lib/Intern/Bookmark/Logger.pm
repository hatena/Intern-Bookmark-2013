package Intern::Bookmark::Logger;

use strict;
use warnings;
use utf8;

use parent qw(Log::Minimal);

our $ENV_DEBUG = 'INTERN_BOOKMARK_DEBUG';
our $HANDLE = \*STDERR;
our $PRINT = sub {
    my ($time, $level, $mess, $trace) = @_;
    print { $HANDLE } "$time [$level] $mess @ $trace\n";
};

1;
__END__
