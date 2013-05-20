# NAME

jdescribe.pl

# SYNOPSIS

    description [ -jenkins <jenkins_url> ] -job <job_name> \
        -build <build_num> -description <description> \
	[ -user <user_id> -password <password_or_api_token> ]

# DESCRIPTION

This program allows you to change the description of a Jenkins build.

# HOW HTTP WORKS IN PERL

This program uses LWP and other associated Perl http modules (including
HTTP::Request and URI).

The way LWP works in Perl is a bit confusing. You create a _browser_ in
Perl using the `LWP::UserAgent-`new> constructor. To actually use this
_browser_, you must construct _http requests_. To do this, you must
create a request object via the `HTTP::Request-`new> constructor. Once
you create the request object, you build it bit-by-bit using the various
`HTTP::Request` methods.

In this program, we must make a _POST_ request to the _Submit
Description_ URL for Jenkins. We may also be required to log into
Jenkins before we can do a request. This is handled by the
`authorization_basic` method for the request. Thus, we need to do the
following steps:

- __Build the User Browser__: `$browser = LWP::UserAgent->new;`
- __Create a request__: `$request = HTTP::Request->new;`
- __Set the method for the request__: `$request->method("POST");`
- __Set the URL__: `$request->url("$jenkins_build/submitDescription");`
- __Login (if necessary)__: `$request->authorization_basic($user, $pass);`
- __Set the content__: `$request->content($content);`

The last step is more difficult than it seems. This is because the
content must be encoded and then you must set headers to explain what
your content consists of, and how long it is. The simplest way to
_encode_ the content is to use the `query_form` method of the `URI`
package. This means creating a `URI` object, then using the
`query_form` method.

Once that is done, you need to set the headers `Content-Type` and
`Content-Length`. You can do that via the `header` method of the
`HTTP::Request` class.

- __Create a URI object (URL doesn't matter)__ `$uri =
URI->new("http://");`
- __Encode the string via the `query_form` method__
    - `$uri->query_form("Description" => $description)`
    - `$content = $uri->query;`;
- __Now set the encoded content__: `$request->content($content);`
- __Set Content-Type Header__: `$request->header( 'Content-Type' =>
'application/x-www-form-urlencoded' );`
- __Set the Content-Length Header__: `$request->header(
'Content-Length' => length($content) );`

Now that the request is built, it can sent to the browser

- `$browser->request($request)`

Nothing could be simpler! There is actually a slightly easier package
called `HTTP::Request::Common` that allows you to build the POST
request, and send the request in a single call, but it doesn't seem
to work when authentication is required.

# OPTIONS

- \-jenkins

    The URL of the Jenkins server. Default is set with `use  constant`. You
    can override this with this option, or change the constant.

    __NOTE__: This must start with `http://` or `https://`

- \-user

    The User to log into the server. This is optional if there is no
    security required to set the description. This is set by default with
    `use constant`. You may override this by changing the constant, or via
    command line parameter. If there is no security, change the constant to
    an `undef`;

- \-password

    The User's password or API tokent. You can find the API Token by going
    into that user's Jenkins page, click on _Configure_, then click on the
    _Show API Token..._ button.

    This is set by default with a `use constant` clause. You may override
    this with a command line parameter. If there is no security, change the
    constant to an `undef`

- \-job

    The Jenkins Job name. Required.

- \-build

    The Jenkins Build Number for that job. Required.

- \-description

    The description you want to set the job to. Required



# AUTHOR

David Weintraub [david@weintraub.name](mailto:david@weintraub.name)

# COPYRIGHT

Copyright &copy; 2013 by David Weintraub. All rights reserved. This program
is covered by the open source BMAB license.

The BMAB (Buy me a beer) license allows you to use all code for whatever
reason you want with these three caveats:

1. If you make any modifications in the code, please consider sending them
to me, so I can put them into my code.
2. Give me attribution and credit on this program.
3. If you're in town, buy me a beer. Or, a cup of coffee which is what I'd
prefer. Or, if you're feeling really spendthrify, you can buy me lunch.
I promise to eat with my mouth closed and to use a napkin instead of my
sleeves.
