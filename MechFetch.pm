#!/usr/bin/perl

#
# Overwrite default WWW::Mechanize functions
#
package Umka::MechFetch::Mechanize;

# Confgure package behaviour
use 5.8.1;
use strict;
use warnings;

# Define a parent module which we are extending
use base qw( WWW::Mechanize );

# Declare custom variables
our $redirect_ctrl;
our @auth_details;

sub redirect_ok
{
    return $redirect_ctrl;
}

sub get_basic_credentials
{
    return @auth_details;
}

#
# Define custom package Umka::MechFetch
#
package Umka::MechFetch;

# Configure package behaviour
use 5.8.1;
use strict;
use warnings;

# Declare required modules
use Carp;

# Declare global variables
our $Config;
our $Mech;

# Declare custom variables
our $quiet_ctrl;
our $request_uri;
our %override;

sub new( $ )
{
    # Initialise local class
    my $class = shift( @_ );
    my $this = {};
    bless( $this, $class );

    # Collect/create required objects
    $Config = shift( @_ );
    $Mech = new Umka::MechFetch::Mechanize();

    # Configure internal object
    $this -> setRedirect([ 'HEAD', 'GET', 'POST' ]);
    $this -> _configure();

    return $this;
}

sub _configure()
{
    my $this = shift( @_ );

    $this -> useWarnings( undef );
    $this -> useRedirect( undef );
    $this -> setRedirect( undef, undef );
    $this -> setAgent( undef );
    $this -> setLang( undef );
    $this -> setTimeout( undef );
    $this -> setAuth( undef, undef );
    $this -> setProxy( undef );

    return 1;
}

sub _retrieve( $ )
{
    my ( $this, $name ) = @_;
    my $output;

    # Define exception object if exception exists
    ( my $Exception = $Config -> obj( "Exception" ) -> obj( $request_uri ))
            if ( $Config -> obj( "Exception" ) -> exists( $request_uri ));

    # Return an overridden value
    if ( exists( $override{ $name })) {
        $output = $override{ $name };
    }

    # Try to use section/variable defined with in an exception
    elsif ( $Exception and $Exception -> exists( $name )
            and $Exception -> is_scalar( $name )) {

        $output = $Exception -> value( $name );
    }

    elsif ( $Exception and $Exception -> exists( $name )
            and $Exception -> is_array( $name )) {

        $output = $Exception -> array( $name );
    }

    elsif ( $Exception and $Exception -> exists( $name )
            and $Exception -> is_hash( $name )) {

        $output = $Exception -> obj( $name );
    }

    # Try to use global definition of a section/variable
    elsif ( $Config -> exists( $name )
            and $Config -> is_scalar( $name )) {

        $output = $Config -> value( $name );
    }

    elsif ( $Config -> exists( $name )
            and $Config -> is_array( $name )) {

        $output = $Config -> array( $name );
    }

    elsif ( $Config -> exists( $name )
            and $Config -> is_hash( $name )) {

        $output = $Config -> obj( $name );
    }

    # Issue a warning if not in quiet mode
    else {
        carp( "No variable or section \"$name\" found" )
                unless ( $quiet_ctrl );
    }

    return $output;
}

sub defaultConfig()
{
    my $this = shift( @_ );
    my $output;

    # Look through DATA file handle, stop if __END__ encountered
    foreach my $line ( readline( DATA )) {
        chomp( $line );
        last if ( $line eq "__END__" );
        $output .= $line."\n";
    }

    return $output;
}

sub useWarnings( $ )
{
    my ( $this, $ctrl ) = @_;
    my $label = 'warnings';

    # Record overridden value
    if ( defined( $ctrl )) {
        $override{ $label } = $ctrl;
    }

    # Retrieve default value
    else {
        $ctrl = $this -> _retrieve( $label );
    }

    # Set mode on overridden WWW::Mechanize object
    $quiet_ctrl = ( $ctrl ? 0 : 1 );
    $Mech -> quiet( $quiet_ctrl );

    return 1;
}

sub useRedirect( $ )
{
    my ( $this, $ctrl ) = @_;
    my $label = 'redirect';

    # Record overridden value
    if ( defined( $ctrl )) {
        $override{ $label } = $ctrl;
    }

    # Retrieve default value
    else {
        $ctrl = $this -> _retrieve( $label );
    }

    # Make overridden WWW::Mechanize remember this value
    $Umka::MechFetch::Mechanize::redirect_ctrl =  $ctrl;

    return 1;
}

sub setRedirect( $;$ )
{
    my ( $this, $req_redirect, $max_redirect ) = @_;
    my $label = 'max_redirect';

    # Define request names that will allow redirection
    if ( defined( $req_redirect )) {
        $Mech -> requests_redirectable( $req_redirect );
    }

    # Record overridden value
    if ( defined( $max_redirect )) {
        $override{ $label } = $max_redirect;
    }

    # Retrieve default value
    else {
        $max_redirect = $this -> _retrieve( $label );
    }

    # Set mode on overridden WWW::Mechanize object
    $Mech -> max_redirect( $max_redirect );

    return 1;
}

sub getRedirect()
{
    my $this = shift( @_ );

    my $req_redirect = $Mech -> requests_redirectable();
    my $max_redirect = $Mech -> max_redirect();
    my @output = ( $req_redirect, $max_redirect );

    return @output;
}

sub setTimeout( $ )
{
    my ( $this, $timeout ) = @_;
    my $label = 'timeout';

    # Record overridden value
    if ( defined( $timeout )) {
        $override{ $label } = $timeout;
    }

    # Retrieve default value
    else {
        $timeout = $this -> _retrieve( $label );
    }

    # Set mode on overridden WWW::Mechanize object
    $Mech -> timeout( $timeout );

    return 1;
}

sub getTimeout()
{
    my $this = shift( @_ );

    my $output = $Mech -> timeout();

    return $output;
}

sub setAgent( $ )
{
    my ( $this, $alias ) = @_;
    my $label = 'agent';

    # Record overridden value
    if ( defined( $alias )) {
        $override{ $label } = $alias;
    }

    # Retreive default value
    else {
        $alias = $this -> _retrieve( $label );
    }

    # Set mode on overridden WWW::Mechanize object
    $Mech -> agent_alias( $alias );

    return 1;
}

sub setLang( $ )
{
    my ( $this, $lang ) = @_;
    my $label = 'lang';

    # Record overriden value
    if ( defined( $lang )) {
        $override{ $label } = $lang;
    }

    # Retreive default value
    else {
        $lang = $this -> _retrieve( $label );
    }

    # Set mode on overridden WWW::Mechanize object
    $Mech -> add_header( 'Accept-Language' => $lang );

    return 1;
}

sub setAuth( $;$ )
{
    my ( $this, $username, $password ) = @_;
    my $label_username = "auth_username";
    my $label_password = "auth_password";

    # Record overriden value
    if ( defined( $username )) {
        $override{ $label_username } = $username;
        $override{ $label_password } = $password;
    }

    # Retreive default value
    else {
        $username = $this -> _retrieve( $label_username );
        $password = $this -> _retrieve( $label_password );
    }

    @Umka::MechFetch::Mechanize::auth_details = ( $username, $password );

    return 1;
}

sub setProxy( $ )
{
    my ( $this, $Config ) = @_;
    my $label = "Proxy";

    # Choose between custom, exception & default proxy lists
    if ( defined( $Config )) {
        $override{ $label } = $Config;
    }

    # Retreive default value
    else {
        $Config = $this -> _retrieve( $label );
    }

    # Setup all proxies for all required protocols
    foreach my $protocol ( $Config -> keys()) {
        next if $protocol eq 'none';
        my $address = $Config -> value( $protocol );
        $Mech -> proxy( $protocol, $address );
    }

    # Define a single url access to which should by-pass proxy
    if ( $Config -> is_scalar( 'none' )) {
        $Mech -> no_proxy( $Config -> value( 'none' ));
    }

    # Define a list of urls which should by-pass proxy
    elsif ( $Config -> is_array( 'none' )) {
        $Mech -> no_proxy( $Config -> array( 'none' ));
    }

    return 1;
}

sub setUri( $ )
{
    my $this = shift( @_ );

    $request_uri = shift( @_ );
    croak( "Missing request URI" ) unless ( $request_uri );
    $this -> _configure();

    return 1;
}

sub getUri( ;$$$ )
{
    my ( $this, $uri, $submit, $Config ) = @_;
    my $label = "Form";

    # Fetch required URI and return HTTP::Response object
    $this -> setUri( $uri ) if ( defined( $uri ));
    croak( "Missing request URI" ) unless ( $request_uri );
    $Mech -> get( $request_uri );

    # Choose between custom, exception & default proxy lists
    if ( defined( $Config )) {
        $override{ $label } = $Config;
    }

    # Retrieve default value
    else {
        $Config = $this -> _retrieve( $label );
    }

    # Populate form(s) on the page
    foreach my $Form ( $Mech -> forms()) {
        my $name = $Form -> attr( "name" );
        next unless ( $Config -> exists( $name ));
        $Mech -> form_name( $name );
        $Mech -> set_fields( $Config -> hash( $name ));
    }

    # Submit required form
    if ( defined( $submit )) {
        # Show error if no form defined in the config file
        unless ( $Config -> exists( $submit )) {
            carp( "Required form \"$submit\" missing submission data" )
                    unless ( $quiet_ctrl );
        }

        # Show error if no form defined on the returned page
        unless ( $Mech -> form_name( $submit )) {
            carp( "Required form \"$submit\" is not part of the page" )
                    unless ( $quiet_ctrl );
        }

        $Mech -> submit();
    }


    my $output = $Mech -> response();

    return $output;
}

1;

__DATA__

#
# Umka::MechFetch Configuration File
#

# This is a sample configuration file which defines a list of variables
# required for a successful connection to a given location using one of the
# available protocols (eg: file, http, ftp, etc).

# Correctly identify user agent as one of the following: Windows IE 6,
# Windows Mozilla, Mac Safari, Mac Mozilla, Linux Mozilla, Linux Konqueror
# Example:  agent Windows IE 6
agent Windows IE 6

# On/Off switch controlling whether to show warnings or not.
# Example:  warnings off
warnings off

# Defines expected language for the retrieved pages.
# Example:  lang en
lang en

# Set timeout value in seconds after which a socket will close.
# Please note that setting this to 0 will block the socket.
# Example:  timeout 15
timeout 15

# On/Off switch controlling whether to follow redirects or not.
# Possible values are: true (aka 1) or false (aka 0).
# Example:  redirect off
redirect off

# Maximum number of redirects to follow when retrieving a page.
# Example:  max_redirect = 7
max_redirect 7

# Defines details for Apache's Basic Authentication method.
# Example:  auth_username example_username
#           auth_password example_password
auth_username example_username
auth_password example_password

# The following is a list of proxy servers through which we should
# direct our traffic. It follows a fairly basic format: PROTOCOL =
# PROXY, where PROTOCOL is the name of the protocol that will be
# proxied, and PROXY is a fully qualified address of the proxy.
#
# "none" is a special protocol case which indicates that no proxy
# should be used when accessing defined host. Multiple definitions
# of "none" are allowed.
#
# Example:
# <Proxy>
#     none 127.0.0.1
#     none localhost
#     http http://cache.example.com:8080/
# </Proxy>
<Proxy>
</Proxy>

# Searches resulting page for any occurrence of a form where the value of
# the "name" tag equals to Form_Name_Tag and populates supplied form
# fields with values provided.
#
# If no forms with the name of Form_Name_Tag found then no form fields are
# filled and original page code is returned.
#
# Example:
# <Form Form_Name_Tag>
#     field_name example_field_entry
#     field_name example_field_entry
# </Form>
<Form >
</Form>

# A list of rules for accessing remote sites. This section allows any of
# the values used above. Also, multiple "Exception" sections are allowed
# and are used to overwrite defaults on per URI basis.
#
# Please note that values given within <Exception> section overwrite
# their corresponding default values. This means that if at least one
# <Form> section is given then all of the corresponding default <Form>
# sections will be discarded in preference to the specified one.
#
# Example:
# <Exception http://www.example.com/your/destination.html>
#     lang ru
#     redirect on
#     max_redirect 10
#     <Proxy>
#         none localhost
#         http http://cache.example.com/
#     </Proxy>
#     <Form Form_Name_Tag>
#         field_name example_field_entry
#         field_name example_field_entry
#     </Form>
# </Exception>
<Exception >
</Exception>

__END__

=pod

=head1 NAME

Umka::MechFetch - object-orientated automated page retrieval.

=head1 SYNOPSIS

The following is an example of the way this module can be used from within a
custom script. This example will download an page located at
"protocol://example/uri" and will display its content.

    use Umka::MechFetch;

    my $file = 'config.rc';
    my $path_fs = [ '.', '../etc', '/etc', '/usr/local/etc' ];
    my $paht_rc = [ 'Umka', 'Www' ];

    our $Browser = new Umka::MechFetch( $file, $path_fs, $path_rc );
    my $Page = $Browser -> getUri( "protocol://example/uri" );

    print( $Page -> content());

If a page is hidden behind custom login to which we are redirected upon
accessing "protocol://example/uri", and assuming that login is done through a
form for which C<name="Login">. Then, after we have configured a new form
"Login" in the config file (<Form Login>...<Form>), we can access our URI
with:

    $Browser -> getUri( "protocol://example/uri", "Login" );

Function C<getUri()> return the current response as an HTTP::Response object,
and is the only function in the library that allows access to the retrieved
source.

=head1 DESCRIPTION

This library is designed to complement ones scripts with the ability to
automatically retrieve pre-configured pages from a remote location. The
library supports numerous protocols (file, ftp, http, https, etc) as well as a
number of access methods, eg: access through a proxy, access behind apache's
basic authentication, etc.

Most importantly this library can access pages hidden behind a custom user
login. This is done by configuring and submitting a custom login form upon
accessing a predefined URI. See C<getUri()>, and Form section with in the
config.

=head2 Requirements

The following is a list of modules required by Umka::MechFetch. Please note that
version numbers indicate the version of a module this package was built with.
With minor tweaking you should be able to get Umka::MechFetch to run with older
versions of the same modules.

    Config::General 2.31    Generic config file parser
    WWW::Mechanize  1.18    Automates web page form & link interaction
    Carp            1.03    Throw exceptions outside current package

=head2 Installation

Currently this module is not distributed as part of the CPAN archive,
therefore installing it is not as simple as doing C<install Umka::MechFetch> from
the CPAN shell. However, it is not much harder then that either.

First of all make sure that you have successfully installed all of the modules
listed in the required section. Once that is done, complete installation by
copying the module to a location where perl can find it.

A list of directories searched by perl for a file you are attempting to C<use>
or C<require> can be found by running C<perl -V> or set by using C<use lib
'/path/to/module'> pragma within a script.

=head2 Configuration

This modules behaviour is largely controlled by editing appropriate sections
in the configuration file. Default config file can be retreived by either
calling C<< $Browser -> defaultConfig() >>, which will return default config
file as a single string. Or by executing the following from the command line:

    perl -e 'use lib "/include/path"; use Umka::MechFetch;
            print( Umka::MechFetch::defaultConfig());'

=head2 Overriding

Please note that when using this library it is possible to override variables
defined in the configuration file by explicitly supplying their values, eg:
C<< $Browser -> setAuth( 'my_name', 'my_pass' ) >>. The following is the order
in which such variables are overridden:

Variables specified as part of global configuration have the lowest priority
and can be overridden by both: variables defined in the Exception section and
variables supplied explicitly through a script.

Variables declared in the exception section will override any value given to
the same variable as part of global configuration but only when accessing an
exceptional URI.

Variables explicitly defined through a script using built-in declaration
functions have the highest priority and will override any other values (global
or exceptional).

=head1 METHODS

=head2 Publicly Available

The following is a list of publicly available methods, their arguments and
return values. Any changes to the syntax of this methods would result in a
change to the minor version of the library.

=head3 new( file; path, block )

Creates and returns a new Umka::MechFetch object.

=over

=item file (required; string, hash reference or filehandle reference)

The name of the configuration file to be used. This can be a filename of a
config file, which will be opened and parsed by the parser, a hash reference,
which will be used as the config, or a filehandle ref to an already open
config file, which will be parsed by the parser.

    new Umka::MechFetch( 'config.rc' );
    new Umka::MechFetch( \%config_hash );
    new Umka::MechFetch( \$file_handle );

=item path (optional; string or array reference)

Specifies a search path for relative config files which have to be included.
The module will search within this path for the config file if it cannot find
it at the location relative to the current script. To provide multiple search
paths you can specify an array reference for the path.

    new Umka::MechFetch( 'config.rc', '/etc' );
    new Umka::MechFetch( 'config.rc', [ '/etc', '~/etc' ]);

=item block (optional; string or array reference)

Specifies location of the browser configuration block within the config file.
First element specified is the top most, defined configuration block within
the config. To provide a path to the required config block you can specify an
array reference.

    new Umka::MechFetch( 'config.rc', '/etc', 'Browser' );
    new Umka::MechFetch( 'config.rc', '/etc', [ 'Umka', 'Browser' ]);

=back

=head3 defaultConfig( )

This method does not take any arguments and if invoked, it will return default
configuration file as a single string.

    $Browser -> defaultConfig();

=head3 useWarnings( switch )

Controls libraries verbosity level. Allows to suppress all non fatal warning
generated by the library. This method always returns 1.

=over

=item switch (required; boolean)

Sets library's desired level of verbosity. If set to C<undef> then default
value from the config is used, if set to C<0> then no warnings are displayed,
if set to anything else then all generated warnings are shown.

    $Browser -> useWarnings( undef );
    $Browser -> useWarnings( 0 );
    $Browser -> useWarnings( 1 );

=back

=head3 useRedirect( switch )

This method is used to determine whether a redirection in the request should
be followed or not. Uses an overloaded version of C<redirect_ok()> in
WWW::Mechanize library, always returns 1.

=over

=item switch (required; boolean)

Controls library behaviour when redirect is encountered as part of a request.
If set to C<undef> then default value from the config is used, if set to C<0>
then no redirects are followed, if set to anything else then all encountered
redirects are followed.

    $Browser -> useRedirect( undef );
    $Browser -> useRedirect( 0 );
    $Browser -> useRedirect( 1 );

=back

=head3 setRedirect( request; maximum )

Used to set the object's list of request names that will allow redirection as
well as a limit of how many times object will obey redirect responses in a
given request cycle. Always returns 1.

=over

=item request (required; array reference)

Defines a list of request names that will allow redirection. By default, this
is C<['GET', 'HEAD']>, as per RFC 2616. If value is set to C<undef> then
object's behaviour is not modified and last set value is used.

    $Browser -> setRedirect( undef );
    $Browser -> setRedirect([ 'POST' ]);
    $Browser -> setRedirect([ 'HEAD', 'GET', 'POST' ]);

=item maximum (optional; integer)

Sets a maximum limit of how many times object will obey redirection responses
in a given request cycle. By default, the value is set to 7. If set to
C<undef> then default value from the config file is used.

    $Browser -> setRedirect( undef, undef );
    $Browser -> setRedirect( undef, 10 );

=back

=head3 getRedirect( )

Method returns a list of two elements. First one is an array reference
containing a current list of request names that will allow redirection. The
second one is a maximum limit of how many times object will obey redirection
responses in a given request cycle.

    my( $requests, $maximum ) = $Browser -> getRedirect();

=head3 setTimeout( delay )

This method is used to set request timeout value. Requests is aborted if no
activity on the connection to the server is observed for B<delay> seconds,
which is not the same as the actual time it takes for the complete transaction
to return. This method always returns 1.

=over

=item delay (required; integer)

Sets request timeout value in seconds. The default timeout value is 180
seconds, i.e. 3 minutes. If set to C<undef> then default value from the config
file is used.

    $Browser -> setTimeout( undef );
    $Browser -> setTimeout( 10 );

=back

=head3 getTimeout( )

Method returns an integer containing current delay value in seconds. Please
note that this value is used to determine when to abort request connection to
the server if no activity detected. The actual time it takes for the complete
transaction to return might be longer.

    my $delay = $Browser -> getTimeout();

=head3 setAgent( agent )

This method allows a user to masquerade current object as a user defined
browser. This method always returns a value of 1.

=over

=item agent (required; string)

Sets the user agent string to the expanded version from a table of actual user
string. B<Agent> could be one of the following: Windows IE 6, Windows Mozilla,
Mac Safari, Mac Mozilla, Linux Mozilla, Linux Konqueror. If set to C<undef>
then default value from the config file is used.

    $Browser -> setAgent( undef );
    $Browser -> setAgent( 'Windows IE 6' );

=back

=head3 setLang( lang )

Defines a preferred language for the returned page by setting
C<Accept-Language> header on the request. This method always returns 1.

=over

=item lang (required; string)

This is either a single language defined by its language code (eg: en, fr, ru,
en-GB, en-US), or a comma separated list of languages in the order of their
preference. If set to C<undef> then default config value is used.

    $Browser -> setLang( undef );
    $Browser -> setLang( 'en' );
    $Browser -> setLang( 'en-GB, en' );

=back

=head3 setAuth( username; password )

This method is used to define a username and an optional password for the
Apache's Basic or Digest Authentication. This method always returns 1.

=over

=item username (required; string)

This variable defines a username to be used with Apache's Basic or Digest
Authentication when a challenge is received. If set to C<undef> then default
config values are used for both username and password.

    $Browser -> setAuth( undef );
    $Browser -> setAuth( 'my_user' );

=item password (required; string)

This variable defines a password to be used with Apache's Basic or Digest
Authentication when a challenge is received. If set to C<undef> then no
password will be used for the defined user, unless user is set to C<undef>
too, then default config values for both username and password are used.

    $Browser -> setAuth( 'my_user', undef );
    $Browser -> setAuth( 'my_user', 'my_pass' );

=back

=head3 setProxy( Proxy )

This method is used to define a list of proxies for a number of various
protocols. This method alwais returns a value of 1.

=over

=item Proxy (required; object)

This variable contains a Config::General object describing all available
proxies for a particular set of protocols, see C<< <Proxy>...</Proxy> >>
section with in the config file for more information. If set to C<undef> then
default config value is used.

    $Browser -> setProxy( undef );
    $Browser -> setProxy( $Proxy );

=back

=head3 setUri( uri )

This method allows a user to specify a uri to be retrieved by a subsequent
call to C<< $Browser -> getUri() >>. Please note that this method only
prepares the uri, you would still need to fetch it afterwards. This method
always returns 1.

=over

=item uri (required; string)

Defines a URI/URL to be retrieved by the script. Such a URI would often, but
not always, be of the following format: protocol://server:port/path/to/file,
eg: http://localhost/. If set to C<undef> then default config value is used.

    $Browser -> setUri( undef );
    $Browser -> setUri( 'http://www.example.com/path/file.html' );
    $Browser -> setUri( 'http://.../file.html?one=1&two=2#anchor' );

=back

=head3 getUri( uri, name, Config )

This method is used to retrieve the source code of the desired page. It takes
three optional arguments and returns current response as an HTTP::Response
object.

=over

=item uri (optional; string)

Defines a URI/URL to be retrieved by the script. Such a URI would often, but
not always, be of the following format: protocol://server:port/path/to/file,
eg: http://localhost/. If set to C<undef> then default value is used.

    $Browser -> getUri( undef );
    $Browser -> getUri( 'http://www.example.com/path/file.html' );
    $Browser -> setUri( 'http://.../file.html?one=1&two=2#anchor' );

=item name (optional; string)

If B<name> is defined then it indicates the name of the page's form element
that will be submitted in order to retrieve final page. In other words, this
allows you to retrieve pages from behind custom user authentication mechanism.
If set to C<undef> then no submission will be made.

    $Browser -> getUri( 'http://.../file.html', undef );
    $Browser -> getUri( 'http://.../file.html', 'My_Form' );

=item Config (optional; object)

This variable contains a Config::General object describing any number of named
forms and data that a form would be filled with. See C<< <Form>...</Form> >>
section within the config file for more information. If set to C<undef> then
default config value is used.

    $Browser -> getUri( 'http://.../file.html', 'My_Form', undef );
    $Browser -> getUri( 'http://.../file.html', 'My_Form', $Config );

=back

=head2 Internal Access

The following is a list of internal methods, their arguments and return
values. This methods are designed to be accessed by the package subroutines
only and may change with out further notice.

=head3 _configure( )

Internal method designed to configure all other methods within browser package
according to the values stored in the config or already provided in the code.

=head3 _retrieve( name )

Internal method designed to retrieve a value of a variable described by
B<name> and taking into account variable overriding by explicit or exceptional
declarations.

=head2 Local Overrides

The following methods should never be used directly and are provided here for
the completeness of documentation only. The only use of this methods is
provide a link between objects API and low end modules used by the package.

=head3 redirect_ok

An overloaded version of C<redirect_ok()> in WWW::Mechanize. This method is
used to determine whether a redirection in the request should be followed

=head3 get_basic_credentials

An overloaded version of C<get_basic_credential()> in LWP::UserAgent. This
method should return a username and password or an empty list to abort the
authentication resolution attempt.

=head1 SEE ALSO

Config::General, WWW::Mechanize, LWP::UserAgent, HTTP::Response

=cut
