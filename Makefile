SRC_DIR=R
RAND_SRC=randomize-animo.R
SAP_SRC=sap.Rmd
SAP_DOC=sap.html
RESULTS_DIR=results
METHODS_DIR=methods
RAND_CSV=randomization-list.csv
WRITEUP_DIR=docs
RAW_DIR=data-raw
RAW_CSVS=$(RAW_DIR)/animo.csv $(RAW_DIR)/blood.csv
TOKEN_DIR=tokens
TOKEN_FILES=$(wildcard $(TOKEN_DIR)/*.token)
RAW_CSVS=$(patsubst $(TOKEN_DIR)/%.token, $(RAW_DIR)/%.csv, $(TOKEN_FILES))

## all          : Make all files
.PHONY : all
all : sap randomize pull

## sap          : Generate the SAP (including sample size justification).
.PHONY : sap
sap : $(METHODS_DIR)/$(SAP_DOC)

$(METHODS_DIR)/$(SAP_DOC) : $(WRITEUP_DIR)/$(SAP_SRC)
	@mkdir -p $(METHODS_DIR)
	R -e 'rmarkdown::render("$<", output_format = "html_document", \
	  output_file = "$(SAP_DOC)", output_dir = "$(METHODS_DIR)")'


## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(METHODS_DIR)/$(RAND_CSV)

$(METHODS_DIR)/$(RAND_CSV) : $(SRC_DIR)/$(RAND_SRC)
	@mkdir -p $(METHODS_DIR)
	Rscript $< 9 50 $@ # second argument: seed, third: total # of participants


## clean       : Remove auto-generated files.
.PHONY : clean
clean :
	rm -fR $(METHODS_DIR)
	rm -fR $(RESULTS_DIR)


## clean-data  : Removed data downloaded from REDCap
.PHONY : clean-data
	rm -f $(RAW_CSVS)


## pull        : Download data from REDCap (must have API tokens).
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


## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
