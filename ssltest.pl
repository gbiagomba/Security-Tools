#!/usr/bin/perl
# Originally based on Cryptonark by Chris Mahns, techstacks.com
# Written by lupin, grey-corner.blogspot.com
# Visit the blog to see if a newer version of the tool has been released
# To Do: certificate validity checks, matching of cn to hostname, check for certificate expiry, check for certificate revocation, check for signing by trusted certificate authority

# History:
# Changes 0.1 - 0.1.1 : Minor bug fix and cosmetic changes
# Changes 0.1.1 - 0.1.2: More minor cosmetic changes, 
# Changes 0.1.2 - 0.2: More cosmetic changes, Windows Support, improved greppable output, Help text re OpenSSL, helpful errors for missing modules
# Changes 0.2 - 0.3: Added check to confirm listening service on host:port before running SSL tests, and added checks for friendly https cipher denials
# Changes 0.3 - 0.4: Minor bugfix with list command, all SSL2 ciphers now not listed as supported under pci

$version = "0.4";

#Copyright (c) 2010, grey-corner.blogspot.com
#All rights reserved.

#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

#    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#    * Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



# Check that IO::Socket::SSL module is installed, explain what to do if not
if (not eval("require IO::Socket::SSL;")){
  noiosockethelp();
	die($noiosockethelp);
}

use IO::Socket::INET;
use Getopt::Long;
Getopt::Long::Configure ("bundling");

# Separator values for cipher listing output
$gsep = "   ";
$sep = ", ";

# Search strings used to determine which ciphers are compliant with various standards, ISM Sep 2009, pci check values taken from cnark.pl
$ismstring = '^NULL|^ADH-|DES-CBC-|MD5|RC'; # No NULL cipher, No Null Auth, No single DES, No MD5, No RC ciphers
$pcistring = '^NULL|^ADH-|DES-CBC-|^EXP-'; # No NULL cipher, No Null Auth, No single DES, No Export encryption

# search strings to find to detect friendly "update your browser" responses
$friendlystring = '^HTTP/1.1 401 Unauthorized';
$friendlydetected = 0;

GetOptions('h|help' => \$help, 'v|verbose+' => \$verbose, 'r|ssl2' => \$ssl2, 's|ssl3' => \$ssl3, 't|tls1' => \$tls1, 'x|timeout=i' => \$timeout, 'i|ism' => \$ism, 'p|pci' => \$pci, 'g|grep' => \$grep, 'l|list' => \$list, 'f|friend' => \$friend, 'n|nohelp' => \$nohelp);

# Check which OS we are running on, use appropriate terminal colouring module
if ($^O =~ m/MSWin32/) {
	if (not $grep) {
		# Win32::Console::ANSI is not commonly installed on Windows, so lets check for it and provide a workaround
		if (not eval("require Win32::Console::ANSI;")) { 
			die("Module Win32::Console::ANSI not found to support coloured terminal output.\nEither install this using your perl package manager, or enable greppable\noutput using the -g|--grep switch.\n\n");
		}		
	}
} else { # Assuming that all other OS'es support Term::ANSIColor properly - Linux does, others.... dunno
	use Term::ANSIColor qw(:constants);
}


if ($grep) { $sep = ";" }

# List the supported ssl2 and 3 ciphers and a description (modified from output of command `openssl ciphers -v 'ALL:eNULL'`)
%ssl2ciphers = (
	'DES-CBC3-MD5' => '3DES 168 bits, RSA Auth, MD5 MAC, RSA Kx',
	'DES-CBC-MD5' => 'DES 056 bits, RSA Auth, MD5 MAC, RSA Kx',
	'EXP-RC2-CBC-MD5' => 'RC2 040 bits, RSA Auth, MD5 MAC, RSA 512 Kx',
	'RC2-CBC-MD5' => 'RC2 128 bits, RSA Auth, MD5 MAC, RSA Kx',
	'EXP-RC4-MD5' => 'RC4 040 bits, RSA Auth, MD5 MAC, RSA 512 Kx',
	'RC4-MD5' => 'RC4 128 bits, RSA Auth, MD5 MAC, RSA Kx'
);

%ssl3ciphers = (
	'ADH-AES256-SHA' => 'AES 256 bits, No Auth, SHA1 MAC, DH Kx',	
	'DHE-RSA-AES256-SHA' => 'AES 256 bits, RSA Auth, SHA1 MAC, DH Kx',
	'DHE-DSS-AES256-SHA' => 'AES 256 bits, DSS Auth, SHA1 MAC, DH Kx',
	'AES256-SHA' => 'AES 256 bits, RSA Auth, SHA1 MAC, RSA Kx',
	'ADH-AES128-SHA' => 'AES 128 bits, No Auth, SHA1 MAC, DH Kx',	
	'DHE-RSA-AES128-SHA' => 'AES 128 bits, RSA Auth, SHA1 MAC, DH Kx',
	'DHE-DSS-AES128-SHA' => 'AES 128 bits, DSS Auth, SHA1 MAC, DH Kx',
	'AES128-SHA' => 'AES 128 bits, RSA Auth, SHA1 MAC, RSA Kx',
	'ADH-DES-CBC3-SHA' => '3DES 168 bits, No Auth, SHA1 MAC, DH Kx',
	'ADH-DES-CBC-SHA' => 'DES 056 bits, No Auth, SHA1 MAC, DH Kx',
	'EXP-ADH-DES-CBC-SHA' => 'DES 040 bits, No Auth, SHA1 MAC, DH 512 Kx',
	'ADH-RC4-MD5' => 'RC4 128 bits, No Auth, MD5 Mac, DH Kx',
	'EXP-ADH-RC4-MD5' => 'RC4 040 bits, No Auth, MD5 MAC, DH 512 Kx',
	'EDH-RSA-DES-CBC3-SHA' => '3DES 168 bits, RSA Auth, SHA1 MAC, DH Kx',
	'EDH-RSA-DES-CBC-SHA' => 'DES 056 bits, RSA Auth, SHA1 MAC, DH Kx',
	'EXP-EDH-RSA-DES-CBC-SHA' => 'DES 040 bits, RSA Auth, SHA1 MAC, DH 512 Kx', 
	'EDH-DSS-DES-CBC3-SHA' => '3DES 168 bits, DSS Auth, SHA1 MAC, DH Kx',
	'EDH-DSS-DES-CBC-SHA' => 'DES 056 bits, DSS Auth, SHA1 MAC, DH Kx',
	'EXP-EDH-DSS-DES-CBC-SHA' => 'DES 040 bits, DSS Auth, SHA1 MAC, DH 512 Kx',
	'DES-CBC3-SHA' => '3DES 168 bits, RSA Auth, SHA1 MAC, RSA Kx',
	'DES-CBC-SHA' => 'DES 056 bits, RSA Auth, SHA MAC, RSA Kx',
	'EXP-DES-CBC-SHA' => 'DES 040 bits, RSA Auth, SHA1 MAC, RSA 512 Kx',
	'EXP-RC2-CBC-MD5' => 'RC2 040 bits, RSA Auth, MD5 MAC, RSA 512 Kx',
	'RC4-SHA' => 'RC4 128 bits, RSA Auth, SHA1 MAC, RSA Kx',
	'RC4-MD5' => 'RC4 128 bits, RSA Auth, MD5 MAC, RSA Kx', 
	'EXP-RC4-MD5' => 'RC4 040 bits, RSA Auth, MD5 MAC, RSA 512 Kx',
	'NULL-SHA' => 'X NULL Encryption, RSA Auth, SHA1 MAC, RSA Kx',
	'NULL-MD5' => 'X NULL Encryption, RSA Auth, MD5 MAC, RSA Kx'
);

# Choose the appropriate check string based on selected compliance standard
if ($pci && $ism) {
	print "Both ISM and PCI-DSS standards selected, defaulting to more restrictive standard of ISM.\n";
	$checkstring = $ismstring;
} elsif ($ism) {
	$checkstring = $ismstring;
} elsif ($pci) {
	$checkstring = $pcistring;
} else { # Default to ISM standard if none specified
	$checkstring = $ismstring;
}

# If list option specified, just print out the ciphers and exit
if ($list) {
	$hostport = "";
	if ( (!$ssl2) && (!$ssl3) && (!$tls1) ) {
		print "SSLv2 Ciphers Supported...\n";
		foreach $hk (sort {$ssl2ciphers{$a} cmp $ssl2ciphers{$b}} keys %ssl2ciphers) { checkcompliance($hk, $ssl2ciphers{$hk}, "SSLv2") }
		print "SSLv3/TLSv1 Ciphers Supported...\n";
		foreach $hk (sort {$ssl3ciphers{$a} cmp $ssl3ciphers{$b}} keys %ssl3ciphers) { checkcompliance($hk, $ssl3ciphers{$hk}, "SSLv3/TLSv1") }
	} else {
		if ($ssl2) { 
			print "SSLv2 Ciphers Supported...\n";
			foreach $hk (sort {$ssl2ciphers{$a} cmp $ssl2ciphers{$b}} keys %ssl2ciphers) { checkcompliance($hk, $ssl2ciphers{$hk}, "SSLv2") }
		}
		if ($ssl3 || $tls1) {
			print "SSLv3/TLSv1 Ciphers Supported...\n";
			foreach $hk (sort {$ssl3ciphers{$a} cmp $ssl3ciphers{$b}} keys %ssl3ciphers) { checkcompliance($hk, $ssl3ciphers{$hk}, "SSLv3/TLSv1") }
		}
	}
	exit;
}	
	

if ( !$ARGV[1] || $help ) {
	help();
}

$host = $ARGV[0];
$port = $ARGV[1];

if (!$timeout) { 
	$timeout = 4; # Default timeout of 4 seconds for connections
}

# HTTP request to send to server to check for friendly SSL errors
$httprequest = "GET / HTTP/1.1\r\nHost: $host\r\nConnection: close\r\n\r\n";

# Check if there is something listening on $host:$port
IO::Socket::INET->new(
  PeerAddr => $host,
  PeerPort => $port,
  Proto => 'tcp',
  Timeout => $timeout
) || die("Can't make a connection to $host:$port.\nAre you sure you specified the host and port correctly?\n\n");


if ($grep) { 
	print "Status(Compliant,Non-compliant,Disabled);Hostname:Port;SSL-Protocol;Cipher-Name;Cipher-Description\n"; 
	$hostport = "$host:$port$sep";
}

# Run the appropriate SSL tests
if ( (!$ssl2) && (!$ssl3) && (!$tls1) ) { # If no protocols specified, run all tests
	ciphertests('SSLv2', \%ssl2ciphers);
	ciphertests('SSLv3', \%ssl3ciphers);
	ciphertests('TLSv1', \%ssl3ciphers);
} else {
	if ($ssl2) { ciphertests('SSLv2', \%ssl2ciphers); }
	if ($ssl3) { ciphertests('SSLv3', \%ssl3ciphers); }
	if ($tls1) { ciphertests('TLSv1', \%ssl3ciphers); }
}

# Called on event of a successful SSL connection from ciphertests(), used to determine compliant status of supported ciphers
sub checkcompliance{	
  if ( (! $friend) && (! $list) ){
    $socket = $_[3];    
    print $socket $httprequest;    
    $response = "";
    while (<$socket>) {
      $response .= $_;
    }
    if ($verbose > 2) {
      $n = "=" x 40;
      print "\n$n\nHTTP Request:\n$n\n$httprequest$n\nHTTP Response:\n$n\n$response\n$n\n\n";
    }
    if ($response =~ m/($friendlystring)/) {
      unsupported($_[0], $_[1], $_[2]);
      $friendlydetected = 1;
      return;
    }
	}
	if ( ($_[0] =~ /($checkstring)/) || ($_[2] eq 'SSLv2') ) {
		if ($grep) {
			$description = $_[1];
			$description =~ s/( bits, |, )/,/g; # Shorten cipher description for greppable output
			print "N" . $sep . $hostport . $_[2] . $sep . $_[0] . $sep . $description . "\n";
		} elsif ($^O =~ m/MSWin32/) {
			print "\e[1;31m" . $gsep . $_[0] . $sep . $_[1] . "\e[0m\n";
		} else {
			print RED, $gsep . $_[0] . $sep . $_[1] . "\n", RESET;
		}		
	} else {
		if ($grep) {
			$description = $_[1];
			$description =~ s/( bits, |, )/,/g;
			print "C" . $sep . $hostport . $_[2] . $sep . $_[0] . $sep . $description . "\n";
		} elsif ($^O =~ m/MSWin32/) {
			print "\e[1;32m" . $gsep . $_[0] . $sep . $_[1] . "\e[0m\n";
		} else {
			print GREEN, $gsep . $_[0] . $sep . $_[1] . "\n", RESET;
		}
	}
	

}

# Called on event of a SSL connection error from ciphertests(), used for verbose output of unsupported ciphers
sub unsupported{
	if ($verbose) {		
		if ($grep) {
			$description = $_[1];
			$description =~ s/( bits, |, )/,/g;			
			print "D" . $sep . $hostport . $_[2] . $sep . $_[0] . $sep . $description . "\n";
		} elsif ($^O =~ m/MSWin32/) {
			print "\e[1;34m" . $gsep . $_[0] . $sep . $_[1] . " (Disabled)\e[0m\n";
		} else {
			print BLUE, $gsep . $_[0] . $sep . $_[1] . " (Disabled)\n", RESET;
		}
	}
}


# Subroutine to run cipher connection tests
sub ciphertests {
  $success = 0;
  $fail = 0;
	$hashref = $_[1];
	%hash = %$hashref;	
	if (not $grep) { print "Checking for Supported $_[0] Ciphers on $host:$port...\n"; }
	foreach $hk (sort {$hash{$a} cmp $hash{$b}} keys %hash) {
		if ($verbose > 1) {print "Attempting connection to $host:$port using $_[0] $hk...\n"; }
		$sslsocket = IO::Socket::SSL->new(
			PeerAddr => $host,
			PeerPort => $port,
			Proto => 'tcp',
			Timeout => $timeout, 
			SSL_version => $_[0], 
			SSL_cipher_list => $hk
		);
    if ($sslsocket) {
      checkcompliance($hk, $hash{$hk}, $_[0], $sslsocket);  
      $sslsocket->close();
    } else {
      unsupported($hk, $hash{$hk}, $_[0]);
    }
    
	}

}


if ( ($friendlydetected) && (! $nohelp)){
  friendlyerror();
}


# Help


sub friendlyerror {
  print STDERR <<FRIENDLYHELPTEXT;

One or more friendly SSL error messages were detected during the cipher 
testing process.  These will allow an SSL connection only for the purpose 
of providing a friendly error message to the client to update their browser
to a newer version.  The process used by this tool to detect these errors is
a little simplistic and potentially prone to errors, so if you see this
message I suggest you run the test with the triple verbose mode (-vvv) 
enabled to see the HTTP response from the server that has triggered this 
detection.  If you think that the detection is a false negative you can 
disable the check using the -f switch, and you can also inform the author of
this tool about the issue so this feature can be improved.

If you like the friendly option, and don't want to see this error message any 
more you can also prevent it from displaying in future by using the -n 
option.

See the help for more information. 
FRIENDLYHELPTEXT
}



sub noiosockethelp {
    $noiosockethelp = <<IOHELPTEXT;
It appears your Perl install does not include the IO::Socket::SSL module, 
which is required for this tool to work.

If you are running ActivePerl on Windows, this module, as well as the
dependant Net::SSLeay do not exist in the ActiveState Repositories, so 
you will need to go to a third party repository appropriate for your 
particular version of Perl.  The uwinnipeg repository is a good source,
just add it from the suggested list in the PPM Preferences window, or 
visit the following URL as a jumping off point to find the correct
repository for your version of perl (the below link is for perl 5.10
but there are links there for perl versions 5.6, 5.8 and 5.12):

http://cpan.uwinnipeg.ca/PPMPackages/10xx/

Don't forget to install "IO-Socket-SSL" AND "Net-SSLeay", and while you're 
there you may as well also install "Win32-Console-ANSI" to get coloured
terminal output (although it is possible to do without this if you use
greppable output).

If running perl on Linux, you can install the needed modules from CPAN.

In both cases you will also require OpenSSL on your system, and the version
of OpenSSL you use may effect your ability to connect to particular systems.
I have had good results with OpenSSL versions 0.9.8g and below but your 
mileage may vary.  Binary versions of OpenSSL for Windows can be obtained
from here, version 0.9.8e is suggested:

http://code.google.com/p/openssl-for-windows/ 

Stick the ssleay32.dll and libeay32.dll files in your path.

For Linux just use your distributions package management system or grab and 
install OpenSSL from source.
IOHELPTEXT
}


sub help {
	print <<HELPTEXT;
ssltest $version
grey-corner.blogspot.com

Tests the provided SSL host to determine supported SSL protocols and ciphers.  
Originally based on Cryptonark by Chris Mahns.

USAGE:

$0 [options] host port
$0 [--pci|--ssl2|--ssl3|--tls1] --list


OPTIONS:

  -v|--verbose  Verbosity level. Use once to also list tested 
                ciphers that are not enabled on the target host.
                Use twice to also show when host connection 
                attempts are made.  Use three times to also show
                the output of HTTP responses from the server
                (used to detect friendly SSL messages - see the
                help for the -f switch below for more info).

  -r|--ssl2     Performs cipher tests for the sslv2 protocol.
                Default is all protocols (ssl2, ssl3, tls1).

  -s|--ssl3     Performs cipher tests for the sslv3 protocol.
                Default is all protocols (ssl2, ssl3, tls1).

  -t|--tls1     Performs cipher tests for the tlsv1 protocol.
                Default is all protocols (ssl2, ssl3, tls1).

  -x|--timeout	Sets timeout value in seconds for connections.  
                Default 4.  Lower value for hosts that may not 
                properly close connections when an unsupported 
                protocol request is attempted.  Raise value for 
                slow links/hosts.

  -i|--ism      Marks enabled ciphers that are compliant with the 
                DSD ISMs standards for in-transit protection of 
                IN-CONFIDENCE information (ISM Sep 2009).  Default 
                compliance standard used (as opposed to PCI).

  -p|--pci      Marks enabled ciphers that are compliant with 
                PCI-DSS standards.  Provided as an alternate 
                compliance standard to the DSD ISM.

  -g|--grep     Outputs in a semicolon ";" separated greppable 
                format, adds text for compliance status.  Use 
                when you need to write output to a text file and 
                you want compliance status to be included in 
                text format instead of just being represented by 
                terminal colour.  Fields ouput are Status;
                Hostname:Port;SSL-Protocol;Cipher-Name;
                Cipher-Description.  Compliance status will be one
                of C (Compliant), N (Non-compliant) or D (Disabled
                - only in verbose mode).

  -l|--list     Lists ciphers checked by this tool and exits, 
                with output colour coded to indicate compliance 
                status with the selected standard (pci or ism).  
                Host and port values do not need to be provided 
                when using this option, as no host connection is 
                made.  Purely informational, so you can see what
                ciphers are tested for, and which are deemed to be
                compliant with the various standards.

  -f|--friend   Disables checks for "friendly" SSL errors. 
                These checks are enabled by default, and will
                essentially try and detect any sites that allow an 
                SSL connection just so that they can tell you to
                get a newer browser.  At the moment this test is
                done very crudely by checking for a HTTP 1.1 401
                Unauthorised message in response to a GET request.
                This is quite possibly prone to false negatives, so
                the tool will warn you if such a detection has 
                occurred and will suggest that you run the test
                again in triple verbose mode to see the HTTP response
                from the server.  If the response does not appear
                to suggest that SSL is only supported for the 
                purpose of a warning the user to upgrade their 
                browser, you can run the test again with this
                switch to disable the friendly check.
                
  -n|--nohelp   Disables the display of helpful (but potentially 
                unwanted) messages, such as the warning about the 
                friendly SSL detection.
                
                 

If one or more protocol/s (SSLV2, SSLV3, TLSV1) are not specifically enabled, 
tests for all protocols will be performed.  If you know that a host does not 
support certain protocols (or does not properly close connection attempts made 
using particular protocols) you can only include tests for the protocols you 
are interested in to speed up the test.  If no compliance standard is 
specifically enabled, or if more than one standard is enabled, the default 
is to use the DSD ISM.

This tool is dependant on using OpenSSL to make SSL connections, and since 
OpenSSL sometimes changes the format of SSL requests in different versions
of the software, if you are having problems getting a connection to a
particular host you may be able to resolve them by using a later (or
earlier) version of OpenSSL.  If using this tool on Linux you can check the
OpenSSL version using the command 'openssl version'.  If on Windows you may
only be using the OpenSSL dll files, which are named ssleay32.dll and
libeay32.dll and are probably in your path.  Check the version of these dll
files to determine the OpenSSL version.  The binary versions of the dll
files that the author uses with this tool (0.9.8e) can be obtained from 
http://code.google.com/p/openssl-for-windows/.


EXAMPLES:

$0 -vvrsi test.example.com 443

Performs testing on host test.example.com port 443, using the sslv3 protocol
(-s), and sslv2 protocol (-r), matches responses against the cipher 
requirements in the ISM (-i) and provides double verbose output (-vv) where 
ciphers unsupported by the destination host and connection attempts are printed
to screen.

$0 --list 

Provides a list of all ciphers supported by the tool, colour coded to indicate 
which ones are considered to be compliant with the ISM.  Add the --pci switch 
to colour code listed ciphers for PCI compliance instead, or supply the --ssl2,
--ssl3 or --tls1 switches to only list ciphers appropriate to those protocols.


HELPTEXT
exit;
}

