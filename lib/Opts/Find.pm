package Opts::Find;
use strict;

my $nameId          = 0;
my ($optarg_dist_min, $optarg_dist_max, $padding_min, $padding_max, $no_commands);
my ($reAnyOptStart, $reAnyOptNext, $reCommand, $reDescription);

sub initRegExps {
    my $reLeftPadding     = qr/ \s{$padding_min,$padding_max} /x;
    my $reArgDist         = qr/ \s{$optarg_dist_min,$optarg_dist_max} /x;

    my $reArgHeadNoAssign = qr/ [^\]\}\)\>=-\s] /x; # One char, no assign, blank, opt char or 
                                                 # closing brackets
    my $reArgHeadAssign   = qr/ =[^]})>-\s] /x;     # One assign char, followed by, no blank, opt char or 
                                                 # closing brackets
    my $reArgBody         = qr/ (?:   \S*[^\s,\|:]+ # Either empty or anything not ending on delimiters
                            | [^,|:\s]+ )?       # or anything except delimiters
                        /x;
    my $reNonAssignArg    = qr/ $reArgHeadNoAssign
                            $reArgBody
                        /x;
    my $reAssignArg       = qr/ $reArgHeadAssign
                            $reArgBody
                        /x;
    my $reArgs            = qr/ (?:$reArgDist$reNonAssignArg)
                            (?:[,\|:]?$reArgDist$reNonAssignArg)* 
                            | $reAssignArg
                            | \[$reAssignArg\]
                            | \[$reNonAssignArg\]
                            | \<$reNonAssignArg\>
                            | \($reNonAssignArg\)
                            | \{$reNonAssignArg\}
                            | \/$reNonAssignArg\/
                        /x;
    my $rePureShortOpt    = qr/ -[a-zA-Z\d] /x;
    my $rePureLongOpt     = qr/ --[\w-]+ /x;
    my $rePrefixedLongOpt = qr/ --\[(?<optprefix>.*?)\](?<optstem>[\w-]+) /x;
    my $rePureCmd         = qr/ \w[\w-]+ /x;
    my $reOptDelim        = qr/ (?:[,\|\s]) /x;

    my $reAnyOptBody      = qr/ (?:  (?<longopt>$rePureLongOpt) 
                                | (?<shortopt>$rePureShortOpt) 
                                | (?<prefixopt>$rePrefixedLongOpt) 
                            )(?<args>$reArgs)? 
                        /x;
    my $reAnyText         = qr/ .* /x;
    my $reEmpty           = qr/ \s*\n? /x;

    $reDescription        = qr/ \S.* /x;
    $reAnyOptStart        = qr/ (?<padding>$reLeftPadding)
                               $reAnyOptBody
                           /x;
    $reAnyOptNext         = qr/ $reOptDelim\s*
                               $reAnyOptBody
                           /x;
    $reCommand            = qr/ ($reLeftPadding)($rePureCmd)(?:\s+($reDescription)?|$reEmpty) /x;
}

sub init { 
    my @conf = (
        # ENVIRONMENT        GLOBAL PACKAGE     DEFAULT    USE ENVIRONMENT VALUES
        # VARIABLE NAME      VARIABLE           VALUE      IF SMALLER THAN
        [ OPTARG_DIST_MIN => \$optarg_dist_min,      1,    \0 ],
        [ OPTARG_DIST_MAX => \$optarg_dist_max,      1,    \$optarg_dist_min ],
        [ PADDING_MIN     => \$padding_min    ,      1,    \0 ],
        [ PADDING_MAX     => \$padding_max    ,     10,    \$padding_min ],
        [ NO_COMMANDS     => \$no_commands    ,      0,    \0 ],
    );
    for (@conf) { main::numberFromEnv($_->[1], $_->[0], $_->[2], ${$_->[3]}, @_ ) }
    $no_commands && (*{Command} = sub {});
    initRegExps();
}

sub mkOpt { my ($lineno, $line, $refopt) = @_;
    my ($optprefix, $optstem) = ($+{optprefix}, $+{optstem});
    my $opt = new Opts::Option { 
        line     => $line, lineno => $lineno, 
        padding  => ($+{padding} || ($refopt && $refopt->{padding})), 
        name     => ($+{longopt} || $+{shortopt} || '--'.$+{optprefix}.$+{optstem}),
        args     => $+{args}, type => ($+{longopt} || $+{prefixopt})?'LONG':'SHORT'
    };
    $+{optprefix} || return $opt;
    my $nextOpt = new Opts::Option { 
        name     => '--'.$+{optstem}, line => $line, lineno => $lineno, 
        padding  => $+{padding} || $refopt && $refopt->{padding}, 
        type => 'LONG', args => ($+{args} || $refopt && $refopt->{args})
    };
    $opt->chain($nextOpt);
    $opt
}

sub Opt {
    my ($line, $lineno, $firstOpt, $currOpt, $nextOpt) = ($_[0], $_[1]);
    $$line =~   /^ $reAnyOptStart /x || return;
    $currOpt = $firstOpt = mkOpt($lineno, $line);
    while ($currOpt->{next}) { $currOpt = $currOpt->{next} }

    my $args = ($+{args} || '');
    my $restOfLine = $';
    while (1) {
        ( $restOfLine !~ /^ $reAnyOptNext /x ) && last;
        $restOfLine = $';
        $+{args} && !$args && ($args = $+{args});
        $nextOpt = mkOpt($lineno, $line, $firstOpt);
        $currOpt->chain($nextOpt);
        while ($currOpt->{next}) { $currOpt = $currOpt->{next} }
    }

    $restOfLine =~ /^ \s*(?<desc>$reDescription)?\n?$ /x;
    $nextOpt = $firstOpt;
    do { $nextOpt->{desc} = $+{desc};
         $nextOpt->{args} = ($nextOpt->{args} || $args);
         $nextOpt->init();
    } while ($nextOpt = $nextOpt->{next});
    return $firstOpt;
}

sub AnyOpt { my ($line, $lineno) = @_;
    my $opt = Opt($line, $lineno);
    $opt && return $opt;
    $opt = Command($line, $lineno)
}

sub DescLine { my $line = $_[0];
    my $padding_max = $padding_max+1;
    $$line !~ /^ \s{$padding_max,}([^-\<\[\(\{].*) /x && return 0;
    return new Opts::Option ({ name => 'Line-'.$nameId++, line => $line, desc => $1, type => 'DESC'})
}

sub EmptyLine { my $line = $_[0];
    $$line !~ /^ \s* $/x && return 0;
    return new Opts::Option({ name => 'Line-'.$nameId++, line => $line, type => 'EMPTY'})
}

sub Command  {
    my ($line, $lineno) = @_;
    $$line=~/^$reCommand$/ || return;
    ::debug3 ("Found COMMAND->START     : cmd $2.");
    my $opt = new Opts::Option  { line     => $line, padding  => $1, name     => $2,
                            desc     => $3   , isCmd    => 1 , type     => 'CMD',
                            lineno   => $lineno };
}

1;
