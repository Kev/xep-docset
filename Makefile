CONTRIBREPO=https://github.com/intosi/Dash-User-Contributions.git
CONTRIBUPSTREAM=https://github.com/Kapeli/Dash-User-Contributions.git
CONTRIBBASE=kapeli
DOCSET=XMPP_Extension_Protocols
CONTRIBDIR=$(CONTRIBBASE)/docsets/$(DOCSET)
XEPSSTAMP=$(shell date -r `git -C xeps --no-pager show --pretty='format:%ct'` +%Y%m%d%H%M%S)
DB=$(DOCSET).docset/Contents/Resources/docSet.dsidx
ICONS=$(DOCSET).docset/icon.png $(DOCSET).docset/icon@2x.png

.PHONY: all
all: docs $(DB) $(ICONS)

.PHONY: clean
clean:
	rm -rf $(DOCSET).docset/Contents/Resources
	rm -f xeps/*.html
	rm -rf $(CONTRIBBASE)


$(CONTRIBDIR)/%.png XEPs.docset/%.png: %.png
	cp -p $< $@

$(DB): generate_index.py $(wildcard $(DOCSET).docset/Contents/Resources/Documents/*)
	python generate_index.py $(DOCSET).docset/Contents/Resources/docSet.dsidx

.PHONY: docs
docs: $(DOCSET).docset/Contents/Resources/Documents xeps-build
	cp -p xeps/*.html $(DOCSET).docset/Contents/Resources/Documents/
	cp -p xeps/*.css $(DOCSET).docset/Contents/Resources/Documents/
	cp -p xeps/*.js $(DOCSET).docset/Contents/Resources/Documents/

$(DOCSET).docset/Contents/Resources/Documents:
	mkdir -p XEPs.docset/Contents/Resources/Documents/

.PHONY: xeps-build
xeps-build: xeps Makefile.xeps
	$(MAKE) -f ../Makefile.xeps -C xeps

xeps:
	git clone git@github.com:xsf/xeps.git

.PHONY: contribcommit
contribcommit: contrib
	git -C $(CONTRIBBASE) add docsets/$(DOCSET)
	git -C $(CONTRIBBASE) commit -m "Import XMPP Extension Protocols docset $(XEPSSTAMP)"

.PHONY: contrib
contrib: $(CONTRIBDIR) all $(CONTRIBDIR)/icon.png $(CONTRIBDIR)/icon@2x.png $(CONTRIBDIR)/$(DOCSET).tgz
	cp -p README.usercontrib.md $(CONTRIBDIR)/README.md
	python generate_docset_json.py xeps $(CONTRIBDIR)/docset.json $(XEPSSTAMP)

.PHONY: $(CONTRIBBASE)
$(CONTRIBBASE):
	test -d $(CONTRIBBASE) || git clone $(CONTRIBREPO) $(CONTRIBBASE)
	git -C $(CONTRIBBASE) remote get-url upstream 2>/dev/null || git -C $(CONTRIBBASE) remote add upstream $(CONTRIBUPSTREAM)
	git -C $(CONTRIBBASE) fetch upstream
	cd $(CONTRIBBASE); git checkout -b xeps-$(XEPSSTAMP) upstream/master || git checkout xeps-$(XEPSSTAMP)

$(CONTRIBDIR): $(CONTRIBBASE)
	test -d $(CONTRIBDIR) || mkdir $(CONTRIBDIR)

$(CONTRIBDIR)/$(DOCSET).tgz: $(DOCSET).docset $(wildcard $(DOCSET).docset/Contents/Resources/Documents/*)
	tar --exclude=.DS_Store -czf $(CONTRIBDIR)/$(DOCSET).tgz $(DOCSET).docset
