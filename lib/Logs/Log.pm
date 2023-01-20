package Logs::Log;
use strict;
use Exporter qw(import);

use subs qw(_debug _debug1 _debug2 _debug3 _debug_end _usage);

our @EXPORT = qw(debug debug1 debug2 debug3 debug_end debug_enabled usage register_usage init_debug_log);

my $DEBUG_ENABLED = 0;

BEGIN {
sub noop          { 1 }

*_usage     = \&noop;
*_debug     = \&noop;
*_debug1    = \&noop;
*_debug2    = \&noop;
*_debug3    = \&noop;
*_debug_end = \&noop;
}

sub usage         { _usage }
sub debug_enabled { $DEBUG_ENABLED }

sub debug     { _debug  @_ }
sub debug1    { _debug1 @_ }
sub debug2    { _debug2 @_ }
sub debug3    { _debug3 @_ }
sub debug_end { _debug_end }

sub logdebug      { 
    my $caller = (caller(1))[3]; 

    if ($caller =~ /debug_log_line/) { 
        $caller = (caller(2))[3] 
    } 

    $_[0] =~ /^>(.*)/ 
        && ($caller = $1, shift);

    my @ARGS=@_; 
    print D "DEBUG: ", $caller, ": ", join("\nDEBUG: ", 
        map{chomp($_);$_='['.$_.']'}@{[@ARGS]} ), "\n" 
}

sub logdebug_end  { 
    for(1..10) { 
        print D ((caller(1))[3], " # ---------------------------------------------------- #\n" )
    } 
}

sub init_debug_log {
    my  ($optname, $DEBUG_FILE) = @_;
    !$DEBUG_FILE && return;
    open D, ">>$DEBUG_FILE" or return; 
    $DEBUG_ENABLED = 1;
    my $loglevel = 0;
    ::numberFromEnv(\$loglevel, DEBUG_LOG_LEVEL => $loglevel, 0);
    $loglevel >= 0 && (*_debug  = \&logdebug);
    $loglevel >= 1 && (*_debug1 = \&logdebug);
    $loglevel >= 2 && (*_debug2 = \&logdebug);
    $loglevel >= 3 && (*_debug3 = \&logdebug);
    *_debug_end = \&logdebug_end;
}

sub register_usage { *_usage = shift }

1;