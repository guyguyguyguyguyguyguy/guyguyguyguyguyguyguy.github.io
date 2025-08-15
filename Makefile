# Makefile with GitHub Pages support
OUTDIR ?= www
DEPLOYDIR ?= /var/www/html

all: site

site:
	mkdir -p $(OUTDIR)
	WEBSITE_OUT_DIR=$(shell readlink -f $(OUTDIR)) ./build.sh

# Local development server
serve: site
	cd $(OUTDIR) && python3 -m http.server 8000

# GitHub Actions will use this
deploy: site
	@echo "Site built in $(OUTDIR)/ - GitHub Actions will handle deployment"

clean:
	rm -rf $(OUTDIR)/*

.PHONY: all site serve deploy clean
