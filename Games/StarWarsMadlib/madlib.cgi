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
    'present-tense verb', 'infinitive', 'noun', 'verb', 'name',
    'interjection', 'person', 'famous role', 'food', 'thing');

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
      while(/$type\d*/gi) {
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


sub Startup {
    select(STDOUT);
    $/ = "<!--Madlib Form-->";
    $temp = <$START>;
    print $temp;
    print("<form method='GET' action='$progname'>\n");
    print("<TABLE>\n");
    foreach $word (reverse keys %wordList) {
      print("<TR><TD>$wordList{$word} : </TD><TD>\n");
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
