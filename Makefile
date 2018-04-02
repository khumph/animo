SRC_DIR=R
RAND_SRC=randomize-animo.R
RAND_CSV=randomization-list.csv
SAP_SRC=sap.Rmd
SAP_DOCX=sap.docx
RESULTS_DIR=results
WRITEUP_DIR=docs

## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(RAND_CSV)

$(RAND_CSV) : $(SRC_DIR)/$(RAND_SRC)
	Rscript $< 9 50 $@ # second argument: seed, third: total # of participants

## sap          : Generate the SAP and sample size justification.
.PHONY : sap
sap : $(RESULTS_DIR)/$(SAP_DOCX)

$(RESULTS_DIR)/$(SAP_DOCX) : $(WRITEUP_DIR)/$(SAP_SRC)
	R -e 'rmarkdown::render("$<", output_format = "word_document", output_file = "$@", output_dir = "$(RESULTS_DIR)")'

## clean       : Remove auto-generated files.
.PHONY : clean
clean :
	rm -f $(RAND_CSV)
	rm -f $(RESULTS_DIR)/$(SAP_DOCX)

## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
