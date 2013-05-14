#! /usr/bin/env perl
# description.pl

use 5.12.0;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Pod::Usage;
use Getopt::Long;

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


my $user_agent = LWP::UserAgent->new
    or die qq(Can't get User Agent);
my $request = HTTP::Request->new ( GET => $jenkins_url )
    or die qq(Can't get request from $jenkins_url);

if ( $user and $password ) {
    $request->authorization_basic( $user, $password );
    my $response = $user_agent->request($request);
    if ( $response->is_error ) {
	die qq(Cannot log into Jenkins Server "$jenkins_url");
    }
}

my $jenkins_build = "$jenkins_url/@{[JOB_URL]}/$job_name/$build";

my $response = $user_agent->request (
    POST "$jenkins_build/@{[SUBMIT_DESCRIPTION]}",
    [
	description => "$description",
    ],
);

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

This program allows you to change the description of a Jenkins build

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

Copyright (c) 2013 by David Weintraub. All rights reserved. This program
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

=cut