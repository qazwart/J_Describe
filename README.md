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
Perl using the `LWP::UserAgent-`new> constructor.

What you send to the browser to operate on are <HTTP Requests>. This is
done via the `HTTP::Request` module. However, there's a
`HTTP::Request::Common` module that uses a `POST` subroutine to
construct the `HTTP::Request` object for you including the content to
post.

Once the request object is created, you can use the
`authentication_basic` method on the request and forward that request
to the \``LWP::UserAgent`\` request method.

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
