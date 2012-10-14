Autorevision
============

A program for extracting version information useful in release/build scripting from repositories. 

Supported repository types include git, hg, and svn. The record can be emitted in a ready-to-use form for C, C++, bash, Python, Perl, lua, or XCode. 

Emitted information includes the ID of the most recent commit, its branch, its date, and several other usaefil pieces of metainformation.

There is support for reasding and writing a cache file so autorevision will remain useful during a buld from an unpacked distrubution tarball.

See the manual page, included in the distribution, for invocation details.
