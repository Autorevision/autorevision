# Makefile for the autorevision project

VERS=$(shell ./autorevision -V | sed '/autorevision /s///')

.SUFFIXES: .md .html

.md.html:
	markdown $< > $@

MANDIR=/usr/local/share/man/man1
BINDIR=/usr/local/bin

DOCS    = README.md COPYING.md CONTRIBUTING.md autorevision.asciidoc NEWS
SOURCES = autorevision Makefile $(DOCS) control
EXTRA_DIST = autorevision.tmp

all: docs

install: autorevision autorevision.1
	install -m755 -D -T autorevision $(DESTDIR)$(BINDIR)/autorevision
	gzip < autorevision.1 > $(DESTDIR)$(MANDIR)/autorevision.1.gz

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/autorevision $(DESTDIR)$(MANDIR)/autorevision.1.gz

autorevision.1: autorevision.asciidoc
	a2x -f manpage autorevision.asciidoc

autorevision.html: autorevision.asciidoc
	a2x -f xhtml autorevision.asciidoc

autorevision-$(VERS).tgz: $(SOURCES) autorevision.1
	mkdir autorevision-$(VERS)
	cp -r $(SOURCES) $(EXTRA_DIST) autorevision-$(VERS)
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
