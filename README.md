# Overview
This github repository contains source code for the following in-review
article:

Powell et al. -- Chemical Analyses of Uluburun Tin Ingots Show Confluence of
Anatolian and Central Asian Metal Sources in Late Bronze Age Mediterranean

In particular, it provides the source code to recreate the tsne analysis (
Figure 3) and the pairs plot (supplement). It contains one input file,
"Supplemental Data Table.xlsx", and two .R files "do_uluburun_tsne_analysis.R"
and "uluburun_functions.R". The following sections provide instructions for
running the code.
   
# Obtain the source code
Either download the source code from github or enter the following commands at
the terminal/command window to clone the directory and change directory into
the repository:

```bash
git clone https://github.com/MichaelHoltonPrice/uluburun_tsne
cd uluburun_tsne
```

# Install packages
In R (and if necessary), install needed packages:

```R
install.packages(c('foreach', 'testthat', 'readxl', 'doParallel', 'Rtsne'))
```

# Run the analysis
Ensure that the working directory is uluburun_tsne (e.g., by using the R
command setwd or, if using the command line, by using the cd command above),
then run the analysis script:

```R
source('do_uluburun_tsne_analysis.R')
```

This will generate two .pdf images, "uluburun_tsne.pdf" and
"uluburun_pairs_plot.pdf". Both are vectorized graphics that do not exhibit
pixelation or degradation when magnified.

# Convert to .svg
If desired, the .pdf images can be converted to .svg images. On an Ubuntu
flavor of Linux, this can be done with the following two commands in a terminal
window:

```bash
sudo apt-get install pdf2svg
pdg2svg uluburun_tsne.pdf  uluburun_tsne.svg
uluburun_pairs_plot.pdf uluburun_pairs_plot.svg
```
