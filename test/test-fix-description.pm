package Test::FixDescription;
use Test::More;
use strict;
use warnings;

subtest "Find description in following lines" => sub {
    setup();
    clearOptlist();

    my @testdata = testData();
    $testdata[1]->[0] =~ /^(\s+)/;
    my $paddingCnt = length($1);

    is($paddingCnt, $testdata[1]->[1], 
        "Testing Setup: Expecting pad2desc of $testdata[1]->[1] in testdata[1]. Actual:"
        .$paddingCnt);
    is(scalar(@{optlist()}), 0,
        "Testing Setup: Expecting optlist being empty. Actual number of elements:"
        .scalar(@{optlist()}));

    my ($allopts) = helptext::completer::find_options(['dummycmd', '-'], 'dummycmd', '--help');

    is(scalar(@$allopts), 2, 
        "Expecting 2 option. Actual: "
        .scalar(@$allopts));
    is($allopts->[-1]->{name}, '--foo', 
        "Expecting option --foo at end (-1) of detected optlist. Actual: "
        .$allopts->[-1]->{name});
    is($allopts->[-2]->{name}, '--test', 
        "Expecting option --test one before end (-2) of detected optlist. Actual: "
        .$allopts->[-2]->{name});
    is($allopts->[-1]->{pad2Desc}, $paddingCnt, 
        "Expecting option --foo with pad2desc=".$paddingCnt.". Actual: "
        .$allopts->[-1]->{pad2Desc});
    is($allopts->[-2]->{pad2Desc}, $paddingCnt, 
        "Expecting option --test with pad2desc=".$paddingCnt.". Actual: "
        .$allopts->[-2]->{pad2Desc});

    teardown();
};

# ---------------------------------------------------------
my $funcs = {};
my $OPT_LIST;

sub setup {
    no strict; no warnings;
    $funcs->{'Opts::Store::new'}                      = \&{Opts::Store::new};
    *{'Opts::Store::new'}                             = \&newOptsStore;
    $funcs->{'HelptextCommand::Open'}                 = \&{HelptextCommand::Open};
    *{'HelptextCommand::Open'}                        = \&openTestData;
    $funcs->{'HelptextCommand::HelpCmdForSubcommand'} = \&HelptextCommand::HelpCmdForSubcommand;
    *{'HelptextCommand::HelpCmdForSubcommand'}        = sub { return { cmd => $_[1] } };

    my $DESC_INDENT = ' ' x 25;
    $OPT_LIST = [
        new Opts::Option({type => 'SHORT', desc => "Test bla bla"  , line => \"${DESC_INDENT} Test bla bla"}),
        new Opts::Option({type => 'LONG', desc => "Test bla bla 2", line => \"${DESC_INDENT}Test bla bla 2"}),
        new Opts::Option({type => 'CMD', desc => "Test bla bla"  , line => \"${DESC_INDENT} Test bla bla"}),
        new Opts::Option({type => 'CMD', desc => "Test bla bla 2", line => \"${DESC_INDENT} Test bla bla 2"}),
    ];
}

sub teardown {
    no strict; no warnings;
    for(my ($k, $v) = each %$funcs) { *{$k} = $v }
}

sub testData {
    return (
        [ q(          --test, --foo)                            , 22 ],
        [ q(                      description after 22 spaces)  , 22 ],
    )
}

sub openTestData {
    my $data;
    open my $whandle, '>', \$data or die $!;
    open my $rhandle, '<', \$data or die $!;
    for (testData()) {
        print $whandle "$_->[0]\n";
    }
    return $rhandle;
}

sub optlist         { $OPT_LIST }
sub clearOptlist    { $OPT_LIST = [] }
sub newOptsStore    { bless { allopts => optlist() } , 'Opts::Store' }

1;
