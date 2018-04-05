SRC_DIR=R
WRITEUP_DIR=docs
METHODS_DIR=methods
TOKEN_DIR=tokens
RAW_DIR=data-raw
CLEAN_DIR=data-processed
RESULTS_DIR=results

RAND_SRC=$(SRC_DIR)/randomize-animo.R
RAND_EXE=Rscript $(RAND_SRC)

RENDER_SRC=$(SRC_DIR)/render.R
RENDER_EXE=Rscript $(RENDER_SRC)

JOIN_SRC=$(SRC_DIR)/join-csvs.R
JOIN_EXE=Rscript $(JOIN_SRC)

CONVERT_SRC=$(SRC_DIR)/convert-excel-csv.R

RAND_CSV=$(METHODS_DIR)/randomization-list.csv
SAP_SRC=$(WRITEUP_DIR)/sap.Rmd
SAP_DOC= $(METHODS_DIR)/sap.docx
TOKEN_FILES=$(wildcard $(TOKEN_DIR)/*.token)
RAW_CSVS=$(patsubst $(TOKEN_DIR)/%.token, $(RAW_DIR)/%.csv, $(TOKEN_FILES)) \
  $(RAW_DIR)/dxa.csv
CLEAN_CSVS=$(patsubst $(RAW_DIR)/%.csv, $(CLEAN_DIR)/%.csv, $(RAW_CSVS)) \
  $(CLEAN_DIR)/food.csv
JOINED_CSV=$(CLEAN_DIR)/all.csv

TABLES_SRC=$(SRC_DIR)/efficacy-tables.Rmd
TFUNCS_SRC=$(SRC_DIR)/table-functions.R
TABLES_DOC=$(RESULTS_DIR)/efficacy-tables.html



## all         : Make all files
.PHONY : all
all : sap randomize pull process eff-tables


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
pull : $(RAW_CSVS)

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
process : $(CLEAN_CSVS) $(JOINED_CSV)

$(CLEAN_DIR)/%.csv : $(SRC_DIR)/clean-%.R $(RAW_DIR)/%*.csv
	@mkdir -p $(CLEAN_DIR)
	Rscript $^ > $@

$(JOINED_CSV) : $(CLEAN_CSVS) $(JOIN_SRC)
	$(JOIN_EXE) $^ > $@


## eff-tables  : Generate efficacy outcome tables.
.PHONY : eff-tables
tables : $(TABLES_DOC)

$(TABLES_DOC) : $(TABLES_SRC) $(RENDER_SRC) $(TFUNCS_SRC)
	@mkdir -p $(RESULTS_DIR)
	$(RENDER_EXE) $< $@


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
