package Plack::Middleware::HatenaOAuth;
use strict;
use warnings;

our $VERSION   = '0.01';

use parent 'Plack::Middleware';
use Plack::Util::Accessor qw( consumer_key consumer_secret consumer login_path );
use Plack::Request;
use Plack::Session;

use OAuth::Lite::Consumer;
use JSON::XS;

sub prepare_app {
    my ($self) = @_;
    die 'require consumer_key and consumer_secret'
        unless $self->consumer_key and $self->consumer_secret;

    $self->consumer(OAuth::Lite::Consumer->new(
        consumer_key       => $self->consumer_key,
        consumer_secret    => $self->consumer_secret,
        site               => q{https://www.hatena.com},
        request_token_path => q{/oauth/initiate},
        access_token_path  => q{/oauth/token},
        authorize_path     => q{https://www.hatena.ne.jp/oauth/authorize},
        ($self->{ua} ? (ua => $self->{ua}) : ()),
    ));
}

sub call {
    my ($self, $env) = @_;
    my $session = Plack::Session->new($env);

    my $handlers = {
        $self->login_path => sub {
            my $req = Plack::Request->new($env);
            my $res = $req->new_response(200);
            my $consumer = $self->consumer;
            my $verifier = $req->parameters->{oauth_verifier};

            if ( $verifier ) {
                my $access_token = $consumer->get_access_token(
                    token    => $session->get('hatenaoauth_request_token'),
                    verifier => $verifier,
                ) or die $consumer->errstr;
                $session->remove('hatenaoauth_request_token');

                {
                    my $res = $consumer->request(
                        method => 'POST',
                        url    => qq{http://n.hatena.com/applications/my.json},
                        token  => $access_token,
                    );
                    $res->is_success or die;
                    $session->set('hatenaoauth_user_info', decode_json($res->decoded_content || $res->content));
                }
                $res->redirect( $session->get('hatenaoauth_location') || '/' );
                $session->remove('hatenaoauth_location');
            } else {
                my $request_token = $self->consumer->get_request_token(
                    callback_url => [ split /\?/, $req->uri, 2]->[0],
                    scope        => 'read_public',
                ) or die $consumer->errstr;

                $session->set(hatenaoauth_request_token => $request_token);
                $session->set(hatenaoauth_location => $req->parameters->{location});
                $res->redirect($consumer->url_to_authorize(token => $request_token));
            }
            return $res->finalize;
        },
    };

    $env->{'hatena.user'} = ($session->get('hatenaoauth_user_info') || {})->{url_name};
    return ($handlers->{$env->{PATH_INFO}} || $self->app)->($env);
}

1;

__END__

=head1 SYNOPSIS

  use Plack::Builder;

  my $app = sub {
      my $env = shift;
      my $session = $env->{'psgix.session'};
      return [
          200,
          [ 'Content-Type' => 'text/html' ],
          [
              "<html><head><title>Hello</title><body>",
              $env->{'hatena.user'}
                  ? ('Hello, id:' , $env->{'hatena.user'}, ' !')
                  : "<a href='/login?location=/'>Login</a>"
          ],
      ];
  };

  builder {
      enable 'Session';
      enable 'Plack::Middleware::HatenaOAuth',
           consumer_key       => 'vUarxVrr0NHiTg==',
           consumer_secret    => 'RqbbFaPN2ubYqL/+0F5gKUe7dHc=',
           login_path         => '/login';
           # ua                 => LWP::UserAgent->new(...);
      $app;
  };

=cut
