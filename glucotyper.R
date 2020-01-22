# glucotyper.r
# command line version of glucotype app

library(ggplot2)
library(lubridate)
library(xts)

source("classifyr.R")

sample_file <- "sample_cgm.tsv"
axisTitle = "Glucose (mg/dL)"
windowsF= "rawDexcomSeries+overlap_37+window_2.5+user_all"
TRAIN_WINDOWS = fread(windowsF)
PARAM_LIST = list(train_mean = 100, train_sd = 1, Y = c(1,2,3))


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
dygraph_cgm = renderDygraph({
  if (is.null(v$data)) return()
  df = v$data
  dygraph(df_to_xts(df), ylab=axisTitle) %>%
    dyOptions(axisLabelWidth=90, useDataTimezone = TRUE)
})



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
}


# this line will render a dygraph
# dygraph(df_to_xts(s_cgm_df), ylab=axisTitle)

glucotype_table(s_cgm_df)
