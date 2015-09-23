#!/usr/bin/perl

# NOTE: This is a perl 5 script.  Be sure to change the call if needed
#    on your machine.
# bonegame.pl
# Copyright 1999 Andrew Rahn      rahn@ucsub.colorado.edu

# a web based permutation of lemonade stand

###########################################################################
# Local variables -- these may need to be changed

### This program as an ACTION on a FORM tag
$progname ="$ENV{SCRIPT_NAME}";
$eggs = "Eggs";
$flour = "Flour";
$bananas = "Bananas";
$price = "Price";
$curprice = "CurPrice";
$buy = "Buy";
$money = "Money";
$stock = "Stock";
$cost = "Cost";

@groceries = ($eggs, $flour, $bananas);
$units{$eggs} = "dozen";
$units{$flour} = "bags";
$units{$bananas} = "bunches";
$unit{$eggs} = "dozen";
$unit{$flour} = "bag";
$unit{$bananas} = "bunch";

# how much to add to make 25 bones
$parts{$eggs} = 0.5;
$parts{$flour} = 2;
$parts{$bananas} = 1;

&ReadParse;   #Read the input
srand();

if (defined($in{'shop'})) {
  &shop;
}
elsif (defined($in{'buy'})) {
  &buy;
}
elsif (defined($in{'bake'})) {
  &bake;
}
elsif (defined($in{'price'})) {
  &price;
}
elsif (defined($in{'sell'})) {
  &sell;
}
elsif (defined($in{'inventory'})) {
  &inventory;
}
else {
  &start;
}


sub doTop {
print <<EOM;
Content-type: text/html

<HTML>  
<HEAD>
  <TITLE>Lucy's Gourmet Milkbone Baking Game</TITLE>
</HEAD>

EOM
}

sub doEnd {
print ("<INPUT TYPE='hidden' NAME='$money' VALUE='" . $in{$money} . "'>\n");
print ("<INPUT TYPE='hidden' NAME='$stock' VALUE='" . $in{$stock} . "'>\n");
print ("<INPUT TYPE='hidden' NAME='$cost' VALUE='" . $in{$cost} . "'>\n");
foreach $item (@groceries) {
  print("<INPUT TYPE=\"hidden\" NAME=\"$item\" VALUE=\"" . $in{$item} . "\">");
  print("<INPUT TYPE=\"hidden\" NAME=\"$item$price\" VALUE=\"" . $in{$item . $price} . "\">");
  print("<INPUT TYPE=\"hidden\" NAME=\"$item$curprice\" VALUE=\"" . $in{$item . $curprice} . "\">");
}
print ("</FORM></BODY></HTML>\n");
}

sub start {
$in{$money} = 50;
$in{$stock} = 0;
$in{$cost} = 1;
foreach $item (@groceries) {
  $in{$item} = 0;
}
$in{$flour . $price} = "2.50";
$in{$bananas . $price} = "1.00";
$in{$eggs . $price} = "1.25";
&doTop;
print <<EOM;
<BODY BGCOLOR="#FFFF00"><FORM ACTION="$progname" METHOD="POST">
<P><CENTER><IMG SRC="title.gif" WIDTH="450" HEIGHT="200" ALIGN="BOTTOM"
BORDER="0" NATURALSIZEFLAG="3"></CENTER></P>
<BR><FONT SIZE="+1">I need to get a summer job.  I saw this really neat doghouse in a catalogue
but Becka and Andy won't give me the money to buy it.  They say that if I really want it, I have to
earn the money myself.  So, I decided to open <FONT COLOR="0000FF"> Lucy's Gourmet Milkbone Shoppe. </FONT>  If you help 
me out, I am sure I can earn enough to get that super cool new dog house!<P>
I have a great recipe for Gourmet Banana Milkbones!  We only need flour, eggs and bananas and I can bake them 
myself.  When I'm done baking, then we can sell them in my shop.  I'll have my doghouse in no time!<P>
Come with me to the grocery store so we can buy eggs, flour and bananas and get started!
<P><CENTER><INPUT NAME="shop" TYPE="submit" VALUE="Go to the Store"></CENTER>

EOM
&doEnd;
}

sub shop {
$special = ($eggs, $flour, "Bananas")[int(rand(3))];
foreach $item (@groceries) {
  $in{$item . $price} += 0.25;
  $in{$item . $curprice} = $in{$item . $price};
}
$in{$special . $curprice} -= 0.25 * int(rand(3)+1);

&doTop;
print <<EOM;
<BODY BGCOLOR="#00FF33"><FORM ACTION="$progname" METHOD="POST">
<BASEFONT SIZE=5>
<P><CENTER><TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0">
  <TR>
    <TD WIDTH="100%" BGCOLOR="#FFFF00"><BASEFONT SIZE=5>
      <P><CENTER><IMG SRC="special1.gif" WIDTH="141" HEIGHT="129" 
      ALIGN="RIGHT" BORDER="0" NATURALSIZEFLAG="3"><FONT SIZE="+2">
      At the grocery store...</FONT></CENTER></P>

      <P><CENTER> On Sale Today!
EOM
printf('$%.2f', $in{$special . $price} - $in{$special . $curprice});
print <<EOM;
 off $special</CENTER>
      <BR>
</TD></TR><TR><TD BGCOLOR="#ffffff"><BR><P><CENTER><FONT SIZE="+2" COLOR='blue'>I have
EOM
printf('$%.2f', $in{$money});
print <<EOM;
 to spend.</FONT></CENTER>
    </TD>
  </TR>
</TABLE></CENTER></P>

<P><CENTER>How many of these things should we buy? <FONT SIZE="-1">(Fill in the blanks.)</FONT></CENTER></P>
EOM
&buyTable();
&doEnd;
}

sub buyTable {
  print <<EOM;
<P><CENTER><TABLE WIDTH="450" BORDER="0" CELLSPACING="2" CELLPADDING="2">
  <TR>
EOM

foreach $item (@groceries) {
  print <<EOM;
    <TD WIDTH="33%"><BASEFONT SIZE=5>
      <P><CENTER>&nbsp;<IMG SRC="$item.gif" WIDTH="64" HEIGHT="64"
      ALIGN="BOTTOM" BORDER="0" NATURALSIZEFLAG="3"></CENTER></P>

      <P><CENTER>$item, one $unit{$item}</CENTER></P>

      <P><CENTER>
EOM
    printf('$%.2f', $in{$item . $curprice});
    print ("</CENTER></TD>\n");
}
print ("</TR><TR>\n");

foreach $item (@groceries) {
  print <<EOM;
    <TD WIDTH="33%" BGCOLOR="#ffffff"><BASEFONT SIZE=5>
      <P><CENTER>&nbsp;buy <INPUT NAME="$buy$item" VALUE="$in{$buy . $item}" TYPE="text" SIZE="4"> $units{$item}</CENTER></TD>
EOM
}
print <<EOM;
  </TR>
</TABLE></CENTER></P>

<P><CENTER><FONT SIZE="-1"><INPUT NAME="buy" TYPE="submit" VALUE="Go to checkout"></FONT>
</CENTER>
EOM
}

sub getSubtotal {
	$spent = 0;
	foreach $item (@groceries) {
	  $spent += $in{$buy . $item} * $in{$item . $curprice};
	}
	$spent;
}

sub buy {
&doTop;
# increase items
$spent = &getSubtotal();
if ($spent > $in{$money}) {
print <<EOM;
<BODY BACKGROUND="money.jpg"><FORM ACTION="$progname" METHOD="POST">

<BASEFONT SIZE=4>
<P><CENTER><FONT SIZE="+2"></FONT>&nbsp;</CENTER></P>

<P><CENTER><FONT SIZE="+2"></FONT>&nbsp;</CENTER></P>

<P><CENTER><FONT SIZE="+2"></FONT><TABLE WIDTH="450" BORDER="1"
CELLSPACING="2" CELLPADDING="0">
  <TR>
    <TD WIDTH="100%" BGCOLOR="#d3dda1"><BASEFONT SIZE=4>
      <P><CENTER>&nbsp;<FONT SIZE="+2">Oops! We don't have</FONT></CENTER></P>

      <P><CENTER><FONT SIZE="+2"> that much money to spend.</FONT></CENTER></P>

      <P><CENTER><FONT SIZE="+2"></FONT>&nbsp;</CENTER></P>

      <P><CENTER><FONT SIZE="+2">We could buy:</FONT></CENTER>
EOM
while ($spent > $in{$money}) {
	foreach $item (@groceries) {
	  $in{$buy . $item}--;
	  if ($in{$buy . $item} < 0) {
	    $in{$buy . $item} = 0;
	  }
	}
	$spent = &getSubtotal();
}
  
&buyTable();
print("</TD></TR></TABLE></CENTER>");

&doEnd;
exit 0;
}
$in{$money} -= $spent;
foreach $item (@groceries) {
  $in{$item} += $in{$buy . $item};
}

print <<EOM;
<BODY BGCOLOR="#00FF33"><FORM ACTION="$progname" METHOD="POST">
<P><CENTER><TABLE WIDTH="310" BORDER="0" CELLSPACING="0" CELLPADDING="8">
  <TR>
    <TD WIDTH="100%" BGCOLOR="#ffffff">
      <P>&nbsp;<TT><FONT SIZE="+2">Sunshine Grocery</FONT></TT></P>

      <P><TT><FONT SIZE="+2">Store Receipt</FONT></TT></P>

      <P><TT><FONT SIZE="+2"></FONT></TT>&nbsp;</P>
EOM
foreach $item (@groceries) {
  if ($in{$buy . $item} == 0) {
    next;
  }
  print("<P><TT><FONT SIZE='+2'>$item</FONT></TT></P>\n");
  print("<BLOCKQUOTE>\n");
  print("<P><TT><FONT SIZE='+2'>");
  $line = $in{$buy . $item} . " ";
  if ($in{$buy . $item} == 1) {
    $line .= $unit{$item};
  }
  else {
    $line .= $units{$item};
  }
  $line .= '.' x (15 - length($line));
  $line .= sprintf('$%.2f', $in{$buy . $item}*$in{$item . $curprice});
  print("$line</FONT></TT></P></BLOCKQUOTE>");
}
print ("<P>&nbsp;</P>\n");
print ("<P><TT><FONT SIZE='+2'>TOTAL</FONT></TT></P>\n");
print ("<BLOCKQUOTE>\n");
print ("<P><TT><FONT SIZE='+2'>...............");
printf('$%.2f', $spent);
print ("</FONT></TT>\n");
print ("</BLOCKQUOTE>\n");
print ("</TD></TR></TABLE></CENTER></P>\n");
print ("<P><CENTER><FONT SIZE='+2' COLOR='#0000FF'><BR>We have ");
printf('$%.2f', $in{$money});
print (" left.  Now it's time to go bake some dog treats!</FONT></CENTER></P>\n");
print ("<P><CENTER><FONT SIZE='+2'><INPUT NAME='bake' TYPE='submit'\n");
print ("VALUE='Go Bake'></FONT></CENTER>\n");

&doEnd;
}

sub bake {
&doTop;
print <<EOM;
<BODY BGCOLOR="#0099FF"><FORM ACTION="$progname" METHOD="POST">
<BASEFONT SIZE=5>
<P><IMG SRC="baking.gif" WIDTH="150" HEIGHT="350" ALIGN="RIGHT"
BORDER="0" NATURALSIZEFLAG="3"><FONT SIZE="+2">Lucy's Kitchen</FONT></P>

<P>We are back home from the grocery store and we now have:</P>

<P><CENTER><TABLE BORDER="0" CELLSPACING="6" CELLPADDING="2">
  <TR>
EOM
undef($bonesMade);

foreach $item (@groceries) {
	$temp = int(25 * $in{$item} / $parts{$item});
	unless (defined($bonesMade) && ($bonesMade < $temp)) {
	  $bonesMade = $temp;
	  $limitingIngredient = $item;
	} 
    if ($in{$item} == 1) {
     	$theUnit = $unit{$item};
    }
    else {
      $theUnit = $units{$item};
    }
print <<EOM;
    <TD WIDTH="33%" BGCOLOR="#ffffff"><BASEFONT SIZE=5>
      <P>&nbsp;<IMG SRC="$item.gif" WIDTH="64" HEIGHT="64" ALIGN="BOTTOM"
      BORDER="0" NATURALSIZEFLAG="3"></P>

      <P><CENTER>$in{$item} $theUnit<BR>
      of $item</CENTER>
    </TD>
EOM
}
$in{$cost} = 0;
foreach $item (@groceries) {
  $temp = int ($parts{$item} *$bonesMade / 25);
  $in{$item} -= $temp;
  $in{$cost} += $temp * $in{$item . $curprice};
}
if ($bonesMade > 0) {
  $in{$cost} = int ($in{$cost} / $bonesMade * 100) / 100;
}
else {
  foreach $item (@groceries) {
    $in{$cost} += $in{$item . $curprice} / $parts{$item};
  }
  $in{$cost} = int ($in{$cost} / 25 * 100) / 100;
}

$in{$stock} += $bonesMade;
$in{$limitingIngredient} = 0; # just in case of round off error
print <<EOM;
  </TR>
</TABLE></CENTER></P>

<P>Wow!  Baking these biscuits is hard work!  I made $bonesMade dog biscuits,
but then I ran out of $limitingIngredient.
But now we have $in{$stock} biscuits to sell!
</P>

<P><CENTER><IMG SRC="biscuit.gif" WIDTH="164" HEIGHT="70" ALIGN="BOTTOM"
BORDER="0" NATURALSIZEFLAG="3"></CENTER>
<P><CENTER><FONT SIZE="+2"><INPUT NAME="price" TYPE="submit"
VALUE="Sell the Milkbones"></FONT></CENTER>

EOM
&doEnd;
}

sub price {
&doTop;
print <<EOM;
<BODY BACKGROUND="bone.gif"><FORM ACTION="$progname" METHOD="POST">
<P><TABLE><TR><TD BGCOLOR="#FFFFFF"><FONT SIZE="+2">Now I need some help.  How much should I sell my biscuits for?
Please pick the price that you think would be best.</FONT></P></TD></TR></TABLE>

<P><CENTER><TABLE WIDTH="450" BORDER="0" CELLSPACING="2" CELLPADDING="2">
  <TR>
    <TD WIDTH="100%" BGCOLOR="#ffff00">
      <P><CENTER>&nbsp;<FONT COLOR="#ff0000" SIZE="+4">Lucy's Gourmet Banana Milkbones For
      Sale</FONT></CENTER></P>

      <P><CENTER><FONT SIZE="+3">only</FONT></CENTER></P>
EOM
$lastPrice = 0;
for($i = 0; $i < 4; $i++) {
  $curPrice = $in{$cost};
  $curPrice *= (1.2, 1.35, 1.5, 1.75)[$i];
  $curPrice = int($curPrice * 20) / 20;
  if ($curPrice == $lastPrice) {
  	$curPrice += 0.05;
  }
  $lastPrice = $curPrice;
  print("<P><CENTER><FONT SIZE='+3'>");
  print("<INPUT NAME='boneprice' TYPE='radio' VALUE='$curPrice'> ");
  printf('$%.2f', $curPrice);
  print("</FONT></CENTER></P>");
}
print <<EOM;

      <P><CENTER><FONT SIZE="+3">each!</FONT></CENTER>
    </TD>
  </TR>
</TABLE></CENTER></P>

<P><CENTER><INPUT NAME="sell" TYPE="submit" VALUE="Start Selling"></CENTER>
EOM
&doEnd;
}

sub sell {
if ($in{'boneprice'} < ($in{$cost}*1.1)) {
  # whoa!  They're cheap, sell them all!
  $numSold = $in{$stock};
}
else {
  $numSold = int ($in{$stock} * $in{$cost} / ($in{'boneprice'}*(rand() * 2)));
}
if ($numSold > $in{$stock}) {
  $numSold = $in{$stock};
}
$in{$stock} -= $numSold;
$earnings = $numSold * $in{'boneprice'};
$in{$money} += $earnings;
&doTop;
print <<EOM;
<BODY BGCOLOR="#009999"><FORM ACTION="$progname" METHOD="POST">

<BASEFONT SIZE=6>
<P><CENTER><IMG SRC="dogs.gif" WIDTH="360" HEIGHT="72" ALIGN="BOTTOM"
BORDER="0" NATURALSIZEFLAG="3"></CENTER></P>

<P><CENTER><IMG SRC="jar.gif" WIDTH="144" HEIGHT="216" ALIGN="RIGHT"
BORDER="0" NATURALSIZEFLAG="3">It's a great day for selling dog treats!  Look at all the puppies that
came to my store.<BR><BR>
We sold $numSold bones and that means we made 
EOM
printf('$%.2f', $earnings);
print <<EOM;
!  So now we have
EOM
printf('$%.2f', $in{$money});
print(" all together.  ");
if ($in{$stock} == 0) {
  print("We also have no bones left.");
}
else {
  print("We also have $in{$stock} bones left that we didn't sell.");
}
if ($in{$money} < 100) {
print <<EOM;
<BR><BR> But that's not quite enough money for my dream dog house.
So, it's time to make some more milkbones!  <BR>
We better stop at home and make a shopping list so we have enough to make more biscuits.</CENTER></P>


<P><CENTER><INPUT NAME="inventory" TYPE="submit" VALUE="Go to the Kitchen"></CENTER>
EOM
}
else {
print <<EOM;
<BR><BR> Guess what that means!</CENTER></P>


<P><CENTER><INPUT NAME="inventory" TYPE="submit" VALUE="Buy the Dog House"></CENTER>
EOM
}
&doEnd;
}

sub inventory {
if ($in{$money} > 100) {
  &finish;
  exit 0;
}
&doTop;
print <<EOM;
<BODY BGCOLOR="#0099FF"><FORM ACTION="$progname" METHOD="POST">

<BASEFONT SIZE=5>
<P><IMG SRC="list.gif" WIDTH="150" HEIGHT="350" ALIGN="RIGHT"
BORDER="0" NATURALSIZEFLAG="3"><FONT SIZE="+2">Lucy's Kitchen</FONT></P>
<CENTER>
<P>I checked the cupboards.  We have:</P>

<P><TABLE BORDER="0" CELLSPACING="6" CELLPADDING="2">
  <TR>
EOM
foreach $item (@groceries) {
    if ($in{$item} == 1) {
     	$theUnit = $unit{$item};
    }
    else {
      $theUnit = $units{$item};
    }
print <<EOM;
    <TD WIDTH="33%" BGCOLOR="#ffffff"><BASEFONT SIZE=5>
      <P>&nbsp;<IMG SRC="$item.gif" WIDTH="64" HEIGHT="64" ALIGN="BOTTOM"
      BORDER="0" NATURALSIZEFLAG="3"></P>

      <P><CENTER>$in{$item} $theUnit<BR>
      $item</CENTER>
    </TD>
EOM
}
print <<EOM;
  </TR>
</TABLE></P>
<BR><FONT COLOR='#000000'>We have 
EOM
printf('$%.2f', $in{$money});
print(" to spend.  We need only ");
printf('$%.2f', 100-$in{$money});
print <<EOM;
 more until I can get my new dog house!  Help me remember what we need to buy!
 </CENTER><P><CENTER><INPUT NAME="shop" TYPE="submit" VALUE="Go Shopping"></CENTER>
EOM
&doEnd;
}

sub finish {
&doTop;
print <<EOM;

<BODY BACKGROUND="toys.jpeg"
TEXT="#0000ff" BGCOLOR="#ffffff" LINK="#000000">

<BASEFONT SIZE=4>
<P><CENTER>&nbsp;</CENTER></P>

<P><CENTER>&nbsp;</CENTER></P>

<P><CENTER><TABLE WIDTH="449" BORDER="1" CELLSPACING="2" CELLPADDING="0">
  <TR>
    <TD WIDTH="100%" BGCOLOR="#ffffff"><BASEFONT SIZE=4>
      <P><CENTER>&nbsp;<FONT SIZE="+3">HOORAY!</FONT></CENTER></P>

      <P><CENTER>We made enough money so that I can buy my new doghouse!</CENTER></P>

      <P><CENTER>Thank you for all of your help. I will be sure to
      invite you over to play in the pool and try out the nifty dog food dispenser!</CENTER>
    </TD>
  </TR>
</TABLE></CENTER></P>

<P><CENTER>&nbsp;</CENTER></P>

<P><CENTER>&nbsp;</CENTER></P>

<P><CENTER><IMG SRC="biscuit.gif"
WIDTH="164" HEIGHT="70" ALIGN="BOTTOM" BORDER="0" NATURALSIZEFLAG="3"></CENTER></P>

<P><CENTER><A HREF="../../"><IMG SRC="../../Everypage/back.gif" BORDER=0></A></CENTER>
EOM
&doEnd;
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
