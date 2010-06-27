use strict;
use lib qw(../gen-perl /usr/local/lib/perl5);
use Thrift::Socket;
use Thrift::Server;
use linuxdating::LinuxDater;

use Data::Dumper;

package LinuxDaterHandler;
use base qw(linuxdating::LinuxDaterIf);

my $sandbox = "/sandbox";
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
    use Data::Dumper;
    my $good = {"ls" => 1,
                "cd" => 1,
                "cat" => 1,
                "echo" => 1,
                "date" => 1,
                "grep" => 1,
                "head" => 1,
                "ed" => 1,
                "rm" => 1,
                "rmdir" => 1,
                "sed" => 1,
                "touch" => 1,
                "wc" => 1,
    }; 
    my($self, $raw) = @_;
    my @cmds = split / /, $raw, 2;
    my $cmd = $cmds[0];
    my $args = $cmds[1];
    if (!$good->{$cmd}) {
        return "$cmd is not allowed -- sorry.";
    }

    if ($args) {
        $args = " ".$args;
        $args =~ s/\.//g;
        $args =~ s/ \// \/sandbox\//;
    }
    print ("busybox $cmd $args 2>&1\n");
    my $result = `busybox $cmd $args 2>&1`;
    $result =~ s/sandbox//;
    return $result;
}

## First, chroot to the sandbox.
## TODO -- make this work.

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

