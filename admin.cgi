#!/usr/bin/perl -w

# Theme configurator
# Started by Andrew Rahn 2/1/2002

# use strict;
use CGI qw/:standard/;
use CGI::Carp 'fatalsToBrowser';
use lib ".";
use Date::Simple;

my $val = "";
my %months = (
	'Jan' => 0,
	'Feb' => 1,
	'Mar' => 2,
	'Apr' => 3,
	'May' => 4,
	'Jun' => 5,
	'Jul' => 6,
	'Aug' => 7,
	'Sep' => 8,
	'Oct' => 9,
	'Nov' => 10,
	'Dec' => 11,
);
my @month_names = sort {$months{$a} <=> $months{$b} } keys %months;
my @month_days = (1..31);
my @years = ("Every Year", 2002..2020);

my $query = new CGI();
print $query->header;
print $query->start_html("Theme Configurator");

unless($query->param) {
	&print_default();
} else {
	&process();
	&print_default();
}

print $query->end_html;

sub print_default {
	print "<H1>Calendar</H1>\n";
	print $query->start_form(-id=>'theForm');
	print "$val\n";
	
	&displayDir("Theme", "Themes/General", "background.gif");
	&displayDir("Theme", "Themes/Specific", "background.gif");
	&displayDir("Features", "Features", "picture.gif");
	
	print "Start Date: ";
	print popup_menu(-name=>'start_month',
		-values => \@month_names);
	print popup_menu(-name=>'start_day',
		-values => \@month_days);
	print "End Date: ";
	print popup_menu(-name=>'end_month',
		-values => \@month_names);
	print popup_menu(-name=>'end_day',
		-values => \@month_days);
	print popup_menu(-name=>'year',
		-values => \@years);
	print $query->submit(-label=>"Add new item", -name=>"add");
	print $query->submit(-label=>"Try it", -name=>"use", -onClick=>"document.getElementById('theForm').action='base.cgi'; return true;");
	&printCurrentSchedule();
	print $query->end_form;
}

sub displayDir {
	my ($cat, $path, $image) = @_;
	
	opendir(GENERAL, $path);
	my @Themes = readdir(GENERAL);
	closedir(GENERAL);
	print "<H2>$path</H2>\n";
	print "<TABLE WIDTH='100%'>\n";
	print "<TR HEIGHT='40'>";
	$colCount = 0;
	foreach $theme (sort @Themes) {
		if ($theme =~ m/\.{1,2}/) {
			next;
		}
		if ($colCount > 4) {
			print "</TR><TR>";
			$colCount = 0;
		}
		print "<TD  HEIGHT='40' background='$path/$theme/$image'>\n";
		print "<B><B><INPUT TYPE='radio' NAME='Theme' VALUE='$path/$theme'><FONT COLOR='#DD6666'>$theme</FONT></INPUT>\n";
		print "</TD>\n";
		$colCount++;
	}
	print "</TR></TABLE>\n";
}	

sub process {
	if (defined $query->param("add")) {
		my $year = $query->param("year");
		if ($year =~ m/Every/) {
			$year = 2000;
		}

		my $start = Date::Simple->new(
			$year,
			1+$months{$query->param("start_month")},
			$query->param("start_day")) or die("Can't create simple date: $!");
		my $end = Date::Simple->new(
			$year,
			1+$months{$query->param("end_month")},
			$query->param("end_day")) or die("Can't create simple date: $!");
		if ($end < $start) {
			$end = Date::Simple->new(
				$end->year + 1,
				$end->month,
				$end->day);
		}
		open(THEME_SCHEDULE, ">>themes_schedule.txt");
		print THEME_SCHEDULE time() . "\t" . $query->param("Theme") . "\t$start\t$end\n";
		close(THEME_SCHEDULE);
	}
	elsif (defined $query->param("delete")) {
		my @entries;
		open(THEME_SCHEDULE, "themes_schedule.txt");
		while(<THEME_SCHEDULE>) {
			$next = $_;
			my ($id, @etc) = split("\t");
			if ($id == $query->param("Target")) {
				next;
			}
			push @entries, $next;
		}
		close(THEME_SCHEDULE);
		open(THEME_SCHEDULE, ">themes_schedule.txt");
		foreach $entry (@entries) {
			print THEME_SCHEDULE $entry;
		}
		close(THEME_SCHEDULE);
	}
}

sub printCurrentSchedule {
	open(SCHEDULE, "themes_schedule.txt");
	
	print "<TABLE WIDTH=100%>";
	while(<SCHEDULE>) {
		my ($id, $path, $start, $end) = split("\t");
		print "<TR><TD background='Themes/$path/background.gif' WIDTH=400>";
		print $query->checkbox(-name=>"Target",
			-value=>"$id", -label=>"$path");
		print "</TD>\n";
		print "<TD>Start on $start</TD><TD>End on $end</TD></TR>\n";
	}	
	close SCHEDULE;
	print "</TABLE>\n";
	print $query->submit(-label=>"Delete selected entry", -name=>"delete", -onClick=>"document.getElementById('theForm').action='admin.cgi'; return true;");
}
