LOCAL_DIR   = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PACKAGE_DIR = $(LOCAL_DIR)/beamertheme-source
DOC_DIR     = $(LOCAL_DIR)/doc
DEMO_DIR    = $(LOCAL_DIR)/demo
CACHE_DIR   = $(LOCAL_DIR)/.latex-cache

PACKAGE_SRC = $(wildcard $(PACKAGE_DIR)/*.dtx)
PACKAGE_STY = $(notdir $(PACKAGE_SRC:%.dtx=%.sty))

DOC_PDF     = $(patsubst %.tex,%.pdf,$(wildcard $(DOC_DIR)/*.tex))

DEMO_PDF    = $(patsubst %.tex,%.pdf,$(patsubst %.md,%.pdf, $(wildcard $(DEMO_DIR)/*.tex) $(wildcard $(DEMO_DIR)/*.md)))

COMPILE_TEX := latexmk -xelatex -output-directory=$(CACHE_DIR)

export TEXINPUTS:=$(LOCAL_DIR):$(shell pwd):$(PACKAGE_DIR):${TEXINPUTS}

.PHONY: all sty doc demo clean mrproper

all: sty demo doc

sty: $(PACKAGE_STY)

doc: $(DOC_PDF)

demo: $(DEMO_PDF)

clean:
	@rm -rf "$(CACHE_DIR)"

mrproper: clean
	@rm -f $(PACKAGE_STY) $(DEMO_PDF) $(DOC_PDF)

$(PACKAGE_STY): $(wildcard $(PACKAGE_DIR)/*.ins) $(PACKAGE_SRC)
	@mkdir -p $(CACHE_DIR)
	@cd $(PACKAGE_DIR) && latex -output-directory=$(CACHE_DIR) $(notdir $<)
	@cp $(addprefix $(CACHE_DIR)/,$(PACKAGE_STY)) .

%.pdf: %.tex  $(wildcard *.bib) $(PACKAGE_STY)
	@mkdir -p $(CACHE_DIR)
	@cd $(dir $< ) && $(COMPILE_TEX) $(notdir $<)
	@cp $(CACHE_DIR)/$(notdir $@) $@
