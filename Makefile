include config.mk


## all         : Make all files
.PHONY : all
all : sap randomize pull process descr feas eff wilcox


## sap         : Generate the SAP (including sample size justification).
.PHONY : sap
sap : $(SAP_DOC)

$(SAP_DOC) : $(RENDER_SRC) $(SAP_SRC)
	@mkdir -p $(METHODS_DIR)
	Rscript $^ $@


## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(RAND_CSV)

$(RAND_CSV) : $(RAND_SRC)
	@mkdir -p $(METHODS_DIR)
	Rscript $< 9 50 $@


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


## feas        : Generate feasibility results.
.PHONY : feas
feas : $(FEAS_DOC)

$(FEAS_DOC) : $(RENDER_SRC) $(FEAS_SRC) $(FULL_DATA) $(SCREEN_CSV)
	@mkdir -p $(RESULTS_DIR)
	Rscript  $^ $@


## descr       : Generate participant characteristics table.
.PHONY : descr
descr : $(DESCR_DOC)

$(DESCR_DOC) : $(RENDER_SRC) $(DESCR_SRC) $(FULL_DATA)
	@mkdir -p $(RESULTS_DIR)
	Rscript $^ $@


## eff         : Generate efficacy outcome tables.
.PHONY : eff
eff : $(EFF_DOC)

$(EFF_RAW_RDS) : $(EFF_MODEL_SRC) $(FULL_DATA)
	@mkdir -p $(RESULTS_DIR)
	Rscript $^ $@

$(EFF_RDS) : $(EFF_FORMAT_SRC) $(EFF_RAW_RDS)
	Rscript $^ $@

$(EFF_DOC) : $(RENDER_SRC) $(EFF_SRC) $(EFF_RDS)
	Rscript $^ $@


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
	rm -fR $(CACHE_DIR)


## remove-raw  : Removed data downloaded from REDCap, converted from other data.
.PHONY : remove-raw
remove-raw :
	rm -f $(RAW_CSVS)


## help        : Show arguments to make and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
