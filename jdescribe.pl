#! /usr/bin/env perl
# description.pl

use 5.12.0;
use warnings;

use Env qw(JENKINS_URL PROMOTED_JOB_NAME PROMOTED_NUMBER);
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Pod::Usage;
use Getopt::Long;

use Env qw(JENKINS_URL PROMOTED_JOB_NAME PROMOTED_NUMBER);
use Data::Dumper;

use constant {
    USER_ID                 => "jenkins",
    PASSWORD                => "swordfish",
};

use constant {
    JOB_URL                 => 'job',
    SUBMIT_DESCRIPTION      => 'submitDescription',
};

my $jenkins_url	= $JENKINS_URL;
my $job_name    = $PROMOTED_JOB_NAME;
my $build       = $PROMOTED_NUMBER;
my $user	= USER_ID;
my $password	= PASSWORD;
my $job_name    = $PROMOTED_JOB_NAME;
my $build       = $PROMOTED_NUMBER;

my ( $description, $help_wanted, $show_options, $show_documentation );

GetOptions (
    "jenkins=s"		=> \$jenkins_url,
    "user=s"		=> \$user,
    "password=s"	=> \$password,
    "job=s"		=> \$job_name,
    "build=s"		=> \$build,
    "description=s"	=> \$description,
    "help"		=> \$help_wanted,
    "options"		=> \$show_options,
    "documentation"	=> \$show_documentation,
) or die pod2usage ( -message => "Invalid parameters" );

if ( $show_documentation ) {
    pod2usage ( -exitval => 0, -verbose => 2 );
}

if ( $show_options ) {
    pod2usage ( -exitval => 0, -verbose => 1 );
}

if ( $help_wanted ) {
    pod2usage (
	-message => "Use -options to see options or -doc to see entire documentation",
	-exitval => 0,
	-verbose => 0 );
}

if ( not ( $jenkins_url and $job_name and $build ) ) {
    pod2usage ( -message => "Missing parameters" );
}
my $jenkins_build = "$jenkins_url/@{[JOB_URL]}/$job_name/$build";

#
# Create Browser
#
my $browser = LWP::UserAgent->new
    or die qq(Can't get User Agent);
my $request; #What you're going to request from browser;

#
# Verify Login Credentials
#
if ( $user and $password ) {
    $request = HTTP::Request->new or die qq(Cannot generate HTTP Request);
    $request->method("GET");
    $request->url($jenkins_url);
    $request->authorization_basic( $user, $password );
    my $response = $browser->request($request);
    if ( not $response->is_success ) {
	die qq(Cannot log into Jenkins Server "$jenkins_url");
    }
}

#
# Create a POST request to submit your description
#

$request = POST (
    "$jenkins_build/@{[SUBMIT_DESCRIPTION]}",
    Content => [ description => $description ],
);

#
# Do the authorization of a log in is required
#
if ( $user and $password ) {
    $request->authorization_basic( $user, $password );
}

#
# Send the HTTP Request to your browser
#

my $response = $browser->request($request);

if ( $response->is_error ) {
    die qq(Cannot set description on Jenkins job "$jenkins_build");
}

exit 0;

__END__
=pod

=head1 NAME

jdescribe.pl

=head1 SYNOPSIS

    description -description [ -jenkins <jenkins_url> ] \
	[ -job <job_name> ]  [ -build <build_num> ] \
	[ -user <user_id> -password <password_or_api_token> ]

=head1 DESCRIPTION

This program allows you to change the description of a Jenkins build.

=head1 HOW HTTP WORKS IN PERL

This program requires the use of
L<<
LWP::UserAgent|http://search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP/UserAgent.pm
>> and L<<
HTTP::Request::Common|http://search.cpan.org/~gaas/HTTP-Message-6.06/lib/HTTP/Request/Common.pm
>>.  If you install these modules from CPAN, the following will also install:

=over 4

=item *

HTTP::LWP

=item * 

HTTP::Request

=item *

HTTP::Headers

=item * HTTP::Response

=item * URI

=back

and several others.

In Perl, you use C<LWP::UserAgent> to create a virtual browser. You send this
browser requests via C<HTTP::Request> or C<HTTP::Request::Common>.
This program creates a C<POST> request via C<HTTP::Request::Common>.
This post request contains the field C<description> and the description.
It will also set the needed HTTP::Headers and use C<authorization_basic>
in the request if the L<-user> and L<-password> parameters are also
given.

This request returns an HTTP::Response which is examined to make sure
the request work.

=head1 OPTIONS

=over 10

=item -jenkins

The URL of the Jenkins server. By default, this is taken from the
C<$JENKINS_URL> environment variable that is set by Jenkins when it
runs. If you use this parameter, be sure to give the full JENKINS URL
including the C<HTTP://> or C<HTTPS://> protocol prefix.

=item -user

The User to log into the server. This is optional if there is no
security required to set the description. This is set by default with
C<use constant>. You may override this by changing the constant, or via
command line parameter. If there is no security, change the constant to
an C<undef>;

=item -password

The User's password or API token. You can find the API Token by going
into that user's Jenkins page, click on I<Configure>, then click on the
I<Show API Token...> button.

This is set by default with a C<use constant> clause. You may override
this with a command line parameter. If there is no security, change the
constant to an C<undef>

=item -job

<<<<<<< HEAD
The Jenkins Job name. The default will be taken from the
C<$PROMOTED_JOB_NAME> environment variable if it is set.

=item -build

The Jenkins Build Number for that job. The default will be taken from
the C<$PROMOTED_NUMBER> environment variable if it is set.

=item -description

The description you want to set the job to. Required

=back

=head1 AUTHOR

David Weintraub L<david@weintraub.name|mailto:david@weintraub.name>

=head1 COPYRIGHT

Copyright E<copy> 2013 by David Weintraub. All rights reserved. This program
is covered by the open source BMAB license.

The BMAB (Buy me a beer) license allows you to use all code for whatever
reason you want with these three caveats:

=over 4

=item 1.

If you make any modifications in the code, please consider sending them
to me, so I can put them into my code.

=item 2.

Give me attribution and credit on this program.

=item 3.

If you're in town, buy me a beer. Or, a cup of coffee which is what I'd
prefer. Or, if you're feeling really spendthrify, you can buy me lunch.
I promise to eat with my mouth closed and to use a napkin instead of my
sleeves.

=back

=cut
