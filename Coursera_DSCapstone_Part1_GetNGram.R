## Coursera Data Science Capstone
## Part 1: Get N-Grams from the Data

## Instruction
##-----------------------------------------------------------
## create a directory, put all the .R files in it
## paste the sub directory "data" into that directory
## run this script one time with the following
##     setwd("") changed to the dir of your choice
##     ** par_n_gram <- 1 **  
##     ** par_createSample <- T **
## run this script additional three times with the following
##     ** par_createSample <- F **
##     ** par_n_gram set to 2, 3, 4 sequentially **
##-----------------------------------------------------------


rm(list = setdiff(ls(), "dictionary"))
gc()


setwd("C:\\Users\\zhxing\\OneDrive\\Coursera\\Coursera_Capstone\\git")
source("./functions_v2.R")

list_library <- c("dplyr", "tm", "quanteda")

index_to_install <- !(list_library %in% installed.packages())
if (any(index_to_install)) {
  install.packages(list_library[index_to_install])
}

library(dplyr)
library(tm)
library(quanteda)


# parameters
#############
par_n_gram <- 1         # 1, 2, 3, 4
par_sampleRate <- 0.07
par_createSample <- F   # change to T if when want to draw a new sample & par_n_gram <- 1


dir_file <- paste0(getwd(), "/data/en_US")
list_files <- list.files(dir_file)
path_files <- paste0(dir_file, "/", list_files)

dir_sample <- paste0(getwd(), "/data/en_US_sample", par_sampleRate*100)

if (!dir.exists(dir_sample)) {dir.create(dir_sample)}


start_time <- Sys.time()

assign( paste0("gram_", par_n_gram), character() )

set.seed(12345)

# create sample
##################################################################
if (par_createSample) {
  
  for (i in 1: length(list_files)) {
    
    conn_read <- file(path_files[i], open = "rb")
    txt_full <- readLines(conn_read, skipNul = T, encoding = "UTF-8")
    close.connection(conn_read)
    
    txt_sample <- sample(txt_full, ceiling(par_sampleRate*length(txt_full)) )
    
    conn_write <- file(paste0(dir_sample, "/", list_files[i]))
    writeLines(txt_sample, con = conn_write)
    close.connection(conn_write)
    
  }
  
  rm(list = c("txt_full", "txt_sample"))
}


# cleaning with corpus
##################################################################
corp_en_sample <- VCorpus(DirSource(dir_sample, encoding = "UTF-8"), 
                          readerControl = list(language = "en_US"))

# remove punctuations
corp_en_sample <- tm_map(corp_en_sample, removePunctuation)

# remove numbers
corp_en_sample <- tm_map(corp_en_sample, removeNumbers)

# remove url
f_removeURL <- function(x) gsub("http[[:alnum:][:punct:]]*","",x)
corp_en_sample <- tm_map(corp_en_sample, content_transformer(f_removeURL) )

# remove non ASCII words
f_toASCII <- function(x) {iconv(x, "latin1", "ASCII", sub="")}
corp_en_sample <- tm_map(corp_en_sample, content_transformer(f_toASCII))

# to lowercase
corp_en_sample <- tm_map(corp_en_sample, content_transformer(tolower))

# remove profanity
corp_en_sample <- tm_map(corp_en_sample, removeWords, readLines("./data/bad_words.txt"))  

# strip white space
corp_en_sample <- tm_map(corp_en_sample, stripWhitespace)


# combine corpus to text, compute counts, indexing
##################################################################
txt_all <- character()
for (i in 1: length(list_files)) {
  txt_all <- c(txt_all, corp_en_sample[[i]]$content)
}

assign(paste0("gram", par_n_gram), dfm(txt_all, ngrams = par_n_gram))
assign(paste0("gram", par_n_gram, "_count"), colSums(get(paste0("gram", par_n_gram))))
if(par_n_gram == 1) {
  gram1_count <- sort(gram1_count, decreasing = T)
  dictionary <- 1:length(gram1_count)
  names(dictionary) <- names(gram1_count)
}

assign(paste0("gram", par_n_gram, "_index"), 
       f_WordToIndex3(get(paste0("gram", par_n_gram, "_count")), par_n_gram, dictionary))


# save dictionary and indexed 2,3,4-gram counts
##################################################################

dir_output <- paste0(getwd(), "./data/en_US_grams_sample", par_sampleRate*100)
if (!dir.exists(dir_output)) {dir.create(dir_output)}

if(par_n_gram != 1) {
  path_output <- paste0(dir_output, './', "gram", par_n_gram, "_index.rds")
  
  a <- get(paste0("gram", par_n_gram, "_index"))
  
  saveRDS(a, file = path_output)
  
} else {
  path_output <- paste0(dir_output, "./dictionary.rds")
  
  saveRDS(dictionary, file = path_output)
}


cat("Congrats! You've reached the end of the script!")