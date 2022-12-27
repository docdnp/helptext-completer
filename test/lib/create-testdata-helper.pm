package Testdata;
use strict;

my @optDelims   = qw(, \| \s);
sub OPT_DELIMS_LIST { return @optDelims }
sub OPT_DELIMS { return '["'.join('" "', @optDelims).'"]' }

my $SPECIAL_CHARS = 
    {
        '\s' => " \f\r\t\n",
        '\t' => "\t",
        '\|' => '|',
        '\d' => join('', @{[0..9]}),
        '\D' => join('', map{$_=chr($_)}@{[32..47,58..254]}), 
        '\w' => join('', @{['a'..'z','A'..'Z', 0..9, '_']}),
        '\W' => join('', map{$_=chr($_)}@{[33..47,58..64,91..94,96,123..254]}),
    };
sub SPECIAL_CHARS { return $SPECIAL_CHARS }

package Testdata::Create;

# RandomChar (@additional_characters) -> $random_char
sub RandomChar    { return ['a'..'z','A'..'Z', 0..9, @_]->[rand 62 + @_] }

# ShortOpt () -> $random_shortopt
sub ShortOpt      { return '-'.RandomChar }

# LongOpt () -> $random_longopt
sub LongOpt       { return '--'.RandomString(rand(5)+rand(8)+5, qw(- _)) }

# Command () -> $random_command 
sub Command       { return lc(RandomString(2).RandomString(rand(13)+5, qw(- _))) }

# Whitespaces ($max_random_value[=10], $offset) -> $rand_num_of_whitespaces_plus_offset
#   Examples:
#     Whitespaces(0)          -> Whitespaces(10)
#     Whitespaces(-1)         -> " "
#     len(Whitespaces(10))    in [1..10]
#     len(Whitespaces(10, 5)) in [6..15]
sub Whitespaces   { return ' ' x (int(rand ($_[0] || 10))+1+$_[1]) }

# FixWhitespaces ($lenWhitespaces) -> $whitespaces (len: $lenWhitespaces)
sub FixWhitespaces { return ' ' x int(shift) }

# RandomString ($len[=100], @additional_args) -> $random_string_with_defined_len
sub RandomString { 
    my ($numOfChars, @additionalChars) = ((shift || 100), @_);
    return join('', 
                map{
                    $_ = RandomChar(@additionalChars)
                }(1..$numOfChars)
            ) 
}

# RandomWords ($lowLenBound[=60], $highLenBound[=150]) -> $random_word_string_in_bounds
sub RandomWords {
    my $lowBound  = ($_[0] || 60);
    my $highBound = ($_[1] || 150);
    my $boundDiff = $highBound - $lowBound;
    return RandomString(
        int(rand($boundDiff)) + $lowBound,
        (map{$_=' '}(1..20))
    )
}

# RandomOptDelim
#   ($addWhitespaceSuffix[=0], $returnUnmappedSpecChar[=0]) 
#       -> $delimiter (in TestData::SHORT_LONG_OPT_DELIMITERS)
sub RandomOptDelim  { 
    my $delim  = [@optDelims]->[int(rand(@optDelims))-1];
    $_[1] && return $delim.($_[0] && ' '); 

    defined ($SPECIAL_CHARS->{$delim}) && do {
        my $matchingChars = $SPECIAL_CHARS->{$delim};
    
    return (split(//,$SPECIAL_CHARS->{$delim}))[
                    int(
                        rand(
                            length($matchingChars)
                        )-1
                    )
                ].($_[0] && ' ') 
    };
}

# RandomArg ($len, $bracketType) => $arg
#   Examples:
#     RandomArg()        =>   No brackets, uppercase, random length
#     RandomArg(0)       =>   No brackets, uppercase, random length
#     RandomArg(0, *)    =>   Random brackets, mixed case, random length
#     RandomArg(N, '[]') =>   Square brackets, mixed case, length is N
sub RandomArg {
    my ($len, $bracketType)  = @_;
        $len = ($len || int(rand(12))+3);
    my $arg = RandomString($len, $len);
    my @bracketTypes = qw([] () {} <>);
    $bracketType eq '[]' && return '['.$arg.']';
    $bracketType eq '()' && return '('.$arg.')';
    $bracketType eq '{}' && return '{'.$arg.'}';
    $bracketType eq '<>' && return '<'.$arg.'>';
    $bracketType eq '*'  && return RandomArg($len, $bracketTypes[int(rand(4))]);
    return uc($arg);
}

1;