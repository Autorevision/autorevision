# Makefile for the autorevision project

# `a2x / asciidoc` is required to generate the Man page.
# `markdown` is required for the `docs` target, though it is not
# strictly necessary for packaging.
# `shipper` is required for the `release` target, which should only be
# used if you are shipping tarballs (you probably are not).

VERS := $(shell ./autorevision -V | sed -e 's:autorevision ::')

.SUFFIXES: .md .html

.md.html:
	markdown $< > $@

prefix ?= /usr/local
mandir ?= /share/man
target = $(DESTDIR)$(prefix)

DOCS = \
	NEWS \
	autorevision.asciidoc \
	README.md \
	CONTRIBUTING.md \
	AUTHORS \
	COPYING.md

SOURCES = \
	$(DOCS) \
	autorevision \
	Makefile \
	control

all : man docs

install: autorevision autorevision.1
	install -d "$(target)/bin"
	install -m 755 autorevision $(target)/bin/autorevision
	install -d "$(target)$(mandir)/man1"
	gzip --no-name < autorevision.1 > $(target)$(mandir)/man1/autorevision.1.gz

uninstall:
	rm -f $(target)/bin/autorevision $(target)$(mandir)/man1/autorevision.1.gz

autorevision.1: autorevision.asciidoc
	a2x -f manpage autorevision.asciidoc

# HTML representation of the man page
autorevision.html: autorevision.asciidoc
	asciidoc --doctype=manpage --backend=xhtml11 autorevision.asciidoc

# The tarball
autorevision-$(VERS).tgz: $(SOURCES) autorevision.1
	mkdir autorevision-$(VERS)
	cp -r $(SOURCES) autorevision-$(VERS)
	COPYFILE_DISABLE=1; export COPYFILE_DISABLE; \
	tar -czf autorevision-$(VERS).tgz autorevision-$(VERS)
	rm -fr autorevision-$(VERS)

dist: autorevision-$(VERS).tgz

clean:
	rm -f autorevision.html autorevision.1 *.tgz
	rm -f autorevision.tmp docbook-xsl.css
	rm -f CONTRIBUTING.html COPYING.html README.html
	rm -f *~  SHIPPER.* index.html

# The Man Page
man: autorevision.1

# HTML versions of doc files suitable for use on a website
docs: \
	autorevision.html \
	README.html \
	CONTRIBUTING.html \
	COPYING.html

# Update ARVERSION in the script before running this.
release: docs
	shipper -u -m -t; make clean
