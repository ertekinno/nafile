SOURCES=$(shell python3 scripts/read-config.py --sources)
FAMILY=$(shell python3 scripts/read-config.py --family)

help:
	@echo "###"
	@echo "# Build targets for $(FAMILY)"
	@echo "###"
	@echo
	@echo "  make build:  Builds the fonts and places them in the fonts/ directory"
	@echo "  make test:   Tests the fonts with fontbakery (Google Fonts profile)"
	@echo "  make proof:  Creates HTML proof documents in the proof/ directory"
	@echo "  make clean:  Removes the virtual environment and build intermediates"
	@echo

build: build.stamp

venv: venv/touchfile

build.stamp: venv sources/config.yaml $(SOURCES)
	rm -rf fonts
	(for config in sources/config*.yaml; do . venv/bin/activate; gftools builder $$config; done) && touch build.stamp

venv/touchfile: requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur requirements.txt
	touch venv/touchfile

test: venv build.stamp
	. venv/bin/activate; mkdir -p out/ out/fontbakery; fontbakery check-googlefonts -l WARN --full-lists --succinct --badges out/badges --html out/fontbakery/fontbakery-report.html --ghmarkdown out/fontbakery/fontbakery-report.md $(shell find fonts/ttf fonts/variable -type f -name '*.ttf') || echo '::warning file=sources/config.yaml,title=Fontbakery failures::The fontbakery QA check reported errors in your font. Please check the generated report.'

proof: venv build.stamp
	. venv/bin/activate; mkdir -p out/ out/proof; diffenator2 proof $(shell find fonts/ttf -type f -name '*.ttf') -o out/proof

clean:
	rm -rf venv build.stamp out
	find . -name "*.pyc" -delete
	rm -rf sources/build.ninja sources/.ninja_log sources/instance_ufos

update:
	pip install --upgrade $(dependency); pip freeze > requirements.txt

.PHONY: help build venv test proof clean update
