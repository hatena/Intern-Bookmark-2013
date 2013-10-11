package Intern::Bookmark::Request;

use strict;
use warnings;
use utf8;

use parent 'Plack::Request';

use Encode;
use Hash::MultiValue;

sub parameters {
    my $self = shift;

    $self->env->{'plack.request.merged'} ||= do {
        my $query = $self->query_parameters;
        my $body  = $self->body_parameters;
        my $path  = $self->route_parameters;
        Hash::MultiValue->new($path->flatten, $query->flatten, $body->flatten);
    };
}

sub route_parameters {
    my ($self) = @_;
    return $self->env->{'intern.bookmark.route.parameters'} ||=
        Hash::MultiValue->new(%{ $self->env->{'intern.bookmark.route'} });
}

sub string_param {
    my ($self, $key) = @_;
    return decode_utf8 $self->parameters->{$key};
}

sub number_param {
    my ($self, $key) = @_;
    my $val = $self->parameters->{$key} // "";
    return $val + 0;
}

sub is_xhr {
    my $self = shift;
    return ( $self->header('X-Requested-With') || '' ) eq 'XMLHttpRequest';
}

1;
