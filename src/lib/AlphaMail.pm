package AlphaMail;
use strict;
use utf8;
use Encode;
use vars qw($VERSION);
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON;
$VERSION = '1.00';


# result class
package Result;
sub new {
    my $class = shift;
    my $self = {
        _errorCode => shift,
        _message => shift,
        _result => shift
    };
    bless $self, $class;
    return $self;
}

# error code
sub errorCode {
    my ( $self, $errorCode ) = @_;
    $self->{_errorCode} = $errorCode if defined($errorCode);
    return $self->{_errorCode};
}

# message
sub message {
    my ( $self, $message ) = @_;
    $self->{_message} = $message if defined($message);
    return $self->{_message};
}

# result
sub result {
    my ( $self, $result ) = @_;
    $self->{_result} = $result if defined($result);
    return $self->{_result};
}


# email contact class
package EmailContact;
sub new {
    my $class = shift;
    my $self = {
        name => shift,
        email => shift,
        id => shift
    };
    bless $self, $class;
    return $self;
}

# id
sub id {
    my ( $self, $id ) = @_;
    $self->{id} = $id if defined($id);
    return $self->{id};
}

# name
sub name {
    my ( $self, $name ) = @_;
    $self->{name} = $name if defined($name);
    return $self->{name};
}

# email
sub email {
    my ( $self, $email ) = @_;
    $self->{email} = $email if defined($email);
    return $self->{email};
}

# serialize to JSON
sub TO_JSON { return { %{ shift() } }; }


# email message payload class
package EmailMessagePayload;
sub new {
    my $class = shift;
    my $self = {
        project_id => 0,        
        sender => '',
        receiver => '',
        payload => ''
    };
    bless $self, $class;
    return $self;
}

# project id
sub projectId {
    my ( $self, $projectId ) = @_;
    $self->{project_id} = $projectId if defined($projectId);
    return $self->{project_id};
}

# sender
sub sender {
    my ( $self, $sender ) = @_;
    $self->{sender} = $sender if defined($sender);
    return '';
}

# receiver
sub receiver {
    my ( $self, $receiver ) = @_;
    $self->{receiver} = $receiver if defined($receiver);
    return '';
}

# body object
sub bodyObject {
    my ( $self, $bodyObject ) = @_;
    # serialize the body to JSON
    $self->{payload} = $bodyObject if defined($bodyObject);
    return $self->{payload};
}

# serialize to JSON
sub TO_JSON { return { %{ shift() } }; }


# alphamail email service class
package AlphaMailEmailService;
use utf8;
use Encode;
sub new {
    my $class = shift;
    my $self = {
        _serviceUrl => shift,
        _apiToken => shift
    };
    bless $self, $class;
    return $self;
}

# service url
sub serviceUrl {
    my ( $self, $serviceUrl ) = @_;
    $self->{_serviceUrl} = $serviceUrl if defined($serviceUrl);
    return $self->{_serviceUrl};
}

# api token
sub apiToken {
    my ( $self, $apiToken ) = @_;
    $self->{_apiToken} = $apiToken if defined($apiToken);
    return $self->{_apiToken};
}

# send an email
sub queue {
	# queue the message
	my ( $self, $payload ) = @_;
	my $ua  = LWP::UserAgent->new;
	my $req = HTTP::Request->new;
	
	# create request and set authentication
	$req->method('POST');
	$req->uri($self->{_serviceUrl}.'email/queue');
	$req->authorization_basic('', $self->{_apiToken});
	
	# serialize the payload to JSON
	$req->content(encode('UTF-8', JSON->new->allow_blessed->convert_blessed->encode($payload)));
	
	# make the request (POST)
	my $response = $ua->request($req);
	
	# read the response
	if ($response->decoded_content) {
		my $result = JSON->new->utf8->decode($response->decoded_content);
		return new Result(
			$result->{error_code},
			$result->{message},
			$result->{result}
		);
	} else {
		# failed (connection problem?)
		return new Result(
			-4,
			$response->status_line,
			''
		);
	}
}
1;
__END__
=head1 NAME

AlphaMail - Perl extension for sending transactional email with the cloud service AlphaMail

=head1 SYNOPSIS

 	use AlphaMail;
 	
	# Hello World-message with data that we"ve defined in our template
	package HelloWorldMessage;
	sub new {
	    my $class = shift;
	    my $self = {
		message => shift,		# Represents the <# payload.message #> in our template
		some_other_message => shift	# Represents the <# payload.some_other_message #> in our template
	    };
	    bless $self, $class;
	    return $self;
	}

	# serialize to JSON
	sub TO_JSON { return { %{ shift() } }; }
	1;


	# Step 1: Let"s start by entering the web service URL and the API-token you"ve been provided
	# If you haven"t gotten your API-token yet. Log into AlphaMail or contact support at "support@amail.io".
	my $service = new AlphaMailEmailService(
		"http://api.amail.io/v2/",		# Service URL
		"YOUR-ACCOUNT-API-TOKEN-HERE"		# API Token
	);

	# Step 2: Let's fill in the gaps for the variables (stuff) we've used in our template
	my $message = new HelloWorldMessage(
		"Hello world like a boss!", 						# message
		"And to the rest of the world! Chíkmàa! مرحبا! नमस्ते! Dumelang!"		# some other message
	);	

	# Step 3: Let's set up everything that is specific for delivering this email
	my $payload = new EmailMessagePayload();
	$payload->projectId(2);												# Project Id
	$payload->sender(new EmailContact("Sender Company Name", 'your-sender-email@your-sender-domain.com', 0));	# Sender
	$payload->receiver(new EmailContact("Joe E. Receiver", 'email-of-receiver@amail.io', 1234));			# Receiver, the 3rd argument is the optional receiver id and should be either a string or an integer
	$payload->bodyObject($message);											# Body Object

	# Step 4: Haven't we waited long enough. Let's send this!
	my $response = $service->queue($payload);

=head1 DESCRIPTION

This module is the official client library for sending transactional emails with the cloud service AlphaMail.
To use this service you need an account. You can sign up for an free account on our website (http://amail.io/). 

This is not a service for sending SPAM, newsletters or bulk emails of any kind. This is for transactional emails exclusive. 
Read more about transactional emails at http://amail.io/.

=head1 SEE ALSO

http://amail.io/

=head1 AUTHOR

Comfirm AB, <lt>support@amail.io<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012-2013, Comfirm AB
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the Comfirm AB nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
