package Test::OptFilters;
use Test::More;
use strict;
use warnings;

Use::As 'unittests::MAX_REPS'              => '.MAX_REPS';
Use::As 'Testdata::Create::Command'        => 'mk::cmd';
Use::As 'Testdata::Create::RandomWords'    => 'mk::desc';
Use::As 'Testdata::Create::RandomString'   => 'mk::word';

subtest "Keep only the majority of command candidates sharing the same left padding"
 => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |  We assume that sub commands are described always with the same left padding.
     |
     |  Given input lines:
     |  * most lines starting with same amount of blanks (the good ones),
     |  * some lines starting with slightly more or less blanks, and
     |  * even less lines starting always with less blanks.
     |
     |  Then:
     |  * the minority of lines not starting the same as the majority is
     |  discarded.
     |  
     |  Example(s):
     |      |  cmd-candidate-1 ...     |        
     |      |  cmd-candidate-2 ...     |          |cmd-candidate-1|
     |      |  cmd-candidate-3 ...     |    =>    |cmd-candidate-2|
     |      | cmd-candidate-4 ...      |          |cmd-candidate-3|
     |      |    cmd-candidate-5 ...   |        
    # ===============================================================================
    EOT

    for (1..MAX_REPS()/25) {
        my %numOf = %{{ AllCandidates => int(rand(1500)+3500) }};
        my @lines;
        foreach my $id (1..$numOf{AllCandidates})
        {
            if (int($id) % 5 == 0) { 
                push @lines, mkCmd('SHORT', int(rand(5))+1);
            } elsif (int($id) % 4 == 0) { 
                push @lines, mkCmd('LONG', 8+int(rand(3)));
            } else {
                push @lines, mkCmd('GOOD', 7);
                $numOf{GoodCandidates}++;
            }
        }

        find_possible_candidates_and_keep_only_good_ones(
            \@lines, $numOf{AllCandidates}, $numOf{GoodCandidates}, '', 
            \&Opts::Filter::KeepByMajorityOfEquallyIndented
        )
    }
};

subtest "Discard command candidates matching name of main command"
=> sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |   We assume that it's improbable that a command has its own name as a sub
     |   command.
     | 
     |  Given input lines:
     |  * a main app name
     |  * lines starting like possible candidates but having the main app's name
     |  * lines with real command candidates
     | 
     |  Then:
     |  * only the real command candidates are returned
     | 
     |  Example(s):
     |     |  realcommand-1 text text  ... |        
     |     |  appname other text ...       |          |realcommand-1|
     |     |  realcommand-2 text text ...  |    =>    |realcommand-2|
     |     |  realcommand-3 more text ...  |          |realcommand-3|
     |     |  appname and foo text ...     |        
    # ===============================================================================
    EOT
    for (1..MAX_REPS()/25) {
        my $appName = mk::word(8);
        my %numOf = %{{ AllCandidates => int(rand(20)+20) }};
        my @lines;
        for (1..$numOf{AllCandidates}) {
            if (int(rand(100))%3 == 0) {
                push(@lines, mkCmd("app:$appName"));
                $numOf{BadCandidates}++;
                next
            }
            push(@lines, mkCmd("GOOD"));
        }
        $numOf{GoodCandidates} = $numOf{AllCandidates} - $numOf{BadCandidates};

        find_possible_candidates_and_keep_only_good_ones(
            \@lines, $numOf{AllCandidates}, $numOf{GoodCandidates}, $appName,
            \&Opts::Filter::DiscardIfMatchesName
        )
    }
};

subtest "Keep only the majority of option candidates whose description shares padding"
=> sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |   We assume that description texts for commands or options have all the same 
     |   indentation.
     | 
     |  Given input lines:
     |  * many commands and opts with the same indentation
     |  * some commands and opts with more or less indentation
     | 
     |  Then:
     |  * the minority of commands/opts with deviating indentation is discarded
     | 
     |  Example(s):
     |     |  cmd-or-opt-1 text text  ...   |        
     |     |  cmd-or-opt-2   other text ... |          |cmd-or-opt-1|
     |     |  cmd-or-opt-3 text text ...    |    =>    |cmd-or-opt-3|
     |     |  cmd-or-opt-4   more text ...  |          |cmd-or-opt-5|
     |     |  cmd-or-opt-5 and foo text ... |        
    # ===============================================================================
    EOT
    for (1..MAX_REPS()/25) {
        my %numOf = %{{ AllCandidates => int(rand(20)+20) }};
        my @lines;
        for (1..$numOf{AllCandidates}) {
            if (int(rand(100))%3 == 0) {
                push @lines, mkCmd('BAD', 10, int(rand(10))+($_%2 ? 20 : 31));
                $numOf{BadCandidates}++;
                next
            }
            push @lines, mkCmd('GOOD', 10, 30);
            $numOf{GoodCandidates}++;
        }
        $numOf{AllCandidates} = $numOf{GoodCandidates} + $numOf{BadCandidates};

        find_possible_candidates_and_keep_only_good_ones(
            \@lines, $numOf{AllCandidates}, $numOf{GoodCandidates}, "",
            \&Opts::Filter::KeepByMajoritysDescrPadding
        )
    }
};

subtest "Discard commands with missing neighbors"
=> sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |   We assume that commands are described within sections. We also assume that a 
     |   command's description isn't longer than a given threshold of lines. In case
     |   we find command candidates seeming to be isolated, they might be just part of
     |   arbitrary description texts and can be discarded.
     | 
     |  Given input lines:
     |  * (A) section of commands, followed by
     |  * (B) multiple non-command lines (above the threshold), followed by
     |  * (C) a single command, followed by 
     |  * (D) multiple non-command lines (above the threshold) and repeat 
     | 
     |  Then:
     |  * the single commands are discarded
     | 
     |  Example(s):
     |     |  cmd1 text text  ...      |        
     |     |  cmd2   other text ...    |          |cmd1|
     |     |  cmd3 text text ...       |    =>    |cmd2|
     |     |  ... lines with text ...  |          |cmd3|
     |     |  cmd4 and foo text ...    |        
    # ===============================================================================
    EOT
    helptext::completer::init();
    testDropCmdIfNoNeighbor();
};

subtest "Config: Discard commands with missing neighbors on basis of HT_MAX_CMD_DIST"
=> sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |   It may be necessary for a user to configure the amount of lines allowed 
     |   between two commands to enable correct parsing of specific help files.
     |   It's actually the same test as "Discard commands with missing neighbors",
     |   but based on a configured value for HT_MAX_CMD_DIST.
     |  
     |  Given:
     |  * HT_MAX_CMD_DIST is set
     |  * (A) sections of commands with line distances <= HT_MAX_CMD_DIST, followed by
     |  * (B) sections of commands with line distances  > HT_MAX_CMD_DIST, and repeat
     | 
     |  Then:
     |  * Commands of type (B) are discarded
    # ===============================================================================
    EOT
    $ENV{HT_MAX_CMD_DIST} = 10; 
    unittests::load_completer;

    testDropCmdIfNoNeighbor();

    delete $ENV{HT_MAX_CMD_DIST}; 
    unittests::load_completer;
};

# ---------------------------------------------------------
my ($desc, $cmd, $cnt);
sub setupCmd {
    $cnt++ > 9999 && ($cnt = 0);
    $desc && return;
    $desc = mk::desc(40,80);
    $desc =~ s/^\s+//;
    $cmd = mk::cmd(40,80);
}
sub mkCmd { my ($cmdprefix, $leftpadding, $cmdwidth) = @_;
    setupCmd();
    $leftpadding = ($leftpadding || 10);
    $cmdwidth    = ($cmdwidth    || 20);
    my $tpl = "%${leftpadding}s%-${cmdwidth}s%s";
    my $cmd = $cmdprefix.'-'.substr($cmd,0,8).'-'.$cnt;
    $cmdprefix eq 'no-cmd'   && ($cmd = ''); 
    $cmdprefix =~ /app:(.*)/ && ($cmd = $1); 
    return [sprintf($tpl, '', $cmd, $desc), $cmd];
}

sub find_possible_candidates_and_keep_only_good_ones {
    my ($lines, $numOfAllCandidates, $numOfGoodCandidates, $name, $checkFunc) = @_;
    my ($opt, $trws, @possibleCandidates, $lineno);

    $lineno = 0;
    for(@$lines) {
        $opt = Opts::Find::AnyOpt (\$_->[0], $lineno);
        $opt && push(@possibleCandidates, $opt);
        $lineno++;
    }
    my $numOfPossibleCandidates = scalar(@possibleCandidates);
    is($numOfPossibleCandidates, $numOfAllCandidates, 
        "Detected $numOfPossibleCandidates of $numOfAllCandidates possible candidates.");

    my $goodCandidates = &$checkFunc (\@possibleCandidates, $name);
    my $detectedGoodCandidates = scalar(@possibleCandidates);
    is(scalar(@$goodCandidates), $numOfGoodCandidates, 
        "Accepted $numOfGoodCandidates of $numOfAllCandidates candidates.");

}

sub testDropCmdIfNoNeighbor {
    for (1..MAX_REPS()/25) {
        my %numOf = %{{ AllCandidates => 2*int(rand(10)*2+20) }};
        my @lines;

        my $addGoodCandidate = sub {
            push @lines, mkCmd('GOOD');
            $numOf{GoodCandidates}++;
        };
        my $addAnyLine = sub { my $times = ($_[0] || $ENV{HT_MAX_CMD_DIST});
            for (1..$times) { push @lines, mkCmd('no-cmd') }
        };
        my $addBadCandidate = sub {
            push @lines, mkCmd('BAD');
            $numOf{BadCandidates}++;
            $addAnyLine->();
        };

        for (1..2) {
          int(rand(2)) && $addBadCandidate->();
          for (1..$numOf{AllCandidates}/4) { 
            $addGoodCandidate->();
            $addAnyLine->(int(rand($ENV{HT_MAX_CMD_DIST}-1)+1));
          }
          $addAnyLine->();
          for (1..$numOf{AllCandidates}/4) {
            $addBadCandidate->();
          }
          int(rand(2)) && $addBadCandidate->();
        }
        $numOf{AllCandidates} = $numOf{GoodCandidates} + $numOf{BadCandidates};

        find_possible_candidates_and_keep_only_good_ones(
            \@lines, $numOf{AllCandidates}, $numOf{GoodCandidates}, '', 
            \&Opts::Filter::DropCmdIfNoNeighbor
        )
    }

}

1;