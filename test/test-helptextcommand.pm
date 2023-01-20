package Test::HelptextCommand;
use Test::More;
use strict;
use warnings;

my @optdefs = (
    new Opts::Option({ name => '--test', args => '' }),
    new Opts::Option({ name => '--last', args => 'arg1' }),
    new Opts::Option({ name => '--next', args => 'arg1 arg2' }),
    new Opts::Option({ name => '--down', args => '[arg1]' }),
    new Opts::Option({ name => '--fear', args => '[arg1] [arg2]' }),
);

subtest "Find last valid option in CLI args (for main command)" => sub {
  my @testdata = (
    { cliargs => [ qw(cmd --any --opt --test and some data)           ], 
        optname => '--test', optindex => 3 },
    { cliargs => [ qw(cmd --any --opt --last arg1 and some data)      ], 
        optname => '--last', optindex => 3 },
    { cliargs => [ qw(cmd --any --opt --next arg1 arg2 and some data) ], 
        optname => '--next', optindex => 3 },
    { cliargs => [ qw(cmd --any --opt --down arg1 and some data)      ], 
        optname => '--down', optindex => 3 },
    { cliargs => [ qw(cmd --any --opt --fear arg1 arg2 and some data) ], 
        optname => '--fear', optindex => 3 },
  );
  for (@testdata) {
    my ($opt, $optindex) = HelptextCommand::LastOption ($_->{cliargs}, 0, \@optdefs);
    ok($opt , "Expecting last option $_->{optname} exists.") &&
    is($opt->{name} , $_->{optname} , "Find last option. Expected $_->{optname}. Actual $opt->{name}");
    ok($optindex, "Expecting last option index $_->{optindex} exists.") &&
    is($optindex, $_->{optindex}, "Find index of last option. Expected $_->{optindex}. Actual $optindex");
  }
};

subtest "Find last valid option in CLI args found after subcommands" => sub {
  my @testdata = (
    { cliargs => [ qw(cmd --any --opt subcmd --test and some data)           ], 
        optname => '--test', optindex => 4, subcmd => 'subcmd', subcmdpos => 3 },
    { cliargs => [ qw(cmd --any subcmd --opt --last arg1 and some data)      ], 
        optname => '--last', optindex => 4, subcmd => 'subcmd', subcmdpos => 2 },
    { cliargs => [ qw(cmd subcmd --any --opt --next arg1 arg2 and some data) ], 
        optname => '--next', optindex => 4, subcmd => 'subcmd', subcmdpos => 1 },
    { cliargs => [ qw(cmd --any subcmd --opt --down arg1 and some data)      ], 
        optname => '--down', optindex => 4, subcmd => 'subcmd', subcmdpos => 2 },
    { cliargs => [ qw(cmd --any --opt subcmd --fear arg1 arg2 and some data) ], 
        optname => '--fear', optindex => 4, subcmd => 'subcmd', subcmdpos => 3 },
  );

  for (@testdata) {
    my ($opt, $optindex) = HelptextCommand::LastOption ($_->{cliargs}, $_->{subcmdpos}, \@optdefs);
    ok($opt , "Expecting last option $_->{optname} exists.") &&
    is($opt->{name} , $_->{optname} , "Find last option. Expected $_->{optname}. Actual $opt->{name}");
    ok($optindex, "Expecting last option index $_->{optindex} exists after subcommand '$_->{subcmd}'") &&
    is($optindex, $_->{optindex}, "Find index of last option. Expected $_->{optindex}. Actual $optindex");
  }
};

subtest "Ignore options in CLI args found before subcommand" => sub {
  my @testdata = (
    { cliargs => [ qw(cmd --any --opt --test subcmd and some data)           ], 
        optname => '', optindex => '', subcmd => 'subcmd', subcmdpos => 4 },
    { cliargs => [ qw(cmd --any --opt --last arg1 subcmd and some data)      ], 
        optname => '', optindex => '', subcmd => 'subcmd', subcmdpos => 5 },
    { cliargs => [ qw(cmd --any --opt --next arg1 arg2 subcmd and some data) ], 
        optname => '', optindex => '', subcmd => 'subcmd', subcmdpos => 6 },
    { cliargs => [ qw(cmd --any --opt --down arg1 subcmd and some data)      ], 
        optname => '', optindex => '', subcmd => 'subcmd', subcmdpos => 5 },
    { cliargs => [ qw(cmd --any --opt --fear arg1 arg2 subcmd and some data) ], 
        optname => '', optindex => '', subcmd => 'subcmd', subcmdpos => 6 },
  );

  for (@testdata) {
    my ($opt, $optindex) = HelptextCommand::LastOption ($_->{cliargs}, $_->{subcmdpos}, \@optdefs);
    ok(!$opt , "Expecting no opt is found after subcommand '$_->{subcmd}'.");
    ok(!$optindex, "Expecting option index $_->{optindex} is not returned.");
  }
};

subtest "Find help command if CLI args contain valids subcommand" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1), '' ], 
        cmd => 'cmd valid-subcmd-1' },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2 --opt2 arg2) ], 
        cmd => 'cmd valid-subcmd-2' },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3 --opt2 arg2) ], 
        cmd => 'app valid-subcmd-3' },
    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        is($res->{cmd}, 
        $td->{cmd}, 
        "Expect full help command '$td->{cmd}' for valid subcommand. Actual is '$res->{cmd}'.")
    }
    teardown();
};

subtest "Ignore help command for even valid subcommands if current arg in CLI args is the subcommand itself" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1) ], 
        cmd => 'cmd' },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2) ], 
        cmd => 'cmd' },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3) ], 
        cmd => 'app' },
    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        is($res->{cmd}, 
        $td->{cmd}, 
        "Expect full help command '$td->{cmd}' for valid subcommand. Actual is '$res->{cmd}'.")
    }
    teardown();
};

subtest "Find correct environment namespace if CLI args contain valid subcommand" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1), '' ], 
        envns => 'cmd_valid_subcmd_1' },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2 --opt2 arg2) ], 
        envns => 'cmd_valid_subcmd_2' },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3 --opt2 arg2) ], 
        envns => 'app_valid_subcmd_3' },
    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        is($res->{envns}, $td->{envns}, "Expect environment namespace '$td->{envns}' for valid subcommand. Actual is '$res->{envns}'.")
    }
    teardown();
};

subtest "Ignore environment namespace for even valid subcommands if current arg in CLI args is the subcommand itself" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1) ], 
        envns => 'cmd' },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2) ], 
        envns => 'cmd' },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3) ], 
        envns => 'app' },
    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        is($res->{envns}, $td->{envns}, "Expect environment namespace '$td->{envns}' for valid subcommand. Actual is '$res->{envns}'.")
    }
    teardown();
};

subtest "Find subcommand name and index if CLI args contain valid subcommand" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1), '' ], 
        subcmd => { name => 'valid-subcmd-1', pos => 1 } },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2 --opt2 arg2) ], 
        subcmd => { name => 'valid-subcmd-2', pos => 3 } },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3 --opt2 arg2) ], 
        subcmd => { name => 'valid-subcmd-3', pos => 4 }  },

    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        ok($res->{subcmd}, "Expect 'subcmd' within valid result.") || next;
        is($res->{subcmd}->{name}, $td->{subcmd}->{name}, "Expect to find subcommand name  '$td->{subcmd}->{name}' for valid subcommand. Actual is '$res->{subcmd}->{name}'.");
        is($res->{subcmd}->{pos} , $td->{subcmd}->{pos} , "Expect to find subcommand index '$td->{subcmd}->{pos}' for '$td->{subcmd}->{name}'. Actual is '$res->{subcmd}->{pos}'.")
    }
    teardown();
};

subtest "Ignore even valid subcommand name and index if current arg in CLI args is the subcommand itself" => sub {
    setup();
    my @testdata = (
     { cliargs => [ qw(cmd valid-subcmd-1) ] },
     { cliargs => [ qw(cmd --opt arg1 valid-subcmd-2) ] },
     { cliargs => [ qw(app other-subcmd --opt arg1 valid-subcmd-3) ] },

    );
    foreach my $td (@testdata) {
        my $res = HelptextCommand::HelpCmdForSubcommand('cmd', '--help', $td->{cliargs});
        ok($res, "Expect to get a valid result for CLI args: ".join(' ', @{$td->{cliargs}})) &&
        ok(!$res->{subcmd}, "Expect key 'subcmd' is missing in valid result.")
    }
    teardown();
};

# ---------------------------------------------------------------------------------------
my $funcs = {};

sub setup {
    no strict; no warnings;
    $funcs = {};
    $funcs->{'HelptextCommand::Open'} = \&{HelptextCommand::Open};
           *{'HelptextCommand::Open'} = \&openFakeHelpText;
}

sub teardown {
    no strict; no warnings;
    for(my ($k, $v) = each %$funcs) { *{$k} = $v }
}

sub openFakeHelpText {
    my $data;
    open my $whandle, '>', \$data or die $!;
    open my $rhandle, '<', \$data or die $!;
    for (1..10) {
        print $whandle "    valid-subcmd-$_         some description for valid-subcmd-$_\n"
    }
    return $rhandle;
}
