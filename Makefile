# Makefile for the autorevision project

VERS=$(shell ./autorevision -V | sed '/autorevision /s///')

.SUFFIXES: .md .html

.md.html:
	markdown $< > $@

prefix?=/usr/local
mandir?=share/man
target=$(DESTDIR)$(prefix)

DOCS    = README.md COPYING.md CONTRIBUTING.md autorevision.asciidoc NEWS
SOURCES = autorevision Makefile $(DOCS) control

all: docs

install: autorevision autorevision.1
	install -d "$(target)/bin"
	install -m 755 autorevision $(target)/bin/autorevision
	install -d "$(target)/$(mandir)/man1"
	gzip < autorevision.1 > $(target)/$(mandir)/man1/autorevision.1.gz

uninstall:
	rm -f $(target)/bin/autorevision $(target)/$(mandir)/man1/autorevision.1.gz

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

dist: autorevision-$(VERS).tgz

clean:
	rm -f autorevision.html autorevision.1 *.tgz
	rm -f autorevision.tmp docbook-xsl.css
	rm -f CONTRIBUTING.html COPYING.html README.html
	rm -f *~  SHIPPER.* index.html

docs: autorevision.1 autorevision.html README.html COPYING.html CONTRIBUTING.html

# Update ARVERSION in the script before running this.
release: autorevision.html README.html COPYING.html CONTRIBUTING.html
	shipper -u -m -t; make clean
