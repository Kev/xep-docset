
.PHONY: all
all: docs db


.PHONY: clean
clean:
	rm -rf XEPs.docset/Contents/Resources
	rm xmpp/extensions/Makefile
	rm xmpp/extensions/*.html

.PHONY: db
db: xmpp-build
	python generate_index.py | sqlite3 XEPs.docset/Contents/Resources/docSet.dsidx

.PHONY: docs
docs: XEPs.docset/Contents/Resources/Documents xmpp-build
	cp xmpp/extensions/*.html XEPs.docset/Contents/Resources/Documents/
	cp xmpp/extensions/*.css XEPs.docset/Contents/Resources/Documents/
	cp xmpp/extensions/*.js XEPs.docset/Contents/Resources/Documents/

XEPs.docset/Contents/Resources/Documents:
	mkdir -p XEPs.docset/Contents/Resources/Documents/

xmpp/extensions/Makefile: xmpp
	cp Makefile.xeps xmpp/extensions/Makefile

.PHONY: xmpp-build
xmpp-build: xmpp/extensions/Makefile
	$(MAKE) -C xmpp/extensions

xmpp:
	git clone git@perseus.jabber.org:xmpp.git
