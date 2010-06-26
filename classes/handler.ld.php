<?php

// Require Thrift
$GLOBALS['THRIFT_ROOT'] = '/usr/local/lib/php';
   
require_once $GLOBALS['THRIFT_ROOT'].'/Thrift.php';
require_once $GLOBALS['THRIFT_ROOT'].'/protocol/TBinaryProtocol.php';
require_once $GLOBALS['THRIFT_ROOT'].'/transport/TSocket.php';
require_once $GLOBALS['THRIFT_ROOT'].'/transport/THttpClient.php';
require_once $GLOBALS['THRIFT_ROOT'].'/transport/TBufferedTransport.php';
require_once $GLOBALS['THRIFT_ROOT'].'/packages/ld/LinuxDater.php';
   
class LinuxDatingHandler {
    
    private static function validate($cmd) {
        return ($cmd)? TRUE: FALSE;
    }

    // OMG, this is insecure.
    public static function process() {
        
        $cmd = $_REQUEST["cmd"];
        if (!static::validate($cmd)) {
            return json_encode("ERROR: invalid cmd");
        }

        file_put_contents("/tmp/ld.log", $cmd."\n", FILE_APPEND);
        
        $socket = new TSocket('localhost', 9090);
        $transport = new TBufferedTransport($socket, 1024, 1024);
        $protocol = new TBinaryProtocol($transport);
        $client = new LinuxDaterClient($protocol);
        
        $transport->open();
   
        $resp = $client->eval_command($cmd);
        return json_encode($resp);

        #$output = array();
        #$retval = 0;
        #$line = exec($cmd, $output, $retval);
        #print(json_encode($line));
        
    }
}

?>