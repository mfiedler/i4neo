LOCAL_DIR  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PACKAGE_DIR = $(LOCAL_DIR)/beamertheme-source
DOC_DIR     = $(LOCAL_DIR)/doc
FONTS_DIR   = $(LOCAL_DIR)/fonts
CACHE_DIR   = $(LOCAL_DIR)/.latex-cache
GS_QUALITY ?= ebook

PANDOC_TEMPLATE = $(LOCAL_DIR)/markdown.beamer

PACKAGE_SRC = $(wildcard $(PACKAGE_DIR)/*.dtx)
PACKAGE_STY = $(notdir $(PACKAGE_SRC:%.dtx=%.sty))
PACKAGE_TGT = $(addprefix $(LOCAL_DIR)/,$(PACKAGE_STY))

DOC_PDF      = $(patsubst %.tex,%.pdf,$(wildcard $(DOC_DIR)/*.tex))

LATEXMK_GEN ?= -xelatex

# bibtex_fudge must be set for latexmk 4.70a (included in Debian Bullseye) to workaround
# output directory restrictions in bibtex. see also https://tex.stackexchange.com/a/564691
COMPILE_TEX  = latexmk $(LATEXMK_GEN) -output-directory=$(CACHE_DIR) --synctex=1 -e '$$bibtex_fudge=1'

export TEXINPUTS:=$(LOCAL_DIR):$(FONTS_DIR):$(shell pwd):$(PACKAGE_DIR):${TEXINPUTS}

.PHONY: all sty doc clean mrproper

all: sty

sty: $(PACKAGE_TGT)

doc: $(DOC_PDF)

clean::
	@rm -rf "$(CACHE_DIR)"

mrproper:: clean
	@rm -f $(PACKAGE_TGT) $(DOC_PDF) $(patsubst %.tex,$(wildcard $(DOC_DIR)/*.tex))

$(PACKAGE_TGT): $(wildcard $(PACKAGE_DIR)/*.ins) $(PACKAGE_SRC) | $(CACHE_DIR)
	@cd $(PACKAGE_DIR) && flock $(CACHE_DIR) latex -output-directory=$(CACHE_DIR) $(notdir $<)
	@flock $(LOCAL_DIR) cp $(addprefix $(CACHE_DIR)/,$(PACKAGE_STY)) $(LOCAL_DIR)/

$(CACHE_DIR):; @mkdir -p $(CACHE_DIR)

%_handout.pdf %_1x2.pdf %_2x2.pdf  %_handout_1x2.pdf %_handout_2x2.pdf %.pdf: %.tex $(wildcard *.bib) $(PACKAGE_TGT) FORCE | $(CACHE_DIR)
	@test -f $@ && touch $@ || true
	@cd $(dir $< ) && $(COMPILE_TEX) -jobname=$(basename $(notdir $@)) $(notdir $<)
	@cp $(CACHE_DIR)/$(notdir $@) $@
	@cp $(CACHE_DIR)/$(notdir $(basename $(notdir $@)).synctex.gz) $(basename $(notdir $@)).synctex.gz

%.tex: %.md $(PANDOC_TEMPLATE)
	@pandoc $< --natbib --slide-level=2 --to=beamer --template="$(PANDOC_TEMPLATE)" --to=beamer | sed -e "s/\\\\citep{/\\\\cite{/g" > $@

%_web.pdf: %.pdf
	@ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$(GS_QUALITY) -dDetectDuplicateImages=true -dFastWebView -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$@ $<

%_bbb.pdf: %.pdf
	@ghostscript -dNoOutputFonts -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$(GS_QUALITY) -dFastWebView -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$@ $<

preview-%: %.tex $(wildcard *.bib) $(PACKAGE_TGT) | $(CACHE_DIR)
	@cd $(dir $< ) && $(COMPILE_TEX) $(notdir $<) -pvc -interaction=nonstopmode -view=pdf

pdfpc-%: %.pdf
	@pdfpc -g -p -C $<

evince-%: %.pdf
	@evince $<

help::
	@echo
	@echo "Useful i4neo targets:"
	@echo
	@echo "	[FILE].pdf          Generate PDF from Latex Beamer ([FILE].tex)"
	@echo "	                    or Markdown ([FILE].md) with Pandoc Beamer flavour"
	@echo "	preview-[FILE]      Live preview with automatic rebuild on change"
	@echo "	pdfpc-[FILE]        Start PDFPC presentation"
	@echo "	evince-[FILE]       Open PDF in Evince viewer"
	@echo "	[FILE]_handout.pdf  Generate handout version of presentation"
	@echo "	[FILE]_1x2.pdf      Generate printable version with two slides per page"
	@echo "	[FILE]_2x2.pdf      Generate printable version with four slides per page"
	@echo "	[FILE]_web.pdf      Generate a compressed version for web"
	@echo "	[FILE]_bbb.pdf      Generate a version to be uploaded in BigBlueButton"
	@echo
	@echo "Concatenation is supported: [FILE]_handout_2x2_web.pdf"
	@echo
	@echo "Source at https://gitlab.cs.fau.de/i4/tex/i4neo"
	@echo

FORCE:
.DELETE_ON_ERROR:
