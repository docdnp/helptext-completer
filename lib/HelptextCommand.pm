package HelptextCommand;
use strict;

my $cacheEnabled;
my $guessHelpOpt;

sub init {
    main::numberFromEnv (\$cacheEnabled, USE_CACHE => 1, 0, @_);
    main::numberFromEnv (\$guessHelpOpt, GUESS_HELPOPT => 1, 0, @_);
}

sub guessHelpOpt { my ($cmd, $helpOpt, %hoptcnt, $opt) = $_[0];
    ::debug("Searching for 'optimal' help source: cmd='$cmd', helpopt='$helpOpt'");
    foreach my $hopt (qw(:man --help -h)) {
        my $helpcmd = $hopt =~ /^:(.*)/ ? "$1 $cmd" : "$cmd $hopt";
        open my $cmdhandle, "$helpcmd 2>&1 |" or next; 
        while (<$cmdhandle>) {
            $opt = Opts::Find::AnyOpt(\$_);
            $opt && ! $opt->{isCmd} && do {
                $hoptcnt{OPT}{$hopt}++;
                next;
            };
            $opt && $opt->{isCmd} && $hoptcnt{CMD}{$hopt}++;
        }
    }
    my @soptkeys = sort { $hoptcnt{OPT}{$a} <=> $hoptcnt{OPT}{$b} } keys %{$hoptcnt{OPT}};
    my $maxkey   = $soptkeys[-1];
    $maxkey && do {
        foreach my $key (@soptkeys) {
            ::debug("Number of options for help opt '$key': $hoptcnt{OPT}{$key}");    
        }
        ::debug("Found most options for '$maxkey': $hoptcnt{OPT}{$maxkey}");
        return $maxkey;
    };

    my @scmdkeys = sort { $hoptcnt{CMD}{$a} <=> $hoptcnt{CMD}{$b} } keys %{$hoptcnt{CMD}};
    $maxkey   = $scmdkeys[-1];
    $maxkey && do {
        ::debug("Found more commands than options. '$maxkey': $hoptcnt{CMD}{$maxkey}");
        return $maxkey;
    };

    ::debug("Keeping default/user-provided help opt: $helpOpt");
    return $helpOpt
}

sub createCacheName { my $cmd = $_[0];
    $cmd =~ s/\s+-\S+\s*/ /g;
    $cmd =~ s/\s$//g;
    $cmd =~ s/[\s-]+/_/g;
    return "/tmp/htext.$ENV{USER}." . $cmd;
}

sub HelpCmdFromCache {
    my ($cmd, $helpOpt, $cmdCopy, $helpCmd) = ($_[0], $_[1], $_[2]);
    $helpOpt =~ /^:(.*?)(\.)?$/ && do {
        ::debug("Found helpopt: <".(caller(2))[3].">: $helpOpt [$1]$2");
        $helpCmd = "$1 ";
        $helpOpt = '';
        $2 eq '.' && ($cmd='');
    };
    ::debug("Calling: <".(caller(2))[3].">: $helpCmd$cmd $helpOpt");
    $cacheEnabled || return "$helpCmd$cmd $helpOpt";
    my $helpCmdCacheFile = createCacheName($cmd);
    if (!-e "$helpCmdCacheFile") {
        ::debug ("Caching to file: ".$helpCmdCacheFile);
        open(my $CMD, "$helpCmd$cmd $helpOpt|") or return "$helpCmd$cmd $helpOpt";
        open(my $CACHE, ">$helpCmdCacheFile");
        while(<$CMD>) { print $CACHE $_ }
    } 
    $cmd = 'cat "' . $helpCmdCacheFile . '"';
}

sub Open {
    my ($cmd, $helpOpt) = @_;
       $cmd = HelpCmdFromCache($cmd, $helpOpt);
    my $handle;
    open($handle, $cmd.'|' );
    return $handle;
}

sub IsSubcommand {
    my ($cmd, $helpOpt, $find) = @_;
    ::debug("Command '$cmd', help opt '$helpOpt'. Try to guess optimal help source: $guessHelpOpt");
    $guessHelpOpt && do {
        my $cache = createCacheName($cmd);
        -e $cache || ($helpOpt = guessHelpOpt($cmd, $helpOpt));
        ::debug("The preferred helpopt is: $helpOpt");
    };

    $cmd eq $find && return 0;
    my (@options, $opt);
    my $stream  =  Open($cmd, $helpOpt);
       $stream  || return;
    while(<$stream>) {
        ($opt = Opts::Find::Command(\$_)) &&  push @options, $opt;
    }
    my @result = grep {$_->{name} eq $find} @options;
    return scalar(@result)
}

sub GuessLastSubcommand {
    my $cliArgs = $_[0];
    my $cnt = 0;
    my $j = -1;
    my $i = scalar(@$cliArgs)-1;
    for(; $i > 0; $i--){
        if (@$cliArgs[$i] && @$cliArgs[$i] !~ /^-/) {
            $cnt++; 
            ::debug3 ("SEEK: Found index: $i");
            $cnt == 1 && ($j = $i);
            $cnt == 2 && last
        }
    }

    my $findSubCommand = @$cliArgs[$j];
    return $findSubCommand, $i, $j;
}

sub HelpCmdForSubcommand {
    my ($cmd, $helpOpt, $cliArgs) = @_;
    ::debug("Command '$cmd', help opt '$helpOpt'. Try to guess optimal help source: $guessHelpOpt");
    $guessHelpOpt && do {
        my $cache = createCacheName($cmd);
        -e $cache || ($helpOpt = guessHelpOpt($cmd, $helpOpt));
        ::debug("The preferred helpopt is: $helpOpt");
    };
    my ($candidate, $prevCandidateCmdPos, $candidatePos) = GuessLastSubcommand($cliArgs);
    $candidatePos < 0 && HelpCmdFromCache ($cmd, $helpOpt) && return { cmd => $cmd, envns => $cmd };

    my ($candCopy, $i, $j) = ($prevCandidateCmdPos, $candidatePos);
    my @toBeChecked;
    while ($i != 0) {
        ($candCopy, $i, $j) = GuessLastSubcommand([@$cliArgs[0..$i]]);
        push(@toBeChecked, $j);
    }
    my @validCmds;
    push(@validCmds, $cliArgs->[$i]);

    my $lastSubCmdPos;
    my $subcmd       = join(' ', @$cliArgs[0..$i]);
    my $candidatePos = pop @toBeChecked;
    my $candidate    = $cliArgs->[$candidatePos];
    my @cliArgs      = @$cliArgs;
    while ($candidatePos || scalar(@toBeChecked)>0) {
        if (IsSubcommand($subcmd, $helpOpt, $candidate)) {
            push @validCmds, $candidate;
            $subcmd        = join(' ', grep {$_!~/^-/ && $_} @cliArgs[0..$candidatePos]);
            $lastSubCmdPos = $candidatePos;
        }
        splice @cliArgs, $candidatePos, 1;
        $candidatePos = pop @toBeChecked;
        $candidate    = $cliArgs->[$candidatePos];
    }
    $lastSubCmdPos == @$cliArgs - 1 && pop @validCmds;

    $cmd = join(' ', @validCmds);
    return {cmd => $cmd, envns => join('_', map { my $a=$_; $a=~s/-/_/g; $a } @validCmds), (@validCmds > 1 &&
                subcmd => { name => $validCmds[-1], pos => $lastSubCmdPos } 
            )};
}

sub GuessLastOption {
    my $cliArgs = $_[0];
    my $cnt = 0;
    my $i = scalar(@$cliArgs)-1;
    for(; $i > 0; $i--){
        ::debug3 ("CHECK: SEEK: $i -> '@$cliArgs[$i]'");
        if (@$cliArgs[$i] && @$cliArgs[$i] =~ /^-/) {
            ::debug3 ("CHECK: SEEK: Found index: $i");
            my $arg = $cliArgs->[$i];
            $arg =~ s/^([^\\]*?)=.*/$1/;
            ::debug3 ("CHECK: SEEK: Result: $i -> $arg");
            return ($arg, $i);
        }
    }
    return;
}

sub LastOption {
    my ($cliArgs, $subcmdpos, $optDefs) = @_;
    ::debug("Subcmdpos: $subcmdpos");
    ::debug("Args: [".join('] [', @$cliArgs)."]");
    my ($lastOptName, $lastOpt);
    my $i = scalar(@$cliArgs)-1;
    my $optIdx;
    while ($i) {
        ::debug2 ("CHECK: SEEK : ".($i)." -> '@$cliArgs[$i]'");
        ($lastOptName, $optIdx) = GuessLastOption([@$cliArgs[0..$i--]]);
        $optIdx <= $subcmdpos && do { ::debug ("optIdx to low: $optIdx <= $subcmdpos") ; return 0};
        ::debug2 ("CHECK: GUESS: $lastOptName");
        $lastOptName || next;
        $optIdx == @$cliArgs - 1 && next;
        my @matchingOptDefs = grep { ($_->{name} eq $lastOptName ) && $_  } @$optDefs;
        ::debug2 ("CHECK: GUESS: OPTIDX: $optIdx CLIARGS: ".(@$cliArgs - 1));
        # @matchingOptDefs > 1 && return;
        $lastOpt = $matchingOptDefs[0];
        ::debug2 ("CHECK: SEEK: RESULT: ".($i)." -> '".($lastOpt && $lastOpt->{name})."'");
        $lastOpt && return ($lastOpt, $optIdx);
    }
    return 0;
}


1;