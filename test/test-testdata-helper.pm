package Test::TestDataHelper;
use Test::More;
use strict;
use warnings;

sub fatal { 
my $listItem = '   -';
my $dep_tests=$listItem.join("\n$listItem", unittests::get_test_modules());

TestFlow::fatal(
"Failures in TestData::Create produce failures in later tests.
The following test modules are skipped:
${\$dep_tests}

Fix TestData::Create or its tests BEFORE you continue!!!
")
}

subtest "Helper: Create random char (Testdata::Create::RandomChar)" => sub {

    is(
        scalar(@{['a'..'z','A'..'Z', 0..9]}), 
        62, 
        "Default char list ['a'..'z','A'..'Z', 0..9] has 62 chars"
    ) || fatal;

    subtest "Helper: Return every char randomly." => sub {
        my %random_chars;
        while (1) {
            my $char = Testdata::Create::RandomChar;
            $random_chars{$char} = 1;
            scalar(%random_chars) == 62 && last
        }
        is(scalar(%random_chars), 62, "Saw every char:\n  => ["
            .join(' ', keys %random_chars)
            ."]"
        ) || fatal;
    };
    subtest "Helper: Return chars from additional list randomly." => sub {
        my @additional_chars = qw(: ; \ /);
        my %additional_chars;

        for (@additional_chars) { $additional_chars{$_}++ }

        while (scalar(%additional_chars)) {
            my $char = Testdata::Create::RandomChar @additional_chars;
            exists  $additional_chars{$char} &&
             delete $additional_chars{$char};
        }
        is(scalar(%additional_chars), 0, "Saw all additional args\n => ["
            .join(' ', @additional_chars) 
            ."]"
        ) || fatal;
    };
};

subtest "Helper: Create valid short opts (Testdata::Create::ShortOpt)" => sub {
    my $optMatcher = qr/^-[a-z\d]$/i;
    for(1..10) {
        my $shortOpt = Testdata::Create::ShortOpt;
        like($shortOpt, $optMatcher, 
            "Short opt '$shortOpt' matches $optMatcher") || fatal;
    }
};

subtest "Helper: Create valid long opts (Testdata::Create::LongOpt)" => sub {
    my $optMatcher = qr/^--[\w-]+$/i;
    for(1..10) {
        my $longOpt = Testdata::Create::LongOpt;
        like($longOpt, $optMatcher, 
            "Long opt '$longOpt' matches $optMatcher") || fatal;
    }
};

subtest "Helper: Create valid commands (Testdata::Create::Command)" => sub {
    my $w = qw(a-z0-9\d_);
    my $optMatcher = '/^['.$w.']['.$w.'-]+$/';
    for(1..10) {
        my $command = Testdata::Create::Command;
        like($command, $optMatcher, 
            "Command '$command' matches $optMatcher") || fatal;
    }
};

subtest "Helper: Create whitespace string (Testdata::Create::Whitespaces)" => sub {
    my $maxLenWsString = 5; my $offset = 5; my $char;
    subtest "Define length range: Testdata::Create::Whitespaces($maxLenWsString) always in [1,$maxLenWsString]." => sub {
        my %wsStrings;
        my $wsMatcher = qr/^[ ]+$/;
        while (scalar(%wsStrings) < $maxLenWsString) {
            my $ws = Testdata::Create::Whitespaces($maxLenWsString);
            $wsStrings{length($ws)} = $ws;
        }
        for (keys %wsStrings) {
            ok($_< $maxLenWsString + 1 && $_ >= 1, "Whitespace string in [1,$maxLenWsString]: [$_:($wsStrings{$_})]") || fatal;
        }
        for (keys %wsStrings) {
            like($wsStrings{$_}, $wsMatcher, "Whitespace string matches: $wsMatcher") || fatal;
        }

    };

    my $ws = Testdata::Create::Whitespaces(-1);
    is($ws, ' ', "Shortest possible WSS (length=1): Testdata::Create::Whitespaces(0) => ' '") || fatal;

    subtest "Use length offset: Testdata::Create::Whitespaces($maxLenWsString, $offset) always in [1+$offset,$maxLenWsString+$offset]." => sub {
        my %wsStrings;
        my $wsMatcher = qr/^[ ]+$/;
        while (scalar(%wsStrings) < $maxLenWsString) {
            my $ws = Testdata::Create::Whitespaces($maxLenWsString, $offset);
            $wsStrings{length($ws)} = $ws;
        }
        for (keys %wsStrings) {
            ok($_< $maxLenWsString + 1 + $offset && $_ >= $offset, "Whitespace string in [$offset,$maxLenWsString+$offset]: [$_:($wsStrings{$_})]") || fatal;
        }
        for (keys %wsStrings) {
            like($wsStrings{$_}, $wsMatcher, "Whitespace string matches: $wsMatcher") || fatal;
        }

    };

};

subtest "Helper: Create fixed whitespace string (Testdata::Create::FixWhitespaces)" => sub {
    foreach my $len (1..10) {
        my $ws = Testdata::Create::FixWhitespaces($len);
        is(length($ws), $len, "Create whitespace string of length: $len") || fatal;
        like($ws, qr/^\s+$/ , "Fixed whitespace string contains only whitespaces: [$ws]") || fatal
    }
};

subtest "Helper: Create random string (Testdata::Create::RandomString)" => sub {
    my $maxLenWsString = 5; my $offset = 5; my $char;
    subtest "Define length of random string." => sub {
        for(1..5) {
            my $len = 20*$_;
            my $string = Testdata::Create::RandomString($len);
            is(length($string), $len, "Defined length $len matches string length ".length($string).'.') || fatal;
        }
    };
    subtest "Use additional chars for random string." => sub {
        my @additional_chars;
        my $len = 100;
        for(1..100) { push @additional_chars, ' ' }
        for(1..5) {
            my $string = Testdata::Create::RandomString(100, @additional_chars);
            like($string, qr/[ ]/, "Added WS to additional args: String contains whitespaces.") || fatal;
        }
    };

};

subtest "Helper: Create random words within bounded length (Testdata::Create::RandomWords)" => sub {
    my @words;
    for (1..3) {
        my $lowBound  = int(rand(20))+30;
        my $highBound = int(rand(50))+100;
        for (1..5) {
            my $words           = Testdata::Create::RandomWords($lowBound, $highBound);
            my $numOfWordDelims = scalar(@words = $words =~ /\s+/g);
            my $lenWords        = length($words);

            ok($lenWords >= $lowBound , "String of words is longer than low bound  : $lenWords >= $lowBound.") || fatal;
            ok($lenWords <= $highBound, "String of words is shorter than high bound: $lenWords <= $highBound.\n => [$words]") || fatal;
            ok($numOfWordDelims > 0   , "String of words has ".($numOfWordDelims + 1)." words.") || fatal;
        }
    }  
};

subtest "Helper: Create long/short option delimiter (Testdata::Create::RandomOptDelim)" => sub 
{
    my %delims;

    subtest "When called often enough '::RandomOptDelim' all opt delimiters." 
    => sub {
        my $delimCount = scalar(Testdata::OPT_DELIMS_LIST());
        for (1..10000) {
            scalar(%delims) < $delimCount || next;
            $delims{Testdata::Create::RandomOptDelim('',1)} = 1
        }
        is(scalar(%delims), $delimCount, 
            "All $delimCount delimiters were produced: [\"".
                (join('" "', keys(%delims))).
            '"]' ) || fatal;
    };

    subtest "Defined opt delimiters match what they say." 
    => sub {
        my $specialChars = Testdata::SPECIAL_CHARS();

        sub shortenListString {
            my ($listStr, $minLenToShorten) = @_;

            length($listStr) <= $minLenToShorten 
                && return '['.$listStr.']';
            return '['.substr($listStr,0,$minLenToShorten)." ...'".']'
        }

        my ($testStr, $testStrLen, @matches);
        foreach my $delim (keys(%delims)){
            $testStr    = exists $specialChars->{$delim} ? $specialChars->{$delim} : $delim;
            $testStrLen = length($testStr);

            like($testStr, qr/$delim/, "Delim ".$delim." matches such delimiters: '"
                .shortenListString($testStr, 30)) || fatal;

            is(scalar(@matches = ($testStr =~ /$delim/sg)), $testStrLen,"Delim ".$delim.' matches '
                .$testStrLen.'x :'
                .shortenListString($testStr, 30)) || fatal
        }
    }

};

1;