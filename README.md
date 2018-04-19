This repository contains the code and statistically-related write-ups for the ANIMO randomized controlled trial pilot study, a gender- and culturally-sensitive weight loss intervention for hispanic males.

The main results of this trial are published in two papers:

#### Protocol and recruitment methods (feasibility outcomes) paper
D.O. Garcia, L.A. Valdez, M.L. Bell, K. Humphrey, M. Hingle, M. McEwen, & S.P. Hooker (2018). A Gender- and Culturally-Sensitive Weight Loss Intervention for Hispanic Males: The ANIMO Randomized Controlled Trial Study Protocol and Recruitment Methods. Contemporary Clinical Trials Communications. https://doi.org/10.1016/j.conctc.2018.01.010. In press.

#### Efficacy outcomes paper
D.O. Garcia, L.A. Valdez, B. Aceves, D. Campas, J. Loya, K. Humphrey, M.L. Bell, M. Hingle, M. McEwen, & S.P. Hooker (2018). A Gender- and Culturally-Sensitive Weight Loss Intervention for Hispanic Males: The ANIMO Randomized Controlled Trial Study Efficacy Outcomes. In progress.

## Reproducing the analyses
### Dependencies
The project was tested on macOS 10.13.4 High Sierra using the following:
- [R](https://www.r-project.org/) version 3.4.4
- The R packages [pacman](http://trinker.github.io/pacman_dev/), [tidyverse](https://www.tidyverse.org/), [lme4](https://github.com/lme4/lme4), [Gmisc](https://github.com/gforge/Gmisc), [htmlTable](https://github.com/gforge/htmlTable), and [rmarkdown](https://rmarkdown.rstudio.com/) (all other required packages should be depenencies of those listed–and thus installed automatically)
- [GNU Make](https://www.gnu.org/software/make/) 3.81 - standard on macOS and Linux
- [GNU Bash](https://www.gnu.org/software/bash/) 3.2.57(1) - default shell in terminal on macOS and many linux distributions

You can ensure you have the required R packages by running the following in an R console:
```r
if (!suppressWarnings(require("pacman", quietly = TRUE))) {
   install.packages("pacman", repo = "https://cran.rstudio.com")
}
```
The magic of the pacman R package will then install any required packages as they are needed.

### Obtaining the data
#### From REDCap (requires API tokens for each project)
To download the data from REDCap, you will need an API token from the REDCap projects "ANIMO", "Screening forms -  ANIMO", and "ANIMO - blood test data". The Makefile expects these tokens to be in a directory called "tokens", so create a directory in the main project directory (i.e., animo/), called "tokens". In this directory, create plain text files with the file extension ".token" which contain only a single line with each token. For example, I created three files called "animo.token", "screen.token", and "blood.token", and I copied and pasted the corresponding token in each. The stem of what you name the token files (e.g., "animo") will become the stem of your data files (e.g., "animo.csv").

### (Re)making the analyses
In a terminal window/shell, navigating to the directory where you downloaded the files (by hitting the "Clone or download" button above) and typing `make help` displays a short description of all of the options to `make`. For example, this might look like:
```bash
cd ~/Downloads/animo
make help
```

To make the randomization list (for instance) type
```bash
make randomize
```
when in the animo directory.

The Makefile expects the raw data to be in a directory called data-raw (automatically created if you download the data from REDCap via the Make).

Running `make all` (or simply `make`) will produce the following:

1. A directory called "data-processed" with cleaned data files
2. A directory called "results" with R files for the models, and the formatted results documents.
3. A directory called "methods" with the radnomization list and formatted statstical analysis plan.
