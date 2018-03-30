SRC_DIR=R
RAND_SRC=randomize-animo.R
RAND_CSV=randomization-list.csv

## randomize   : Generate randomization list.
.PHONY : randomize
randomize : $(RAND_CSV)

$(RAND_CSV) : $(SRC_DIR)/$(RAND_SRC)
	Rscript $< 9 50 $@

## help        : Show arguments and what they do.
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
