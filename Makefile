CONTRIBREPO=https://github.com/intosi/Dash-User-Contributions.git
CONTRIBUPSTREAM=https://github.com/Kapeli/Dash-User-Contributions.git
CONTRIBBASE=kapeli
CONTRIBDOCSET=docsets/XEPs
CONTRIBDIR=$(CONTRIBBASE)/$(CONTRIBDOCSET)
XEPSSTAMP=$(shell date -r `git -C xeps --no-pager show --pretty='format:%ct'` +%Y%m%d%H%M%S)

.PHONY: all
all: docs db icons

.PHONY: clean
clean:
	rm -rf XEPs.docset/Contents/Resources
	rm -f xeps/*.html
	rm -rf $(CONTRIBBASE)

.PHONY: icons
icons: XEPs.docset/icon.png XEPs.docset/icon@2x.png

$(CONTRIBDIR)/%.png XEPs.docset/%.png: %.png
	cp -p $< $@

.PHONY: db
db: xeps-build
	python generate_index.py XEPs.docset/Contents/Resources/docSet.dsidx

.PHONY: docs
docs: XEPs.docset/Contents/Resources/Documents xeps-build
	cp -p xeps/*.html XEPs.docset/Contents/Resources/Documents/
	cp -p xeps/*.css XEPs.docset/Contents/Resources/Documents/
	cp -p xeps/*.js XEPs.docset/Contents/Resources/Documents/

XEPs.docset/Contents/Resources/Documents:
	mkdir -p XEPs.docset/Contents/Resources/Documents/

.PHONY: xeps-build
xeps-build: xeps Makefile.xeps
	$(MAKE) -f ../Makefile.xeps -C xeps

xeps:
	git clone git@github.com:xsf/xeps.git

.PHONY: contribcommit
contribcommit: contrib
	git -C $(CONTRIBBASE) add $(CONTRIBDOCSET)
	git -C $(CONTRIBBASE) commit -m "Import XEPs docset $(XEPSSTAMP)"

.PHONY: contrib
contrib: $(CONTRIBDIR) all $(CONTRIBDIR)/icon.png $(CONTRIBDIR)/icon@2x.png $(CONTRIBDIR)/XEPs.tgz
	cp -p README.usercontrib.md $(CONTRIBDIR)/README.md
	python generate_docset_json.py xeps $(CONTRIBDIR)/docset.json $(XEPSSTAMP)

.PHONY: kapeli
$(CONTRIBBASE):
	test -d $(CONTRIBBASE) || git clone $(CONTRIBREPO) $(CONTRIBBASE)
	git -C $(CONTRIBBASE) remote get-url upstream 2>/dev/null || git -C $(CONTRIBBASE) remote add upstream $(CONTRIBUPSTREAM)
	git -C $(CONTRIBBASE) fetch upstream
	cd $(CONTRIBBASE); git checkout -b xeps-$(XEPSSTAMP) upstream/master || git checkout xeps-$(XEPSSTAMP)

$(CONTRIBDIR): $(CONTRIBBASE)
	test -d $(CONTRIBDIR) || mkdir $(CONTRIBDIR)

$(CONTRIBDIR)/XEPs.tgz: XEPs.docset $(wildcard XEPs.docset/Contents/Resources/Documents/*)
	tar --exclude=.DS_Store -czf $(CONTRIBDIR)/XEPs.tgz XEPs.docset
