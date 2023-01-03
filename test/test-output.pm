package Test::Output;
use Test::More;
use strict;
use warnings;

my @allopts = (
    new Option({type => 'LONG' , name => '--opt-no-arg', args => ''          , desc => 'some help text'}),
    new Option({type => 'LONG' , name => '--opt-1-arg' , args => 'arg'       , desc => 'some help text'}),
    new Option({type => 'LONG' , name => '--opt-2-arg' , args => 'arg1 arg2' , desc => 'some help text'}),
    new Option({type => 'SHORT', name => '-h'          , args => ''          , desc => 'some help text'}),
    new Option({type => 'SHORT', name => '-f'          , args => 'file'      , desc => 'some help text'}),
    new Option({type => 'CMD'  , isCmd => 1, name => 'subcmd-1'              , desc => 'some help text'}),
    new Option({type => 'CMD'  , isCmd => 1, name => 'subcmd-2'              , desc => 'some help text'}),
);
my $optcache = {};
foreach my $opt (@allopts) {
    $optcache->{$opt->{name}} = $opt;
}

# subtest "Cursor within word not at end of line. Word matches exactly one option".
#         " => No output" 
# => sub {
#     my @commands = (
#         q(dummycmd -h --opt-n[o]-arg -f xyz),
#         q(dummycmd -h --opt-no[-]arg -f xyz),
#         q(dummycmd -h --opt-no-[a]rg -f xyz),
#         q(dummycmd -h --opt-no-a[r]g -f xyz),
#         q(dummycmd -h --opt-no-ar[g] -f xyz),
#     );
#     foreach my $cmd (@commands) {
#         my $expresult = {
#             debug   => 0,
#             results => [],
#         };
#         my ($results, $output, $comp_line_tpl, $curword)  
#             = testdata($cmd, $expresult);
#     }
# };

# subtest "Cursor within word not at end of line. Word starts like multiple items ". 
#         " => Return list of matching items" 
# => sub {
#     my @commands = (
#         [ '--'      => q(dummycmd -h --[o]pt-no-arg -f xyz) ],
#         [ '--o'     => q(dummycmd -h --o[p]t-no-arg -f xyz) ],
#         [ '--op'    => q(dummycmd -h --op[t]-no-arg -f xyz) ],
#         [ '--opt'   => q(dummycmd -h --opt[-]no-arg -f xyz) ],
#         [ '--opt-'  => q(dummycmd -h --opt-[n]o-arg -f xyz) ],
#     );
#     foreach my $td (@commands) {
#         my ($respattern, $cmd) = @$td;
#         my $expresult = {
#             debug   => 0,
#             results => [map  { $_->{name} } 
#                         grep { $_->{name} =~ /^$respattern/  
#                            } @allopts],
#         };
#         my ($results, $output, $comp_line_tpl, $curword)  
#             = testdata($cmd, $expresult);
#     }

# };

# subtest "Cursor within word not at end of line. Word's form matches a known opt ".
#         "plus some arbitrary additional chars and starts like ONE item.".
#         " => Return macthing item. If known arg follows => " 
# => sub {
#     my @commands = (
#         [ '--opt-'      => q(dummycmd -h dummycmd -h --opt-n[n]o-arg -f xyz) ],
#         [ '--opt-n'     => q(dummycmd -h dummycmd -h --opt-no[o]-arg -f xyz) ],
#         [ '--opt-no'    => q(dummycmd -h dummycmd -h --opt-no-[-]arg -f xyz) ],
#         [ '--opt-no-'   => q(dummycmd -h dummycmd -h --opt-no-a[a]rg -f xyz) ],
#         [ '--opt-no-a'  => q(dummycmd -h dummycmd -h --opt-no-ar[r]g -f xyz) ],
#         [ '--opt-no-ar' => q(dummycmd -h dummycmd -h --opt-no-arg[g] -f xyz) ],
#     );

#     foreach my $td (@commands) {
#         my ($respattern, $cmd) = @$td;
#         my $expresult = {
#             debug   => 0,
#             results => [ "{{curword}} $respattern" ],
#         };
#         my ($results, $output, $comp_line_tpl, $curword, $before_point)  
#             = testdata($cmd, $expresult);
#     }
# };

# subtest "Cursor within unknown opt (word) not at end of line. Word starts like ONE item.".
#         " => Return matching item and white space. " 
# => sub {
#     my @commands = (
#         [ 0 , q(dummycmd -h --opt-n[u]nknown -f xyz)   ],
#         [ 0 , q(dummycmd -h --opt-n[u]nknown1 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-n[u]nknown2 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-n[u]nknown3 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-1[u]nknown -f xyz)   ],
#         [ 0 , q(dummycmd -h --opt-1[u]nknown1 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-1[u]nknown2 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-1[u]nknown3 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-2[u]nknown -f xyz)   ],
#         [ 0 , q(dummycmd -h --opt-2[u]nknown1 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-2[u]nknown2 -f xyz)  ],
#         [ 0 , q(dummycmd -h --opt-2[u]nknown3 -f xyz)  ],
#         [ 0 , q(dummycmd -h -h[u]nknown -f xyz)        ],
#         [ 0 , q(dummycmd -h -h[u]nknown1 -f xyz)       ],
#         [ 0 , q(dummycmd -h -h[u]nknown2 -f xyz)       ],
#         [ 0 , q(dummycmd -h -h[u]nknown3 -f xyz)       ],
#     );

#     foreach my $td (@commands) {
#         my ($respattern, $cmd) = @$td;
#         my $expresult = {
#             debug   => 0,
#             results => [ "{{curword}} " ],
#         };
#         my ($results, $output, $comp_line_tpl, $curword, $before_point)  
#             = testdata($cmd, $expresult);
#     }
# };

# subtest "Cursor within known sub-command (word) not at end of line. Word starts like ".
#         "ONE item. => Return matching item and white space. " 
# => sub {
#     my @commands = (
#         [ ''        , q(dummycmd -h --opt-nunknown [s]ubcmd-1 -f xyz)  ],
#         [ 's'       , q(dummycmd -h --opt-nunknown1 s[u]bcmd-1 -f xyz)  ],
#         [ 'su'      , q(dummycmd -h --opt-nunknown2 su[b]cmd-1 -f xyz)  ],
#         [ 'sub'     , q(dummycmd -h --opt-nunknown3 sub[c]md-1 -f xyz)  ],
#         [ 'subc'    , q(dummycmd -h --opt-1unknown subc[m]d-1 -f xyz)  ],
#         [ 'subcm'   , q(dummycmd -h --opt-1unknown1 subcm[d]-1 -f xyz)  ],
#         [ 'subcmd'  , q(dummycmd -h --opt-1unknown2 subcmd[-]1 -f xyz)  ],
#         [ 'subcmd-' , q(dummycmd -h --opt-1unknown3 subcmd-[1] -f xyz)  ],
#     );

#     foreach my $td (@commands) {
#         my ($respattern, $cmd) = @$td;
#         my $expresult = {
#             debug       => 0,
#             matchfunc   => sub { $_[0]->{type} eq 'CMD' },
#             results     => [map  { $_->{name} } 
#                         grep { $_->{type} eq 'CMD' 
#                             && $_->{name} =~ /^$respattern/ 
#                           } @allopts],
#         };
#         my ($results, $output, $comp_line_tpl, $curword, $before_point)  
#             = testdata($cmd, $expresult);
#     }
# };

# subtest "Cursor within unknown sub-command (word) not at end of line. Word starts like ".
#         "ONE item. => Return matching item and white space. " 
# => sub {
#     my @commands = (
#         [ ''        , q(dummycmd -h --opt-nunknown [s]ubcmd-X -f xyz)  ],
#         [ 's'       , q(dummycmd -h --opt-nunknown1 s[u]bcmd-X -f xyz)  ],
#         [ 'su'      , q(dummycmd -h --opt-nunknown2 su[b]cmd-X -f xyz)  ],
#         [ 'sub'     , q(dummycmd -h --opt-nunknown3 sub[c]md-X -f xyz)  ],
#         [ 'subc'    , q(dummycmd -h --opt-1unknown subc[m]d-X -f xyz)  ],
#         [ 'subcm'   , q(dummycmd -h --opt-1unknown1 subcm[d]-X -f xyz)  ],
#         [ 'subcmd'  , q(dummycmd -h --opt-1unknown2 subcmd[-]X -f xyz)  ],
#         [ 'subcmd-' , q(dummycmd -h --opt-1unknown3 subcmd-[X] -f xyz)  ],
#     );

#     foreach my $td (@commands) {
#         my ($respattern, $cmd) = @$td;
#         my $expresult = {
#             debug       => 0,
#             matchfunc   => sub { $_[0]->{type} eq 'CMD' },
#             results     => [map  { $_->{name} } 
#                         grep { $_->{type} eq 'CMD' 
#                             && $_->{name} =~ /^$respattern/ 
#                           } @allopts],
#         };
#         my ($results, $output, $comp_line_tpl, $curword, $before_point)  
#             = testdata($cmd, $expresult);
#     }
# };

# subtest "Cursor directly before/after opts at end of line" => sub {
#     sub runtests { my ($commands, $matchfunc, $grepresfunc, $debug) = @_;
#         foreach my $td (@$commands) {
#             my ($respattern, $cmd) = @$td;
#             my $expresult = {
#                 debug       => $debug,
#                 respattern  => $respattern,
#                 matchfunc   => $matchfunc,
#                 results     => [map  { $_->{name} } 
#                                 grep {
#                                     my $c = $grepresfunc && $grepresfunc->() || 1;
#                                     $c && $_->{name} =~ /^$respattern/ 
#                                 } @allopts],
#             };
#             my ($results, $output, $comp_line_tpl, $curword, $before_point)  
#                 = testdata($cmd, $expresult);
#         }
#     }
# sub { my $r = 1;
#                                         if ($_[1] eq 'subcmd') {
#                                             $r = $_[0]->{type} eq 'CMD';
#                                         } else ()= $_[1] eq 'subcmd'  ? $_[0]->{type} eq 'CMD' : 1 ; 
#                                         $r = $r && ! $_[1] eq 'NEEDSARG'; 
#                                         print STDERR ">>> matchfunc: [$_[0]->{name}:$_[0]->{type}] [$_[1]] => [$r]\n";
#                                         $r
#                                     }
#     subtest "Cursor directly between two opts at end of line. ".
#             "Preceeding opt exists doesn't need args.".
#             " => Return preceeding opt. " 
#     => sub {
#         my @commands = (
#             [ '-h'          , q(dummycmd -h --opt-nunknown -h[ ]--opt-no-arg)  ],
#             # [ '-h'          , q(dummycmd -h --opt-nunknown1 -h[ ]--opt-1-arg)  ],
#             # [ '-h'          , q(dummycmd -h --opt-nunknown2 -h[ ]--opt-2-arg)  ],
#             # [ '-h'          , q(dummycmd -h --opt-nunknown3 -h[ ]-h)  ],
#             # [ '-h'          , q(dummycmd -h --opt-1unknown -h[ ]-f)  ],
#             # [ '-h'          , q(dummycmd -h --opt-1unknown1 -h[ ]subcmd-1)  ],
#             # [ '-h'          , q(dummycmd -h --opt-1unknown2 -h[ ]subcmd-2)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-nunknown --opt-no-arg[ ]--opt-no-arg)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-nunknown1 --opt-no-arg[ ]--opt-1-arg)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-nunknown2 --opt-no-arg[ ]--opt-2-arg)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-nunknown3 --opt-no-arg[ ]-h)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-1unknown --opt-no-arg[ ]-f)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-1unknown1 --opt-no-arg[ ]subcmd-1)  ],
#             # [ '--opt-no-arg', q(dummycmd -h --opt-1unknown2 -f --opt-no-arg[ ]subcmd-2)  ],
#         );
#         runtests \@commands;
#     };
#     subtest "Cursor directly between two opts at end of line. ".
#             "Preceeding opt exists and needs args. => No output." 
#     => sub {
#         my @commands = (
#             [ 'NEEDSARG', q(dummycmd -h --opt-nunknown --opt-1-arg[ ]--opt-no-arg)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-nunknown1 --opt-1-arg[ ]--opt-1-arg)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-nunknown2 --opt-1-arg[ ]--opt-2-arg)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-nunknown3 --opt-1-arg[ ]-h)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-1unknown --opt-1-arg[ ]-f)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-1unknown1 --opt-1-arg[ ]subcmd-1)  ],
#             # [ 'NEEDSARG', q(dummycmd -h --opt-1unknown2 -f --opt-1-arg[ ]subcmd-2)  ],
#         );
#         runtests \@commands, 0, 0, 1;
#     };
#     # subtest "Cursor directly before opt at end of line. ".
#     #         " => No all opts/cmds" 
#     # => sub {
#     #     my @commands = (
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown --opt-no-arg [ ]--opt-no-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown1 --opt-no-arg [ ]--opt-1-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown2 --opt-no-arg [ ]--opt-2-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown3 --opt-no-arg [ ]-h)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown --opt-no-arg [ ]-f)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown1 --opt-no-arg [ ]subcmd-1)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown2 -f --opt-no-arg [ ]subcmd-2)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown -f xyz [ ]--opt-no-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown1 -f xyz [ ]--opt-1-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown2 -f xyz [ ]--opt-2-arg)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-nunknown3 -f xyz [ ]-h)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown -f xyz [ ]-f)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown1 -f xyz [ ]subcmd-1)  ],
#     #         [ 'subcmd'      , q(dummycmd -h --opt-1unknown2 -f xyz [ ]subcmd-2)  ],
#     #     );
#     #     runtests \@commands;
#     # };

# };

# dummycmd -h --opt-n[n]o-arg -f xyz
# ---------------------------------------------------------
sub test { my ($comp_line, $expresult) = @_;

}

sub testdata { my ($comp_line, $expresult) = @_;
    $expresult = $expresult || { debug => 0 };

    $expresult->{debug} && do {
        print STDERR ">> ============= TEST THE FOLLOWING ============== \n";
        print STDERR ">>> ----------------------------------------------- \n";
        print STDERR ">>> Num of expected results: ", scalar(@{$expresult->{results}}), "\n";
        print STDERR ">>> Checking               : $comp_line\n";
        print STDERR ">> ================================================ \n";
    };

    my $comp_line_tpl = $comp_line;
    my $comp_point = index($comp_line, '[', 0);
    my ($curwordpos, $curword, $currchar, $after_point, $before_point, $ret_before_point, $before_idx);
    my $curCliPos = 0;
    $expresult->{debug} && print STDERR ">> ============= INIT EXPECTED VALUES ============= \n";
    $comp_line =~ s/\[ \]/\[\[\[\]\]\]  /g;
    foreach my $arg (split(/\s+/, $comp_line)) {
        $arg =~ s/\[\[\[\]\]\]/\[ \]/g;
        $expresult->{debug} && print STDERR ">> check arg        : $arg\n";
        $arg  =~ /\[(.)\]/ && do {
            $currchar = $1;
            $curword = $arg;
            $after_point   = $currchar.substr($arg, index($arg , ']') + 1);
            $expresult->{debug} && do {
                print STDERR ">> found arg        : $arg\n";
                print STDERR ">> found currchar   : $currchar\n";
                print STDERR ">> found after_point: [$after_point]\n";
                print STDERR ">> found curword    : $curword\n";
            };
            last;
        };
        $curwordpos += length($arg) + 1;
        $expresult->{debug} && print STDERR ">> curword          : $curwordpos $arg\n";
        $curCliPos++;
    }
    $comp_line =~ s/\[\[\[\]\]\] /\[ \]/g;
    $expresult->{debug} && print STDERR ">> ================================================ \n";

    $curword =~ s/[\[\]]//g;
    $comp_line =~ s/\[(.)\]/$1/;

    $expresult->{debug} && do {
        print STDERR ">> ============ FIND EXISTING OPTIONS ============ \n";
        print STDERR ">> \$curwordpos                     : ".($curwordpos)."\n";
    };
    my $cnt = 0;
    my $knownopt = {name => ''};
    while (! exists $optcache->{$knownopt->{name}}) {
        $expresult->{debug} && do {
            print STDERR ">> $cnt: \$comp_point - \$curwordpos - \$cnt: ".($comp_point - $curwordpos - $cnt)."\n";
        };
        ($comp_point - $curwordpos - $cnt > 0) || last;
        $ret_before_point = substr($comp_line , $curwordpos, $comp_point - $curwordpos - $cnt);
        $expresult->{debug} && 
            print STDERR ">> $cnt:                     before/after: ${ret_before_point}[]$after_point\n";
            exists $optcache->{$ret_before_point.$after_point} 
                && ($knownopt = $optcache->{$ret_before_point.$after_point})
                && last;
        $cnt++;
        # <STDIN>;
    }
    $expresult->{debug} && print STDERR ">> Found: " .($knownopt->{name}). " \n";
    $expresult->{debug} && print STDERR ">> ================================================ \n";
    $expresult->{debug} && do {
        print STDERR ">> ============= COMPUTE BEFORE POINT ============= \n";
        print STDERR ">> ret_before_point: [$ret_before_point]\n";
    };
    $before_point = substr($comp_line , $curwordpos, $comp_point - $curwordpos);
    $ret_before_point = $ret_before_point || $before_point;
    $expresult->{debug} && do {
        print STDERR ">> comp_line       : [$comp_line]\n";
        print STDERR ">> comp_line_tpl   : [$comp_line_tpl]\n";
        print STDERR ">> curwordpos      : [$curwordpos]\n";
        print STDERR ">> comp_point      : [$comp_point]\n";
        print STDERR ">> ------------------------------------------------ \n";
        print STDERR ">> before_point    : [$before_point]\n";
        print STDERR ">> ret_before_point: [$ret_before_point]\n";
        print STDERR ">> ================================================ \n";
    };

    $expresult->{debug} && print STDERR ">> =========== PREPARE EXPECTED MATCHES =========== \n";
    my $results = {
        matches => [ grep 
            { 
                my $c = $expresult->{matchfunc} 
                        ? $expresult->{matchfunc}->($_, $expresult->{respattern}) 
                        : 1;
                $c = $c && $_->{name} =~ /^$before_point/;
                $expresult->{debug} 
                    && printf STDERR ">> matches: %s %12s =~ /^%10s/x => [$c]\n"
                    , $expresult->{matchfunc} ? '<usercond> &&' : ''
                    , $_->{name}
                    , $before_point;
                $c
            } @allopts ],
        allopts => \@allopts,
        optcache => $optcache
    };
    $expresult->{debug} && do {
        foreach my $match (@{$results->{matches}}) {
            print STDERR ">> match: $match->{name} \n";
        }
        print STDERR ">> ================================================ \n";
    };


    $expresult->{debug} 
        && print STDERR ">> ======== FAKE helptext::completer::main ======== \n";
    my @argv       = split(/\s+/, $comp_line);
    my $curwordref = \$argv[$curwordpos];
    $curword    =  $argv[$curwordpos];

    ($currchar, $curwordpos) = helptext::completer::prepare_argv($comp_point, $comp_line, $curwordref);
    $results = helptext::completer::list_matches([@argv[0..$curCliPos]]);
    my $output = helptext::completer::prepare_output ($results, $comp_point, $comp_line, $curword, $currchar, $curwordpos);
    $expresult->{debug} 
        && print STDERR ">> ================================================ \n";

    if ($expresult->{debug}) {
        print STDERR ">> ================ DETECTED OUTPUT =============== \n";
        for(@$output) { print STDERR ">> OUT: $_"}
        print STDERR ">> ================================================ \n";
    }
    @{$results->{matches}} == 1 && do {
        $curword = $results->{matches}->[0]->{name};
    };

    ok(1, "-------------------------------------");
    ok(1, "Testing: $comp_line_tpl");
    $expresult->{results} && do {
        my $numresults = scalar(@{$expresult->{results}});
        is(scalar(@$output), $numresults, 
            "Expected $numresults result items. Actual: ".scalar(@$output));

        if ($expresult->{debug}) {
            foreach my $outitem (@$output) {
                print STDERR ">>> outitem: [$outitem]\n";
            }
        }
        $expresult->{debug} && print STDERR ">> ============= SEARCH EXPECTED ITEMS ============= \n";
        foreach my $outitem (@{$expresult->{results}}) {
            $outitem =~ s/\{\{curword\}\}/$curword/g;
            $expresult->{debug} && print STDERR ">> Searching $outitem\n";
            my @resitems = (grep { my $a=$_; chomp($a); $a eq $outitem } @$output);
            my $resitem = $resitems[0];
            is(scalar (@resitems), 1, "Expecting $outitem exactly once in results.") 
                && chomp($resitem)
                && is($resitem, $outitem, "Expected $outitem. Actual $resitem");
        }
        $expresult->{debug} && print STDERR ">> ================================================= \n";
    };

    if ($expresult->{debug}) {
        print STDERR ">> ================= RESULT VALUES ================= \n";
        print STDERR ">> comp_point        : $comp_point\n";
        print STDERR ">> comp_line         : $comp_line\n";
        print STDERR ">> comp_line_tpl     : $comp_line_tpl\n";
        print STDERR ">> currchar          : $currchar\n";
        print STDERR ">> curwordpos        : $curwordpos\n";
        print STDERR ">> curword           : $curword\n";
        print STDERR ">> before_point      : $before_point\n";
        print STDERR ">> ret_before_point  : $ret_before_point\n";
        # print STDERR ">> before_point2 : $before_point2\n";
        print STDERR ">> after_point       : $after_point\n";
        print STDERR ">> ================================================= \n";
        print STDERR ">> ************************************************* \n";
        print STDERR ">> ************************************************* \n";
        print STDERR ">> ************************************************* \n";
        print STDERR ">> ================================================= \n";
    }

    return ($results, $output, $comp_line_tpl, $curword, $ret_before_point);
}

1;