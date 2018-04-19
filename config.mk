SRC_DIR=R
WRITEUP_DIR=docs
METHODS_DIR=methods
TOKEN_DIR=tokens
RAW_DIR=data-raw
CLEAN_DIR=data-processed
RESULTS_DIR=results
CACHE_DIR=cache

RAND_SRC=$(SRC_DIR)/randomize-animo.R
RAND_CSV=$(METHODS_DIR)/randomization-list.csv

RENDER_SRC=$(SRC_DIR)/render.R

SAP_SRC=$(WRITEUP_DIR)/sap.Rmd
SAP_DOC= $(METHODS_DIR)/sap.docx

CONVERT_SRC=$(SRC_DIR)/convert-excel-csv.R

PULL_SRC=pull-from-REDCap.sh
PULL_EXE=bash $(PULL_SRC)
TOKEN_FILES=$(wildcard $(TOKEN_DIR)/*.token)
RAW_CSVS=$(RAW_DIR)/animo.csv $(RAW_DIR)/blood.csv $(RAW_DIR)/dxa.csv
CLEAN_RDSS=$(patsubst $(RAW_DIR)/%.csv, $(CLEAN_DIR)/%.rds, $(RAW_CSVS)) \
  $(CLEAN_DIR)/food.rds
SCREEN_CSV=$(RAW_DIR)/screen.csv

JOIN_SRC=$(SRC_DIR)/join-data.R
FULL_DATA=$(CLEAN_DIR)/animo-full.rds

DESCR_SRC=$(WRITEUP_DIR)/baseline-table.Rmd
DESCR_DOC=$(RESULTS_DIR)/baseline-table.html

EFF_SRC=$(WRITEUP_DIR)/efficacy-tables.Rmd
EFF_FUNCS_SRC=$(SRC_DIR)/table-functions.R
EFF_DOC=$(RESULTS_DIR)/efficacy-tables.html

WILCOX_SRC=$(SRC_DIR)/wilcox-ltpa.R
WILCOX_LTPA=$(RESULTS_DIR)/wilcox-ltpa.Rdata

FEAS_SRC=$(WRITEUP_DIR)/feasibility-tables.Rmd
FEAS_DOC=$(RESULTS_DIR)/feasibility-tables.html

EFF_MODEL_SRC=$(SRC_DIR)/efficacy-models.R
EFF_RAW_RDS=$(RESULTS_DIR)/efficacy-tables-data-unformatted.rds

EFF_FORMAT_SRC=$(SRC_DIR)/efficacy-format-results.R
EFF_RDS=$(RESULTS_DIR)/efficacy-tables-data.rds
