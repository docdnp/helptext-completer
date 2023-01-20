package Trace;

use strict;

sub trace {
    no strict 'refs';
    require FindBin;
    my $file = $FindBin::RealBin.'/'.$FindBin::RealScript;
    open my $script, '<'.$file or die "Could not open: $file\n";
    my $pkgName;
    sub mapargs {
        no strict 'subs';
        my $i=-1;
        map { $i++; my $h=$_; my $r = ref($_); if(!ref($_))   { $i.':'.$_ }
                     elsif($r eq ARRAY ){(map{$i.':'.$r.':'.$_}@$_)}
                     elsif($r eq SCALAR){ $i.':'.$r.':'.$$_}
                     elsif($r eq GLOB  ){ $i.':'.$r.':'.$_ }
                     elsif($r eq CODE  ){ $i.':'.$r.':'.$_ }
                     elsif($r eq Option){ my @k = sort keys %$_;(map{ "$i:$r:$_=>[$h->{$_}]" }@k) }
                     else{eval {my @k = sort keys %$_;(map{ "$i:$r:$_=>[$h->{$_}]" }@k)} }
                     } @{$_[0]}
    }
    while (<$script>) {
        $_ =~ /^package\s+(.*?)\s*;/ && ($pkgName = $1);
        $pkgName eq 'main' && next;
        $_ =~ /^sub\s+(.*?)[\s\{\()]/ && do {
            my $subname = $pkgName.'::'.$1;
            *{$subname.'_'} = \&{$subname};
            *{$subname} = sub {
                ::debug(">$subname","args: [".join("] [", mapargs(\@_)).']');
                my @result = (&{$subname.'_'}(@_));
                ::debug(">$subname","result: [".join("] [", mapargs(\@result)).']');
                @result > 1 && return @result;
                return $result[0]
            };
        };
        $_ =~ /^\s*__END__\s*/ && return;
    }
}

1;