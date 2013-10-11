package Intern::Bookmark::Model::User;

use strict;
use warnings;
use utf8;

use JSON::Types qw();

use Class::Accessor::Lite (
    ro => [qw(
        user_id
        name
    )],
    new => 1,
);

use Intern::Bookmark::Util;

sub created {
    my ($self) = @_;
    $self->{_created} ||= eval {
        Intern::Bookmark::Util::datetime_from_db($self->{created});
    };
}

sub json_hash {
    my ($self) = @_;

    return {
        user_id => JSON::Types::number $self->user_id,
        name    => JSON::Types::string $self->name,
        created => JSON::Types::string $self->created,
    };
}

1;
