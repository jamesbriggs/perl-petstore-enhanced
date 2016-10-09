package Pets::Controller::Pet;

use Mojo::Base 'Mojolicious::Controller';
use XML::Simple;
use JSON;
use Pod::Simple::HTML;
use Data::Dumper;
use List::Util qw / min max /;
# use DBI; # get ready for database programming

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

  $VERSION = '1.0';

  @EXPORT = qw(encode_xml);

  use constant PAGE_SIZE => 10;

  my %pets = ( # replace pg database in Swagger2 blog example with a simpler perl hash
     1 => 'alligator',
     2 => 'cat',
     3 => 'cow',
     4 => 'crocodile',
     5 => 'dog',
     6 => 'donkey',
     7 => 'iguana',
     8 => 'groundhog',
     9 => 'guinea pig',
    10 => 'horse',
    11 => 'platypus',
    12 => 'pony',
    13 => 'wallaby',
    14 => 'worm',
  );

# Force the scheme to what you need in custom header output or response body
sub set_scheme {
   return 'https' if defined $ENV{'HTTPS'};
   return 'http';
}

# Force the url to what you need in custom header output or response body
sub set_url {
   my $c = shift;
   my $path = shift;

   # You can build a request url like this if necessary, say if you were SSL-terminated or proxied:
   # $host = set_scheme() . '://' . $c->req->url->to_abs->host . $c->req->url;

   return $c->stash('swagger')->base_url . "/$path";
}

sub list {
  my ($c, $args, $cb) = @_;

  # Example $args:
  # $args->{body_param_name}  == $c->req->json
  # $args->{query_param_name} == $c->req->url->query->param("query_param_name")
  # $args->{"X-Header-Name"}  == $c->req->headers->header("X-Header-Name")

  # $c->$cb({limit => 123}, 200);

  my $limit  = $args->{'limit'}  || PAGE_SIZE;
  my $offset = $args->{'offset'} || 0;
  my $total  = scalar keys %pets;

  my @p = sort values %pets;

  if ($limit) {
     @p = @p[ $offset .. ($offset + $limit - 1) ];
     @p = grep { defined $_ } @p; # remove undef
  }

  $c->stash(my_limit => $limit, my_offset => $offset, my_total => $total);

  if ($cb) {           # Swagger2 request
     $c->res->headers->append('Total-Count' => $total);

     # Link: <https://api.github.com/user/repos?page=3&per_page=100>; rel="next", <https://api.github.com/user/repos?page=50&per_page=100>; rel="last"

     my $last_page = int($total/$limit);
     my $next_page = max int(($offset+$limit)/$limit), $last_page;

     my $url = set_url($c, '/pets');

     $c->res->headers->append('Link' => qq|<$url?page=$next_page&per_page=$limit>; rel="next", <$url?page=$last_page&per_page=$limit>; rel="last"|);

     $c->$cb( \@p, 200 );
  }
  else {               # Web request
    $c->render(\@p);
  }
}

sub show {
  my ($c, $args, $cb) = @_;

  my $id = $args->{'petId'}; # arg name is in api.json

  if ($cb) {           # Swagger2 request
    my %out = (
       id => $id, name => $pets{$id},
   );
    $c->$cb( [ encode_json( \%out ) ], 200);
  }
  else {               # Web request
    $c->render( { $pets{$id} } );
  }
}

sub ping {
  my ($c, $args, $cb) = @_;

  if ($cb) {           # Swagger2 request
    $c->$cb( [ 'pong' ], 200);
  }
  else {               # Web request
    $c->render( { 'pong' } );
  }
}

sub menu {
  my ($c, $args, $cb) = @_;

  my $menu = 'Menu';
# $menu .=  $ENV{'MOD_PERL'};

  if ($cb) {           # Swagger2 request
    $c->$cb( [ $menu ], 200);
  }
  else {               # Web request
    $c->render( { $menu } );
  }
}

sub delete {
  my ($c, $args, $cb) = @_;

  my $id = $args->{'petId'};

  my $response_code = 404;

  if (exists $pets{$id}) {
     delete $pets{$id};

     $response_code = 204;
  }

  if ($cb) {           # Swagger2 request
     $c->$cb([], $response_code);
  }
  else {
     $c->render({}, $response_code);
  }
}

sub create {
  my ($c, $args, $cb) = @_;

# any spec disagreement will result in 400 bad request

  my $name = $args->{'name'}->{'name'}; # arg name is in api.json

  if ($cb) {           # Swagger2 request
#open X, ">>/tmp/pp";
    for my $p (values %pets) {
#print X Dumper($name);
#print X "name=$name\n";
#print X "pet=$p\n";
       if ($p eq $name) {
          $c->$cb( [ ], 409);
          return;
       }
    }

    my $n = 1 + scalar keys %pets;
    $pets{$n} = $name;
    $c->$cb( [ $name ], 201);
    $c->res->headers->append('Location' => set_url($c, 'pets') . "/$n");
  }
  else {               # Web request
    $c->render( { $name } );
  }
}

sub info {
  my ($c, $args, $cb) = @_;

  $c->stash(title => 'API Info');
  $c->reply->not_found();
}

sub doc {
  my ($c, $args, $cb) = @_;

  my $s = $c->stash('swagger')->pod->to_string;
  # $s = Mojolicious::Plugin::PODRenderer::_pod_to_html($s); # needs a lot of improvements to be usable, so we wrote our own ...
  $s = _pod_to_html($s);
  $c->render(text => $s);
}

# based on Mojolicious/Plugin/PODRenderer.pm
sub _pod_to_html {
  return undef unless defined(my $pod = shift);

  # Block
  $pod = $pod->() if ref $pod eq 'CODE';

  my $title = 'Petstore API Documentation';

  my $css = <<EOD;
     body { font: 1.0em 'Verdana', Helvetica, sans-serif; }
     h1   { margin:  0; }
     h2   { margin: 10; }
     h3   { margin: 20; }
     h4   { margin: 30; }
     pre  { margin: 40; }
     p    { margin: 40; }
EOD

  $css = '<link rel="stylesheet" type="text/css" title="pod_stylesheet" href="http://st.pimg.net/tucs/style.css?3">';

  my $escaped_title = $title;
  $escaped_title =~ s/ /_/g;

  my $parser = Pod::Simple::HTML->new;
  $parser->html_header_before_title("<html lang=\"en\"><head><title>$title</title><style>$css</style></head><body>");
#  $parser->html_css('<link rel="stylesheet" type="text/css" title="pod_stylesheet" href="http://st.pimg.net/tucs/style.css?3">'); # not inline
  $parser->force_title("<h1>$title</h1>");
  #$parser->html_header_before_title("<html><head><title>$title</title></head><body>");
  $parser->html_header_after_title('<hr>');
  $parser->html_footer(qq|<center><a href="#$title">Top</a></center></body></html>|);
  $parser->index(1);
  $parser->output_string(\(my $output));
  return $@ unless eval { $parser->parse_string_document($pod); 1 };

  # Filter
  $output =~ s!<a name='___top' class='dummyTopAnchor'\s*?></a>\n!!g;
  $output =~ s!<a class='u'.*?name=".*?"\s*>(.*?)</a>!$1!sg;

  # remove minor item links
  # <li class='indexItem indexItem3'><a href='#Resource_URL'>Resource URL</a>
  $output =~ s/(indexItem[34].*?)<a href=[^>]*>([^<]*?)<\/a>/$1$2/g;

  # generate HTML anchor tags so index works
  my $section = '';
  $output =~ s[<(h[1-2])>(.*?)<\/(h[1-2])>][<hr><a name="$2"></a><$1>$2<\/$1>]gis;
  #$output =~ s[<(h[3-4])>(.*?)<\/(h[3-4])>][<$1>$2</$3>]gis;
  $output =~ s/([#"])COPYRIGHT AND LICENSE/$1COPYRIGHT_AND_LICENSE/g;

  return $output;
}

sub encode_xml {
   my $s = shift;

   return XMLout( { pet => $s },
                  RootName => 'pets',
                  XMLDecl => '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>',
    );
}

sub my_throttle {
   my $c = shift;

   my $throttled = 0;

   my $limit     = 1000;
   my $remaining = 1000;
   my $reset     = 0;

   #my $blacklist = qr/108.81.224.240/;
   my $blacklist = qr//;

   my $ip = $c->tx->remote_address || '108.81.224.240';

   if ($blacklist ne qr// and $ip =~ $blacklist) {
      $throttled = 1;

      $limit     = 0;
      $remaining = 0;
      $reset     = 0;
   }

   $c->res->headers->header('X-Rate-Limit-Limit'     => "$limit");
   $c->res->headers->header('X-Rate-Limit-Remaining' => "$remaining");
   $c->res->headers->header('X-Rate-Limit-Reset'     => "$reset");

   return $throttled;
}

1;
