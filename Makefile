LOCAL_DIR  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PACKAGE_DIR = $(LOCAL_DIR)/beamertheme-source
DOC_DIR     = $(LOCAL_DIR)/doc
FONTS_DIR   = $(LOCAL_DIR)/fonts
CACHE_DIR   = $(LOCAL_DIR)/.latex-cache
PDFPC_SIZE  = 40000

PANDOC_TEMPLATE = $(LOCAL_DIR)/markdown.beamer

PACKAGE_SRC = $(wildcard $(PACKAGE_DIR)/*.dtx)
PACKAGE_STY = $(notdir $(PACKAGE_SRC:%.dtx=%.sty))
PACKAGE_TGT = $(addprefix $(LOCAL_DIR)/,$(PACKAGE_STY))

DOC_PDF      = $(patsubst %.tex,%.pdf,$(wildcard $(DOC_DIR)/*.tex))

LATEXMK_GEN ?= -xelatex

COMPILE_TEX  = latexmk $(LATEXMK_GEN) -output-directory=$(CACHE_DIR) --synctex=1

export TEXINPUTS:=$(LOCAL_DIR):$(FONTS_DIR):$(shell pwd):$(PACKAGE_DIR):${TEXINPUTS}

.PHONY: all sty doc clean mrproper

.INTERMEDIATE: %.pdfpc

all: sty doc

sty: $(PACKAGE_TGT)

doc: $(DOC_PDF)

clean::
	@rm -rf "$(CACHE_DIR)"

mrproper:: clean
	@rm -f $(PACKAGE_TGT) $(DOC_PDF) $(patsubst %.tex,%.pdfpc,$(wildcard $(DOC_DIR)/*.tex))

$(PACKAGE_TGT): $(wildcard $(PACKAGE_DIR)/*.ins) $(PACKAGE_SRC) | $(CACHE_DIR)
	@cd $(PACKAGE_DIR) && latex -output-directory=$(CACHE_DIR) $(notdir $<)
	@cp $(addprefix $(CACHE_DIR)/,$(PACKAGE_STY)) $(LOCAL_DIR)/

$(CACHE_DIR):; @mkdir -p $(CACHE_DIR)

%_handout.pdf: %.tex $(wildcard *.bib) $(PACKAGE_TGT) | $(CACHE_DIR)
	@# touch pdf to ensure it is deleted on build failures
	@test -f $@ && touch $@ || true
	@cd $(dir $< ) && $(COMPILE_TEX) -jobname=$*_handout $(notdir $<)
	@cp $(CACHE_DIR)/$(notdir $@) $@
	@cp $(CACHE_DIR)/$(notdir $*_handout.synctex.gz) $*_handout.synctex.gz
	@test ! -f $@pc -a -f $(CACHE_DIR)/$(notdir $@)pc && ( /bin/echo "[file]"; /bin/echo "$@"; /bin/echo "[font_size]"; /bin/echo "$(PDFPC_SIZE)"; cat $(CACHE_DIR)/$(notdir $@)pc | sed 's/\\\\/\n/g' | sed 's/\\par/\n\n/g' ) > $@pc || echo "ignoring PDFPC file" && exit 0

%.pdf: %.tex $(wildcard *.bib) $(PACKAGE_TGT) | $(CACHE_DIR)
	@# touch pdf to ensure it is deleted on build failures
	@test -f $@ && touch $@ || true
	@cd $(dir $< ) && $(COMPILE_TEX) $(notdir $<)
	@cp $(CACHE_DIR)/$(notdir $@) $@
	@cp $(CACHE_DIR)/$(notdir $*.synctex.gz) $*.synctex.gz
	@test ! -f $@pc -a -f $(CACHE_DIR)/$(notdir $@)pc && ( /bin/echo "[file]"; /bin/echo "$@"; /bin/echo "[font_size]"; /bin/echo "$(PDFPC_SIZE)"; cat $(CACHE_DIR)/$(notdir $@)pc | sed 's/\\\\/\n/g' | sed 's/\\par/\n\n/g' ) > $@pc || echo "ignoring PDFPC file" && exit 0

%.tex: %.md $(PANDOC_TEMPLATE)
	pandoc $< --natbib --slide-level=2 --to=beamer --template="$(PANDOC_TEMPLATE)" --to=beamer | sed -e "s/\\\\citep{/\\\\cite{/g" > $@

preview-%: %.tex $(wildcard *.bib) $(PACKAGE_TGT) | $(CACHE_DIR)
	@cd $(dir $< ) && $(COMPILE_TEX) $(notdir $<) -pvc -interaction=nonstopmode -view=pdf

pdfpc-%: %.pdf
	@pdfpc -g -p -C $<

evince-%: %.pdf
	@evince $<

FORCE:
.DELETE_ON_ERROR:
