# Requires an Ott with the Typst backend (github.com/andreabedini/ott).
OTT ?= ott
TYPST ?= typst

all: build/expressions.pdf build/expressions.doc.pdf build/layout.pdf

build/expressions.typ build/expressions.doc.typ: ott/style.ott ott/expressions.ott doc/expressions.src.typ
	@mkdir -p build
	$(OTT) -i ott/style.ott -i ott/expressions.ott -o build/expressions.typ \
	  -typst_filter doc/expressions.src.typ build/expressions.doc.typ

build/layout.typ: ott/style.ott ott/layout.ott
	@mkdir -p build
	$(OTT) -i ott/style.ott -i ott/layout.ott -o build/layout.typ

build/%.pdf: build/%.typ
	$(TYPST) compile $< $@

build/expressions.doc.pdf: build/expressions.typ

clean:
	rm -rf build

.PHONY: all clean
