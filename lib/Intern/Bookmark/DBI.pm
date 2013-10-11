package Intern::Bookmark::DBI;

use strict;
use warnings;
use utf8;

use parent 'DBIx::Sunny';
use SQL::NamedPlaceholder;
use Carp ();

sub _expand_args (@) {
    my ($query, @args) = @_;

    if (@args == 1 && ref $args[0] eq 'HASH') {
        ( $query, my $binds ) = SQL::NamedPlaceholder::bind_named($query, $args[0]);
        @args = @$binds;
    }

    return ($query, @args);
}

package Intern::Bookmark::DBI::db;

use strict;
use warnings;
use utf8;

use parent -norequire => 'DBIx::Sunny::db';
use Class::Load qw(load_class);

sub select_one {
    my $self = shift;
    return $self->SUPER::select_one(Intern::Bookmark::DBI::_expand_args(@_));
}

sub select_row {
    my $self = shift;
    return $self->SUPER::select_row(Intern::Bookmark::DBI::_expand_args(@_));
}

sub select_all {
    my $self = shift;
    return $self->SUPER::select_all(Intern::Bookmark::DBI::_expand_args(@_));
}

sub select_row_as {
    my $self = shift;
    my $class = pop;
    my $row = $self->select_row(@_);
    load_class($class);
    return $row && $class->new($row);
}

sub select_all_as {
    my $self = shift;
    my $class = pop;
    my $rows = $self->select_all(@_);
    load_class($class);
    return [ map { $class->new($_) } @$rows ];
}

sub query {
    my $self = shift;
    return $self->SUPER::query(Intern::Bookmark::DBI::_expand_args(@_));
}

package Intern::Bookmark::DBI::st;
use parent -norequire => 'DBIx::Sunny::st';

1;
