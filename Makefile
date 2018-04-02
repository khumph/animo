include api-token.mk

SRC_DIR=R
RAND_SRC=randomize-animo.R
RAND_CSV=randomization-list.csv
SAP_SRC=sap.Rmd
SAP_DOCX=sap.docx
RESULTS_DIR=results
WRITEUP_DIR=docs
RAW_DIR=raw-data
ANIMO_CSV=animo.csv

## sap          : Generate the SAP (including sample size justification).
.PHONY : sap
sap : $(RESULTS_DIR)/$(SAP_DOCX)

$(RESULTS_DIR)/$(SAP_DOCX) : $(WRITEUP_DIR)/$(SAP_SRC)
	R -e 'rmarkdown::render("$<", output_format = "word_document", output_file = "$@", output_dir = "$(RESULTS_DIR)")'


## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(RAND_CSV)

$(RAND_CSV) : $(SRC_DIR)/$(RAND_SRC)
	Rscript $< 9 50 $@ # second argument: seed, third: total # of participants


## clean       : Remove auto-generated files.
.PHONY : clean
clean :
	rm -f $(RAND_CSV)
	rm -f $(RESULTS_DIR)/$(SAP_DOCX)


## pull        : Download data from REDCap (must have API token).
.PHONY : pull
pull : $(RAW_DIR)/$(ANIMO_CSV)

$(RAW_DIR)/$(ANIMO_CSV) : api-token.mk
	@mkdir -p $(RAW_DIR)
	curl -X POST https://redcap.uahs.arizona.edu/api/ \
	  -d token=$(API_TOKEN) \
	  -d content=record \
	  -d format=csv \
	  -d rawOrLabel=label \
	  -d rawOrLabelHeaders=raw \
	  > $@


## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
