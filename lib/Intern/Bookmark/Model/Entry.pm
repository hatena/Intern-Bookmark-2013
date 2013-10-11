package Intern::Bookmark::Model::Entry;

use strict;
use warnings;
use utf8;

use Encode;

use JSON::Types qw();

use Class::Accessor::Lite (
    ro => [qw(
        entry_id
        url
    )],
    new => 1,
);

use Intern::Bookmark::Util;

sub title {
    my ($self) = @_;
    decode_utf8 $self->{title} || '';
}

sub created {
    my ($self) = @_;
    $self->{_created} ||= eval { Intern::Bookmark::Util::datetime_from_db(
        $self->{created}
    )};
}

sub updated {
    my ($self) = @_;
    $self->{_updated} ||= eval { Intern::Bookmark::Util::datetime_from_db(
        $self->{updated}
    )};
}

sub json_hash {
    my ($self) = @_;

    return {
        entry_id => JSON::Types::number $self->entry_id,
        url      => JSON::Types::string $self->url,
        title    => JSON::Types::string $self->title,
        created  => JSON::Types::string $self->created,
        updated  => JSON::Types::string $self->updated,
    };
}

1;
