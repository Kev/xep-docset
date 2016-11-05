
.PHONY: all
all: docs db


.PHONY: clean
clean:
	rm -rf XEPs.docset/Contents/Resources
	rm xeps/Makefile
	rm xeps/*.html

.PHONY: db
db: xeps-build
	python generate_index.py | sqlite3 XEPs.docset/Contents/Resources/docSet.dsidx

.PHONY: docs
docs: XEPs.docset/Contents/Resources/Documents xeps-build
	cp xeps/*.html XEPs.docset/Contents/Resources/Documents/
	cp xeps/*.css XEPs.docset/Contents/Resources/Documents/
	cp xeps/*.js XEPs.docset/Contents/Resources/Documents/

XEPs.docset/Contents/Resources/Documents:
	mkdir -p XEPs.docset/Contents/Resources/Documents/

.PHONY: xeps-build
xeps-build: Makefile.xeps
	$(MAKE) -f ../Makefile.xeps -C xeps

xeps:
	git clone git@github.com:xsf/xeps.git
