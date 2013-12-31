# Makefile for the autorevision project

# `a2x / asciidoc` is required to generate the Man page.
# `markdown` is required for the `docs` target, though it is not
# strictly necessary for packaging.
# `shipper` is required for the `release` target, which should only be
# used if you are shipping tarballs (you probably are not).

# Get the version number
VERS := $(shell ./autorevision.sh -s VCS_TAG -o ./autorevision.cache | sed -e 's:v/::')

.SUFFIXES: .md .html

.md.html:
	markdown $< > $@

# `prefix`, `mandir` & `DESTDIR` can and should be set on the command line to control installation locations
prefix ?= /usr/local
mandir ?= /share/man
target = $(DESTDIR)$(prefix)

DOCS = \
	NEWS \
	autorevision.asciidoc \
	README.md \
	CONTRIBUTING.md \
	COPYING.md

SOURCES = \
	$(DOCS) \
	autorevision.sh \
	Makefile \
	control

EXTRA_DIST = \
	AUTHORS.txt \
	autorevision.cache

all : cmd man auth

# The script
cmd: autorevision

autorevision: autorevision.sh
	sed -e 's:&&ARVERSION&&:$(VERS):g' autorevision.sh > autorevision
	chmod +x autorevision

# The Man Page
man: autorevision.1

autorevision.1: autorevision.asciidoc
	a2x -f manpage autorevision.asciidoc

# HTML representation of the man page
autorevision.html: autorevision.asciidoc
	asciidoc --doctype=manpage --backend=xhtml11 autorevision.asciidoc

# Authors
auth:
	git log --format='%aN <%aE>' | awk '{arr[$$0]++} END{for (i in arr){print arr[i], i;}}' | sort -rn | cut -d\  -f2- > AUTHORS.txt

# The tarball
dist: autorevision-$(VERS).tgz

autorevision-$(VERS).tgz: $(SOURCES) all
	mkdir autorevision-$(VERS)
	cp -pR $(SOURCES) $(EXTRA_DIST) autorevision-$(VERS)/
	@COPYFILE_DISABLE=1 tar -czf autorevision-$(VERS).tgz autorevision-$(VERS)
	rm -fr autorevision-$(VERS)

install: cmd man
	install -d "$(target)/bin"
	install -m 755 autorevision "$(target)/bin/autorevision"
	install -d "$(target)$(mandir)/man1"
	gzip --no-name < autorevision.1 > "$(target)$(mandir)/man1/autorevision.1.gz"

uninstall:
	rm -f "$(target)/bin/autorevision" "$(target)$(mandir)/man1/autorevision.1.gz"

clean:
	rm -f autorevision autorevision.html autorevision.1 *.tgz
	rm -f docbook-xsl.css
	rm -f AUTHORS AUTHORS.txt
	rm -f CONTRIBUTING.html COPYING.html README.html
	rm -f *~ index.html

# Not safe to run in a tarball
devclean: clean
	rm -f autorevision.cache

# HTML versions of doc files suitable for use on a website
docs: \
	autorevision.html \
	README.html \
	CONTRIBUTING.html \
	COPYING.html

# Tag with `git tag -s v/<number>` before running this.
release: docs dist
	git tag -v "v/$(VERS)"
	shipper version=$(VERS) | sh -e -x
