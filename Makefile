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

$(RAW_DIR)/%.csv : $(TOKEN_DIR)/%.token $(PULL_SRC)
	@mkdir -p $(RAW_DIR)
	$(PULL_EXE) $< > $@

$(RAW_DIR)/%.csv : $(CONVERT_SRC) $(RAW_DIR)/%.xlsx
	Rscript $^ $@


## process     : Process raw data.
.PHONY : process
process : $(FULL_DATA)

$(CLEAN_DIR)/%.rds : $(SRC_DIR)/clean-%.R $(RAW_DIR)/%*.csv \
                     $(SRC_DIR)/clean-%*.R
	@mkdir -p $(CLEAN_DIR)
	Rscript $^ $@

$(FULL_DATA) : $(JOIN_SRC) $(CLEAN_RDSS)
	Rscript $^ $@


## feasibility : Generate feasibility results.
.PHONY : feasibility
feasibility : $(FEAS_DOC)

$(FEAS_DOC) : $(FEAS_SRC) $(RENDER_SRC) $(FULL_DATA)
	@mkdir -p $(RESULTS_DIR)
	$(RENDER_EXE) $< $@


## eff-tables  : Generate efficacy outcome tables.
.PHONY : eff-tables
eff-tables : $(TABLES_DOC)

$(TABLES_DOC) : $(TABLES_SRC) $(RENDER_SRC) $(TFUNCS_SRC) $(FULL_DATA)
	@mkdir -p $(RESULTS_DIR)
	$(RENDER_EXE) $< $@


## wilcox      : Run Wilcoxon tests on LTPA data.
.PHONY : wilcox
wilcox : $(WILCOX_LTPA)

$(WILCOX_LTPA) : $(WILCOX_SRC) $(FULL_DATA)
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


## help        : Show arguments to make and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
