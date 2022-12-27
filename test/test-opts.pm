package Test::Opts;
use Test::More;
use strict;
use warnings;

Use::As 'unittests::MAX_REPS'              => '.MAX_REPS';
Use::As 'Testdata::Create::ShortOpt'       => 'mk::sopt';
Use::As 'Testdata::Create::LongOpt'        => 'mk::lopt';
Use::As 'Testdata::Create::Whitespaces'    => 'mk::blanks';
Use::As 'Testdata::Create::Whitespaces'    => 'mk::padding';
Use::As 'Testdata::Create::RandomWords'    => 'mk::descr';
Use::As 'Testdata::Create::RandomOptDelim' => 'mk::delim';
Use::As 'Testdata::Create::RandomArg'      => 'mk::arg';

sub testData {
    return (
    [ q(   -w   )                                                   , { name => '-w', numArgs => 0, args => '' } ],
    [ q( -w   )                                                     , { name => '-w', numArgs => 0, args => '' } ],
    [ q(  -w   )                                                    , { name => '-w', numArgs => 0, args => '' } ],
    [ q(   -w)                                                      , { name => '-w', numArgs => 0, args => '' } ],
    [ q(   -w  ARG1    )                                            , { name => '-w', numArgs => 1, args => 'ARG1' } ],
    [ q(   -w=ARGEQ    )                                            , { name => '-w', numArgs => 1, args => 'ARGEQ' } ],
    [ q(   -w=ARGCOMMA, ASD           asdsad dsasa dssadas )        , { name => '-w', numArgs => 1, args => 'ARGCOMMA' } ],
    [ q(   -w=ARGCOMMA, ASD asdsad dsasa dssadas )                  , { name => '-w', numArgs => 1, args => 'ARGCOMMA' } ],
    [ q(   -w=ARGCOMMA,NOSPACE1    )                                , { name => '-w', numArgs => 1, args => 'ARGCOMMA,NOSPACE1' } ],
    [ q(   -w=ARGCOMMA:NOSPACE2    )                                , { name => '-w', numArgs => 1, args => 'ARGCOMMA:NOSPACE2' } ],
    [ q(   -w=ARGCOMMA NOSPACE3    )                                , { name => '-w', numArgs => 1, args => 'ARGCOMMA' } ],
    [ q(   -w  ARGCOMMA NOSPACE4    )                               , { name => '-w', numArgs => 2, args => 'ARGCOMMA NOSPACE4' } ],
    [ q(   -w  ARG1)                                                , { name => '-w', numArgs => 1, args => 'ARG1' } ],
    [ q(   -w  [ARG2] )                                             , { name => '-w', numArgs => 1, args => '[ARG2]' } ],
    [ q(   -w  [ARG2 ] )                                            , { name => '-w', numArgs => 1, args => '[ARG2' } ],
    [ q(   -w  [ARG2 )                                              , { name => '-w', numArgs => 1, args => '[ARG2' } ],
    [ q(   -w  <ARG3> )                                             , { name => '-w', numArgs => 1, args => '<ARG3>' } ],
    [ q(   -w    asd asd 4444)                                      , { name => '-w', numArgs => 3, args => 'asd asd 4444' } ],
    [ q(   -w    asd asd asd dasf 231 v 5555)                       , { name => '-w', numArgs => 7, args => 'asd asd asd dasf 231 v 5555' } ],
    [ q(   -w --wdas ARG      asdsad dsad sd d as  66666)           , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w --wdas <arg>       asdsad dsad sd d as  66666)        , { name => '-w', numArgs => 1, args => '<arg>' } ],
    [ q(   -w ARG, --wdas ARG       asdsad dsad sd d as  7777)      , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w, --wdas ARG         asdsad dsad sd d as  8888)        , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w, --wdas   asdsad dsad sd d as  9999)                  , { name => '-w', numArgs => 6, args => 'asdsad dsad sd d as  9999' } ],
    [ q(   -w| --wdas  (ArG)       asdsad dsad sd d as  9999)       , { name => '-w', numArgs => 1, args => '(ArG)' } ],
    [ q(   -w|--wdas  (ArG)      asdsad dsad sd d as  9999)         , { name => '-w', numArgs => 1, args => '(ArG)' } ],
    [ q(   -w,   --wdas [ARG]       asdsad dsad sd sdAS 10)         , { name => '-w', numArgs => 1, args => '[ARG]' } ],
    [ q(   -w   --wdas [ARG]       asdsad dsad sd d as asd  11)     , { name => '-w', numArgs => 1, args => '[ARG]' } ],
    [ q(   -w   --wdas [ARG1] [ARG2]       asdsad dsad 1 11 11)     , { name => '-w', numArgs => 2, args => '[ARG1] [ARG2]' } ],
    [ q(   -w,   --wdas <ArG1> (ArG2)       asdsad dsad sd d XASA)  , { name => '-w', numArgs => 2, args => '<ArG1> (ArG2)' } ],
    [ q(   -w   --wdas ARG1 ARG2        asdsad dsad sd d as  )      , { name => '-w', numArgs => 2, args => 'ARG1 ARG2' } ],
    [ q(   -w   --wdas ARG1, ARG2        asdsad dsad sd d as  11 )  , { name => '-w', numArgs => 2, args => 'ARG1, ARG2' } ],
    [ q(   -w|  --wdas ARG1 aRG2        asdsad dsad sd d as  11 1)  , { name => '-w', numArgs => 2, args => 'ARG1 aRG2' } ],
    [ q(   -w arg, --wdas=ARGEQ    asdsad dsad sd d as  7777)       , { name => '-w', numArgs => 1, args => 'arg' } ],
    [ q(   -w ARG, --wdas=ARGEQ, NOSPACE1    asdsad dsad sd )       , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w ARG, --wdas=ARGEQ,NOSPACE2    asdsad dsad sd d)       , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w ARG, --wdas=<ARGEQ>,(NOSPACE2)    asdsad dsad sd)     , { name => '-w', numArgs => 1, args => 'ARG' } ],
    [ q(   -w xxx           sadsd asd sd asdd   asdsad dsad sd)     , { name => '-w', numArgs => 1, args => 'xxx' } ],
    [ q(   -w[=xxx]         sadsd asd sd asdd   asdsad dsad sd)     , { name => '-w', numArgs => 1, args => 'xxx' } ],
    [ q(   -w [xxx:]XY:123            sd asdd   asdsad dsad sd)     , { name => '-w', numArgs => 1, args => '[xxx:]XY:123' } ],
    [ q(   -w[<arg1,arg2,...>], --wdas          asdsad asdsad)      , { name => '-w', numArgs => 1, args => '[<arg1,arg2,...>]' } ],
    [ q(   -w<arg1> --wdas          asdsad asdsad)                  , { name => '-w', numArgs => 1, args => '<arg1>' } ],
    [ q(   -w<n> --wdas          asdsad asdsad)                     , { name => '-w', numArgs => 1, args => '<n>' } ],
    [ q(   -w[n] --wdas          asdsad asdsad)                     , { name => '-w', numArgs => 1, args => '[n]' } ],
    [ q(   -w/pattern/ --wdas          asdsad asdsad)               , { name => '-w', numArgs => 1, args => '/pattern/' } ],
    [ q(   -w      like --wdas but does not accept an argument)     , { name => '-w', numArgs => 0, args => '' } ],
    [ q(   -w, -a, -b      asdsad sad sad s accept an argument)     , { name => '-w', numArgs => 0, args => '', 
                                                                        numNextOpts => 2, nextopts => [qw(-a -b)] } ],
    [ q(   -w <ARG>, --a1, -b      asds sad sad s accept an ar)     , { name => '-w', numArgs => 1, args => '<ARG>', 
                                                                        numNextOpts => 2, nextopts => [qw(--a1 -b)] } ],
    [ q(   -w --a1 <ARG> -b, --c2     asds sad  accept an ar)       , { name => '-w', numArgs => 1, args => '<ARG>', 
                                                                        numNextOpts => 3, nextopts => [qw(--a1 -b --c2)] } ],

    );
}

subtest "ShortOpt: Different patterns" 
    => sub { testDifferentPatterns(\&testData) };
subtest "LongOpt: Different patterns"  
    => sub { testDifferentPatterns(sub { toLongOpt(\&testData)}) };
subtest "ShortOpt: Discard detection when indentation is too low" 
    => sub { testDiscardDetectionOnTooLowIndentation(\&testData) };
subtest "LongOpt: Discard detection when indentation is too low" 
    => sub { testDiscardDetectionOnTooLowIndentation(sub { toLongOpt(\&testData)}) };
subtest "ShortOpt: Discard detection when indentation is too high" 
    => sub { testDiscardDetectionOnTooHighIndentation(\&testData) };
subtest "LongOpt: Discard detection when indentation is too high" 
    => sub { testDiscardDetectionOnTooHighIndentation(sub { toLongOpt(\&testData)}) };
subtest "Config: ShortOpt: User changes padding: HT_PADDING_MIN/HT_PADDING_MAX" 
    => sub { testUserChangesPadding(\&testData) };
subtest "Config: LongOpt: User changes padding: HT_PADDING_MIN/HT_PADDING_MAX" 
    => sub { testUserChangesPadding(sub { toLongOpt(\&testData)}) };

subtest "Detect random long or short opts followed by random long or short opt" => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Tests include:
     |    * Any opt followed by any opt followed by any opt
     |    * Any opt means: any long or short opt
     |    * A third opt is added randomly
    # ===============================================================================
    EOT

    my @lines = ();
    my @bracketTypes = qw([] () {} <>);
    for (1..MAX_REPS()) {
        my $opt         = {name=> int(rand(2)) ? mk::sopt() : mk::lopt()};
        my $bracketType = $bracketTypes[int(rand(5))];
        my $numArgs     = int(rand(4));
        my $args        = join('', map { mk::arg(0, $bracketType).mk::blanks(3) } (1..$numArgs));
           $args        =~ s/\s*$//g; 
           $args        =~ s/\n//g; 
        my $argFlag     = int(rand(2));
        my $description = mk::descr (30,40);
           $description =~ s/^\s*//g;
        my $delim       = mk::delim();
        my $nopt        = int(rand(2)) ? mk::lopt() : mk::sopt();
        my $nnopt       = int(rand(2)) ? mk::lopt() : mk::sopt();
        my $useNnopt    = int(rand(2));
        my $firstArgs   =  ($argFlag && $args ? ' '.$args : '');
        my $nextArgs    = (!$argFlag && $args ? ' '.$args : '');
        my $line        = mk::padding(10)
                            . $opt->{name} 
                            . $firstArgs
                            . $delim
                            . mk::blanks(3)
                            . $nopt
                            . $nextArgs
                            . ($useNnopt ? ' '.$nnopt.$nextArgs : '')
                            . mk::blanks(5, 10)
                            . $description . "\n";
        push @lines, [$line, { %$opt, 
            desc => $description, numArgs => ($args?$numArgs:0), 
            delim => $delim, argFlag => $argFlag, 
            nextName => $nopt, nextNextName => $nnopt,
            args => $args, firstArgs => $args, nextArgs => $nextArgs,
            useNnopt => $useNnopt
        }];
    }
    foreach my $lineDef (@lines) {
        my ($line, $optSpec) = @$lineDef; 
        my $opt = Opts::Find::Opt(\$line);
        chomp($line);
        ok(1,'----------------------');
        ok($opt, "Accept option $optSpec->{name} ($optSpec->{delim}) in line: [$line]") || next;
        is($opt->{name}, $optSpec->{name}, "Expected name $optSpec->{name}. Actual is $opt->{name}.");
        is($opt->{desc}, $optSpec->{desc}, "Expected description '$optSpec->{desc}'. Actual is '$opt->{desc}'.");
        is($opt->{numArgs}, $optSpec->{numArgs}, "Expected arg count $optSpec->{numArgs}. Actual is $opt->{numArgs}. Args:  [$opt->{args}]");
        ok($opt->{next}, "Option $optSpec->{name} has next option.");
        is($opt->{next}->{name}, $optSpec->{nextName}, "Expected next opt's name $optSpec->{nextName}. Actual is $opt->{next}->{name}");
        is($opt->{next}->{args}, $optSpec->{firstArgs}, "Expected next opt's args '$optSpec->{firstArgs}'. Actual is '$opt->{next}->{args}'");
        if ($optSpec->{useNnopt}) {
            ok($opt->{next}->{next}, "Next option $optSpec->{nextName} has also next option.");
            is($opt->{next}->{next}->{name}, $optSpec->{nextNextName}, "Expected next-next opt's name $optSpec->{nextNextName}. Actual is $opt->{next}->{next}->{name}");
            is($opt->{next}->{next}->{args}, $optSpec->{firstArgs}, "Expected next-next opt's args '$optSpec->{firstArgs}'. Actual is '$opt->{next}->{next}->{args}'");
        }
    }
};

subtest "Detect prefixed long opts like --[no-]rename-empty" => sub {
    my @lines = (
     [ q(  --[no-]greet arg       asd asd asd), { opts => [qw(--no-greet --greet)] } ],
     [ q(  --[any]thing        asd asd asddda), { opts => [qw(--anything --thing)] } ],
     [ q(  --[what]ever        asd asd asdass), { opts => [qw(--whatever --ever )] } ],
     [ q(  --[no-]greet arg --test      asasd), { opts => [qw(--no-greet --greet --test)] } ],
     [ q(  --[any]thing --test        asd asd), { opts => [qw(--anything --thing --test)] } ],
     [ q(  --[what]ever --test       asd asad), { opts => [qw(--whatever --ever --test)] } ],
     [ q(  --[no-]greet --[no-]test      sasd), { opts => [qw(--no-greet --greet --no-test --test)] } ],
     [ q(  --[any]thing --[no-]test       asd), { opts => [qw(--anything --thing --no-test --test)] } ],
     [ q(  --[what]ever --[no-]test      asda), { opts => [qw(--whatever --ever --no-test --test)] } ],
     [ q(  --[no-]greet --[no-]test -a     sd), { opts => [qw(--no-greet --greet --no-test --test -a)] } ],
     [ q(  --[any]thing --[no-]test -b     sd), { opts => [qw(--anything --thing --no-test --test -b)] } ],
     [ q(  --[what]ever --[no-]test -c     da), { opts => [qw(--whatever --ever --no-test --test -c)] } ],
     [ q(  --[no-]greet -a --[no-]test     sd), { opts => [qw(--no-greet --greet -a --no-test --test)] } ],
     [ q(  --[any]thing -b --[no-]test     sd), { opts => [qw(--anything --thing -b --no-test --test)] } ],
     [ q(  --[what]ever -c --[no-]test     da), { opts => [qw(--whatever --ever -c --no-test --test)] } ],
    );
    foreach my $lineDef (@lines) {
        ok(1,"------------------------");
        my ($line, $optSpec) = @$lineDef; 
        my $expectedNumOfChainedOpts = scalar(@{$optSpec->{opts}});
        my $chainCnt = 0;
        my $opt = Opts::Find::Opt(\$line);
        foreach my $expectedOpt (@{$optSpec->{opts}}) {
            is($opt->{name}, $expectedOpt, 
                 "Expect opt $expectedOpt. Actual: $opt->{name}");
            $opt->{next} && ($opt = $opt->{next});
            $chainCnt++;
        }
        is($chainCnt, $expectedNumOfChainedOpts,
             "Expected ".scalar(@{$optSpec->{opts}}." prefixed and chained opts. Actual: "
             .$chainCnt));
    }
};

# ---------------------------------------------------------------------------------------
sub toLongOpt { my $dataFunc = shift;
    return map {
        $_->[0] =~ s/\-\-wdas/-n/g;
        $_->[0] =~ s/ \-w/ --wdas/g;
        $_->[1]->{name} = '--wdas';
        $_
    } $dataFunc->()
}

sub testDifferentPatterns { my $dataFunc = shift;
    foreach my $lineDef ($dataFunc->()) {
        my ($line, $optSpec) = @$lineDef; 
        my $opt = Opts::Find::Opt(\$line); 
        ok(1,'----------------------');

        ok($opt!=0, "Detect any short option in line:\n\t[$line]") || next;

        is($opt->{name}, $optSpec->{name}, 
            "Expect short option [$optSpec->{name}]. Actual is [$opt->{name}]."
        );

        is($opt->{args}, $optSpec->{args}, 
            "Expect args [$optSpec->{args}]. Actual is [$opt->{args}]."
        );

        is($opt->{numArgs}, $optSpec->{numArgs},
            "Expect arg count [$optSpec->{numArgs}]. Actual is [$opt->{numArgs}]."
        );

        no warnings;
        for (1..$optSpec->{numNextOpts}) {
            ok($opt->{next}, "Option $optSpec->{name} has $_ following opt(s).");
            is($opt->{next}->{name}, $optSpec->{nextopts}->[$_-1],
                "Expected follower name: [".$optSpec->{nextopts}->[$_-1]."], Actual name: [$opt->{next}->{name}]");
            $opt = $opt->{next};
        }
    }
}

sub testDiscardDetectionOnTooLowIndentation { my $dataFunc = shift;
    subtest "Accept on default minimal indentation == 1" => sub {
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/ /;
            my $opt = Opts::Find::Opt(\$line);
            ok($opt, "Accept option $optSpec->{name} indented by 1 in line: [$line]");
        }
    };
    subtest "Discard below default minimal indentation < 1" => sub {
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+//;
            my $opt = Opts::Find::Opt(\$line);
            ok(!$opt, "Discard option $optSpec->{name} indented by 0 in line: [$line]");
        }
    };
}

sub testDiscardDetectionOnTooHighIndentation { my $dataFunc = shift;
    subtest "Accept on default maximal indentation == 10" => sub {
        my $indent = ' ' x 10;
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/$indent/;
            my $opt = Opts::Find::Opt(\$line);
            ok($opt, "Accept option $optSpec->{name} indented by $indent in line: [$line]");
        }
    };
    subtest "Discard below default minimal indentation > 10" => sub {
        my $indent = ' ' x (11 + rand(5));
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/$indent/;
            my $opt = Opts::Find::Opt(\$line);
            ok(!$opt, "Discard option $optSpec->{name} indented by $indent in line: [$line]");
        }
    };

}

sub testUserChangesPadding { my $dataFunc = shift;
    subtest "Set to minimal indentation == 5" => sub {
        $ENV{HT_PADDING_MIN} = 5;
        unittests::load_completer;
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            my $opt = Opts::Find::Opt(\$line);
            ok(!$opt, "Discard option $optSpec->{name} at min padding $ENV{HT_PADDING_MIN} in line: [$line]");
        }
        my $indent = ' ' x 5;
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/$indent/;
            my $opt = Opts::Find::Opt(\$line);
            ok($opt, "Accept option $optSpec->{name} at min padding $ENV{HT_PADDING_MIN} in line: [$line]");
        }
        delete $ENV{HT_PADDING_MIN};
        unittests::load_completer;
    };

    subtest "Set to maximal indentation == 5" => sub {
        $ENV{HT_PADDING_MAX} = 5;
        unittests::load_completer;
        my $indent = ' ' x 6;
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/$indent/;
            my $opt = Opts::Find::Opt(\$line);
            ok(!$opt, "Discard option $optSpec->{name} at max padding $ENV{HT_PADDING_MAX} in line: [$line]");
        }
        $indent = ' ' x 4;
        foreach my $lineDef ($dataFunc->()) {
            my ($line, $optSpec) = @$lineDef; 
            $line =~ s/^\s+/$indent/;
            my $opt = Opts::Find::Opt(\$line);
            ok($opt, "Accept option $optSpec->{name} at max padding $ENV{HT_PADDING_MAX} in line: [$line]");
        }
        delete $ENV{HT_PADDING_MAX};
        unittests::load_completer;
    };
}

1;
