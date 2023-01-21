package Histogram;
use strict;

sub CreateHistogram {
    my ($list, $propfunc) = @_;
    my $h = {};
    my $i = 0;
    foreach my $item (@$list) {
        my ($prop) = &$propfunc($item);
        $h->{$prop}->{$i} = 1;
        $i++
    }
    return $h
}

sub MaxBinIndex {
    my ($hist)  = @_;
    my $maxCnt  = 0;
    my $maxBin = 0;
    foreach my $binIdx (keys %$hist) {
        my $binCnt = keys %{$hist->{$binIdx}};
        if ($maxCnt < $binCnt) {
            $maxCnt  = $binCnt;
            $maxBin  = $binIdx;
        }
    }
    return $maxBin
}

# ------------------------------------------------------------------------------------------
package Opts::Filter;
use strict;

my $maxCmdDist;
my @filters    = (
    [ FILTER_APPNAME     => \&DiscardIfMatchesName],
    [ FILTER_DESCRIPTION => \&KeepByMajoritysDescrPadding],
    [ FILTER_PADDING     => \&KeepByMajorityOfEquallyIndented],
    [ FILTER_NO_NEIGHBOR => \&DropCmdIfNoNeighbor]
);

sub init {
    my $no_commands = 0;
    main::numberFromEnv(\$maxCmdDist , MAX_CMD_DIST => 5, 0, @_);
    main::numberFromEnv(\$no_commands, NO_COMMANDS  => 0, 0, @_);
    $no_commands && do {
        $ENV{HT_FILTER_PADDING} = $ENV{HT_FILTER_DESCRIPTION} = $ENV{HT_FILTER_NO_NEIGHBOR} = 1;
    };
    my $filterDisabled;    
    @filters = grep {
        main::numberFromEnv(\$filterDisabled, $_->[0], 0, 0, @_);
        ! $filterDisabled && $_
    } @filters;
}

sub KeepByMajoritysMatchingProp {
    my ($candidates, $propfunc, $propname) = @_;
    my $caller = (caller(1))[3];
    ::debug("$caller: $propname: candidate list size: ".scalar(@$candidates));
    my $hist      = Histogram::CreateHistogram($candidates, $propfunc);
    ::debug("$caller: $propname: Hist result: ". $hist);
    my $numOfBins = scalar(keys %{$hist});
       $numOfBins < 2 
       && ::debug("$caller: $propname: Number of bins: $numOfBins < 2: Returning.")
       && return $candidates;

    my $mostCandidatesPropIdx = Histogram::MaxBinIndex($hist);
    ::debug("Most option candidates property".($propname?" '$propname'":'')." has len=$mostCandidatesPropIdx, cnt=".(scalar keys %{$hist->{$mostCandidatesPropIdx}}));
    delete %{$hist}{$mostCandidatesPropIdx};
    my @remove;
    foreach my $candidateIdx (keys %$hist) {
        ::debug1("Marking for removal: All candidates with property".($propname?" '$propname'":'')." len=$candidateIdx, cnt=".(scalar keys %{$hist->{$candidateIdx}}));
        foreach my $len (keys %{$hist->{$candidateIdx}}) {
            $candidates->[$len]->{type} =~ /EMPTY|DESC/ && next;
            push(@remove, $len);
        }
    }
    foreach my $rm (sort {$b <=> $a} (@remove)) {
        ::debug("Removing: $candidates->[$rm]->{name} [$candidates->[$rm]->{args}] $candidates->[$rm]->{pad2Desc} $candidates->[$rm]->{isCmd}");
        splice @$candidates, $rm, 1;
    }
    ::debug("$caller: END: $propname: candidate list size: ".scalar(@$candidates));
    return $candidates;
}

sub KeepByMajorityOfEquallyIndented { KeepByMajoritysMatchingProp ($_[0], sub { (length($_[0]->{padding}) || 0) }, 'padding' )}
sub KeepByMajoritysDescrPadding     { KeepByMajoritysMatchingProp ($_[0], sub { ($_[0]->{pad2Desc} || 0) }       , 'pad2Desc')}

sub DiscardIfMatchesName {
    my ($candidates, $name) = @_;
    return [grep {$_->{name} ne $name && $_} @{$candidates}];
}

sub DropCmdIfNoNeighbor {
    my $maxNeighborDistance = $maxCmdDist;
    my ($candidates, $id) = ($_[0]);
    my @commands = grep { $_->{type} eq 'CMD' } map { $id++; { type   => $_->{type},
                                                               lineno => $_->{lineno}, 
                                                               index => $id-1
                                                     } } @{$candidates};
    ::debug("command list size: ".scalar(@commands));
    ::debug("line distance: $maxNeighborDistance");
    my @remove;
    for (0..@commands-1) {
        ::debug1("checking $_ ".$commands[$_]->{lineno});
        my ($cond1, $cond2) = ($_ == @commands-1, $_ == 0);
        $_ < @commands - 1 && ($cond1 = $commands[$_+1]->{lineno} - $commands[$_]->{lineno}   > $maxNeighborDistance);
        $_ > 0             && ($cond2 = $commands[$_]->{lineno}   - $commands[$_-1]->{lineno} > $maxNeighborDistance);
        $cond1 && $cond2 
            && ::debug1("$_: Marking for removal: ".$commands[$_]->{name}.": ".$commands[$_]->{index})
            && push(@remove, $commands[$_]->{index});
    }
    foreach my $rm (sort {$b <=> $a} (@remove)) {
        ::debug("Removing: $rm: $candidates->[$rm]->{name} [$candidates->[$rm]->{args}] $candidates->[$rm]->{pad2Desc} $candidates->[$rm]->{isCmd}");
        splice @$candidates, $rm, 1;
    }
    return $candidates
}

sub ProbableCandidates {
    my ($candidates, $name) = @_;
    foreach my $filter (@filters) {
        $candidates = $filter->[1]->($candidates, $name)
    }
    ::debug("END: candidate list size: ".scalar(@$candidates));
    return $candidates
}

1;
