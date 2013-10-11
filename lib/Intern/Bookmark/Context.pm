package Intern::Bookmark::Context;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Request;
use Intern::Bookmark::Config;

use Carp ();
use Encode ();
use URI;
use URI::QueryParam;

use Class::Accessor::Lite::Lazy (
    rw_lazy => [ qw(request response route stash db) ],
    rw      => [ qw(env) ],
    new     => 1,
);

use Intern::Bookmark::Error;
use Intern::Bookmark::DBI::Factory;

use Intern::Bookmark::Service::User;

### Properties

sub from_env {
    my ($class, $env) = @_;
    return $class->new(env => $env);
}

sub _build_request {
    my $self = shift;

    return undef unless $self->env;
    return Intern::Bookmark::Request->new($self->env);
};

sub _build_response {
    my $self = shift;
    return $self->request->new_response(200);
};

sub _build_route {
    my $self = shift;
    return Intern::Bookmark::Config->router->match($self->env);
};

sub _build_stash { +{} };

*req = \&request;
*res = \&response;

### HTTP Response

sub render_file {
    my ($self, $file, $args) = @_;
    $args //= {};

    require Intern::Bookmark::View::Xslate;
    my $content = Intern::Bookmark::View::Xslate->render_file($file, {
        c => $self,
        %{ $self->stash },
        %$args
    });
    return $content;
}

sub html {
    my ($self, $file, $args) = @_;

    my $content = $self->render_file($file, $args);
    $self->response->code(200);
    $self->response->content_type('text/html; charset=utf-8');
    $self->response->content(Encode::encode_utf8 $content);
}

sub json {
    my ($self, $hash) = @_;

    require JSON::XS;
    my $json = JSON::XS->new;
    $json->utf8;
    # $json->pretty(1);

    $self->response->code(200);
    $self->response->content_type('application/json; charset=utf-8');
    $self->response->content($json->encode($hash));
}

sub plain_text {
    my ($self, @lines) = @_;
    $self->response->code(200);
    $self->response->content_type('text/plain; charset=utf-8');
    $self->response->content(join "\n", @lines);
}

sub redirect {
    my ($self, $url) = @_;

    $self->response->code(302);
    $self->response->header(Location => $url);
}

sub error {
    my ($self, $code, $message, %opts) = @_;
    Intern::Bookmark::Error->throw($code, $message, %opts);
}

sub uri_for {
    my ($self, $path_query) = @_;
    my $uri = URI->new(config->param('origin'));
    $uri->path_query($path_query);
    return $uri;
}

### DB Access
sub _build_db {
    my ($self) = @_;
    return Intern::Bookmark::DBI::Factory->new;
}

sub dbh {
    my ($self, $name) = @_;
    return $self->db->dbh($name);
}

# Utility
sub user {
    my ($self) = @_;
    return $self->{user} if $self->{user};

    my $user_name = $self->req->env->{'hatena.user'} or return '';
    my $user = Intern::Bookmark::Service::User->find_user_by_name($self->db, {
        name => $user_name,
    });
    $user //= Intern::Bookmark::Service::User->create($self->db, {
        name => $user_name,
    });

    return $self->{user} = $user;
}

1;
