#!/usr/bin/perl
# Copyright (c) 2012-2013, Comfirm AB
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

#     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of the Comfirm AB nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
use lib qw(../src);
use strict;
use utf8;
use Switch;
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
	"http://api.amail.io/v2",		# Service URL
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

# Error handling
switch ($response->errorCode) {
	case 0 {
		# OK
		# Step #5: Pop the champagné! We got here which mean that the request was sent successfully and the email is on it's way!        
		print "Successfully queued message with id '".$response->result."' (you can use this ID to get more details about the delivery)\n"; 
	}
	case -1 {
		# AUTHENTICATION ERROR
		# Ooops! You've probably just entered the wrong API-token.
        	print "Authentication error: ".$response->message." (".$response->errorCode.")\n";
	}
	case -2 {
		# VALIDATION ERROR
		# Example: Handle request specific error code here.
		if ($response->errorCode == 3) {
			# Example: Print a nice message to the user.
		} else {
			# Something in the input was wrong. Probably good to double double-check!
			print "Validation error: ".$response->message." (".$response->errorCode.")\n";
		}
	}
	case -3 {
		# INTERNAL ERROR
		# Not that it is going to happen.. Right :-)
		print "Internal error: ".$response->message." (".$response->errorCode.")\n";
	}
	case -4 {
		# UNKNOWN ERROR
		# Most likely your internet connection that is down. We are covered for most things except "multi-data-center-angry-server-bashing-monkeys" (remember who coined it) or.. nuclear bombs.
        	# If one blew. Well.. It's just likely that our servers are down.
        	print "An error (probably related to connection) occurred: ".$response->message."\n";
	}
}

# Writing to out like a boss
die("\n\nIn doubt or experiencing problems?\n" .
 "Please email our support at support\@amail.io\n");
 
