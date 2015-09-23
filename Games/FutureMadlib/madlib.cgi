#!/usr/bin/perl

# NOTE: This is a perl 5 script.  Be sure to change the call if needed
#    on your machine.
# madlib.cgi
# Copyright 1999 Andrew Rahn      rahn@ucsub.colorado.edu

# A crazy madlib.

###########################################################################
# Local variables -- these may need to be changed

### This program as an ACTION on a FORM tag
$progname ="$ENV{SCRIPT_NAME}";

### This program can run as either a command line or CGI
$isCGI = defined($ENV{"SCRIPT_NAME"});

@wordTypes = ('adverb', 'adjective', 'proper noun', 'past-tense verb',
    'present-tense verb', 'verb-ing', 'infinitive', 'pluralnoun', 'noun', 'verb', 'name',
    'interjection', 'person', 'famous role', 'food', 'thing', 'room',
    'number', 'expression', 'dogbreed', 'tvshow', 'animal', 'place' );

%wordDesc = (
	'adverb' => ['An adverb', 'An adverb is a word that modifies a verb.  Most adverbs end in -ly.  For example, "quickly" and "happily" are adjverbs.'],
	'adjective' => ['An adjective', 'An adjective is a word that modifies a noun.  For example, "quick" and "happy" are adjectives.'],
	'proper noun' => ['A proper noun', 'A proper noun is a name of a person or place.  Proper nouns are capitalized.  For example, "Mount Rushmore" and "Bette" are proper nouns.'],
	'past-tense verb' => ['A past-tense verb', 'A verb is in the past-tense if it is an action that has already happened.  Past-tense verbs often end in -ed.  For example, the past-tense of "run" is "ran".  The past-tense of "explode" is "exploded".'],
	'present-tense verb' => ['A present-tense verb', 'A verb is in the present-tense if it is currently happening.  For example, the present-tense of "run" is "runs".'],
	'verb-ing' => ['A verb ending in -ing', 'A verb that ends in -ing can be used as a verb or an adjective.  For example "The running faucet" uses the word "running" as an adjective.  "The faucet is running" uses the word "running as a verb.'],
	'infinitive' => ['An infinitive', 'An infinitive is a verb with the word "to" in front of it.  For example, "to be" or "to run".'],
	'pluralnoun' => ['A plural noun', 'A plural noun is a word for more than one person, place or thing.  A plural noun almost always ends in -s.  For example "cars" or "shoes" but also "geese".'],
	'verb' => ['A verb', 'A verb is a word that does something, or is an action.  For example "run" or "explode".'],
	'noun' => ['A noun', 'A noun is a word for a person, place or thing.  For example, "car" "shoe" or "goose".'],
	'name' => ['A name', 'A name is somebody\'s name.  For example "Rachel" or "Becka".'],
	'interjection' => ['An interjection', 'An interjection is something you might say in a moment of panic.  For example, "Oh my goodness" or "Watch out".'],
	'person' => ['A person', 'A person is a name of someone famous or someone you know.  For example, "George Washington" or "Mom".'],
	'famous role' => ['A famous roll', 'A famous roll.'],
	'food' => ['A food', 'A food is something you eat.  For example, "banana" or "potato".'],
	'thing' => ['A thing', 'A thing is a thing.'],
	'room' => ['A room in a house', 'A room in a house is any place inside.  For example, "Dining Room", "Hall" or "Foyer".'],
	'number' => ['A number', 'A number is a word that describes quantity.  For example "five" "7" or "three point one".'],
	'expression' => ['An expression', 'An expression is a saying that people say over and over.  For example "Well you don\'t see that every day" or "Snug as a bug in a rug".'],
	'dogbreed', ['A dog breed', 'A dog breed is a variety of domesticated canine.  For example, "St Bernard", "Laborador Retreiver" or "Slipper dog".'],
	'tvshow', ['A TV Show', 'A TV show is a half-hour or an hours worth of entertainment interrupted frequently by advertisements for things you don\'t want accompanyied by annoying jingles.  For example, "Blue\'s Clues" or "The West Wing".'],
	'animal', ['An animal', 'An animal is a multi-cellular living organism whose cells lack a cell wall.  For example, "rainbow trout", "jaguar" and "tick" are all animals.'],
	'place', ['A place', 'Somewhere in the world, or out of this world.  For example "Paris" or "Mars" or "upstairs".']
);
### Get started....
print("Content-type: text/html\n\n");

&ReadParse;   #Read the input--it had better be in multipart format
### The map file
if (defined($in{'file'})) {
  $madLibFile = $in{'file'};
}
else {
  $madLibFile = "madlib.html";
}

###########################################################################
# Select process

if (defined($in{'process'})) {
  &OutputLib;
  exit 0;
}
if (defined($in{'intro'})) {
  open(TEMP, $in{'intro'});
  $START = \*TEMP;
}
else {
  $START = \*DATA;
}
&LoadLib;
&Startup;

sub LoadLib {
  %wordList = ();
  open(LIB, $madLibFile);
  while(<LIB>) {
    foreach $type (@wordTypes) {
      while(/$type\d/gi) {
        unless (defined ($wordList{lc $&})) {
          $wordList{lc $&} = $type;
        }
      }
    }
  }
}

sub OutputLib {

  open(LIB, $madLibFile);
  while(<LIB>) {
    foreach $word (reverse sort keys %in) {
      eval ('s/(' . lc($word) . ')/lc($in{lc $&})/eg;');
      eval ('s/(' . uc($word) . ')/uc($in{lc $&})/eg;');
      eval ('s/(' . ucfirst($word) . ')/ucfirst($in{lc $&})/eg;');
      eval ('s/(' . $word . ')/$in{lc $&}/ieg;');
    }
    print;
  }
}

# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

sub Startup {
    select(STDOUT);
# make input separator equal to <!--Madlib Form-->
# this makes the input file split along that token
# rather than the default of line-by-line
    $/ = "<!--Madlib Form-->";
    $temp = <$START>;
    print $temp;
    print("<form method='GET' action='$progname'>\n");
    print("<TABLE>\n");
    my @keys = keys %wordList;
    fisher_yates_shuffle(\@keys);
    foreach $word (@keys) {
      print("<TR><TD><A TITLE='$wordDesc{$wordList{$word}}[1]'>\n");
      print("$wordDesc{$wordList{$word}}[0] : </TD><TD>\n");
      print("<INPUT NAME=\"$word\" TYPE=\"text\" SIZE=\"20\"></TD></TR>\n");
    }
    print("<TR><TD ALIGN='CENTER' COLSPAN=2>\n");
    print("<input type='hidden' name='file' value='$madLibFile'>\n");
    print("<BR><input type='submit' name='process' value='Make My MadLib'>\n");
    print("</TD></TR>\n");
    print("</TABLE>\n");
    print("</form>\n");
    print <$START>;
}


###########################################################################
# Perl Routines to Manipulate CGI input
# Andrew Rahn 1999
#
# Copyright 1999 ?
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.

# ReadParse
# Reads in GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter (e.g., *cgi_input) is passed to ReadParse,
# information is stored there, rather than in $in, @in, and %in.

sub ReadParse {
  if (@_) {
    local (*in) = @_;
  }

  local ($i, $loc, $key, $val);

  # Read in text
  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    for ($i = 0; $i < $ENV{'CONTENT_LENGTH'}; $i++) {
      $in .= getc;
    }
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert plus's to spaces
    $in[$i] =~ s/\+/ /g;

    # Convert %XX from hex numbers to alphanumeric
    $in[$i] =~ s/%(..)/pack("c",hex($1))/ge;

    # Split into key and value.
    $loc = index($in[$i],"=");
    $key = substr($in[$i],0,$loc);
    $val = substr($in[$i],$loc+1);
    $in{$key} .= '\0' if (defined($in{$key})); # \0 is the multiple sep
    $in{$key} .= $val;
  }
  return 1; # just for fun

}

__END__
<HTML><BODY>
<H1>Madlib</H1>
<TABLE>
<TR>
<TD><IMG SRC="mad.gif"></TD><TD>
<!--Madlib Form-->
</TD>
<TD><IMG SRC="mad.gif"></TD>
</BODY></HTML>
