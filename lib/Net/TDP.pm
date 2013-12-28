package Net::TDP;

use Moose;

use Net::HTTP::Spore;
use Try::Tiny;
use Carp;

# ABSTRACT: Perl access to the TDP.me API

has '_spec' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_spec'
);

has '_spore' => (
    is      => 'rw',
    isa     => 'Net::HTTP::Spore::Core',
    lazy    => 1,
    builder => '_build_spore',
);

has 'debug' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

has 'base_url' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'http://tdp.me/v1'
);

has 'api_key' => (
    is        => 'rw',
    isa       => 'Str',
    required  => 1,
);

{
  no strict 'refs';
  foreach my $write_method ( qw/create_goal completed add_tag edit_completed remove_completion/) {
    *{$write_method} = sub {
        shift->_spore->$write_method( @_, payload => { @_ } )->body;
    };
  }

  foreach my $read_method ( qw/list_goals list_categories archive_goal overview report_by_day get_tags delete_tag/ ) {
    *{$read_method} = sub {
      my ( $self, @args ) = @_;
      try {
        $self->_spore->$read_method(@args)->body;
      } catch {
        my $err = "The TDP webservice responded with an error:";
        if ( ref $_ and $_->isa('Net::HTTP::Spore::Response') ) {
          $err .= "\n" . $_->body->{error};
        }
        else {
          $err .= "\n$_";
        }
        Carp::croak $err;
      };
    };
  }
}

sub _build_spore {
    my ( $self ) = @_;

    my $client = Net::HTTP::Spore->new_from_string(
        $self->_spec,
        base_url => $self->base_url,
        ( $self->debug ? ( trace => 1 ) : () )
    );

    $client->enable('Format::JSON');
    $client->enable('Auth::Header',
      header_name => 'X-Access-Token',
      header_value => $self->api_key,
    );
    return $client;
}

sub _build_spec {
    return q({
        "base_url"     : "http://tdp.me/v1",
        "api_base_url" : "http://tdp.me/v1",
        "version"      : "v1",
        "name"         : "tdp.me",
        "author"       : [ "J. Shirley <jshirley@tdp.me>" ],
        "meta"         : { "documentation" : "http://tdp.me/account/api" },
        "methods"      : {
            "list_categories" : {
                "api_format"      : [ "json" ],
                "path"            : "/category",
                "method"          : "GET",
                "expected_status" : [ 200 ],
                "description"     : "Fetch all categories",
                "authentication"  : true
            },
            "overview" : {
                "api_format"      : [ "json" ],
                "path"            : "/report/stats",
                "method"          : "GET",
                "expected_status" : [ 200 ],
                "description"     : "Report high level attributes on the account",
                "authentication"  : true
            },
            "report_by_day" : {
                "api_format"      : [ "json" ],
                "path"            : "/report/by_day",
                "method"          : "GET",
                "expected_status" : [ 200 ],
                "description"     : "Return a list of activity grouped by day",
                "authentication"  : true
            },
            "list_goals" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals",
                "method"          : "GET",
                "expected_status" : [ 200 ],
                "description"     : "Fetch all goals",
                "authentication"  : true
            },
            "create_goal" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals",
                "method"          : "POST",
                "expected_status" : [ 201, 400 ],
                "description"     : "Add a new goal",
                "authentication"  : true,
                "requires_params" : [
                  "name", "description", "color",
                  "quantity", "frequency",
                  "category_id"
                ],
                "optional_params": [
                  "quantity_needed", "score", "cooldown",
                  "require_note", "note_prompt",
                  "active", "public", "position"
                ]
            },
            "completed" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals/:id/completion",
                "method"          : "POST",
                "expected_status" : [ 202, 400 ],
                "description"     : "Mark a goal as completed",
                "authentication"  : true,
                "requires_params" : [ "id" ],
                "optional_params" : [ "date", "note", "quantity", "duration", "vacation" ]
            },
            "archive_goal" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals/:id",
                "method"          : "DELETE",
                "expected_status" : [ 200 ],
                "description"     : "Archive a goal",
                "authentication"  : true,
                "requires_params" : [ "id" ],
                "optional_params" : [ "permanent" ]
            },
            "get_tags" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals/:id/tags",
                "method"          : "GET",
                "expected_status" : [ 200 ],
                "description"     : "Fetch tags on a goal",
                "authentication"  : true,
                "requires_params" : [ "id" ],
                "optional_params" : [ ]
            },
            "add_tag" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals/:id/tags",
                "method"          : "POST",
                "expected_status" : [ 201, 202, 400 ],
                "description"     : "Add a tag to a goal",
                "authentication"  : true,
                "requires_params" : [ "id", "tag" ],
                "optional_params" : [ ]
            },
            "remove_tag" : {
                "api_format"      : [ "json" ],
                "path"            : "/goals/:id/tags/:tag_id",
                "method"          : "DELETE",
                "expected_status" : [ 202 ],
                "description"     : "Removes a tag on a goal",
                "authentication"  : true,
                "requires_params" : [ "id", "tag_id" ],
                "optional_params" : [ ]
            },
            "edit_completed" : {
              "requires_params" : [
                  "goal_id", "id"
              ],
              "expected_status" : [
                  202,
                  400
              ],
              "optional_params" : [
                  "date",
                  "note",
                  "quantity",
                  "duration",
                  "vacation"
              ],
              "api_format" : [
                  "json"
              ],
              "method" : "PUT",
              "path" : "/goals/:goal_id/completion/:id",
              "authentication" : true,
              "description" : "Edit a completion record"
            },
            "remove_completion" : {
              "requires_params" : [
                "goal_id", "id"
              ],
              "expected_status" : [
                202,
                400
              ],
              "api_format" : [
                "json"
              ],
              "method" : "DELETE",
              "path" : "/goals/:goal_id/completion/:id",
              "authentication" : true,
              "description" : "Remove a completion record"
            }
        }
    });
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
