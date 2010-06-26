use strict;
use lib qw(../gen-perl /usr/local/lib/perl5);
use Thrift::Socket;
use Thrift::Server;
use linuxdating::LinuxDater;

use Data::Dumper;

package LinuxDaterHandler;
use base qw(linuxdating::LinuxDaterIf);

my $sandbox = "/home/ian/per/linuxdating/sandbox";
my $port = 9090;
my $host = "localhost";

sub new {
    my $classname = shift;
    my $self      = {};

    return bless($self,$classname);
}


sub ping
{
    print "ping()\n";
}

## Actually run the command, and then print the response.
sub eval_command
{
    my($self, $cmd) = @_;
    printf("eval(%s)\n", $cmd);
    return `$cmd 2>&1`;
}

## First, chroot to the sandbox.

chdir($sandbox);
#chroot($sandbox);

eval {

    my $handler       = new LinuxDaterHandler;
    my $processor     = new linuxdating::LinuxDaterProcessor($handler);
    my $serversocket  = new Thrift::ServerSocket($port, $host);
    my $forkingserver = new Thrift::ForkingServer($processor, $serversocket);
    print "Starting the server...\n";
    $forkingserver->serve();
    print "done.\n";
}; if ($@) {
    if ($@ =~ m/TException/ and exists $@->{message}) {
        my $message = $@->{message};
        my $code    = $@->{code};
        my $out     = $code . ':' . $message;
        die $out;
    } else {
        die $@;
    }
}

