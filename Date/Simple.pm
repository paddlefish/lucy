package Date::Simple;

use strict;
$Date::Simple::VERSION = '1.03';

use Carp;
use overload
    '+='  => '_increment',
    '-='  => '_decrement',
    '+'   => '_add',
    '-'   => '_subtract',
    '<=>' => '_compare',
    'cmp' => '_compare',
    '""'  => '_stringify';

use POSIX qw(strftime mktime);

sub new {
    my ($that, @ymd) = @_;
    my $class = ref($that) || $that;
    if (@ymd == 1) {
        my $x = $ymd[0];
        if(ref $x eq 'ARRAY') {
            @ymd = @$x;
        } else {
            @ymd = $ymd[0] =~ /^(\d{4})-(\d{2})-(\d{2})$/
                or croak "'$_[0]' is not a valid ISO formated date";
        }
    }
    my $time;
    if (@ymd == 3) {
        return undef unless validate(@ymd);
        $time = _mkdateymd(@ymd);
    } elsif (@ymd == 0) {
        $time = time;
    } else {
        croak "please read the documentation";
    }
    return bless \$time, $class;
}

sub next { return $_[0] + 1 }
sub prev { return $_[0] - 1 }

# return a copy of self
sub _copy {
    my $self = shift;
    my $copy = \$$self;
    bless $copy, ref $self;
    return $copy;
}

sub leap_year {
    my $y = shift;
    return (($y%4==0) and ($y%400==0 or $y%100!=0)) || 0;
}

my @days_in_month = (
 [0,31,28,31,30,31,30,31,31,30,31,30,31],
 [0,31,29,31,30,31,30,31,31,30,31,30,31],
);

sub days_in_month ($$) {
    my ($y,$m) = @_;
    return $days_in_month[leap_year($y)][$m];
}

sub validate ($$$) {
    my ($y, $m, $d)= @_;
    # any +ve integral year is valid
    return 0 if $y != abs int $y;
    return 0 unless 1 <= $m and $m <= 12;
    return 0 unless 1 <= $d and $d <= $days_in_month[leap_year($y)][$m];
    return 1;
}

sub _mkdateymd ($$$) {
    my ($y, $m, $d) = @_;
    $y -= 1900;
    $m -= 1;
    return mktime 0, 0, 12, $d, $m, $y;
}
    
sub year  { return (localtime ${$_[0]})[5] + 1900 }
sub month { return (localtime ${$_[0]})[4] + 1    }
sub day   { return (localtime ${$_[0]})[3]        }

sub format {
    my $self = shift;
    my $format = shift || '%Y-%m-%d';
    return strftime $format, localtime $$self;
}

#------------------------------------------------------------------------------
# the following methods are called by the overloaded operators, so they should
# not normally be called directly.
#------------------------------------------------------------------------------
sub _stringify { $_[0]->format }

sub _increment {
    my ($self, $n) = @_;
    $$self += $n*86400;
    return $self;
}

sub _decrement {
    my ($self, $n, $reverse) = @_;
    $$self -= $n*86400;
    return $self;
}

sub _add {
    my ($self, $n) = @_;
    my $copy = $self->_copy;
    $copy += $n;
    return $copy;
}

sub _subtract {
    my ($self, $n, $reverse) = @_;
    if (UNIVERSAL::isa($n, 'Date::Simple')) {
        my $diff = $$self - $$n;
        $diff /= 86400;
        # $reverse should probably always be false here, but...
        return $reverse ? -$diff : $diff;
    } else {
        # we don't know how to subtract a date from a non-date
        my $copy = $self->_copy;
        $copy -= $n;
        return $copy;
    }
}

sub _compare {
    my ($self, $x, $reverse) = @_;
    $x = Date::Simple->new($x) unless UNIVERSAL::isa($x, 'Date::Simple');
    my $c = (int(${$self}/86400) <=> int(${$x}/86400));
    return $reverse ? -$c : $c;
}

1;

__END__

=head1 NAME

Date::Simple - a simple date object

=head1 SYNOPSIS

    my $date  = Date::Simple->new('1972-01-17');
    my $year  = $date->year;
    my $month = $date->month;
    my $day   = $date->day;
    my $date2 = Date::Simple->new($year, $month, $day);

    my $today = Date::Simple->new;
    my $tomorrow = $today + 1;
    print "Tomorrow's date (in ISO 8601 format) is $tomorrow.\n";
    if ($tomorrow->year != $today->year) {
        print "Today is New Year's Eve!\n";
    }

    if ($today > $tomorrow) {
        die "warp in space-time continuum";
    }

    # you can also do this:
    ($date cmp "2001-07-01")
    # and this
    ($date <=> [2001, 7, 1])

=head1 DESCRIPTION

This module may be used to create simple date objects.  It only handles dates
within the range of Unix time.  It will only allow the creation of objects for
valid dates.  Attempting to create an invalid date will return undef.

=cut

=head1 CONSTRUCTOR

=head2 new

    my $date = Date::Simple->new('1972-01-17');
    my $otherdate = Date::Simple->new(2000, 12, 25);

The new method will return a date object if the values passed in specify a
valid date.  If an invalid date is passed, the method returns undef.

=head1 INSTANCE METHODS

=head2 next

    my $tomorrow = $today->next;

Returns an object representing tomorrow.

=head2 prev

    my $yesterday = $today->prev;

Returns an object representing yesterday.

=head2 year

    my $year  = $date->year;

Return the year of the date held in this date object

=head2 month

    my $month = $date->month;

Return the month of the date held in this date object

=head2 day

    my $day   = $date->day;

Return the day of the date held in this date object

=head2 format

Returns a string representing the date, in the format specified.
If you don't pass a parameter, an ISO 8601 formatted date is returned.

    my $change_date = $date->format("%d %b %y");
    my $iso_date1 = $date->format("%Y-%m-%d");
    my $iso_date2 = $date->format;

The formatting parameter is similar to one you would pass to strftime(3).
This is because we actually do pass it to strftime to format the date.

=head1 OPERATORS

Some operators can be used with Date::Simple instances:

=over 4

=item * You can increment or decrement a date by a number of days using the +=
and -= operators

=item * You can construct new dates offset by a number of days using the + and -
operators.

=item * You can subtract two dates ($d1 - $d2) to find the number of days
between them.

=item * You can compare two dates using the arithmetic comparison operators.

=item * You can interpolate a date instance directly into a string, in the
format specified by ISO 8601 (eg: 2000-01-17).

=back

=head1 AUTHOR

Marty Pauley E<lt>marty@kasei.comE<gt>

=head1 COPYRIGHT

  Copyright (C) 2001  Kasei

  This program is free software; you can redistribute it and/or modify it
  under the terms of either:
  a) the GNU General Public License;
     either version 2 of the License, or (at your option) any later version.
  b) the Perl Artistic License.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.

=cut

