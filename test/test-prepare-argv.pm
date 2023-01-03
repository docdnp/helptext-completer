package Test::PrepareArgv;
use Test::More;
use strict;
use warnings;

subtest "Current cursor position at first character of current word" => sub {
    test_prepare_argv(0);
};

subtest "Current cursor position directly before current word" => sub {
    test_prepare_argv('before');
};

subtest "Current cursor position within current word" => sub {
    test_prepare_argv('inbetween');
};

# ---------------------------------------------------------
sub test_prepare_argv { my $inbetween = shift;
    foreach my $td (testdata($inbetween)) {
        my $curword = ${$td->{curword}};
        my ($curchar) = helptext::completer::prepare_argv(
            $td->{comp_point}, $td->{comp_line}, $td->{curword}
        );

        is($curchar, $td->{result}->{curchar}, 
            "Expecting current char '$td->{result}->{curchar}'. ".
            "Actual: $curchar.");
        is($td->{cliargs}->[$td->{index}], $td->{result}->{curword}, 
            "Expecting current word '$curword' => '$td->{result}->{curword}'. ".
            "Actual: '".$td->{cliargs}->[$td->{index}]."'".
            "\n     Called command: $td->{comp_line_disp}".
            "\n  Remaining command: ".join(' ', grep {$_} @{$td->{result}->{cliargs}}));
    }
}

sub testdata { my $mode = shift;
    my $inbetween = $mode eq 'inbetween';
    my $before    = $mode eq 'before';
    my @tpl_cliargs   = qw(dummycmd --opt ABC --opt DEF -o 1 --abc sub-command -x 1 --next FILENAME1 FILENAME2);
    my $tpl_comp_line = join(' ', @tpl_cliargs);
    my @testdata;
    foreach my $i (1..@tpl_cliargs-1) {
        my @cliargs         = @tpl_cliargs;
        my @rescliargs      = @tpl_cliargs;
        my $comp_line       = $tpl_comp_line;
        my $comp_line_disp  = $tpl_comp_line;
        my $curword         = \$cliargs[$i];
        my $rescurchar      = ($before ? ' ' : substr($$curword, 0, 1));
        my $cliargPos;
        foreach my $j (0..$i-1) {
            $cliargPos += length($cliargs[$j]) + 1;
        }
        my $comp_point = $cliargPos + ($before && -1);
        my $rescurword = "";

        $inbetween && do {
            my $lencurword  = length($$curword);
               $lencurword == 1 && next;

            my $idxinword   = int(rand($lencurword-1)) + 1;
            $comp_point    += $idxinword;
            $rescurchar     = substr($$curword, $idxinword, 1);
            $rescurword     = substr($$curword, 0, $idxinword);
            $rescliargs[$i] = $rescurword;
        };

        substr($comp_line_disp, $comp_point+1, 0, ']'); 
        substr($comp_line_disp, $comp_point  , 0, '[');

        my $td = {
            cliargs         => \@cliargs,
            comp_line       => $comp_line,
            comp_line_disp  => $comp_line_disp,
            curword         => \$cliargs[$i],
            comp_point      => $comp_point,
            index           => $i,
            result => {
                curchar => $rescurchar,
                curword => $rescurword,
                cliargs => [@rescliargs[0..$i]]
            }
        };

        push(@testdata, $td)
    }
    return @testdata
}

1;