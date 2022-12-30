package Test::Output;
use Test::More;
use strict;
use warnings;

subtest "Default: Return commands only" => sub {
    Test::Output::setup();
    my ($allopts) = helptext::completer::list_matches(["dummycmd", '']);
    is(scalar(@$allopts), 3, "3 commands are returned");
    for(@$allopts){
        ok($_->{isCmd}, "Returned option is command")
    }
    Test::Output::teardown();
};

subtest "Default: Return options if requested" => sub {
    Test::Output::setup();
    my ($allopts) = helptext::completer::list_matches(["dummycmd", '-']);
    is(scalar(@$allopts), 4, "4 options are returned");
    for(@$allopts){
        ok(!$_->{isCmd}, "Returned option is option")
    }
    Test::Output::teardown();
};

subtest "Default: Be quiet if last option's mandatory arg is missing" => sub {
    Test::Output::setup();
    subtest "Last option needs one mandatory argument" => sub {
        my $command = "dummycmd --opt-1-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', '']);
        is(scalar(@$allopts), 0, "Call $command ''. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', '-']);
        is(scalar(@$allopts), 0, "Call $command '-'. Return nothing. Last option still needs 1 argument.");
    };
    subtest "Last option needs two mandatory argument" => sub {
        my $command = "dummycmd --opt-2-args";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC']);
        is(scalar(@$allopts), 0, "Call $command 'ABC'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC', '']);
        is(scalar(@$allopts), 0, "Call $command 'ABC' ''. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC', '-']);
        is(scalar(@$allopts), 0, "Call $command 'ABC' '-'. Return nothing. Last option still needs 1 argument.");
    };
    subtest "Last option ignores one optional argument" => sub {
        my $command = "dummycmd --opt-1-opt-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', '']);
        is(scalar(@$allopts), 3, "Call $command ''. Return 3 commands. Last option ignores optional argument.");
        for(@$allopts){ ok($_->{isCmd}, "Returned option is command") }
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', '-']);
        is(scalar(@$allopts), 4, "Call $command '-'. Return 4 options. Last option ignores optional argument.");
        for(@$allopts){ ok(!$_->{isCmd}, "Returned option is option") }
    };
    Test::Output::teardown();
};

subtest "Default: Be quiet while last option's mandatory arg is created" => sub {
    Test::Output::setup();
    subtest "Last option needs one mandatory argument" => sub {
        my $command = "dummycmd --opt-1-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', 'A']);
        is(scalar(@$allopts), 0, "Call $command 'A'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', 'AB']);
        is(scalar(@$allopts), 0, "Call $command 'AB'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', 'ABC']);
        is(scalar(@$allopts), 0, "Call $command 'ABC'. Return nothing. Last option still needs 1 argument.");
    };
    subtest "Last option needs two mandatory argument" => sub {
        my $command = "dummycmd --opt-2-args";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC']);
        is(scalar(@$allopts), 0, "Call $command 'ABC' 'D'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC', 'DE']);
        is(scalar(@$allopts), 0, "Call $command 'ABC' 'DE'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC', 'DEF']);
        is(scalar(@$allopts), 0, "Call $command 'ABC' 'DEF'. Return nothing. Last option still needs 1 argument.");
    };    
    subtest "Last option needs one optional argument" => sub {
        my $command = "dummycmd --opt-1-opt-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', 'A']);
        is(scalar(@$allopts), 0, "Call $command 'A'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', 'AB']);
        is(scalar(@$allopts), 0, "Call $command 'AB'. Return nothing. Last option still needs 1 argument.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', 'ABC']);
        is(scalar(@$allopts), 0, "Call $command 'ABC'. Return nothing. Last option still needs 1 argument.");
    };
    Test::Output::teardown();
};

subtest "Default: Return commands only after last option is completed" => sub {
    Test::Output::setup();
    subtest "Last option needs one mandatory argument" => sub {
        my $command = "dummycmd --opt-1-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-arg', 'ABC', '']);
        is(scalar(@$allopts), 3, "Call $command 'ABC' ''. Return 3 commands. Last option ignores optional argument.");
        for(@$allopts){ ok($_->{isCmd}, "Returned option is command") }
    };
    subtest "Last option needs two mandatory argument" => sub {
        my $command = "dummycmd --opt-2-args";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-2-args', 'ABC', 'DEF', '']);
        is(scalar(@$allopts), 3, "Call $command 'ABC' 'DEF' ''. Return 3 commands. Last option ignores optional argument.");
        for(@$allopts){ ok($_->{isCmd}, "Returned option is command") }
    };
    subtest "Last option ignores one optional argument" => sub {
        my $command = "dummycmd --opt-1-opt-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-1-opt-arg', 'ABC', '']);
        is(scalar(@$allopts), 3, "Call $command 'ABC' ''. Return 3 commands. Last option ignores optional argument.");
        for(@$allopts){ ok($_->{isCmd}, "Returned option is command") }
    };
    Test::Output::teardown();
};

subtest "Default: Don't complete on shell pipes or redirects" => sub {
    Test::Output::setup();
    subtest "Don't react on current arg '>' or '>>'" => sub {
        my $command = "dummycmd --opt-no-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>']);
        is(scalar(@$allopts), 0, "Call $command '>'. Return 0 commands. Shell redirect '>' is ignored.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>>']);
        is(scalar(@$allopts), 0, "Call $command '>>'. Return 0 commands. Shell redirect '>>' is ignored.");
        $command = "dummycmd";
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>']);
        is(scalar(@$allopts), 0, "Call $command '>'. Return 0 commands. Shell redirect '>' is ignored.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>>']);
        is(scalar(@$allopts), 0, "Call $command '>>'. Return 0 commands. Shell redirect '>>' is ignored.");
    };
    subtest "Don't react on previous arg '>' or '>>'" => sub {
        my $command = "dummycmd --opt-no-arg";
        my ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>', '']);
        is(scalar(@$allopts), 0, "Call $command '>' ''. Return 0 commands. Shell redirect '>' is ignored.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>>', '']);
        is(scalar(@$allopts), 0, "Call $command '>>' ''. Return 0 commands. Shell redirect '>>' is ignored.");
        $command = "dummycmd";
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>', '']);
        is(scalar(@$allopts), 0, "Call $command '>' ''. Return 0 commands. Shell redirect '>' is ignored.");
        ($allopts) = helptext::completer::list_matches(["dummycmd", '--opt-no-arg', '>>', '']);
        is(scalar(@$allopts), 0, "Call $command '>>' ''. Return 0 commands. Shell redirect '>>' is ignored.");
    };

    Test::Output::teardown();
};

subtest "Config: Return commands and options on HT*_SHOW_ALL" => sub {
    subtest "Config: Return commands and options on HT_SHOW_ALL" => sub {
        Test::Output::setup({SHOW_ALL => 1});
        testOption_SHOW_ALL();
        Test::Output::teardown(1);
    };
    subtest "Config: Return commands and options on HT_APP_<APPNAME>_SHOW_ALL" => sub {
        Test::Output::setup({APP_DUMMYCMD_SHOW_ALL => 1});
        testOption_SHOW_ALL();
        Test::Output::teardown(1);
    }
};

# ---------------------------------------------------------
my @env;

sub setup { my $env = $_[0];
    while (my ($e, $v) = each %$env) {
        push @env, $e;
        $ENV{'HT_'.$e} = $v;
    }
    @env>0 && unittests::load_completer();
    no strict;
    no warnings;
    *{helptext::completer::find_options_bak} = \&{helptext::completer::find_options};
    *{helptext::completer::find_options} = \&createCommandsAndOptions;
}

sub teardown { 
    my $reload = @env>0;
    for (@env) { delete $ENV{'HT_'.$_} }
    $reload && unittests::load_completer();
    no strict;
    no warnings;
    *{helptext::completer::find_options} = \&{helptext::completer::find_options_bak};
}

sub testOption_SHOW_ALL {
    my $cntCmdsAndOpts = sub { my $cliargs = $_[0];
        my $allopts = helptext::completer::list_matches($cliargs);
        is(scalar(@$allopts), 7, "Call: $cliargs->[0] '".join("' '",@$cliargs[1..@$cliargs-1])."': 7 commands and options are returned");
        my ($cntCmds, $cntOpts);
        for(@$allopts){ 
            $_->{isCmd} && ++$cntCmds && next;
            $cntOpts++ 
        }
        is($cntCmds, 3, "Call: ".join(' ',@$cliargs).": 3 commands are returned");
        is($cntOpts, 4, "Call: ".join(' ',@$cliargs).": 4 options are returned");
    };

    subtest "Return commands and options" => sub {
        $cntCmdsAndOpts->(["dummycmd", ''])
    };
    subtest "Last option has one mandatory argument" => sub {
        $cntCmdsAndOpts->(["dummycmd", '--opt-1-arg', 'ABC', ''])
    };
    subtest "Last option has two mandatory arguments" => sub {
        $cntCmdsAndOpts->(["dummycmd", '--opt-1-arg', 'ABC', 'DEF', ''])
    };
    subtest "Last option has all optional arguments" => sub {
        $cntCmdsAndOpts->(["dummycmd", '--opt-1-opt-arg', 'ABC', ''])
    };
    subtest "Last option has none of all optional arguments" => sub {
        $cntCmdsAndOpts->(["dummycmd", '--opt-1-opt-arg', ''])
    };
    subtest "Last option doesn't need arguments" => sub {
        $cntCmdsAndOpts->(["dummycmd", '--opt-1--opt-arg', ''])
    };

}

sub createCommandsAndOptions {
    my $long = {type => 'LONG', line => \"", desc => ""};
    my $cmd  = {type => 'CMD', isCmd => 1, line => \"", desc => ""};
    return [
        new Option ({ %$long, name => '--opt-1-arg'    , args => 'MANDATORY_ARG'}),
        new Option ({ %$long, name => '--opt-2-args'   , args => 'MANDATORY_ARG1 MANDATORY_ARG2'}),
        new Option ({ %$long, name => '--opt-1-opt-arg', args => '[OPTIONAL_ARG]'}),
        new Option ({ %$long, name => '--opt-no-arg'   , args => ''}),
        new Option ({ %$cmd,  name => 'cmd-1' }),
        new Option ({ %$cmd,  name => 'cmd-2' }),
        new Option ({ %$cmd,  name => 'cmd-3' }),
    ], {} , {envns => 'dummycmd'};
}

1;
