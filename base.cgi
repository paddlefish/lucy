#!/usr/bin/perl -w

# Theme configurator
# Started by Andrew Rahn 2/1/2002

# use strict;
use CGI qw/:standard/;
use CGI::Carp 'fatalsToBrowser';
use lib ".";
use Date::Simple;

{
 local ($oldbar) = $|;
 $cfh = select (STDOUT);
 $| = 1;
 #
 # print your HTTP headers here
 #
 print "Content-type: text/html\r\n\r\n";

 $| = $oldbar;
 select ($cfh);
}
print "<!-- Thanks for reading my source code -->\n";

my @themes = ();
my @features = ();
my $today = Date::Simple->new();

open(THEME_SCHEDULE, "themes_schedule.txt");
while(<THEME_SCHEDULE>) {
  my ($id, $path, $start, $end) = split("\t");
  $start = Date::Simple->new($start);
  $end = Date::Simple->new($end);
  if ($start->year < 2002) {
    $start = Date::Simple->new(
      $start->year + $today->year - 2000,
      $start->month,
      $start->day);
  }
  if ($end->year < 2002) {
    $end = Date::Simple->new(
      $end->year + $today->year - 2000,
      $end->month,
      $end->day);
  }
  if ($start <= $today and $end >= $today) {
    if ($path =~ m/Theme/) {
      push @themes, $path;
    }
    elsif ($path =~ m/Feature/) {
      push @features, $path;
    }
  }
}
close(THEME_SCHEDULE);

if (param()) {
  my $temp = param('Theme');
  if ($temp =~ m/Themes/) {
    @themes = ($temp);
  } else {
    @features = ( $temp );
  }
}

my $randomizer = $today->month * 31 + $today->year * 365 + $today->day;
srand($randomizer);

# foreach $key (keys %ENV) {
# print "<!-- $key = $ENV{$key} -->\n";
# }
my %replacements = ();

{
  # add theme replacements...

  my @ALLFILES;
  if ($#themes == -1) {
    opendir(THEMES, "Themes/General");
    @ALLFILES = readdir THEMES;
    foreach $file (@ALLFILES) {
      if ($file ne '.' and $file ne '..' and -d "Themes/General/$file") {
	push @themes, "Themes/General/$file";
      }
    }
  }
  closedir THEMES;

  my $Theme = $themes[ int( rand(100000))%($#themes + 1)];
  my $baseUrl = "$ENV{HTTP_HOST}$ENV{SCRIPT_NAME}";
  $baseUrl =~ s/\/lucy\/.+/\/lucy\//;
  print "<BASE HREF='http://$baseUrl$Theme/'>\n";
  
  # find out what files are there... .jpg, .gif, etc...
  opendir(FILES, $Theme) or die ("Can't open $Theme : $!");
  @ALLFILES = readdir FILES;
  closedir(FILES);

  foreach $file(@ALLFILES) {
    if ($file =~ m/^\./) {
      next;
    }
    my ($shortcut, $x) = split(/\./, $file);
    $replacements{$shortcut} = $file;
  }
}

{
  # add feature to replacements
  my @ALLFILES;
  if ($#features == -1) {
    opendir(FEATURES, "Features");
    @ALLFILES = readdir FEATURES;
    foreach $file (@ALLFILES) {
      if ($file ne '.' and $file ne '..' and -d "Features/$file") {
	push @features, "Features/$file";
      }
    }
    closedir FEATURES;
  }

  my $Feature = $features[ int( rand(100002))%($#features + 1)];
  print "<!-- Day $randomizer 's feature $Feature of " . ($#features+1) . " possible. -->\n";
  open (IN, "$Feature/incl.html") or die("Can't open $Feature/incl.html : $!");
  undef $/;
  $replacements{"<!--feature-->"} = <IN>;
  close IN;
}

# open the template and print it row by row,
# replacing all the special {{tokens}}
open(IN, "template.html");
while(<IN>) {
  foreach $pat (keys %replacements) {
    s/{{$pat}}/$replacements{$pat}/g;
  }
  print;
}
