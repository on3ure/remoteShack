#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Mojolicious::Lite -signatures;
use Mojo::UserAgent;
use Mojo::Redis;
use Mojo::JSON qw(decode_json encode_json);
use Config::YAML;
use Data::Dumper;
use lib 'lib';

# Config
my $config = Config::YAML->new( config => "centralStation.yaml" );

# UserAgent
my $ua = Mojo::UserAgent->new;

# Mojo Config
my $mojoconfig = plugin Config => { file => 'mojo.conf' };

helper redis => sub { state $r = Mojo::Redis->new };

get '/' => 'ws';

websocket '/socket' => sub {
    my $self      = shift;
    my $pubsub = $self->redis->pubsub;
    my $cb     = $pubsub->listen(
        'remoteShack:events' => sub {
            my ( $pubsub, $msg ) = @_;
            $self->send($msg);
        }
    );

    $self->inactivity_timeout(3600);
    $self->on( finish => sub { $pubsub->unlisten( 'remoteShack:events' => $cb ) }
    );
    $self->on(
        message => sub {
            my ( $self, $msg ) = @_;
            $pubsub->notify( 'remoteShack:events' => $msg );
        }
    );
};

get '/broadcast/:category/:endpoint/:state' => sub {
    my $self = shift;
    
    my $pubsub = $self->redis->pubsub;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');
    my $endpoint = $self->stash('endpoint');
    my $state = $self->stash('state');

    my $wsdata = { $category => { $endpoint => $state } };
            
    $pubsub->notify( 'remoteShack:events' => encode_json $wsdata );
        
    my $rstate;

    $rstate->{error}   = 'false';
    $rstate->{message} = 'send';

    $self->render( json => $rstate );

};

get '/:category/state' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');

    my $state;

    if ( defined $config->{$category}->{active}
        && ( $config->{$category}->{active} eq 'true' ) )
    {
        $state->{error} = 'false';

        foreach my $endpoint ( keys %{ $config->{$category}->{endpoint} } ) {
            if ( $config->{$category}->{endpoint}->{$endpoint}->{active} eq
                'true' )
            {
                my $res
                    = $ua->get(
                    $config->{$category}->{endpoint}->{$endpoint}->{state} )
                    ->result->json;
                $state->{$endpoint}
                    = $config->{$category}->{endpoint}->{$endpoint}->{map}
                    ->{ $res->{state} };
            }
        }
    }
    else {
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

get '/:category/:endpoint/state' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');
    my $endpoint = $self->stash('endpoint');

    my $state;

    if ( $config->{$category}->{active} eq 'true' ) {
        $state->{error} = 'false';

        if (defined $config->{$category}->{endpoint}->{$endpoint}->{active}
            && ( $config->{$category}->{endpoint}->{$endpoint}->{active} eq
                'true' )
            )
        {
            my $res
                = $ua->get(
                $config->{$category}->{endpoint}->{$endpoint}->{state} )
                ->result->json;
            $state->{$endpoint}
                = $config->{$category}->{endpoint}->{$endpoint}->{map}
                ->{ $res->{state} };
        }
        else {
            $state->{error}   = 'true';
            $state->{message} = $endpoint . " not found";
        }
    }
    else {
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

get '/:category/:endpoint/:switch' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');
    my $endpoint = $self->stash('endpoint');
    my $switch   = lc( $self->stash('switch') );

    my $state;

    if ( defined $config->{$category}->{active}
        && ( $config->{$category}->{active} eq 'true' ) )
    {
        $state->{error} = 'false';
        if ( ( $switch eq 'on' ) || ( $switch eq 'off' ) ) {
            if ( $config->{$category}->{multiple} eq 'false' ) {
                foreach my $endpoint (
                    keys %{ $config->{$category}->{endpoint} } )
                {
                    if ( $config->{$category}->{endpoint}->{$endpoint}
                        ->{active} eq 'true' )
                    {
                        my $res
                            = $ua->get(
                            $config->{$category}->{endpoint}->{$endpoint}
                                ->{state} )->result->json;
                        if ( $config->{$category}->{endpoint}->{$endpoint}
                            ->{map}->{ $res->{state} } eq 'on' )
                        {
                            $ua->get(
                                $config->{$category}->{endpoint}->{$endpoint}
                                    ->{off} )->result->json;

                        }
                    }
                }

            }

            if (defined $config->{$category}->{endpoint}->{$endpoint}
                ->{active}
                && ( $config->{$category}->{endpoint}->{$endpoint}->{active}
                    eq 'true' )
                )
            {
                my $res
                    = $ua->get(
                    $config->{$category}->{endpoint}->{$endpoint}->{$switch} )
                    ->result->json;
                foreach my $endpoint (
                    keys %{ $config->{$category}->{endpoint} } )
                {
                    if ( $config->{$category}->{endpoint}->{$endpoint}
                        ->{active} eq 'true' )
                    {
                        my $res
                            = $ua->get(
                            $config->{$category}->{endpoint}->{$endpoint}
                                ->{state} )->result->json;
                        $state->{$endpoint}
                            = $config->{$category}->{endpoint}->{$endpoint}
                            ->{map}->{ $res->{state} };
                    }
                }
            }
            else {
                $state->{error}   = 'true';
                $state->{message} = $endpoint . " not found";
            }
        }
        else {
            $state->{error}   = 'true';
            $state->{message} = 'a switch can only by on or off';
        }
    }
    else {
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

app->start;

__DATA__
@@ ws.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>remoteShack:events</title>
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Roboto:300,300italic,700,700italic">
    <link rel="stylesheet" href="//cdn.rawgit.com/necolas/normalize.css/master/normalize.css">
    <link rel="stylesheet" href="//cdn.rawgit.com/milligram/milligram/master/dist/milligram.min.css">
    <style>
      body {
        margin: 3rem 1rem;
      }
      pre {
        padding: 0.2rem 0.5rem;
      }
      .wrapper {
        max-width: 35em;
        margin: 0 auto;
      }
    </style>
  </head>
  <body>
    <div class="wrapper">
      <h1>remoteShack:events</h1>
      <form>
        <label>
          <span>Message:</span>
          <input type="search" name="message" value="Some message" placeholder="Write a message" autocomplete="off" disabled>
        </label>
        <button class="button" disabled>Send message</button>
      </form>
      <h2>Messages</h2>
      <pre id="messages">Connecting...</pre>
    </div>
    %= javascript begin
      var formEl = document.getElementsByTagName("form")[0];
      var inputEl = formEl.message;
      var messagesEl = document.getElementById("messages");
      var ws = new WebSocket("<%= url_for('socket')->to_abs %>");
      var hms = function() {
        var d = new Date();
        return [d.getHours(), d.getMinutes(), d.getSeconds()].map(function(v) {
          return v < 10 ? "0" + v : v;
        }).join(":");
      };
      formEl.addEventListener("submit", function(e) {
        e.preventDefault();
        if (inputEl.value.length) ws.send(inputEl.value);
        inputEl.value = "";
      });
      ws.onopen = function(e) {
        inputEl.disabled = false;
        document.getElementsByTagName("button")[0].disabled = false;
        messagesEl.innerHTML = hms() + " &lt;server> Connected.";
      };
      ws.onmessage = function(e) {
        messagesEl.innerHTML = hms() + " " + e.data.replace(/</g, "&lt;") + "<br>" + messagesEl.innerHTML;
      };
    % end
  </body>
</html>
