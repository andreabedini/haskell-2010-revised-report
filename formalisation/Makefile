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

# The modules imported by the report, without the document wrapper.  They are
# committed, unlike build/.
typst: typst/expressions.typ typst/layout.typ

typst/expressions.typ: ott/style.ott ott/expressions.ott
	$(OTT) -tex_wrap false -i ott/style.ott -i ott/expressions.ott -o $@

typst/layout.typ: ott/style.ott ott/layout.ott
	$(OTT) -tex_wrap false -i ott/style.ott -i ott/layout.ott -o $@

clean:
	rm -rf build

.PHONY: all typst clean
