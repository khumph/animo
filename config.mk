SRC_DIR=R
WRITEUP_DIR=docs
METHODS_DIR=methods
TOKEN_DIR=tokens
RAW_DIR=data-raw
CLEAN_DIR=data-processed
RESULTS_DIR=results

RAND_SRC=$(SRC_DIR)/randomize-animo.R
RAND_EXE=Rscript $(RAND_SRC)
RAND_CSV=$(METHODS_DIR)/randomization-list.csv

RENDER_SRC=$(SRC_DIR)/render.R
RENDER_EXE=Rscript $(RENDER_SRC)

SAP_SRC=$(WRITEUP_DIR)/sap.Rmd
SAP_DOC= $(METHODS_DIR)/sap.docx

CONVERT_SRC=$(SRC_DIR)/convert-excel-csv.R

TOKEN_FILES=$(wildcard $(TOKEN_DIR)/*.token)
RAW_CSVS=$(RAW_DIR)/animo.csv $(RAW_DIR)/blood.csv $(RAW_DIR)/dxa.csv
CLEAN_CSVS=$(patsubst $(RAW_DIR)/%.csv, $(CLEAN_DIR)/%.csv, $(RAW_CSVS)) \
  $(CLEAN_DIR)/food.csv

JOIN_SRC=$(SRC_DIR)/join-csvs.R
JOIN_EXE=Rscript $(JOIN_SRC)
JOINED_CSV=$(CLEAN_DIR)/all.csv

FORMAT_SRC=$(SRC_DIR)/format-animo.R
FORMAT_EXE=Rscript $(FORMAT_SRC)
FORMATTED_DATA=$(CLEAN_DIR)/animo.Rdata

TABLES_SRC=$(SRC_DIR)/efficacy-tables.Rmd
TFUNCS_SRC=$(SRC_DIR)/table-functions.R
TABLES_DOC=$(RESULTS_DIR)/efficacy-tables.html

WILCOX_SRC=$(SRC_DIR)/wilcox-ltpa.R
WILCOX_LTPA=$(RESULTS_DIR)/wilcox-ltpa.Rdata

FEAS_SRC=$(SRC_DIR)/feasibility-tables.Rmd
FEAS_DOC=$(RESULTS_DIR)/feasibility-tables.html