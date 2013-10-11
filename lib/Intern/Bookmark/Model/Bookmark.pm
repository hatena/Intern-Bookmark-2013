package Intern::Bookmark::Model::Bookmark;

use strict;
use warnings;
use utf8;

use Encode;

use JSON::Types qw();

use Class::Accessor::Lite (
    ro => [qw(
        bookmark_id
        user_id
        entry_id
    )],
    rw => [qw( entry user )],
    new => 1,
);

use Intern::Bookmark::Util;

sub comment {
    my ($self) = @_;
    decode_utf8 $self->{comment} || '';
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
        bookmark_id => JSON::Types::number $self->bookmark_id,
        user        => $self->user->json_hash,
        entry       => $self->entry->json_hash,
        comment     => JSON::Types::string $self->comment,
        created     => JSON::Types::string $self->created,
        updated     => JSON::Types::string $self->updated,
    };
}

1;
