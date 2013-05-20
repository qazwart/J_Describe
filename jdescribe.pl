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
    JENKINS_URL             => "http://jenkins",
    USER_ID                 => "build_meister",
    PASSWORD                => "swordfish",
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
my $jenkins_build = "$jenkins_url/" . JOB_URL . "/$job_name/$build";

#
# Create Browser
#
my $browser = LWP::UserAgent->new or die qq(Can't get User Agent);
my $request;		#What you're going to request from browser;

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
# Create Another Request to modify the description
#

$request = HTTP::Request->new or die qq(Cannot generate HTTP Request);
$request->method("POST");
$request->url( "$jenkins_build/" . SUBMIT_DESCRIPTION );
$request->authorization_basic( $user, $password ) if ( $user and $password );

#
# Use URI to Encode Content String
#

my $uri = URI::new("http://");
$uri->query_form( description => $description );
my $content = $uri->query;

$request->content($content);
$request->header( 'Content-Type' => 'application/x-www-form-urlencoded' );
$request->header( 'Content-Length' => length($content) );

my $response = $browser->request($request);

say "DEBUG: Code = " . $response->code;
say "DEBUG: " . Dumper $response;
if ( $response->is_error ) {
    die qq(Cannot set description on Jenkins job "$jenkins_build");
}
exit 0;

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
Perl using the C<LWP::UserAgent->new> constructor. To actually use this
I<browser>, you must construct I<http requests>. To do this, you must
create a request object via the C<HTTP::Request->new> constructor. Once
you create the request object, you build it bit-by-bit using the various
C<HTTP::Request> methods.

In this program, we must make a I<POST> request to the I<Submit
Description> URL for Jenkins. We may also be required to log into
Jenkins before we can do a request. This is handled by the
C<authorization_basic> method for the request. Thus, we need to do the
following steps:

=over 5

=item * B<Build the User Browser>: C<< $browser = LWP::UserAgent->new; >>

=item * B<Create a request>: C<< $request = HTTP::Request->new; >>

=item * B<Set the method for the request>: C<< $request->method("POST"); >>

=item * B<Set the URL>: C<< $request->url("$jenkins_build/submitDescription"); >>

=item * B<Login (if necessary)>: C<< $request->authorization_basic($user, $pass); >>

=item * B<Set the content>: C<< $request->content($content); >>

=back

The last step is more difficult than it seems. This is because the
content must be encoded and then you must set headers to explain what
your content consists of, and how long it is. The simplest way to
I<encode> the content is to use the C<query_form> method of the C<URI>
package. This means creating a C<URI> object, then using the
C<query_form> method.

Once that is done, you need to set the headers C<Content-Type> and
C<Content-Length>. You can do that via the C<header> method of the
C<HTTP::Request> class.

=over 5

=item * B<Create a URI object (URL doesn't matter)> C<< $uri =
URI->new("http://"); >>

=item * B<< Encode the string via the C<query_form> method >>

=over 5

=item * C<< $uri->query_form("Description" => $description) >>

=item * C<< $content = $uri->query; >>;

=back

=item * B<Now set the encoded content>: C<< $request->content($content); >>

=item * B<Set Content-Type Header>: C<< $request->header( 'Content-Type' =>
'application/x-www-form-urlencoded' ); >>

=item * B<Set the Content-Length Header>: C<< $request->header(
'Content-Length' => length($content) ); >>

=back 

Now that the request is built, it can sent to the browser

=over 5

=item * C<< $browser->request($request) >>

=back

Nothing could be simpler! There is actually a slightly easier package
called C<HTTP::Request::Common> that allows you to build the POST
request, and send the request in a single call, but it doesn't seem
to work when authentication is required.

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
