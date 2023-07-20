nagios-check_file_content
=========================

Nagios file parser check

Usage
-----
```
Usage : check_file_content.pl -f file -i include [-e exclude] [-n lines_number] [-m max_search] [-h]

Options :
 -f
	Full path to file to analyze (mandatory)
 -n
	Number of lines to find (default is 1)
 -m
	Maximum number of lines to search on (default is all)
 -i
	Include pattern (mandatory, can be repeated multiple times)
 -e
	Exclude pattern (can be repeated multiple times)
 -h, --help
	Print this help screen

Example : check_file_content.pl -f /etc/passwd -i 0 -e root -n 5
```