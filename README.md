MechFetch
=========

**Status:** ARCHIVED - Fully functional, but missing tests  
**Version:** 4.1.79  

*   [NAME](#NAME)
*   [SYNOPSIS](#SYNOPSIS)
*   [DESCRIPTION](#DESCRIPTION)
    *   [Requirements](#Requirements)
    *   [Installation](#Installation)
    *   [Configuration](#Configuration)
    *   [Overriding](#Overriding)
*   [METHODS](#METHODS)
    *   [Publicly Available](#Publicly-Available)
        *   [new( file; path, block )](#new-file-path-block)
        *   [defaultConfig( )](#defaultConfig)
        *   [useWarnings( switch )](#useWarnings-switch)
        *   [useRedirect( switch )](#useRedirect-switch)
        *   [setRedirect( request; maximum )](#setRedirect-request-maximum)
        *   [getRedirect( )](#getRedirect)
        *   [setTimeout( delay )](#setTimeout-delay)
        *   [getTimeout( )](#getTimeout)
        *   [setAgent( agent )](#setAgent-agent)
        *   [setLang( lang )](#setLang-lang)
        *   [setAuth( username; password )](#setAuth-username-password)
        *   [setProxy( Proxy )](#setProxy-Proxy)
        *   [setUri( uri )](#setUri-uri)
        *   [getUri( uri, name, Config )](#getUri-uri-name-Config)
    *   [Internal Access](#Internal-Access)
        *   [_configure( )](#configure)
        *   [_retrieve( name )](#retrieve-name)
    *   [Local Overrides](#Local-Overrides)
        *   [redirect_ok](#redirect_ok)
        *   [get_basic_credentials](#get_basic_credentials)
*   [SEE ALSO](#SEE-ALSO)
*   [DONATIONS](#DONATIONS)

## NAME

Umka::MechFetch - object-orientated automated page retrieval.

## SYNOPSIS

The following is an example of the way this module can be used from within a custom script. This example will download an page located at "protocol://example/uri" and will display its content.

        use Umka::MechFetch;

        my $file = 'config.rc';
        my $path_fs = [ '.', '../etc', '/etc', '/usr/local/etc' ];
        my $paht_rc = [ 'Umka', 'Www' ];

        our $Browser = new Umka::MechFetch( $file, $path_fs, $path_rc );
        my $Page = $Browser -> getUri( "protocol://example/uri" );

        print( $Page -> content());

If a page is hidden behind custom login to which we are redirected upon accessing "protocol://example/uri", and assuming that login is done through a form for which `name="Login"`. Then, after we have configured a new form "Login" in the config file (<Form Login>...<Form>), we can access our URI with:

        $Browser -> getUri( "protocol://example/uri", "Login" );

Function `getUri()` return the current response as an HTTP::Response object, and is the only function in the library that allows access to the retrieved source.

## DESCRIPTION

This library is designed to complement ones scripts with the ability to automatically retrieve pre-configured pages from a remote location. The library supports numerous protocols (file, ftp, http, https, etc) as well as a number of access methods, eg: access through a proxy, access behind apache's basic authentication, etc.

Most importantly this library can access pages hidden behind a custom user login. This is done by configuring and submitting a custom login form upon accessing a predefined URI. See `getUri()`, and Form section with in the config.

### Requirements

The following is a list of modules required by Umka::MechFetch. Please note that version numbers indicate the version of a module this package was built with. With minor tweaking you should be able to get Umka::MechFetch to run with older versions of the same modules.

        Config::General 2.31    Generic config file parser
        WWW::Mechanize  1.18    Automates web page form & link interaction
        Carp            1.03    Throw exceptions outside current package

### Installation

Currently this module is not distributed as part of the CPAN archive, therefore installing it is not as simple as doing `install Umka::MechFetch` from the CPAN shell. However, it is not much harder then that either.

First of all make sure that you have successfully installed all of the modules listed in the required section. Once that is done, complete installation by copying the module to a location where perl can find it.

A list of directories searched by perl for a file you are attempting to `use` or `require` can be found by running `perl -V` or set by using `use lib '/path/to/module'` pragma within a script.

### Configuration

This modules behaviour is largely controlled by editing appropriate sections in the configuration file. Default config file can be retreived by either calling `$Browser -> defaultConfig()`, which will return default config file as a single string. Or by executing the following from the command line:

        perl -e 'use lib "/include/path"; use Umka::MechFetch;
                print( Umka::MechFetch::defaultConfig());'

### Overriding

Please note that when using this library it is possible to override variables defined in the configuration file by explicitly supplying their values, eg: `$Browser -> setAuth( 'my_name', 'my_pass' )`. The following is the order in which such variables are overridden:

Variables specified as part of global configuration have the lowest priority and can be overridden by both: variables defined in the Exception section and variables supplied explicitly through a script.

Variables declared in the exception section will override any value given to the same variable as part of global configuration but only when accessing an exceptional URI.

Variables explicitly defined through a script using built-in declaration functions have the highest priority and will override any other values (global or exceptional).

## METHODS

### Publicly Available

The following is a list of publicly available methods, their arguments and return values. Any changes to the syntax of this methods would result in a change to the minor version of the library.

#### new( file; path, block )

Creates and returns a new Umka::MechFetch object.

<dl>

<dt id="file-required-string-hash-reference-or-filehandle-reference">file (required; string, hash reference or filehandle reference)</dt>

<dd>

The name of the configuration file to be used. This can be a filename of a config file, which will be opened and parsed by the parser, a hash reference, which will be used as the config, or a filehandle ref to an already open config file, which will be parsed by the parser.

        new Umka::MechFetch( 'config.rc' );
        new Umka::MechFetch( \%config_hash );
        new Umka::MechFetch( \$file_handle );

</dd>

<dt id="path-optional-string-or-array-reference">path (optional; string or array reference)</dt>

<dd>

Specifies a search path for relative config files which have to be included. The module will search within this path for the config file if it cannot find it at the location relative to the current script. To provide multiple search paths you can specify an array reference for the path.

        new Umka::MechFetch( 'config.rc', '/etc' );
        new Umka::MechFetch( 'config.rc', [ '/etc', '~/etc' ]);

</dd>

<dt id="block-optional-string-or-array-reference">block (optional; string or array reference)</dt>

<dd>

Specifies location of the browser configuration block within the config file. First element specified is the top most, defined configuration block within the config. To provide a path to the required config block you can specify an array reference.

        new Umka::MechFetch( 'config.rc', '/etc', 'Browser' );
        new Umka::MechFetch( 'config.rc', '/etc', [ 'Umka', 'Browser' ]);

</dd>

</dl>

#### defaultConfig( )

This method does not take any arguments and if invoked, it will return default configuration file as a single string.

        $Browser -> defaultConfig();

#### useWarnings( switch )

Controls libraries verbosity level. Allows to suppress all non fatal warning generated by the library. This method always returns 1.

<dl>

<dt id="switch-required-boolean">switch (required; boolean)</dt>

<dd>

Sets library's desired level of verbosity. If set to `undef` then default value from the config is used, if set to `0` then no warnings are displayed, if set to anything else then all generated warnings are shown.

        $Browser -> useWarnings( undef );
        $Browser -> useWarnings( 0 );
        $Browser -> useWarnings( 1 );

</dd>

</dl>

#### useRedirect( switch )

This method is used to determine whether a redirection in the request should be followed or not. Uses an overloaded version of `redirect_ok()` in WWW::Mechanize library, always returns 1.

<dl>

<dt id="switch-required-boolean1">switch (required; boolean)</dt>

<dd>

Controls library behaviour when redirect is encountered as part of a request. If set to `undef` then default value from the config is used, if set to `0` then no redirects are followed, if set to anything else then all encountered redirects are followed.

        $Browser -> useRedirect( undef );
        $Browser -> useRedirect( 0 );
        $Browser -> useRedirect( 1 );

</dd>

</dl>

#### setRedirect( request; maximum )

Used to set the object's list of request names that will allow redirection as well as a limit of how many times object will obey redirect responses in a given request cycle. Always returns 1.

<dl>

<dt id="request-required-array-reference">request (required; array reference)</dt>

<dd>

Defines a list of request names that will allow redirection. By default, this is `['GET', 'HEAD']`, as per RFC 2616\. If value is set to `undef` then object's behaviour is not modified and last set value is used.

        $Browser -> setRedirect( undef );
        $Browser -> setRedirect([ 'POST' ]);
        $Browser -> setRedirect([ 'HEAD', 'GET', 'POST' ]);

</dd>

<dt id="maximum-optional-integer">maximum (optional; integer)</dt>

<dd>

Sets a maximum limit of how many times object will obey redirection responses in a given request cycle. By default, the value is set to 7\. If set to `undef` then default value from the config file is used.

        $Browser -> setRedirect( undef, undef );
        $Browser -> setRedirect( undef, 10 );

</dd>

</dl>

#### getRedirect( )

Method returns a list of two elements. First one is an array reference containing a current list of request names that will allow redirection. The second one is a maximum limit of how many times object will obey redirection responses in a given request cycle.

        my( $requests, $maximum ) = $Browser -> getRedirect();

#### setTimeout( delay )

This method is used to set request timeout value. Requests is aborted if no activity on the connection to the server is observed for **delay** seconds, which is not the same as the actual time it takes for the complete transaction to return. This method always returns 1.

<dl>

<dt id="delay-required-integer">delay (required; integer)</dt>

<dd>

Sets request timeout value in seconds. The default timeout value is 180 seconds, i.e. 3 minutes. If set to `undef` then default value from the config file is used.

        $Browser -> setTimeout( undef );
        $Browser -> setTimeout( 10 );

</dd>

</dl>

#### getTimeout( )

Method returns an integer containing current delay value in seconds. Please note that this value is used to determine when to abort request connection to the server if no activity detected. The actual time it takes for the complete transaction to return might be longer.

        my $delay = $Browser -> getTimeout();

#### setAgent( agent )

This method allows a user to masquerade current object as a user defined browser. This method always returns a value of 1.

<dl>

<dt id="agent-required-string">agent (required; string)</dt>

<dd>

Sets the user agent string to the expanded version from a table of actual user string. **Agent** could be one of the following: Windows IE 6, Windows Mozilla, Mac Safari, Mac Mozilla, Linux Mozilla, Linux Konqueror. If set to `undef` then default value from the config file is used.

        $Browser -> setAgent( undef );
        $Browser -> setAgent( 'Windows IE 6' );

</dd>

</dl>

#### setLang( lang )

Defines a preferred language for the returned page by setting `Accept-Language` header on the request. This method always returns 1.

<dl>

<dt id="lang-required-string">lang (required; string)</dt>

<dd>

This is either a single language defined by its language code (eg: en, fr, ru, en-GB, en-US), or a comma separated list of languages in the order of their preference. If set to `undef` then default config value is used.

        $Browser -> setLang( undef );
        $Browser -> setLang( 'en' );
        $Browser -> setLang( 'en-GB, en' );

</dd>

</dl>

#### setAuth( username; password )

This method is used to define a username and an optional password for the Apache's Basic or Digest Authentication. This method always returns 1.

<dl>

<dt id="username-required-string">username (required; string)</dt>

<dd>

This variable defines a username to be used with Apache's Basic or Digest Authentication when a challenge is received. If set to `undef` then default config values are used for both username and password.

        $Browser -> setAuth( undef );
        $Browser -> setAuth( 'my_user' );

</dd>

<dt id="password-required-string">password (required; string)</dt>

<dd>

This variable defines a password to be used with Apache's Basic or Digest Authentication when a challenge is received. If set to `undef` then no password will be used for the defined user, unless user is set to `undef` too, then default config values for both username and password are used.

        $Browser -> setAuth( 'my_user', undef );
        $Browser -> setAuth( 'my_user', 'my_pass' );

</dd>

</dl>

#### setProxy( Proxy )

This method is used to define a list of proxies for a number of various protocols. This method alwais returns a value of 1.

<dl>

<dt id="Proxy-required-object">Proxy (required; object)</dt>

<dd>

This variable contains a Config::General object describing all available proxies for a particular set of protocols, see `<Proxy>...</Proxy>` section with in the config file for more information. If set to `undef` then default config value is used.

        $Browser -> setProxy( undef );
        $Browser -> setProxy( $Proxy );

</dd>

</dl>

#### setUri( uri )

This method allows a user to specify a uri to be retrieved by a subsequent call to `$Browser -> getUri()`. Please note that this method only prepares the uri, you would still need to fetch it afterwards. This method always returns 1.

<dl>

<dt id="uri-required-string">uri (required; string)</dt>

<dd>

Defines a URI/URL to be retrieved by the script. Such a URI would often, but not always, be of the following format: protocol://server:port/path/to/file, eg: http://localhost/. If set to `undef` then default config value is used.

        $Browser -> setUri( undef );
        $Browser -> setUri( 'http://www.example.com/path/file.html' );
        $Browser -> setUri( 'http://.../file.html?one=1&two=2#anchor' );

</dd>

</dl>

#### getUri( uri, name, Config )

This method is used to retrieve the source code of the desired page. It takes three optional arguments and returns current response as an HTTP::Response object.

<dl>

<dt id="uri-optional-string">uri (optional; string)</dt>

<dd>

Defines a URI/URL to be retrieved by the script. Such a URI would often, but not always, be of the following format: protocol://server:port/path/to/file, eg: http://localhost/. If set to `undef` then default value is used.

        $Browser -> getUri( undef );
        $Browser -> getUri( 'http://www.example.com/path/file.html' );
        $Browser -> setUri( 'http://.../file.html?one=1&two=2#anchor' );

</dd>

<dt id="name-optional-string">name (optional; string)</dt>

<dd>

If **name** is defined then it indicates the name of the page's form element that will be submitted in order to retrieve final page. In other words, this allows you to retrieve pages from behind custom user authentication mechanism. If set to `undef` then no submission will be made.

        $Browser -> getUri( 'http://.../file.html', undef );
        $Browser -> getUri( 'http://.../file.html', 'My_Form' );

</dd>

<dt id="Config-optional-object">Config (optional; object)</dt>

<dd>

This variable contains a Config::General object describing any number of named forms and data that a form would be filled with. See `<Form>...</Form>` section within the config file for more information. If set to `undef` then default config value is used.

        $Browser -> getUri( 'http://.../file.html', 'My_Form', undef );
        $Browser -> getUri( 'http://.../file.html', 'My_Form', $Config );

</dd>

</dl>

### Internal Access

The following is a list of internal methods, their arguments and return values. This methods are designed to be accessed by the package subroutines only and may change with out further notice.

#### _configure()

Internal method designed to configure all other methods within browser package according to the values stored in the config or already provided in the code.

#### _retrieve( name )

Internal method designed to retrieve a value of a variable described by **name** and taking into account variable overriding by explicit or exceptional declarations.

### Local Overrides

The following methods should never be used directly and are provided here for the completeness of documentation only. The only use of this methods is provide a link between objects API and low end modules used by the package.

#### redirect_ok

An overloaded version of `redirect_ok()` in WWW::Mechanize. This method is used to determine whether a redirection in the request should be followed

#### get_basic_credentials

An overloaded version of `get_basic_credential()` in LWP::UserAgent. This method should return a username and password or an empty list to abort the authentication resolution attempt.

## SEE ALSO

Config::General, WWW::Mechanize, LWP::UserAgent, HTTP::Response
