# NAME

jdescribe.pl

# SYNOPSIS

    description [ -jenkins <jenkins_url>  -job <job_name> ] \
        [ -build <build_num> ] -description <description> \
	[ -user <user_id> -password <password_or_api_token> ]

# DESCRIPTION

This program allows you to change the description of a Jenkins build.

# HOW HTTP WORKS IN PERL

This program uses `LWP::UserAgent` and `HTTP::Request::Common`. These
in turn require `LWP`, `URI`, `HTTP::Response`, `HTTP::Request`
`HTTP::Header`, `HTTP::Message`, `HTTP::Response` and others. None of
these are standard Perl modules, but all should be installed via CPAN if
you install `LWP::UserAgent` and `HTTP::Request::Common`.

In order to use HTTP, you need to first create a virtual browser via the
`new` constructor of `LWP::UserAgent`. Once you create this
_browser_, you can send HTTP requests via the `request` method of
`LWP::UserAgent`.

Constructing the requests is done by `HTTP::Request` or the
`HTTP::Request::Common` modules. The `HTTP::Request::Common` module
handles `POST` and `GET` requests in a very easy to use manner and
hides much of the complexity in creating requests.

In this program, the request is a `POST` request in a form that
contains a `description` field which contains the description of that
build. The request can do basic authorization via the
`authorization_basic` method.

The constructed request is sent via the virtual browser, and an
`HTTP::response` object is returned. This program examines the response
and verifies that the request was successful.

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

    This is taken by the [Promoted Build Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin) `$PROMOTED_JOB_NAME` environment variable.

- \-build

    The Jenkins Build Number for that job. This is taken by the [Promoted Build Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin)
    `$PROMOTED_JOB` environment variable.

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
