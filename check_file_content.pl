#!/usr/bin/perl -w
#===============================================================================
#       AUTHOR:  Pierre Mavro (), pierre@mavro.fr (original version 0.1)
#                Rodrigo Araujo (version >= 1.0.0)
#===============================================================================

use warnings;
use strict;
use Monitoring::Plugin;
my $version = '1.0.0';


## Monitoring plugin data
my $license = << 'EOLICENSE';
Nagios/Icinga plugin to check file contents

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
EOLICENSE

my $extra_help = << 'EOH';

Example : check_file_content.pl -f /etc/passwd -i 0 -e root -n 5

See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.
EOH

my $np = Monitoring::Plugin->new(
	version => $version,
	usage => "Usage : %s -f file -i include [-e exclude] [-c lines_number_range] [-m max_search] [--help]",
	extra => $extra_help,
	license => $license,
);


## Monitoring plugin arguments
$np->add_arg(
	spec => "f=s",
	help => "Full path to file to analyze (mandatory)",
	required => 1,
);
$np->add_arg(
	spec => "c=s",
	help => "Critical threshold for the number of lines to find, in RANGE format (see link below).\n".
		"   Default is \"1:\" which means \"at least 1\".",
	# default has to be set after some othe checks below, because of the possibility of the deprecated -n option being used instead
);
$np->add_arg(
	spec => "w=s",
	help => "Warning threshold for the number of lines to find, in RANGE format (see link below).\n".
		"   Defaults to none (no warning).",
);
$np->add_arg(
	spec => "n=i",
	help => "(DEPRECATED) Number of lines to find (in integer format, for compatibility with older versions or\n".
		"   variants of this plugin). Usage of this option is discouraged in new setups.\n".
		"   Using this option with a N value is equivalent as using -c N: and it cannot be used at the same\n".
		"   time as -w or -c.",
);
$np->add_arg(
	spec => "m=i",
	help => "Maximum number of lines to search on (default is all).",
);
$np->add_arg(
	spec => "i=s@",
	help => "Include pattern (mandatory, can be repeated multiple times).",
	required => 1,
);
$np->add_arg(
	spec => "e=s@",
	help => "Exclude pattern (can be repeated multiple times).",
);
$np->getopts;

my $file = $np->opts->get('f');
my $crit = $np->opts->get('c');
my $warn = $np->opts->get('w');
my $num = $np->opts->get('n');
my $maxl = $np->opts->get('m');
my $qr_include = check_compile_regexps($np->opts->get('i'));
my $qr_exclude = check_compile_regexps($np->opts->get('e'));

if (defined($num)) {
	# deprecated option, for compatibility purposes
	if (defined($crit) || defined($warn)) {
		$np->plugin_die("Option -n cannot be used at the same time as -c or -w");
	}
	if ($num < 1) {
		$np->plugin_die("Option -n minimum value is 1");
	}
	$crit = "$num:";
}
elsif (!defined($crit)) {
	# for the above test to work, we need to provide the critical default here
	$crit = "1:";
}

if (defined($maxl) && $maxl < 1) {
	$np->plugin_die("Maximum number of lines to search on should be at least 1");
}

if (!open(FILER, '<', $file)) {
	$np->plugin_die("Can't open $file: $!");
}

## Actual check
my $i = 0;
my $l = 0;
while(<FILER>) {
	if (defined($maxl)) {
		$l++;
		if ($l > $maxl) {
			last;
		}
	}
	chomp($_);
	my $line = $_;
	my $found = 0;

	# Should match
	foreach (@$qr_include) {
		if ($line =~ $_) {
			$found=1;
			last;
		}
	}

	# Shouldn't match
	foreach (@$qr_exclude) {
		if ($line =~ $_) {
			$found=0;
			last;
		}
	}

	$i++ if ($found == 1);
}
close(FILER);

my $code = $np->check_threshold(
	check => $i,
	warning => $warn,
	critical => $crit,
);
$np->add_perfdata(
	label => 'Matches',
	value => $i,
	min => 0,
	warning => $warn,
	critical => $crit,
);
$np->plugin_exit($code, "$file ($i match" . ( $i == 1 ? '' : 'es' ) . ' found' . ( defined($maxl) ? ' in the first ' . ( $maxl > 1 ? "$maxl lines" : 'line' ) : '' ) . ')');


## Helper sub(s)
sub check_compile_regexps {
	my $list = shift;

	my @qr_list;
	if (defined($list)) {
		foreach my $r (@$list) {
			my $qr = eval { qr/$r/ };
			if ($@) {
				$np->plugin_die("Invalid regex \"$r\": $@");
			}
			push @qr_list, $qr;
		}
	}

	return \@qr_list;
}
