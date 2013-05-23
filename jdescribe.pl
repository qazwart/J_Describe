#! /usr/bin/env perl
# description.pl

use 5.12.0;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Pod::Usage;
use Getopt::Long;

use Data::Dumper;

use constant {
    JENKINS_URL             => "http://buildl02.tcprod.local/jenkins",
    USER_ID                 => "dweintraub",
    PASSWORD                => "192ada2b9f993161cae976dfa20dac89",
};

use constant {
    JOB_URL                 => 'job',
    SUBMIT_DESCRIPTION      => 'submitDescription',
};

my $jenkins_url	= JENKINS_URL;
my $user	= USER_ID;
my $password	= PASSWORD;

my ( $job_name, $build, $description);
my ( $help_wanted, $show_options, $show_documentation);

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

    description [ -jenkins <jenkins_url> ] -job <job_name> \
        -build <build_num> -description <description> \
	[ -user <user_id> -password <password_or_api_token> ]

=head1 DESCRIPTION

This program allows you to change the description of a Jenkins build.

=head1 HOW HTTP WORKS IN PERL

This program uses LWP and other associated Perl http modules (including
HTTP::Request and URI).

The way LWP works in Perl is a bit confusing. You create a I<browser> in
Perl using the C<LWP::UserAgent->new> constructor.

What you send to the browser to operate on are <HTTP Requests>. This is
done via the C<HTTP::Request> module. However, there's a
C<HTTP::Request::Common> module that uses a C<POST> subroutine to
construct the C<HTTP::Request> object for you including the content to
post.

Once the request object is created, you can use the
C<authentication_basic> method on the request and forward that request
to the `C<LWP::UserAgent>` request method.

=head1 OPTIONS

=over 10

=item -jenkins

The URL of the Jenkins server. Default is set with C<use  constant>. You
can override this with this option, or change the constant.

B<NOTE>: This must start with C<http://> or C<https://>

=item -user

The User to log into the server. This is optional if there is no
security required to set the description. This is set by default with
C<use constant>. You may override this by changing the constant, or via
command line parameter. If there is no security, change the constant to
an C<undef>;

=item -password

The User's password or API tokent. You can find the API Token by going
into that user's Jenkins page, click on I<Configure>, then click on the
I<Show API Token...> button.

This is set by default with a C<use constant> clause. You may override
this with a command line parameter. If there is no security, change the
constant to an C<undef>

=item -job

The Jenkins Job name. Required.

=item -build

The Jenkins Build Number for that job. Required.

=item -description

The description you want to set the job to. Required


=back

=head1 AUTHOR

David Weintraub L<david@weintraub.name|mailto:david@weintraub.name>

=cut
