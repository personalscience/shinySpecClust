#!/usr/bin/env Rscript
# glucotyper.r
# command line version of glucotype app

suppressPackageStartupMessages(library("optparse"))



suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(tidyverse))


suppressPackageStartupMessages(library(xts))

# Load classifier functions -----
source("classifyr.R")

## Setup -----
sample_file <- "sample_cgm.tsv"
axisTitle = "Glucose (mg/dL)"
windowsF= "rawDexcomSeries+overlap_37+window_2.5+user_all"

TRAIN_WINDOWS = readr::read_delim(windowsF, delim = "\t")

# TRAIN_WINDOWS = fread(windowsF)
PARAM_LIST = list(train_mean = 100, train_sd = 1, Y = c(1,2,3))

load("train.overlap_37+window_2.5.params.Rdata")
PARAM_LIST = param_list
rm(param_list)

# Functions -----
read_cgmF = function(f) {
  df = tryCatch( {
    read.table(f, sep='\t', h=T, quote="")},
    error=function(e)
      read.table(f, sep='\t',
                 fileEncoding="UTF-16LE", h=T, quote="")
  )
  df[[1]] = ymd_hms(df[[1]])
  return (df)
}

# Other functions for data formatting
df_to_xts = function(df) {
  ts = xts(df[,-1], order.by=ymd_hms(df[,1]))
  return(ts)
}


s_cgm_df <- read_cgmF(sample_file)

# dygraph of raw cgm values
# generates this in Javascript (with the dygraph library)
# dygraph_cgm = renderDygraph({
#   if (is.null(v$data)) return()
#   df = v$data
#   dygraph(df_to_xts(df), ylab=axisTitle) %>%
#     dyOptions(axisLabelWidth=90, useDataTimezone = TRUE)
# })



glucotype_table <- function (cgm, train_windows = TRAIN_WINDOWS, param_list = PARAM_LIST){
  cachedF = "glucotypes.df.tsv"
  if (!file.exists(cachedF)) {
    #print(head(preprocess_cgm(cgm)));
    res = classify_glucotype(cgm, train_windows, param_list, 0.25)
    train = res$train
    test = res$test
    df = reshape_test_windows(test, train)
    glucotypes = define_glucotypes(train)
    DT = data.table(test$cgm_w_windows)[windowPos==1,] %>%
      .[,label:=glucotypes[test$test_labels[windowId]]] %>%
      .[,c(4,6)]
    #			Have to think of a better way to cache dataframe
    #			write.zoo(df, file = cachedF, quote=F, sep='\t')
  } else {
    df = fread(cachedF)
    df = as.xts.data.table(df[,Index:=ymd_hms(Index)])
  }
  df
}


# this line will render a dygraph
# dygraph(df_to_xts(s_cgm_df), ylab=axisTitle)

#gt <- glucotype_table(s_cgm_df)
# gt %>% fortify.zoo()

# specify our desired options in a list
# by default OptionParser will add an help option equivalent to
# make_option(c("-h", "--help"), action="store_true", default=FALSE,
#               help="Show this help message and exit")
option_list <- list(
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Print extra output [default]"),
  make_option(c("-q", "--quietly"), action="store_false",
              dest="verbose", help="Print little output"),
  make_option(c("-c", "--count"), type="integer", default=5,
              help="Number of random normals to generate [default %default]",
              metavar="number"),
  make_option(c("-f", "--file"), help="Glucose value file to be parsed",
              dest="file",
              default=sample_file),
  make_option("--generator", default="rnorm",
              help = "Function to generate random deviates [default \"%default\"]"),
  make_option("--mean", default=0,
              help="Mean if generator == \"rnorm\" [default %default]"),
  make_option("--sd", default=1, metavar="standard deviation",
              help="Standard deviation if generator == \"rnorm\" [default %default]")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list=option_list))

#message("opt=",opt[["file"]],"\n")

# print some progress messages to stderr if "quietly" wasn't requested
# if ( opt$verbose ) {
#   write("writing some verbose output to standard error...\n", stderr())
# }

if( opt$file != ""){

  message("output the file: ",opt$file)
  glucotype_table(read_cgmF(opt$file)) %>% fortify.zoo()
}


#gt <- glucotype_table(s_cgm_df)
# gt %>% fortify.zoo()

# do some operations based on user input
# if( opt$generator == "rnorm") {
#   cat(paste(rnorm(opt$count, mean=opt$mean, sd=opt$sd), collapse="\n"))
# } else {
#   cat(paste(do.call(opt$generator, list(opt$count)), collapse="\n"))
# }
cat("\n")

