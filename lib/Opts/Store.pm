package Opts::Store;
use strict;
use warnings;

sub new { my ($class) = @_;
    my  $self = { allopts   => [],
                  optcache  => {},
                  optbuffer => [],
                };
    return bless($self, $class);
}

sub allOpts  { my $me = shift; return $me->{allopts} }
sub optCache { my $me = shift; return $me->{optcache} }
sub inCache  { my ($me, $opt) = @_; exists $me->{optcache}->{$opt->{name}} }
sub toCache  { my ($me, $opt) = @_; $me->{optcache}->{$opt->{name}} = $opt }
sub store    { my ($me, $opt) = @_;
    do { ( ! $opt || $me->inCache($opt) ) || do {
        ::debug3("Storing: $opt->{name} args:[$opt->{args}] padding:[$opt->{padding}] pad2Desc:[$opt->{pad2Desc}]");
        push @{$me->{allopts}}, $me->toCache($opt);
    }}
    while($opt = $opt->{next});
}

sub knownOptWithDescription { my ($me, $opt) = @_;
    my $prevOpt;
    for (my $prevOptIdx = @{$me->{allopts}}-2; $prevOptIdx != 0; $prevOptIdx--) {
        $prevOptIdx < 0 && last;
        $prevOpt = $me->{allopts}->[$prevOptIdx];
        $prevOpt->{type} eq 'CMD' && next;
        $prevOpt->{pad2Desc} && return $prevOpt;
    }
}

sub tryToFixDescription { my ($me, $opt, $line) = @_;
    ! $opt && return;
    if (!$opt->{pad2Desc} && $opt->{numArgs} > 1) {
        $opt->{args} =~ /^(?:[\w\-\d]+)(?:\s+[\w\-\d]+)*$/ 
            && $opt->useArgsAsDesc()
    }
    if (!$opt->{pad2Desc}) {
        my $nextOpt = Opts::Find::DescLine(\$_);
        ::debug2("Check opt: ".($opt && $opt->{name}));
        ::debug2("Next  opt: ".($nextOpt && $nextOpt->{name}.": $nextOpt->{pad2Desc}"));

        $nextOpt && $opt->copyDescription($nextOpt) 
            && return;

        ::debug2("Buffering: ".($opt && $opt->{name}));
        push(@{$me->{optbuffer}}, $opt);
    }
    elsif ($opt->{pad2Desc} && @{$me->{optbuffer}}) {
        foreach my $bopt (@{$me->{optbuffer}}) {
            $bopt->copyDescription($opt, 1);
        }
        $me->{optbuffer} = []
    }
}

1;
