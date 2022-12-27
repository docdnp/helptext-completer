package Test::Redirection;
use Test::More;
use strict;
use warnings;

subtest "Redirect command and subcommand completion to external completers" => sub {
    setup ({
        REDIRECT_CMD                        => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD                   => 'othertool_or_shellfunc',
        REDIRECT_CMD_SUBCMD1                => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD_SUBCMD1           => 'othertool_or_shellfunc',
        REDIRECT_CMD_SUBCMD1_SUBCMD2        => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD_SUBCMD1_SUBCMD2   => 'othertool_or_shellfunc',
    });

    subtest "No redirection for unregistered commands." => sub {
        my @testdata = map { $_->{noredirect} = 1; $_ }
        (
            new_test ('otherapp', [qw(otherapp)], []),
            new_test ('anytool' , [qw(anytool)] , []),
            new_test ('cooltool', [qw(cooltool)] , []),
        );
        test_redirection (\@testdata);
    };

    subtest "Redirect the main command (without opts and subcommands)" => sub {
        my @testdata = (
            new_test ('cmd', [qw(cmd)], 
                [qw(<<HT_REDIRECT>> 2 anytool_or_shellfunc cmd)]),
            new_test ('othercmd', [qw(othercmd)], 
                [qw(<<HT_REDIRECT>> 2 othertool_or_shellfunc othercmd)]),
        );
        test_redirection (\@testdata);
    };

    subtest "Redirect the main command (having opts and subcommands)" => sub {
        my @testdata = (
            new_test ('cmd', [qw(cmd  --opt with-arg --noarg-opt)], 
                [qw(<<HT_REDIRECT>> 2 anytool_or_shellfunc cmd)]),
            new_test ('cmd', [qw(cmd  with-subcmd --and-subcmd-opt)], 
                [qw(<<HT_REDIRECT>> 2 anytool_or_shellfunc cmd)]),
            new_test ('othercmd', [qw(othercmd --withopt)], 
                [qw(<<HT_REDIRECT>> 2 othertool_or_shellfunc othercmd)]),
        );
        test_redirection (\@testdata);
    };

    subtest "Redirect sub commands" => sub {
        my @testdata = (
            new_test ('cmd subcmd1', [qw(cmd subcmd1)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd subcmd1)]),
            new_test ('othercmd subcmd1', [qw(othercmd subcmd1)],
                [qw(<<HT_REDIRECT>> 3 othertool_or_shellfunc othercmd subcmd1)]),
            new_test ('cmd subcmd1 subcmd2', [qw(cmd subcmd1 subcmd2)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 subcmd2)]),
            new_test ('othercmd subcmd1 subcmd2', [qw(othercmd subcmd1 subcmd2)],
                [qw(<<HT_REDIRECT>> 4 othertool_or_shellfunc othercmd subcmd1 subcmd2)]),
        );
        test_redirection (\@testdata);
    };

    subtest "Redirect sub commands (having arbitrary opts overall)" => sub {
        my @testdata = (
            new_test ('cmd subcmd1', [qw(cmd --anyopt subcmd1)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd subcmd1)]),
            new_test ('cmd subcmd1', [qw(cmd --anyopt subcmd1 --anysubcmdopt with-arg)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd subcmd1)]),
            new_test ('othercmd subcmd1', [qw(othercmd --someopt --otheropt arg subcmd1 --subcmdopt)],
                [qw(<<HT_REDIRECT>> 3 othertool_or_shellfunc othercmd subcmd1)]),
            new_test ('cmd subcmd1 subcmd2', [qw(cmd --opt1 -a arg subcmd1 -b -c -d subcmd2 --hello)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 subcmd2)]),
            new_test ('othercmd subcmd1 subcmd2', [qw(othercmd -a -b -c --subcmd1 subcmd1 -a -b -c subcmd2)],
                [qw(<<HT_REDIRECT>> 4 othertool_or_shellfunc othercmd subcmd1 subcmd2)]),
        );
        test_redirection (\@testdata);
    };

    teardown();
};

subtest "Redirect option argument completion to external completers" => sub {
    setup ({
        REDIRECT_CMD__OPT1                   => 'anytool_or_shellfunc',
        REDIRECT_CMD__X                      => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD__OPTA              => 'othertool_or_shellfunc',
        REDIRECT_OTHERCMD__OPTB              => 'othertool_or_shellfunc',
        REDIRECT_CMD_SUBCMD1__OPT1           => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD_SUBCMD1__OPT3      => 'othertool_or_shellfunc',
        REDIRECT_CMD_SUBCMD1_SUBCMD2__A      => 'anytool_or_shellfunc',
        REDIRECT_OTHERCMD_SUBCMD1_SUBCMD2__B => 'othertool_or_shellfunc',
        REDIRECT_OTHERCMD_SUBCMD1_SUBCMD2__C => 'othertool_or_shellfunc',
    });

    subtest "Redirect specific opts of main command" => sub {
        my @testdata = (
            new_test ('cmd', [qw(cmd --opt1)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd --opt1)], 
                '--opt1'),
            new_test ('cmd', [qw(cmd -X)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd -X)], '-X'),
            new_test ('othercmd', [qw(othercmd --opta)],
                [qw(<<HT_REDIRECT>> 3 othertool_or_shellfunc othercmd --opta)], 
                '--opta'),
            new_test ('othercmd', [qw(othercmd --optb)],
                [qw(<<HT_REDIRECT>> 3 othertool_or_shellfunc othercmd --optb)], 
                '--optb'),
            new_test ('cmd', [qw(cmd --opt1 1stOf2Args)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd --opt1 1stOf2Args)], 
                '--opt1', 2, 1),
            new_test ('cmd', [qw(cmd --opt1 1stOf3Args 2stOf3Args)],
                [qw(<<HT_REDIRECT>> 5 anytool_or_shellfunc cmd --opt1 1stOf3Args 2stOf3Args)], 
                '--opt1', 3, 2),
        );
        test_redirection (\@testdata);
    };

    subtest "Redirect specific opts of sub commands" => sub {
        my @testdata = (
            new_test ('cmd subcmd1', [qw(cmd subcmd1 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt1)], 
                '--opt1'),
            new_test ('cmd subcmd1', [qw(cmd --anyopt andstuff subcmd1 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt1)], 
                '--opt1'),
            new_test ('othercmd subcmd1', [qw(othercmd subcmd1 --opt3)],
                [qw(<<HT_REDIRECT>> 4 othertool_or_shellfunc othercmd subcmd1 --opt3)],
                '--opt3'),
            new_test ('othercmd subcmd1', [qw(othercmd --otheropt -x subcmd1 -z 1 --opt3)],
                [qw(<<HT_REDIRECT>> 4 othertool_or_shellfunc othercmd subcmd1 --opt3)],
                '--opt3'),
            new_test ('cmd subcmd1 subcmd2', [qw(cmd subcmd1 subcmd2 -A)],
                [qw(<<HT_REDIRECT>> 5 anytool_or_shellfunc cmd subcmd1 subcmd2 -A)], 
                '-A'),
            new_test ('othercmd subcmd1 subcmd2', [qw(othercmd subcmd1 subcmd2 -B)],
                [qw(<<HT_REDIRECT>> 5 othertool_or_shellfunc othercmd subcmd1 subcmd2 -B)],
                '-B'),
            new_test ('othercmd subcmd1 subcmd2', [qw(othercmd subcmd1 subcmd2 -C)],
                [qw(<<HT_REDIRECT>> 5 othertool_or_shellfunc othercmd subcmd1 subcmd2 -C)],
                '-C'),
        );
        test_redirection (\@testdata);
    };

    subtest "Don't redirect main command options that don't need args" => sub {
        my @testdata = (
            new_test ('cmd', [qw(cmd --opt1)]                , [], '--opt1', 0),
            new_test ('cmd', [qw(cmd --opt1 arg1of1)]        , [], '--opt1', 1, 1),
            new_test ('cmd', [qw(cmd --opt1 arg1of2 arg2of2)], [], '--opt1', 2, 2),
        );
        test_redirection (\@testdata);
    };
    teardown();
};

subtest "Redirect option argument completion for options in any occurence" => sub {
    setup ({
        REDIRECT_CMD__ANY__OPT1 => 'anytool_or_shellfunc',
    });

    subtest "Redirect a single opts everywhere" => sub {
        my @testdata = (
            new_test ('cmd', [qw(cmd --opt1)],
                [qw(<<HT_REDIRECT>> 3 anytool_or_shellfunc cmd --opt1)], 
                '--opt1'),
            new_test ('cmd subcmd1', [qw(cmd subcmd1 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt1)], 
                '--opt1'),
            new_test ('cmd subcmd2', [qw(cmd subcmd2 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd2 --opt1)], 
                '--opt1'),
        );
        test_redirection (\@testdata);
    };

    teardown();
};

subtest "Redirect option argument completion for a option occuring at any subcommand " => sub {
    setup ({
        REDIRECT_CMD__ANY__OPT1 => 'anytool_or_shellfunc',
        REDIRECT_CMD__ANY__OPT2 => 'anytool_or_shellfunc',
        REDIRECT_CMD__ANY__OPT3 => 'anytool_or_shellfunc',
        REDIRECT_CMD__OPT1      => 'false',
        REDIRECT_CMD__OPT2      => 'no',
        REDIRECT_CMD__OPT3      => "0",
    });

    subtest "Redirect a single opts for all sub commands" => sub {
        my @testdata = 
        map { 
                $_->{cmdctx}->{cmd} eq 'cmd' 
                    && ($_->{noredirect} = 1);
                $_
            }
        (
            new_test ('cmd', [qw(cmd --opt1)], [], '--opt1'),
            new_test ('cmd', [qw(cmd --opt2)], [], '--opt2'),
            new_test ('cmd', [qw(cmd --opt3)], [], '--opt3'),
            new_test ('cmd subcmd1', [qw(cmd subcmd1 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt1)], 
                '--opt1'),
            new_test ('cmd subcmd2', [qw(cmd subcmd2 --opt1)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd2 --opt1)], 
                '--opt1'),
            new_test ('cmd subcmd1', [qw(cmd subcmd1 --opt2)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt2)], 
                '--opt2'),
            new_test ('cmd subcmd1', [qw(cmd subcmd1 --opt3)],
                [qw(<<HT_REDIRECT>> 4 anytool_or_shellfunc cmd subcmd1 --opt3)], 
                '--opt3'),

        );
        test_redirection (\@testdata);
    };

    teardown();
};

# ---------------------------------------------------------------------------------------
my @env;

sub setup { my $env = shift;
    while (my ($e, $v) = each %$env) {
        push @env, $e;
        $ENV{'HT_'.$e} = $v;
    }
    unittests::load_completer();
}

sub teardown {
    for (@env) { delete $ENV{'HT_'.$_} }
    unittests::load_completer();
}

sub new_test {my ($ctxcmd, $cliargs, $expresult, $optname, $maxargs, $curargs) = @_;
    my $ctxenvns = $ctxcmd;
    my $appname  = $ctxcmd;
    my $i = -1;
    $maxargs  = (defined $maxargs ? $maxargs : 1);
    $curargs  = (defined $curargs ? $curargs : 0);
    $ctxenvns =~ s/[-\s]/_/g;
    $appname  =~ s/\s.+//; 
    { cliargs           => $cliargs, 
      app               => $appname,
      compresults       => [],
      cmdctx            => { cmd => $ctxcmd, envns => $ctxenvns },
      opt               => ($optname 
                            ? new Option ({name      => $optname, 
                                           needsArgs => $maxargs-$curargs,
                                           args      => join(' ', map { 'opt'.$_ } (1..$maxargs)),
                                           cliindex  => [
                                                map  { $_->[0] } 
                                                grep { $_->[1] eq $optname } 
                                                map  { [++$i, $_] } @$cliargs
                                                ] -> [-1]
                                          })
                            : 0),
      expected_result   => $expresult }
}

sub test_redirection { my $testdata = shift;
    foreach my $td (@$testdata) {
        my $results = helptext::completer::redirect ( 
            $td->{compresults}, $td->{cmdctx}, $td->{cliargs}, $td->{opt}
        );

        ok(1, "--------------------------------------------------------------");
        is(scalar(@$results), @{$td->{expected_result}}, 
            "Expect redirection result with " . @{$td->{expected_result}} . 
            " items. Actual: ". scalar(@$results).". CLI args: [".join('] [', @{$td->{cliargs}}).']');
        $td->{noredirect} && do {
            my $optname     = $td->{opt} ? '__'.uc($td->{opt}->{name}) : '';
            my $app         = uc($td->{app});
               $optname     =~ s/-//g;
            my $redirect    = main::redirectOptFromEnv($td->{opt}, "", $td->{cmdctx}->{envns}, $td->{app});
            ok(!$redirect, "No redirection as no env entry HT_REDIRECT_${app}_*$optname exists.")
                && next;
        };
        $td->{opt} && ! $td->{opt}->{needsArgs} && do {
            ok(!@$results, "No redirection as opt $td->{opt}->{name} doesn't need args.");
            next;
        };
        ok (@$results, "Expect redirection result") || next;
        is($results->[0]->{name}, '<<HT_REDIRECT>>', 
            "Expect <<HT_REDIRECT>> list. ".
            "Actual: $results->[0]->{name}");
        foreach my $i (1..@$results-1) {
            is( $results->[$i]->{name}, $td->{expected_result}->[$i], 
                "Expect value for redirection item $i is $td->{expected_result}->[$i]. " . 
                "Actual: $results->[$i]->{name}");
        }
    }
}

1;
