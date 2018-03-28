LOCAL_DIR  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PACKAGE_DIR = $(LOCAL_DIR)/beamertheme-source
DOC_DIR     = $(LOCAL_DIR)/doc
CACHE_DIR   = $(LOCAL_DIR)/.latex-cache
PDFPC_SIZE  = 40000

PACKAGE_SRC = $(wildcard $(PACKAGE_DIR)/*.dtx)
PACKAGE_STY = $(notdir $(PACKAGE_SRC:%.dtx=%.sty))
PACKAGE_TGT = $(addprefix $(LOCAL_DIR)/,$(PACKAGE_STY))

DOC_PDF      = $(patsubst %.tex,%.pdf,$(wildcard $(DOC_DIR)/*.tex))

COMPILE_TEX := latexmk -lualatex -output-directory=$(CACHE_DIR)

export TEXINPUTS:=$(LOCAL_DIR):$(LOCAL_DIR)/fonts/:$(shell pwd):$(PACKAGE_DIR):${TEXINPUTS}

.PHONY: all sty doc clean mrproper

.INTERMEDIATE: %.pdfpc

all: sty doc

sty: $(PACKAGE_TGT)

doc: $(DOC_PDF)

clean::
	@rm -rf "$(CACHE_DIR)"

mrproper:: clean
	@rm -f $(PACKAGE_TGT) $(DOC_PDF) $(patsubst %.tex,%.pdfpc,$(wildcard $(DOC_DIR)/*.tex))

$(PACKAGE_TGT): $(wildcard $(PACKAGE_DIR)/*.ins) $(PACKAGE_SRC)
	@mkdir -p $(CACHE_DIR)
	@cd $(PACKAGE_DIR) && latex -output-directory=$(CACHE_DIR) $(notdir $<)
	@cp $(addprefix $(CACHE_DIR)/,$(PACKAGE_STY)) $(LOCAL_DIR)/

%.pdf: %.tex  $(wildcard *.bib) $(PACKAGE_TGT)
	@mkdir -p $(CACHE_DIR)
	@cd $(dir $< ) && $(COMPILE_TEX) $(notdir $<)
	@cp $(CACHE_DIR)/$(notdir $@) $@
	@test ! -f $@pc -a -f $(CACHE_DIR)/$(notdir $@)pc && ( /bin/echo -e "[file]\n$@\n[font_size]\n$(PDFPC_SIZE)" ; cat $(CACHE_DIR)/$(notdir $@)pc | sed 's/\\\\/\n/g' | sed 's/\\par/\n\n/g' ) > $@pc || echo "ignoring PDFPC file" && exit 0

pdfpc-%: %.pdf
	@pdfpc -p -C $<

evince-%: %.pdf
	@evince $<

