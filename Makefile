SRC_DIR=R
RAND_SRC=randomize-animo.R
SAP_SRC=sap.Rmd
SAP_DOC=sap.docx
RESULTS_DIR=results
METHODS_DIR=methods
RAND_CSV=randomization-list.csv
WRITEUP_DIR=docs
RAW_DIR=data-raw
TOKEN_DIR=tokens
TOKEN_FILES=$(wildcard $(TOKEN_DIR)/*.token)
RAW_CSVS=$(patsubst $(TOKEN_DIR)/%.token, $(RAW_DIR)/%.csv, $(TOKEN_FILES)) \
 $(RAW_DIR)/dxa.csv
CLEAN_DIR=data-processed
CLEAN_CSVS=$(patsubst $(RAW_DIR)/%.csv, $(CLEAN_DIR)/%.csv, $(RAW_CSVS)) \
$(CLEAN_DIR)/food.csv
RENDER_SRC=$(SRC_DIR)/render.R


## all         : Make all files
.PHONY : all
all : sap randomize pull process


## sap         : Generate the SAP (including sample size justification).
.PHONY : sap
sap : $(METHODS_DIR)/$(SAP_DOC)

$(METHODS_DIR)/$(SAP_DOC) : $(RENDER_SRC) $(WRITEUP_DIR)/$(SAP_SRC) 
	@mkdir -p $(METHODS_DIR)
	Rscript $^ $(SAP_DOC) $(METHODS_DIR)


## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(METHODS_DIR)/$(RAND_CSV)

$(METHODS_DIR)/$(RAND_CSV) : $(SRC_DIR)/$(RAND_SRC)
	@mkdir -p $(METHODS_DIR)
	Rscript $< 9 50 $@ # second argument: seed, third: total # of participants


## pull        : Get raw data (from REDCap, or convert from xlsx)
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

$(RAW_DIR)/%.csv : $(RAW_DIR)/%.xlsx
	Rscript $(SRC_DIR)/convert-excel-csv.R $< $@


## process     : Process raw data.
.PHONY : process
process : $(CLEAN_CSVS)

$(CLEAN_DIR)/%.csv : $(SRC_DIR)/clean-%.R $(RAW_DIR)/%.csv
	@mkdir -p $(CLEAN_DIR)
	Rscript $^ > $@

$(CLEAN_DIR)/food.csv : $(SRC_DIR)/clean-food.R $(wildcard $(RAW_DIR)/food*.csv)
	Rscript $^ > $@


## remove      : Remove auto-generated files.
.PHONY : remove
remove :
	rm -fR $(METHODS_DIR)
	rm -fR $(CLEAN_DIR)
	rm -fR $(RESULTS_DIR)
	rm -f $(WRITEUP_DIR)/*cache


## remove-raw  : Removed data downloaded from REDCap, converted from other data.
.PHONY : remove-raw
remove-raw :
	rm -f $(RAW_CSVS)


## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
