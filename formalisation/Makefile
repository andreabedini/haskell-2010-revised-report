# Requires an Ott with the Typst backend (github.com/andreabedini/ott).
OTT ?= ott
TYPST ?= typst

all: build/expressions.pdf build/layout.pdf build/report.pdf

build/expressions.typ build/report.typ: ott/style.ott ott/expressions.ott doc/report.src.typ
	@mkdir -p build
	$(OTT) -i ott/style.ott -i ott/expressions.ott -o build/expressions.typ \
	  -typst_filter doc/report.src.typ build/report.typ

build/layout.typ: ott/style.ott ott/layout.ott
	@mkdir -p build
	$(OTT) -i ott/style.ott -i ott/layout.ott -o build/layout.typ

build/%.pdf: build/%.typ
	$(TYPST) compile $< $@

build/report.pdf: build/expressions.typ build/layout.typ

clean:
	rm -rf build

.PHONY: all clean
