# NAME

jdescribe.pl

# SYNOPSIS

    description -description [ -jenkins <jenkins_url> ] \
	[ -job <job_name> ]  [ -build <build_num> ] \
	[ -user <user_id> -password <password_or_api_token> ]

# DESCRIPTION

This program allows you to change the description of a Jenkins build.

# HOW HTTP WORKS IN PERL

This program requires the use of
[LWP::UserAgent](http://search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP/UserAgent.pm) and [HTTP::Request::Common](http://search.cpan.org/~gaas/HTTP-Message-6.06/lib/HTTP/Request/Common.pm).  If you install these modules from CPAN, the following will also install:

- HTTP::LWP
- HTTP::Request
- HTTP::Headers
- HTTP::Response
- URI

and several others.

In Perl, you use `LWP::UserAgent` to create a virtual browser. You send this
browser requests via `HTTP::Request` or `HTTP::Request::Common`.
This program creates a `POST` request via `HTTP::Request::Common`.
This post request contains the field `description` and the description.
It will also set the needed HTTP::Headers and use `authorization_basic`
in the request if the [\-user](http://search.cpan.org/perldoc?\-user) and [\-password](http://search.cpan.org/perldoc?\-password) parameters are also
given.

This request returns an HTTP::Response which is examined to make sure
the request work.

# OPTIONS

- \-jenkins

    The URL of the Jenkins server. By default, this is taken from the
    `$JENKINS_URL` environment variable that is set by Jenkins when it
    runs. If you use this parameter, be sure to give the full JENKINS URL
    including the `HTTP://` or `HTTPS://` protocol prefix.

- \-user

    The User to log into the server. This is optional if there is no
    security required to set the description. This is set by default with
    `use constant`. You may override this by changing the constant, or via
    command line parameter. If there is no security, change the constant to
    an `undef`;

- \-password

    The User's password or API token. You can find the API Token by going
    into that user's Jenkins page, click on _Configure_, then click on the
    _Show API Token..._ button.

    This is set by default with a `use constant` clause. You may override
    this with a command line parameter. If there is no security, change the
    constant to an `undef`

- \-job

    The Jenkins Job name. The default will be taken from the
    `$PROMOTED_JOB_NAME` environment variable if it is set.

- \-build

    The Jenkins Build Number for that job. The default will be taken from
    the `$PROMOTED_NUMBER` environment variable if it is set.

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
