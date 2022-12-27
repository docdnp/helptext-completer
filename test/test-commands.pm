package Test::Commands;
use Test::More;
use strict;
use warnings;

Use::As 'unittests::MAX_REPS'              => '.MAX_REPS';
Use::As 'Testdata::Create::Whitespaces'    => 'mk::ws';
Use::As 'Testdata::Create::FixWhitespaces' => 'mk::fixws';
Use::As 'Testdata::Create::Command'        => 'mk::cmd';
Use::As 'Testdata::Create::RandomWords'    => 'mk::words';
Use::As 'Testdata::Create::RandomString'   => 'mk::word';

subtest "Detect command candidates at start of line"
 => sub {
    print <<~EOT;
    # -------------------------------------------------------------------------------
     |  Motivation:
     |  We want shell completion for CLIs like those of e.g. 'apt' or 'git'.
     |  
     |  Given:
     |  * Lines starting with
     |  - command candidates with 'valid' indentation, followed by
     |  - either a new line, whitespaces only or any text
     |  * Other lines  starting with
     |  - command candidates being too deep indented
     | 
     |  Then:
     |  * Only commands with valid indentation are returned.
     | 
     |  Example(s):
     |      '      command\\n'                      => 'command'
     |      '    command    '                       => 'command'
     |      '  command  any text ...'               => 'command'
     |      '                command  any text ...' => ''
    # ===============================================================================
    EOT

    my @lines = ();
    for (1..MAX_REPS()) {
        my $command = mk::cmd();
        push(@lines, [ mk::ws(10) . $command."\n", $command ])
    }

    subtest "Detect validly indented command at end of lines." => sub {
        foreach my $lineDef (@lines) {
            my ($line, $expResult) = @$lineDef;
            my $cmd = Opts::Find::Command(\$line);
            is($cmd->{name}, $expResult, "Find command [$expResult] at beginning of line: [$line]" );
        }
    };
    subtest "Detect validly indented command candidates blanks only." => sub {
        foreach my $lineDef (@lines) {
            my ($line, $expResult) = @$lineDef;
            my  $whitespaces       = mk::ws(10);

            chomp($line);
            my $cmd = Opts::Find::Command(\"$line$whitespaces");
            is($cmd->{name}, $expResult, "Find command [$expResult] at beginning of line: [$line$whitespaces]" );
        }
    };
    subtest "Detect validly indented command candidates followed by any text." => sub {
        foreach my $lineDef (@lines) {
            my ($line, $expResult) = @$lineDef;
            my  $anytext           = mk::words(40,80);

            chomp($line);
            my $cmd = Opts::Find::Command(\"$line $anytext");
            is($cmd->{name}, $expResult, "Find command [$expResult] at beginning of line: [$line $anytext]" );
        }
    };    

    subtest "Discard command candidates that are indented too deep." => sub {
        foreach my $lineDef (@lines) {
            my ($line, $expResult) = @$lineDef;
            my  $anytext           = mk::words(40,80);
            my  $highIndentation   = mk::fixws(10);

            chomp($line);
            my $cmd = Opts::Find::Command(\"$highIndentation$line $anytext");
            ok(!$cmd, "Discard too highly indented command [$expResult] in line: [$highIndentation$line $anytext]");
        }
    };    

};


1;