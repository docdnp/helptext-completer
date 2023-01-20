package Opts::Option;
use strict;
use Exporter qw(import);

our @EXPORT = qw(new);

my @RW = qw( args lineno cliindex needsArgs );

sub new { my ($class, $args) = @_;
    my  $self = { name => '', isCmd   => 0 , line    => '', lineno   => 0,
                  desc => '', padding => '', args    => '', pad2Args => 0, 
                  prev => 0 , next    => 0 , numArgs => 0 , pad2Desc => 0 , 
                  type => '', hasOptArgs => 0, cliindex => 0, needsArgs => 0
                };
    $args && ($self = { %$self , %$args });
    $self = bless($self, $class)->init();
    # Internals::SvREADONLY(%$self,1);
    # while(my ($k,$v) = each %$self) {
    #     grep (/$k/, @RW )|| Internals::SvREADONLY($v,1);
    # }
    return $self
}

sub init { my $self = $_[0];
    $self->{args} =~ /^\s*\[/ && ($self->{hasOptArgs} = 1);
    $self->{args} =~ s/^\[=(.*?)\]$/$1/;
    $self->{args} =~ s/^[=\s]*//;
    $self->{args} =~ s/\s*$//;
    $self->{numArgs}  = () = $self->{args} =~ /(?:[^\s]+)/g;
    $self->{line} && do {
        $self->{pad2Desc} = index(${$self->{line}}, $self->{desc});
        $self->{pad2Args} = index(${$self->{line}}, $self->{args});
    };
    return $self
}

sub copyDescription { my ($dest, $source, $onlyPadding) = @_;
    my $self = $dest;
    $dest->{pad2Args} && $dest->{pad2Desc} && $dest->{pad2Args} == $source->{pad2Desc} 
        && return $dest->useArgsAsDesc();
    do {
        $dest->{desc} = ($onlyPadding ? "?" : $source->{desc});
        $dest->{pad2Desc} = $source->{pad2Desc};
        $source = $dest;
    } while ($dest = $dest->{next});
    return $self;
}

sub useArgsAsDesc { my ($dest, $source) = @_;
    my $self = $dest;
    $source = $dest;
    do {
        $dest->{pad2Desc} = $source->{pad2Args};
        $dest->{desc}     = $source->{args};
        $dest->{pad2Args} = 0;
        $dest->{args}     = '';
        $source = $dest;
    } while ($dest = $dest->{next});
    return $self;
}

sub chain { my ($self, $nextOpt) = @_;
    $self->{next} = $nextOpt;
    $nextOpt->{prev} = $self;
}

1;
