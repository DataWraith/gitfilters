#!/usr/bin/env ruby

#
# filter_stripwhitespace_clean.rb is a simple filter that removes whitespace
# from the end of all lines, because I'm too lazy to do this myself every time.
#
# It also adds a newline at the end of the file if there wasn't one before.
#
# To use the filter, add the following to your .gitconfig:
#
# [filter "stripwhitespace"]
#         clean = "/path/to/script/filter_stripwhitespace_clean.rb"
#
# and add an appropriate glob-pattern to the .gitattributes file at the root
# of a git working copy, for example:
#
# *.txt        filter=stripwhitespace
# *.c          filter=stripwhitespace
#

$stdin.each_line do |line|
  $stdout.puts line.rstrip
end
