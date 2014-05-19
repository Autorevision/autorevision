# Generic makefile showing how to use autorevision.
#
# Get the version number for use in the makefile and generate / update
# the cache as needed.
VERS := $(shell autorevision -s VCS_TAG -o ./autorevision.cache)

# This gives you a $(VERS) variable that you can use later in the
# makefile (say, in your tarball name); it also means that the
# expensive operations that autorevision runs only have to be done
# once.


SOURCES = \
	autorevision.h \
	autorevision.json

EXTRA_DIST = \
	autorevision.cache

# Make sure that the cache file ends up in your tarball or
# autorevision will break.


all : json cpp



# Generate json output
json: autorevision.json

autorevision.json: autorevision.cache
	autorevision -f -t json -o ./autorevision.cache > autorevision.json


# Generate C/C++ header output
cpp: autorevision.h

autorevision.h: autorevision.cache
	autorevision -f -t h -o ./autorevision.cache > autorevision.h
