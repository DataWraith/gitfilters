#!/usr/bin/env ruby

#
# Together with filter_sqlite_smudge.rb, this file allows you to more
# efficiently store SQLite-databases inside a git-repository. Instead of a
# binary file, it makes git store an SQL dump of the database, which is easier
# to diff and compress.
#
# This script takes a binary SQLite database from stdin and returns a database
# dump to stdout by passing the input through 'sqlite3' or, with the "-2"
# command line switch, through 'sqlite'. Both commands should be in your PATH.
#
# To use the filter, add the following to your .gitconfig:
#
# [filter "sqlite3"]
#         clean = "/path/to/script/filter_sqlite_clean.rb"
#         smudge = "/path/to/script/filter_sqlite_smudge.rb"
#
# [filter "sqlite2"]
#         clean = "/path/to/script/filter_sqlite_clean.rb -2"
#         smudge = "/path/to/script/filter_sqlite_smudge.rb -2"
#
# and add glob-patterns for your sqlite databases to the .gitattributes file
# at the root of a git working copy, for example:
#
# *.db          filter=sqlite3
# *.anki        filter=sqlite3
#


require 'tmpdir'

tmpdir   = Dir.tmpdir
tmpinput = File.join(tmpdir, "sqlite_dump-#{Time.now.to_i}-in-#{rand(32)}.db")

EMPTY_DATABASE = "BEGIN TRANSACTION;\nCOMMIT;\n"

if ARGV.include?('-2')
  sqlite_cmd = 'sqlite'
else
  sqlite_cmd = 'sqlite3'
end

begin
  # Get database file from stdin
  infile = $stdin.read

  # Write file to temporary location
  File.open(tmpinput, 'w') { |input|
    input.print(infile)
  }

  # Dump database
  output = `#{sqlite_cmd} #{tmpinput} .dump`

  # Check result
  if ($? == 0)
    if (output == EMPTY_DATABASE)
      raise "SQLite returned an empty database."
    end

    $stdout.print(output)
  else
    raise("An SQLite error occured.", output)
  end

rescue Exception => the_error
  $stderr.puts "Error: #{the_error}"
  $stderr.print the_error.backtrace.join("\n")
  exit 1
ensure
  File.delete(tmpinput) if File.exists?(tmpinput)
end
