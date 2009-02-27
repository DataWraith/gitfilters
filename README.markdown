gitattributes filter-scripts
============================

This repository contains a few scripts for use with [git]'s [filter]-mechanism.

The little-known filter-mechanism allows you to change the way git stores
your files. For example, you can tell git to invoke gzip and automatically
decompress `.gz`-files before storing them inside your repository, so that
git can actually show you a diff of the contents instead of just "Binary files
differ". When you check out the file, git can call gzip again to compress it,
so you don't end up with a huge, uncompressed file in your working directory.

Ideally the two operations ("clean" and "smudge"), should be exactly inverse,
but it still mostly works if they aren't.

The scripts
-----------

The scripts were mostly just to play around with, and even though I'm using
them without problems, they **may or may not eat up your data for breakfast**.

The repository includes the following scripts:

* `filter_zip_clean.rb`

  This script decompresses ZIP-files before they are added to the repository,
  which is useful for OpenDocument files, because this allows git to generate
  better diffs. Compressed files that are changed, are only equal up to
  the point where the change was made, so everything after that counts as
  different and is saved into the repository again, wasting space.

  Optionally, the script will also strip unnecessary data from OpenDocument
  files (e.g. the thumbnails).

* `filter_sqlite_clean.rb` / `filter_sqlite_smudge.rb`

  This filter-pair allows you to better store sqlite-databases inside a
  repository. The filters will convert a binary database file into an SQL
  dump for storage, and back into a database for use with your programs.

  You could, for example, track .[anki]-files using this filter-pair.

* `filter_pdf_clean.rb` / `filter_pdf_smudge.rb` (experimental)

  These filters (un)compress PDF-files using `pdftk`, which may (or may not)
  help with the compression efficiency inside of git's pack-files. There
  seems to be some effect, but it's probably too small to justify the time
  spent compressing.

If you find any of these useful, feel free to use them however you want.


[git]:    http://www.git-scm.org
[anki]:   http://ichi2.net/anki/
[filter]: http://www.kernel.org/pub/software/scm/git/docs/gitattributes.html#_tt_filter_tt
