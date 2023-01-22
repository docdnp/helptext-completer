package Trace;

use strict;

sub mapargs {
    no strict 'subs';
    my $i=-1;
    map { 
            $i++; 
            my $h=$_;
            my $s=$_;
            my $rs=$_;
            my $r = ref($_);
            if   (!$r)         { chomp($s); $i.':'.$s }
            elsif($r eq ARRAY ){(map{$i.':'.$r.':'.$_}@$_)}
            elsif($r eq SCALAR){ chomp; $i.':'.$r.':'.$_}
            elsif($r eq GLOB  ){ $i.':'.$r.':'.$_ }
            elsif($r eq CODE  ){ $i.':'.$r.':'.$_ }
            elsif($r eq Option){ my @k = sort keys %$_;(map{ "$i:$r:$_=>[$h->{$_}]" }@k) }
            else{
                eval {my @k = sort keys %$_;(map{ "$i:$r:$_=>[$h->{$_}]" }@k)} 
            }
        } @{$_[0]}
}

sub trace {
    no strict;
    my @pkgs = @_; 
    foreach my $p (@pkgs) {
    local *syms = *{$p.'::'};
    foreach my $k (keys %syms) {
        if ($k ne '__ANON__' && $syms{$k} && *{$syms{$k}}{CODE}) {
            my $func = *{$syms{$k}}{CODE};
            my $funcName = $syms{$k};
            $funcName =~ s/^\*//;
            *{$funcName} = sub {
                ::debug(">$funcName: START: args: [".join("] [", mapargs(\@_)).']');
                my @result = ($func->(@_));
                ::debug(">$funcName: END: result: [".join("] [", mapargs(\@result)).']');
                @result > 1 && return @result;
                return $result[0]
            };

        }
    }
    }
}

1;