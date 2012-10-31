# Makefile for the autorevision project

VERS=$(shell ./autorevision -o autorevision.tmp -s VCS_TAG | sed -e 's:refs/heads/::' -e 's:v/::')

.SUFFIXES: .md .html

.md.html:
	markdown $< >$@

MANDIR=/usr/share/man/man1
BINDIR=/usr/bin

DOCS    = README.md COPYING.md CONTRIBUTING.md autorevision.asciidoc NEWS
SOURCES = autorevision Makefile $(DOCS) control
EXTRA_DIST = autorevision.tmp

all: autorevision-$(VERS).tgz

install: autorevision.1
	cp autorevision
	gzip <autorevision.1 >$(MANDIR)/autorevision.1.gz
	rm autorevision.1

uninstall:
	rm -f $(BINDIR)/autorevision $(MANDIR)/autorevision.1.gz

autorevision.1: autorevision.asciidoc
	a2x -f manpage autorevision.asciidoc

autorevision.html: autorevision.asciidoc
	a2x -f xhtml autorevision.asciidoc

autorevision-$(VERS).tgz: $(SOURCES) autorevision.1
	mkdir autorevision-$(VERS)
	cp -r $(SOURCES) autorevision-$(VERS)
	COPYFILE_DISABLE=1; export COPYFILE_DISABLE; \
	tar -czf autorevision-$(VERS).tgz autorevision-$(VERS)
	rm -fr autorevision-$(VERS)
	ls -l autorevision-$(VERS).tgz

dist: autorevision-$(VERS).tgz

clean:
	rm -f autorevision.html autorevision.1 *.tgz
	rm -f autorevision.tmp docbook-xsl.css
	rm -f CONTRIBUTING.html COPYING.html README.html
	rm -f *~  SHIPPER.* index.html

docs: autorevision.html README.html COPYING.html CONTRIBUTING.html

# Don't forget to release-tag (signed or annotated) in the repo and update
# 'ARVERSION' autorevision *before* calling make release.
# This is required for the release number to be correct.
release: autorevision-$(VERS).tgz autorevision.html README.html COPYING.html CONTRIBUTING.html
	shipper -u -m; make clean
