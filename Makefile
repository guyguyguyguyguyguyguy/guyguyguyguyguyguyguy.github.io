OUTDIR ?= www
DEPLOYDIR ?= /var/www/html

all: site

site:
	mkdir -p $(OUTDIR)
	WEBSITE_OUT_DIR=$(shell readlink -f $(OUTDIR)) ./build.sh

# Force a clean publish (clears timestamps)
site-clean:
	mkdir -p $(OUTDIR)
	WEBSITE_OUT_DIR=$(shell readlink -f $(OUTDIR)) CLEAN=1 ./build.sh

serve: site
	cd $(OUTDIR) && python3 -m http.server 8000

deploy: site
	@echo "Site built in $(OUTDIR)/ - GitHub Actions will handle deployment"

clean:
	rm -rf $(OUTDIR)/*

.PHONY: all site site-clean serve deploy clean
