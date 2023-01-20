package main;

use Logs::Log;

sub fromEnv {  my  ($envvar, $defaultval, $envns, $mainapp) = @_;
    $envns = defined $envns ? uc($envns) : uc($ARGV[0]);
    $mainapp = uc($mainapp);
    $envns   =~ s/-/_/g;
    $mainapp =~ s/-/_/g;

    ::debug ("Checking: $envvar, default: $defaultval, envns: $envns, mainapp: $mainapp");
    my $envv = 'HT_APP_'.$envns.'_'.$envvar;
    $envns   && defined $ENV{$envv} 
             && ::debug("Result: ".$ENV{$envv})
             && return  $ENV{$envv};
    
    $envv = 'HT_APP_'.$mainapp.'_SUBCOMMANDS_'.$envvar;
    $mainapp && defined $ENV{$envv}
             && ::debug("Result: ".$ENV{$envv})
             && return  $ENV{$envv};

    $envv = 'HT_'.$envvar;
                defined $ENV{$envv} 
             && ::debug("Result: ".$ENV{$envv})
             && return  $ENV{$envv};
    return $defaultval;
}

sub redirectOptFromEnv {  my  ($optname, $defaultval, $envns, $mainapp) = @_;
    $envns   = uc($envns);
    $mainapp = uc($mainapp);
    $optname = uc($optname);
    $envns   =~ s/-/_/g;
    $mainapp =~ s/-/_/g;
    $optname =~ s/-//g;
    sub env { defined $ENV{$_[1]} && do { ${$_[0]}=$ENV{$_[1]}; 1 } }
    my $ret;
       $optname && $envns   && env(\$ret, 'HT_REDIRECT_'.$envns.'__'.$optname) 
    || $optname && $mainapp && env(\$ret, 'HT_REDIRECT_'.$mainapp.'__ANY__'.$optname)
    ||             $envns   && env(\$ret, 'HT_REDIRECT_'.$envns)
    ||             $mainapp && env(\$ret, 'HT_REDIRECT_'.$mainapp)
    || ($ret = $defaultval);
    $ret =~ s/^(false|no|0)$//ig;
    return $ret;
}

sub numberFromEnv {  my  ($ref2var, $envvar, $defaultval, $ifGreaterThan, $appname, $mainapp) = @_;
    my $envval = fromEnv($envvar, $defaultval, $appname, $mainapp);
    ! ($envval =~ /^\d+$/ && ($envval >= $ifGreaterThan)) && return $defaultval;
    return $$ref2var = $ENV{'HT_'.$envvar} = $envval;
}

sub error {
    print STDERR @_,"\n";
    debug ("ARG ERROR: ", @_);
    usage(*STDERR);
    exit 1;
}

1;