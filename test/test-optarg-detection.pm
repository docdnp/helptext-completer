package Test::OptargDetection;
use Test::More;
use strict;
use warnings;

Use::As 'unittests::MAX_REPS'              => '.MAX_REPS';
Use::As 'Testdata::Create::ShortOpt'       => 'mk::sopt';
Use::As 'Testdata::Create::LongOpt'        => 'mk::lopt';
Use::As 'Testdata::Create::Whitespaces'    => 'mk::padding';
Use::As 'Testdata::Create::Whitespaces'    => 'mk::blanks';
Use::As 'Testdata::Create::RandomWords'    => 'mk::descr';
Use::As 'Testdata::Create::RandomString'   => 'mk::cmd';
Use::As 'Testdata::Create::RandomArg'      => 'mk::arg';
Use::As 'Testdata::Create::RandomOptDelim' => 'mk::delim';

subtest "Detect number of option args (Static Examples)" => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Given:
     |      * Input of different known options and commands with argument(s)
     |  Then: 
     |      * After creation the number of argument(s) is available.
    # ===============================================================================
    EOT

    subtest "Short opts: Detect number of option args" => sub {
        my @lines = (
        [ q(   -a, --wdas          Short opt has no argument(s))                                    , 0],
        [ q(   -b| --wdas  (ArG)      Short opt has 1 long opt's argument)                          , 1],
        [ q(   -c,   --wdas [ARG]       Short opt has 1 long opt's argument)                        , 1],
        [ q(   -d   --wdas [ARG]        Short opt has 1 long opt's argument)                        , 1],
        [ q(   -e   --wdas [ARG1] [ARG2]      Short opt has 2 long opt's argument(s))               , 2],
        [ q(   -f,   --wdas <ArG1> (ArG2)      Short opt has 2 long opt's argument(s))              , 2],
        [ q(   -g   --wdas ARG1 ARG2          Short opt has 2 long opt's argument(s))               , 2],
        [ q(   -h   --wdas ARG1, ARG2         Short opt has 2 long opt's argument(s))               , 2],
        [ q(   -i|  --wdas ARG1 aRG2         Short opt has 1 long opt's argument)                   , 2],
        [ q(   -j ARG, --wdas=ARGEQ          Short opt has 1 argument)                              , 1],
        [ q(   -k ARG, --wdas=ARGEQ, NOSPACE1    Short opt has 1 argument)                          , 1],
        [ q(   -l ARG, --wdas=ARGEQ,NOSPACE2    Short opt has 1 argument)                           , 1],
        [ q(   -m ARG, --wdas=<ARGEQ>,(NOSPACE2)    Short opt has 1 argument)                       , 1],
        [ q(  -Z (KwOcf11yCAHH)   (suCCu)        Short opt has 2 argument(s))                       , 2],
        [ q(  -X YIZ672QRVW   ZUOQMXRJI         Short opt has 2 argument(s))                        , 2],
        [ q(  -Y [AAA]   (BBB)  {CCCC}         Short opt has 3 mixed argument(s))                   , 3],
        [ q(  -V=asdsad.::sad (BBB) {CCCC}      Short opt has 1 "assigned" argument(s))             , 1],
        [ q(  -W --WUSUS=asdsad.::sad (BBB) {X} Short opt has 1 "assigned" long opt's argument(s))  , 1],
        );
        numArgIsDetected(\@lines, \&Opts::Find::Opt);
    };

    subtest "Long opts: Detect number of option args" => sub {
        my @lines = (
        [ q(   --Awdas, -A       Long opt has 0 argument(s).)                                       , 0],
        [ q(   --Awdas ARGEQ NOSPACE2 NOSPACE3       Long opt has 3 argument(s).)                   , 3],
        [ q(   --Bwdas, -w ARGEQ NOSPACE2 NOSPACE3      Long opt has 3 short opt's argument(s).)    , 3],
        [ q(   --Cwdas=SDS                    Long opt has 1 "assigned" argument(s))                , 1],
        [ q(   --Xwdas -x=BLA  BLUB    Long opt has 1 "assigned" short arg's argument(s))           , 1],
        [ q(   --Dwdas=SDS  SDS2                         Long opt has 1 "assigned" argument(s).)    , 1],
        [ q(   --Ewd [ARG1]  [ARG2]  (ARG3)       Long opt has 3 argument(s).)                      , 3],
        [ q(  --Fwdas| -Z (KwOcf11yCAHH)   (suCCu)      Long opt has 2 short opt's argument(s).)    , 2],
        [ q(  --Fwdas, -Z [ASD] [DSA]      Long opt has 2 short opt's argument(s).)                 , 2],
        [ q(  --Fwdas, -Z (ASD) [DSA]      Long opt has 2 mixed short opt's argument(s).)           , 2],
        [ q(  --Fwdas (ASD) [DSA]         Long opt has 2 mixed argument(s).)                        , 2],
        [ q(  --WUSUS -W=asdsad.::sad (BBB) {C} Long opt has 1 short opt's "assigned" argument(s))  , 1],
        );
        numArgIsDetected(\@lines, \&Opts::Find::Opt);
    };

    subtest "Commands: Detect number of option args (NOT SUPPORTED YET!!!)" => sub {
        my @lines = (
        [ q(   cmd-1 ARG1     Commands don't support arguments yet!!!)          , 0],
        [ q(   cmd-2 (ARG1)   Commands don't support arguments yet!!!)          , 0],
        [ q(   cmd-3 =ARG     Commands don't support arguments yet!!!)          , 0],
        );
        numArgIsDetected(\@lines, \&Opts::Find::Command);
    };

};

subtest "Detect optional arguments for options (Static Examples)" => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Given:
     |      * Input of different known options and commands with argument(s)
     |  Then: 
     |      * Options with arguments in such [brackets] are marked as having 
     |        optional arguments
    # ===============================================================================
    EOT

    subtest "Detect optional arguments" => sub {
        my @lines = (
        [ q(   -b| --wdas  (ArG)      Short opt has 1 long opt's argument)                          , 0],
        [ q(   -c,   --wdas [ARG]       Short opt has 1 long opt's argument)                        , 1],
        [ q(   -d   --wdas [ARG]        Short opt has 1 long opt's argument)                        , 1],
        [ q(   -e   --wdas [ARG1] [ARG2]      Short opt has 2 long opt's argument(s))               , 1],
        [ q(   -f,   --wdas <ArG1> (ArG2)      Short opt has 2 long opt's argument(s))              , 0],
        [ q(   -g   --wdas ARG1 ARG2          Short opt has 2 long opt's argument(s))               , 0],
        [ q(   -h   --wdas [ARG1], [ARG2]     Short opt has 2 long opt's argument(s))               , 1],
        [ q(   -i|  --wdas ARG1 aRG2         Short opt has 1 long opt's argument)                   , 0],
        [ q(   -j[=ARG], --wdas[=ARGEQ]      Short opt has 1 argument)                              , 1],
        [ q(   --burn| --wdas  (ArG)       Long opt has 1 long opt's argument)                      , 0],
        [ q(   --cute,   --wdas [ARG]        Long opt has 1 long opt's argument)                    , 1],
        [ q(   --dumb   --wdas [ARG]         Long opt has 1 long opt's argument)                    , 1],
        [ q(   --eternal   --wdas [ARG1] [ARG2]       Long opt has 2 long opt's argument(s))        , 1],
        [ q(   --fuck,   --wdas <ArG1> (ArG2)       Long opt has 2 long opt's argument(s))          , 0],
        [ q(   --great   --wdas ARG1 ARG2           Long opt has 2 long opt's argument(s))          , 0],
        [ q(   --hate   --wdas [ARG1], [ARG2]      Long opt has 2 long opt's argument(s))           , 1],
        [ q(   --idea|  --wdas ARG1 aRG2          Long opt has 1 long opt's argument)               , 0],
        [ q(   --jupiter[=ARG], --wdas[=ARGEQ]       Long opt has 1 argument)                       , 1],
        );
        optionalArgsAreDetected(\@lines, \&Opts::Find::Opt);
    };
};


subtest "Detect number of option args (Random Examples)" => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Given:
     |     * Input of different random options and commands with argument(s)
     |  Then: 
     |     * After creation the number of argument(s) is available.
    # ===============================================================================
    EOT

    my $optTypes     = { ShortOpt => sub {{name=>mk::sopt()}}, 
                         LongOpt  => sub {{name=>mk::lopt()}}, 
                         Command  => sub {{name=>mk::cmd(int(rand(10)+5)), isCmd => 1}}
                       };
    my @bracketTypes = qw([] () {} <>);
    my @lines = ();

    my $createOptionsWithArgs = sub {
        my $optType = shift;
        @lines = ();
        for (1..MAX_REPS()) {
            my $optCreator  = $optTypes->{$optType};
            my $opt         = &$optCreator();
            my $bracketType = $bracketTypes[int(rand(5))];
            my $numArgs     = $opt->{isCmd} ? 0 : int(rand(4));
            my $args        = join('', map { mk::arg(0, $bracketType).mk::blanks(3) } (1..$numArgs));
        
            push @lines, [ mk::padding(10)
                            . $opt->{name} . ' ' . $args
                            . mk::blanks(10, 5)
                            . ($opt->{isCmd} 
                                    ? q(Commands don't support arguments yet!!!) 
                                    : mk::descr (30,40)
                              )
                            . "\n"
                            , $numArgs
                         ];
        }
    };
    &$createOptionsWithArgs(qw(ShortOpt));
    numArgIsDetected(\@lines, \&Opts::Find::Opt);
    &$createOptionsWithArgs(qw(LongOpt));
    numArgIsDetected(\@lines, \&Opts::Find::Opt);
    &$createOptionsWithArgs(qw(Command));
    numArgIsDetected(\@lines, \&Opts::Find::Command);
};

subtest "Detect padding of an option's description (Static Examples)"
 => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Given:
     |      * Input of different known options and commands with description
     |  Then: 
     |      * After the number of characters between the start of a line and
     |      the first character of an option's description text is available.
    # ===============================================================================
    EOT

    subtest "Short opts: Detect index of description" => sub {
        my @lines = (
        [ q(   -a, --wdas          Short opt has no argument(s))                                    , 23],
        [ q(   -b| --wdas  (ArG)      Short opt has 1 long opt's argument)                          , 26],
        [ q(   -c,   --wdas [ARG]      Short opt has 1 long opt's argument)                         , 27],
        [ q(   -d   --wdas [ARG]      Short opt has 1 long opt's argument)                          , 26],
        [ q(   -e   --wdas [ARG1] [ARG2]       Short opt has 2 long opt's argument(s))              , 35],
        );
        pad2descIsDetected(\@lines, \&Opts::Find::Opt);
    };
    # TestFlow::test_to_be_implemented; return;
    subtest "Long opts: Detect index of description" => sub {
        my @lines = (
        [ q(   --Awdas, -A       Long opt has 0 argument(s).)                                       , 21],
        [ q(   --Awdas ARGEQ NOSPACE2 NOSPACE3       Long opt has 3 argument(s).)                   , 41],
        [ q(   --Bwdas, -w ARGEQ NOSPACE2 NOSPACE3      Long opt has 3 short opt's argument(s).)    , 44],
        [ q(   --Cwdas=SDS                    Long opt has 1 "assigned" argument(s))                , 34],
        [ q(   --Xwdas -x=BLA  BLUB    Long opt has 1 "assigned" short arg's argument(s))           , 19],
        );
        pad2descIsDetected(\@lines, \&Opts::Find::Opt);
    };

    subtest "Commands: Detect index of description" => sub {
        my @lines = (
        [ q(   cmd-1 ARG1     Commands don't support arguments yet!!!)              , 9],
        [ q(   cmd-2 (ARG1)       Commands don't support arguments yet!!!)          , 9],
        [ q(   cmd-3 =ARG     Commands don't support arguments yet!!!)              , 9],
        [ q(     cmd-4             Commands don't support arguments yet!!!)         , 23],
        );
        pad2descIsDetected(\@lines, \&Opts::Find::Command);
    };

};

subtest "Detect number of option args (Random Examples)" => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Given:
     |     * Input of different random options and commands with argument(s)
     |  Then: 
     |     * After creation the number of argument(s) is available.
    # ===============================================================================
    EOT

    # ok(1,""); return;
    my $optTypes     = { ShortOpt => sub {{name=>mk::sopt()}}, 
                         LongOpt  => sub {{name=>mk::lopt()}}, 
                         Command  => sub {{name=>mk::cmd(int(rand(10)+5)), isCmd => 1}}
                       };
    my @bracketTypes = qw([] () {} <>);
    my @lines = ();

    my $createOptionsWithArgs = sub {
        my $optType = shift;
        @lines = ();
        for (1..MAX_REPS()) {
            my $optCreator  = $optTypes->{$optType};
            my $opt         = &$optCreator();
            my $bracketType = $bracketTypes[int(rand(5))];
            my $numArgs     = $opt->{isCmd} ? 0 : int(rand(4));
            my $args        = join('', map { mk::arg(0, $bracketType).mk::blanks(3) } (1..$numArgs));
            my $description = $opt->{isCmd} 
                                ? q(Commands don't support arguments yet!!!) 
                                : mk::descr (30,40);
            my $line        = mk::padding(10)
                               . $opt->{name} . ' ' . $args
                               . mk::blanks(10, 5)
                               . $description . "\n";

            $description =~s/^\s+//;
            push @lines, [$line, index($line, $description)];
        }
    };
    &$createOptionsWithArgs(qw(ShortOpt));
    pad2descIsDetected(\@lines, \&Opts::Find::Opt);
    &$createOptionsWithArgs(qw(LongOpt));
    pad2descIsDetected(\@lines, \&Opts::Find::Opt);
    &$createOptionsWithArgs(qw(Command));
    pad2descIsDetected(\@lines, \&Opts::Find::Command);
};

subtest "Detect if CLI args contain all mandatory arguments for an option" => sub {
  my @testdata = (
    [ Opt("--test", 1, 1), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(1) ],
    [ Opt("--test", 1, 1), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(1) ],
    [ Opt("--test", 1, 1), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(1) ],
    [ Opt("--test", 1, 1), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(0) ],
    [ Opt("--test", 1, 1), CliArgs('--test', qw(cmd --test ASD XY         )), NeedsArgs(0) ],

    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(2) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(2) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(2) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(1) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test ASD ABC        )), NeedsArgs(1) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test ASD ABC), ''   ) , NeedsArgs(0) ],
    [ Opt("--test", 2, 1), CliArgs('--test', qw(cmd --test ASD ABC XY     )), NeedsArgs(0) ],

    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(3) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(3) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(3) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(2) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD ABC        )), NeedsArgs(2) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD ABC), ''   ) , NeedsArgs(1) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD ABC XY     )), NeedsArgs(1) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD ABC XY), '') , NeedsArgs(0) ],
    [ Opt("--test", 3, 1), CliArgs('--test', qw(cmd --test ASD ABC XY ZZZ)) , NeedsArgs(0) ],
  );
  for (@testdata) {
      my ($opt, $cliargs, $needsargs) = @$_;
      my $na = helptext::completer::needs_args($opt, $cliargs->{optindex}, $cliargs->{cliargs}, $cliargs->{curarg});
      is($na, $needsargs, "Expected $opt->{name} with $opt->{numArgs} args '$opt->{args}' needs" 
                  . " $needsargs args for CLI call: [" . join("] [", @{$cliargs->{cliargs}}).']'
          );
  }
};

subtest "Detect if CLI args contain all optional arguments for an option" => sub {
  my @testdata = (
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(0) ],
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(1) ],
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(1) ],
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(0) ],
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test ASD XY         )), NeedsArgs(0) ],
    [ Opt("--test", 1), CliArgs('--test', qw(cmd --test -              )), NeedsArgs(0) ],

    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(0) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(2) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(2) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(0) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test ASD ABC        )), NeedsArgs(1) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test ASD ABC), ''   ) , NeedsArgs(0) ],
    [ Opt("--test", 2), CliArgs('--test', qw(cmd --test ASD ABC XY     )), NeedsArgs(0) ],

    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test), ''           ) , NeedsArgs(0) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test =), ''         ) , NeedsArgs(3) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD            )), NeedsArgs(3) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD), ''       ) , NeedsArgs(0) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD ABC        )), NeedsArgs(2) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD ABC), ''   ) , NeedsArgs(0) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD ABC XY     )), NeedsArgs(1) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD ABC XY), '') , NeedsArgs(0) ],
    [ Opt("--test", 3), CliArgs('--test', qw(cmd --test ASD ABC XY ZZZ)) , NeedsArgs(0) ],
  );
  for (@testdata) {
      my ($opt, $cliargs, $needsargs) = @$_;
      my $na = helptext::completer::needs_args($opt, $cliargs->{optindex}, $cliargs->{cliargs}, $cliargs->{curarg});
      is($na, $needsargs, "Expected $opt->{name} with $opt->{numArgs} args '$opt->{args}' needs" 
                  . " $needsargs args. Actual: $na. CLI call: [" . join("] [", @{$cliargs->{cliargs}}).']'
          );
  }

};

# ---------------------------------------------------------------------------------------
sub Opt { my ($name, $numArgs, $argsAreMandatory) = @_;
    my ($prefix, $suffix) = ('','');
    
    $argsAreMandatory || do { $prefix = '['; $suffix = ']' };

    new Opts::Option({ 
        name => $name,
        args => join(' ', map { $prefix.'opt-'.$_.$suffix } (1..$numArgs)),
     });
}

sub CliArgs { my ($optname, @cliargs) = (shift, @_);
    my $i = -1;
    my $cliargs = {
        cliargs  => \@cliargs,
        curarg   => $cliargs[-1],
        optindex => map  { $_->[0] } 
                    grep { $optname eq $_->[1] } 
                    map  { $i++; [$i, $_] } 
                    @cliargs
    }
}

sub NeedsArgs { $_[0] }

sub optArgsAreDetected { my ($lines, $func2test, $checkfunc) = @_;
    my $opt;
    foreach my $linedef (@$lines) {
            my ($line, $expectedVal) = @{$linedef};
        $opt = &$func2test(\$line);
        chomp($line);
        ok($opt, "An option should be detected in line: [$line]") || return;
        &$checkfunc($opt, $expectedVal, \$line)
    }
}

sub numArgIsDetected { my ($lines, $func2test) = @_;
    optArgsAreDetected( $lines, $func2test, 
        sub { my ($opt, $expResult, $line) = @_;
            is ($opt->{numArgs}, $expResult, 
                "Expect $expResult args. Actual args are [$opt->{args}] ".
                "for $opt->{name} in line: [$$line]")
        }
    )
}

sub optionalArgsAreDetected { my ($lines, $func2test) = @_;
    optArgsAreDetected( $lines, $func2test, 
        sub { my ($opt, $expResult, $line) = @_;
            is ($opt->{hasOptArgs}, $expResult, 
                "Expect has optional args: $expResult. Actual args are [$opt->{hasOptArgs}] ".
                "for $opt->{name} in line: [$$line]")
        }
    )
}

sub pad2descIsDetected { my ($lines, $func2test) = @_;
    optArgsAreDetected( $lines, $func2test, 
        sub { my ($opt, $expResult, $line) = @_;

            is $opt->{pad2Desc}, $expResult, 
                "Expected description at position $expResult. ".
                "Actual position [$opt->{pad2Desc}] for $opt->{name}.\n".
                "  Line       : [${$line}]\n".
                "  Args       : [$opt->{args}]\n".
                "  Description: ".($opt->{isCmd}?"CMD: ":"OPT: ")."[$opt->{desc}]\n"
        }
    )
}

1;