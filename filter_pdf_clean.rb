#!/usr/bin/env ruby

#
# This is a simple filter that decompresses PDF-files using pdftk, which needs
# to be in your PATH. Together with filter_pdf_smudge.rb, this can increase the
# storage efficiency inside a git-repository.
#
# NOTE: Input and output will _not_ be identical, since pdftk's compress and
#       uncompress functions are (of course) not directly inverse. If you need
#       to have PDF files that have to pass an md5sum check or something,
#       *don't* use this script.
#
# If pdftk fails to (un)compress a file, which usually happens because that
# file is password protected, the script just passes the input back to git,
# making itself a no-op.
#
# To use the scripts, add the following to your .gitconfig:
#
# [filter "pdf"]
#        clean = "/path/to/script/filter_pdf_clean.rb"
#        smudge = "/path/to/script/filter_pdf_smudge.rb"
#
# and add glob-patterns for PDF-files to the .gitattributes file at the
# root of a git working copy:
#
# *.pdf    filter=pdf
#


require 'open3'

begin
  # Get PDF from stdin
  input  = $stdin.read
  output = ''
  errors = ''

  # Try decompressing it using pdftk
  Open3.popen3("pdftk - output - uncompress") do |stdin, stdout, stderr|
    stdin.print(input)
    stdin.close
    output = stdout.read
    errors = stderr.read
  end

  # Success?
  if ($? == 0) and (errors.empty?)
    print output
  else
    print input
  end

rescue Exception => the_error
  $stderr.puts "Error: #{the_error}"
  $stderr.print the_error.backtrace.join("\n")
  exit 1
end
