nagios-check_file_content
=========================

Nagios/Icinga plugin to check file contents

Usage
-----
```
Usage : check_file_content.pl -f file -i include [-e exclude] [-c lines_number_range] [-m max_search] [--help]

 -?, --usage
   Print usage information
 -h, --help
   Print detailed help screen
 -V, --version
   Print version information
 --extra-opts=[section][@file]
   Read options from an ini file. See https://www.monitoring-plugins.org/doc/extra-opts.html
   for usage and examples.
 -f=STRING
   Full path to file to analyze (mandatory)
 -c=STRING
   Critical threshold for the number of lines to find, in RANGE format (see link below).
   Default is "1:" which means "at least 1".
 -w=STRING
   Warning threshold for the number of lines to find, in RANGE format (see link below).
   Defaults to none (no warning).
 -n=INTEGER
   (DEPRECATED) Number of lines to find (in integer format, for compatibility with older versions or
   variants of this plugin). Usage of this option is discouraged in new setups.
   Using this option with a N value is equivalent as using -c N: and it cannot be used at the same
   time as -w or -c.
 -m=INTEGER
   Maximum number of lines to search on (default is all).
 -i=STRING
   Include pattern (mandatory, can be repeated multiple times).
 -e=STRING
   Exclude pattern (can be repeated multiple times).
 -t, --timeout=INTEGER
   Seconds before plugin times out (default: 15)
 -v, --verbose
   Show details for command-line debugging (can repeat up to 3 times)

Example : check_file_content.pl -f /etc/passwd -i 0 -e root -n 5

See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.
```
