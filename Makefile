# Makefile for the autoversion project
VERS=1.0

.SUFFIXES: .md .html

.md.html:
	markdown $<

MANDIR=/usr/share/man/man1
BINDIR=/usr/bin

DOCS    = README.md COPYING.md CONTRIBUTING.md autoversion.asc
SOURCES = autoversion manlifter Makefile $(DOCS) control

all: autoversion-$(VERS).tar.gz

install: autoversion.1
	cp autoversion 
	gzip <autoversion.1 >$(MANDIR)/autoversion.1.gz
	rm autoversion.1

uninstall:
	rm -f $(BINDIR)/autoversion $(MANDIR)/autoversion.1.gz

autoversion.1: autoversion.asc
	a2x -f manpage autoversion.asc

autoversion.html: autoversion.asc
	a2x -f html autoversion.asc

autoversion-$(VERS).tar.gz: $(SOURCES) autoversion.1 
	tar --transform='s:^:autoversion-$(VERS)/:' --show-transformed-names -cvzf autoversion-$(VERS).tar.gz $(SOURCES)

dist: autoversion-$(VERS).tar.gz

clean:
	rm -f autoversion.html autoversion.1 manlifter.1 *.tar.gz 
	rm -f *~  SHIPPER.* index.html

release: autoversion-$(VERS).tar.gz autoversion.html README.html COPYING.html CONTRIBUTING.html
	shipper -u -m -t; make clean

