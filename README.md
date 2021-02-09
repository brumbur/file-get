<pre>
   ____     __   __        ____
  / __/__  / /__/ /__ ____/ __/_ _____  ____
 / _// _ \/ / _  / -_) __/\ \/ // / _ \/ __/
/_/  \___/_/\_,_/\__/_/ /___/\_, /_//_/\__/
                            /___/
</pre>

## TL;DR:
Simple script to download files from a remote FTP server. Can run as a one-off job or to check every so often.

## Background:
A friend asked me for help with a simple FTP utility script abd I quickly realized that, after years spent coding in Java, JS, Python, etc. I could use a refresher on my shell scripting know-how.

The result is this small utility that can monitor a remote FTP directory and download any new files. While by itself the functionality is rather trivial, It could help as a quick reference for many of the common tasks that that deal with curl, ftp and file handling:

- FTP using curl and capturing both output and error codes
- Job controls and IPC to track progress and errors
- Functions override to customize bash built-in commands
- Passing arrays as function arguments and returning array as function result
- Redirecting standard output to catch errors and subshell output
- CLI argument parsing with getopt and associative arrays
- Fun with ASCII art, prompt control, console colors and formatting

## Dev Notes
TBD

## Credits:
TBD
