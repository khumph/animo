# ANIMO

This repository contains the code and statistically-related write-ups for the ANIMO randomized controlled trial pilot study, a gender- and culturally-sensitive weight loss intervention for hispanic males.

The main results of this trial are published in two papers:

## Protocol and recruitment methods (feasibility outcomes) paper

D.O. Garcia, L.A. Valdez, M.L. Bell, K. Humphrey, M. Hingle, M. McEwen, & S.P. Hooker (2018). A Gender- and Culturally-Sensitive Weight Loss Intervention for Hispanic Males: The ANIMO Randomized Controlled Trial Study Protocol and Recruitment Methods. Contemporary Clinical Trials Communications. [https://doi.org/10.1016/j.conctc.2018.01.010](https://doi.org/10.1016/j.conctc.2018.01.010). In press.

## Efficacy outcomes paper

D.O. Garcia, L.A. Valdez, B. Aceves, D. Campas, J. Loya, K. Humphrey, M.L. Bell, M. Hingle, M. McEwen, & S.P. Hooker (2018). A Gender- and Culturally-Sensitive Weight Loss Intervention for Hispanic Males: The ANIMO Randomized Controlled Trial Study Efficacy Outcomes. In progress.

## Reproducing the analyses

### Dependencies

The project was tested on macOS 10.13.4 High Sierra using the following:

- [R](https://www.r-project.org/) version 3.4.4
- The R packages [pacman](http://trinker.github.io/pacman_dev/), [tidyverse](https://www.tidyverse.org/), [lme4](https://github.com/lme4/lme4), [Gmisc](https://github.com/gforge/Gmisc), [htmlTable](https://github.com/gforge/htmlTable), [docopt](https://github.com/docopt/docopt.R), and [rmarkdown](https://rmarkdown.rstudio.com/)
- [GNU Make](https://www.gnu.org/software/make/) 3.81 - standard on macOS and Linux
- [GNU Bash](https://www.gnu.org/software/bash/) 3.2.57(1) - default shell in terminal on macOS and many Linux distributions

You can ensure you have the required R packages by running the following in an R console:

```r
# Install pacman, if needed
if (!suppressWarnings(require("pacman", quietly = TRUE))) {
   install.packages("pacman", repo = "https://cran.rstudio.com")
}

# Load docopt, install if not installed
pacman::p_load(docopt)
```

The magic of the `pacman` R package will then install any other required packages as they are needed.

### Obtaining the data

Unfortunately, our data are not publicly available. If you are a study collaborator with access to the REDCap project, you can use the next section to obtain the data stored in REDCap.


#### From REDCap (requires API tokens for each project)

To download the data from REDCap, you will need an API token from the REDCap projects "ANIMO", "Screening forms -  ANIMO", and "ANIMO - blood test data". The Makefile expects these tokens to be in a directory called "tokens", so create a directory in the main project directory (i.e., animo/), called "tokens". In this directory, create plain text files with the file extension ".token" which contain only a single line with each token. For example, I created three files called "animo.token", "screen.token", and "blood.token", and I copied and pasted the corresponding token in each. The stem of what you name the token files (e.g., "animo") will become the stem of your data files (e.g., "animo.csv").

### (Re)making the analyses

First, download the project files (e.g., by hitting the "Clone or download" button above).

Then navigate to the main directory of the project (called animo by default) in a terminal window. Typing `make help` when in the main project directory displays a short description of all of the options to `make`. For example, the previous two steps might look like:

```bash
cd ~/Downloads/animo
make help
```

To make the randomization list, for instance, type

```bash
make randomize
```

when in the `animo` directory.

The Makefile expects the raw data to be in a directory called data-raw (automatically created if you download the data from REDCap via Make).

Running `make all` (or simply `make`) will produce the following:

1. A directory called "data-processed" with cleaned data files
2. A directory called "results" with R files for the models, and the formatted results documents.
3. A directory called "methods" with the randomization list and formatted statistical analysis plan.
4. A directory called "cache" with cached results from the Rmarkdown files.
