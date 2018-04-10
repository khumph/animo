include config.mk


## all         : Make all files
.PHONY : all
all : sap randomize pull process eff-tables wilcox feasibility


## sap         : Generate the SAP (including sample size justification).
.PHONY : sap
sap : $(SAP_DOC)

$(SAP_DOC) : $(SAP_SRC) $(RENDER_SRC)
	@mkdir -p $(METHODS_DIR)
	$(RENDER_EXE) $< $(SAP_DOC)


## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(RAND_CSV)

$(RAND_CSV) : $(RAND_SRC)
	@mkdir -p $(METHODS_DIR)
	$(RAND_EXE) 9 50 $@


## pull        : Get raw data (from REDCap, and/or convert from xlsx)
.PHONY : pull
pull : $(RAW_CSVS) $(RAW_DIR)/screen.csv

$(RAW_DIR)/%.csv : $(TOKEN_DIR)/%.token
	@mkdir -p $(RAW_DIR)
	curl -X POST https://redcap.uahs.arizona.edu/api/ \
	    -d token=$$(head -1 $<) \
	    -d content=record \
	    -d format=csv \
	    -d rawOrLabel=label \
	    -d rawOrLabelHeaders=raw \
	    > $@

$(RAW_DIR)/%.csv : $(CONVERT_SRC) $(RAW_DIR)/%.xlsx
	Rscript $^ $@


## process     : Process raw data.
.PHONY : process
process : $(FORMATTED_DATA)

$(CLEAN_DIR)/%.csv : $(SRC_DIR)/clean-%.R $(RAW_DIR)/%*.csv
	@mkdir -p $(CLEAN_DIR)
	Rscript $^ > $@

$(JOINED_CSV) : $(CLEAN_CSVS) $(JOIN_SRC)
	$(JOIN_EXE) $^ > $@

$(FORMATTED_DATA) : $(JOINED_CSV) $(FORMAT_SRC)
	$(FORMAT_EXE) $< $@


## feasibility   : Generate feasibility results.
.PHONY : feasibility
feasibility : $(FEAS_DOC)

$(FEAS_DOC) : $(FEAS_SRC) $(RENDER_SRC) $(FORMATTED_DATA)
	@mkdir -p $(RESULTS_DIR)
	$(RENDER_EXE) $< $@


## eff-tables  : Generate efficacy outcome tables.
.PHONY : eff-tables
eff-tables : $(TABLES_DOC)

$(TABLES_DOC) : $(TABLES_SRC) $(RENDER_SRC) $(TFUNCS_SRC) $(FORMATTED_DATA)
	@mkdir -p $(RESULTS_DIR)
	$(RENDER_EXE) $< $@


## wilcox      : Run Wilcoxon tests on LTPA data.
.PHONY : wilcox
wilcox : $(WILCOX_LTPA)

$(WILCOX_LTPA) : $(WILCOX_SRC) $(FORMATTED_DATA)
	@mkdir -p $(RESULTS_DIR)
	Rscript $^ $@


## remove      : Remove auto-generated files.
.PHONY : remove
remove :
	rm -fR $(METHODS_DIR)
	rm -fR $(CLEAN_DIR)
	rm -fR $(RESULTS_DIR)
	rm -fR $(WRITEUP_DIR)/*cache
	rm -fR $(SRC_DIR)/*cache


## remove-raw  : Removed data downloaded from REDCap, converted from other data.
.PHONY : remove-raw
remove-raw :
	rm -f $(RAW_CSVS)


## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
