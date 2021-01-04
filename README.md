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
A friend asked me for help with a simple utility script. I realized that, after years spent in coding in Java, JS, Python, etc. I would need a refresher on all things bash. In the process I've discovered that a ton of new cool features are now making bash scripting much more efficient and fun to write.

The result is a small utility that can monitor a remote FTP directory and download any new files. While by itself the functionality is rather trivial, I'm using it as a quick reference guide for many common tasks - a short list:

- FTP using curl
- Job controls and IPC to track progress and errors
- Bash function override to customize built-in commands
- Passing arrays as function arguments and function result
- Redirecting standard output to catch errors and subshell output
- Convenient and flexible arguments parsing with getopt and associative arrays
- Fun with ASCII art, prompt control, and console colors and formatting

## Interesting parts, explanation, and resources:
TBD

## Credits:
TBD
