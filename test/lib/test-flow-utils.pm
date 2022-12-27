package TestFlow;
use Test::More;

my $FATAL_TEXT = ""; 

sub fatal {
    @_ && ($FATAL_TEXT = $_[0]);
    return $FATAL_TEXT
}

sub test_to_be_implemented {
    my $result = ($_[0] || 1);
    ok(1); print ("    => NOT IMPLEMENTED YET!!!!")
}

sub format_fatal {
    my $ret;
    $ret.="# Skipping all following tests!!!\n#\n# Reason:\n";
    for(split(/\n/, $FATAL_TEXT)){ 
        $ret.="#   $_\n";
    }
    $ret.="#";
    return \$ret
}

sub exit_fatal {
print STDOUT <<EOF;
# -----------------------------------------------------------------
# WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!!
# =================================================================
${format_fatal()}
# =================================================================
# WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!!
# -----------------------------------------------------------------
EOF
exit 1
}
1;