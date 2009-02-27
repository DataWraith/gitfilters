#!/usr/bin/env ruby

#
# This is a simple filter that decompresses ZIP-files (stores all files
# uncompressed inside a new ZIP file). This can increase the storage efficiency
# inside a git-repository, since
#
# a) the entire file is compressed by git, and compressing already compressed
#    files tends to not be very efficient.
#
# and
#
# b) without the compression, it will be easier for git to determine
#    similarities between files when making a pack. This is especially important
#    for OpenDocument files that are changed frequently.
#
# The disadvantage is, that the file inside your working copy will be
# bigger than before. ALSO: It does not seem to work with .jar-files.
#
# When the --odf option is passed on the commandline, the script will also
# remove superfluous files inside a OpenDocument file (cache, thumbnails).
#
# To use the script, install the rubyzip gem and add the following
# to your .gitconfig:
#
# [filter "zip"]
#         clean = "/path/to/script/filter_zip_clean.rb"
#
# [filter "odf"]
#         clean = "/path/to/script/filter_zip_clean.rb --odf"
#
# and add glob-patterns for zip and OpenDocument files to the .gitattributes
# file at the root of a git working copy:
#
# *.zip         filter=zip
# *.od[tpsgb]   filter=odf
#


require 'rubygems'
require 'zip/zip'

require 'tmpdir'

tmpdir   = Dir.tmpdir
tmpinput = File.join(tmpdir, "ziphook-#{Time.now.to_i}-in-#{rand(32)}.zip")
tmpzip   = File.join(Dir.tmpdir, "ziphook-#{Time.now.to_i}-out-#{rand(32)}.zip")

is_opendocument = false
if ARGV.include?("--odf")
  is_opendocument = true
end

begin
  # Get file from stdin
  infile = $stdin.read

  # Write file to temporary location
  File.open(tmpinput, 'w') { |input|
    input.print(infile)
  }

  # Write decompressed file to temporary location
  Zip::ZipOutputStream::open(tmpzip) { |output|
    Zip::ZipFile.open(tmpinput) { |zf|
      zf.each { |entry|
        unless (is_opendocument) and ((entry.name.match(/^Thumbnails\//)) or (entry.name == "layout-cache"))
          output.put_next_entry(entry.name, Zlib::NO_COMPRESSION)
          unless entry.directory?
            output << zf.read(entry)
          end
        end
      }
    }
  }

  $stdout.print File.read(tmpzip)

rescue Exception => the_error
  $stderr.puts "Error: #{the_error}"
  $stderr.print the_error.backtrace.join("\n")
  exit 1
ensure
  File.delete(tmpzip) if File.exists?(tmpzip)
  File.delete(tmpinput) if File.exists?(tmpinput)
end
