package Test::RealWorldExamples;
use Test::More;
use strict;
use warnings;

sub find_opts {
    no strict 'subs';
    no warnings;

    my $datafile = $_[0];
    open(my $handle, '<'.$datafile) or die $!;

    my $oldVal = $ENV{HT_OPTARG_DIST_MAX};
    $ENV{HT_USE_CACHE}          = 0;
    $ENV{HT_OPTARG_DIST_MAX}    = 1;
    $ENV{HT_SHOW_ALL} = 1;
    unittests::load_completer;

    *{HelptextCommand::Open} = sub { $handle };

    my $allOpts    = helptext::completer::list_matches(['cmd-dummy', ''])->{matches};
    my $shortOpts  = [grep {defined $_->{type} && $_->{type} eq 'SHORT' && $_ } @$allOpts];
    my $longOpts   = [grep {defined $_->{type} && $_->{type} eq 'LONG'  && $_ } @$allOpts];
    my $cmdOpts    = [grep {defined $_->{type} && $_->{type} eq 'CMD'   && $_ } @$allOpts];

    $ENV{HT_OPTARG_DIST_MAX} = $oldVal;
    $oldVal || delete $ENV{HT_OPTARG_DIST_MAX};
    delete $ENV{HT_SHOW_ALL};
    delete $ENV{HT_USE_CACHE};
    unittests::load_completer;

    return ($shortOpts, $longOpts, $cmdOpts);
}

subtest "Find options in 'pip -h'" => sub {
    my $datafile = 'test/data/pip-opts.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) ,  4, "Should be  4 short opts in $datafile");
    is(scalar(@$longOpts)  , 24, "Should be 24 long  opts in $datafile");
    is(scalar(@$cmdOpts)   , 17, "Should be 17 commands in $datafile");
};

subtest "Find options in 'pip wheel -h'" => sub {
    my $datafile = 'test/data/pip-wheel-opts.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) , 10, "Should be 10 short opts in $datafile");
    is(scalar(@$longOpts)  , 49, "Should be 49 long  opts in $datafile");
    is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
};

subtest "Find options in 'man cp'" => sub {
    my $datafile = 'test/data/cp.man.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) , 21, "Should be 21 short opts in $datafile");
    is(scalar(@$longOpts)  , 28, "Should be 28 long  opts in $datafile");
    is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
};

subtest "Find options in 'man ssh'" => sub {
    my $datafile = 'test/data/ssh.man.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) , 44, "Should be 44 short opts in $datafile");
    is(scalar(@$longOpts)  ,  0, "Should be  0 long  opts in $datafile");
    is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
};

subtest "Find options in 'man sort'" => sub {
    my $datafile = 'test/data/sort.man.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) , 22, "Should be 22 short opts in $datafile");
    is(scalar(@$longOpts)  , 30, "Should be 30 long  opts in $datafile");
    is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
};

subtest "Find options in 'man cat'" => sub {
    my $datafile = 'test/data/cat.man.txt';
    my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
    is(scalar(@$shortOpts) , 10, "Should be 10 short opts in $datafile");
    is(scalar(@$longOpts)  ,  9, "Should be  9 long  opts in $datafile");
    is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
};

# subtest "Find options in 'man ls'" => sub {
#     my $datafile = 'test/data/ls.man.txt';
#     my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
#     is(scalar(@$shortOpts) , 10, "Should be 10 short opts in $datafile");
#     is(scalar(@$longOpts)  ,  9, "Should be  9 long  opts in $datafile");
#     is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
# };

# subtest "Find options in 'git log'" => sub {
#     my $datafile = 'test/data/git-log.txt';
#     my ($shortOpts, $longOpts, $cmdOpts) = find_opts($datafile);
#     is(scalar(@$shortOpts) , 44, "Should be 44 short opts in $datafile");
#     is(scalar(@$longOpts)  ,  0, "Should be  0 long  opts in $datafile");
#     is(scalar(@$cmdOpts)   ,  0, "Should be  0 commands in $datafile");
# };


1;