#!/usr/bin/perl -w

# Theme configurator
# Started by Andrew Rahn 2/1/2002

# use strict;
use CGI qw/:standard/;
use CGI::Carp 'fatalsToBrowser';
use lib ".";
use Date::Simple;

my @choices = ();
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
		if (($0 =~ m/base/) and ($path =~ m/Theme/)) {
			push @choices, $path;
		}
		elsif ($0 =~ m/feature/ and $path =~ m/Feature/) {
			push @choices, $path;
		}
	}
}

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
srand($yday);

	print "Content-type: text/html\n\n";
	print "<!-- $0 -->";
if ($0 =~ m/base/) {
	if ($#choices == -1) {
	  opendir(THEMES, "Themes/General");
	  @ALLFILES = readdir THEMES;
	  foreach $file (@ALLFILES) {
		if ($file ne '.' and $file ne '..') {
		  push @choices, "Themes/General/$file";
		}
	  }
	}
	closedir THEMES;

	my $Theme = $choices[ int( rand(100000))%($#choices + 1)];
	print "<BASE HREF='http://www.rahnengineering.com/lucy/$Theme/'>\n";
}
elsif ($0 =~ m/feature/ ) {
	if ($#choices == -1) {
	  opendir(FEATURES, "Features");
	  @ALLFILES = readdir FEATURES;
	  foreach $file (@ALLFILES) {
		if ($file ne '.' and $file ne '..') {
		  push @choices, "Features/$file";
		}
	  }
	}
	closedir FEATURES;

	my $Theme = $choices[ int( rand(100000))%($#choices + 1)];
	print "<!-- Today's feature $Theme. -->";
	open (IN, "$Theme/incl.html");
	while(<IN>) {
	  print;
	}
	close IN;
}
