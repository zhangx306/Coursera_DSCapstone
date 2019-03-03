## Coursera Data Science Capstone
## Part 2: Prediction using the n-gram models
## Similar to server.R, but to test the prediction without running shiny app

## Instruction
##-----------------------------------------------------------------
## run Coursera_DSCapstone_Part1_GetNGram.R first
## run this script with the following
##     setwd("") changed to the same as in Part1
##     ** par_sampleRate should set to the same one as in part1 **  
##     ** par_sentence is the text user provide for prediction **
##-----------------------------------------------------------------

rm(list = ls())
gc()

start_time <- Sys.time()

library(tm)

setwd("C:\\Users\\zhxing\\OneDrive\\Coursera\\Coursera_Capstone\\git")
source("./functions_v2.R")


# parameters
#############
par_sampleRate <- 0.07
par_sentence <- "i wish you couldd talk about"

# read files
dir_input <- paste0(getwd(), "/data/en_US_grams_sample", par_sampleRate*100)
badWords <-  readLines(paste0(getwd(), "/data/bad_words.txt"))
dictionary <- readRDS(paste0(dir_input, "/dictionary.rds"))
gram2 <- readRDS(paste0(dir_input, "/gram2_index.rds"))
gram3 <- readRDS(paste0(dir_input, "/gram3_index.rds"))
gram4 <- readRDS(paste0(dir_input, "/gram4_index.rds"))

# clean the sentence
####################
# remove punctuations
par_sentence <- removePunctuation(par_sentence)

# remove numbers
par_sentence <- removeNumbers(par_sentence)

# remove url
par_sentence <- gsub("http[[:alnum:][:punct:]]*", "", par_sentence)

# remove non ASCII words
par_sentence <- iconv(par_sentence, "latin1", "ASCII", sub="")

# to lowercase
par_sentence <- tolower(par_sentence)

# remove profanity
par_sentence <- removeWords(par_sentence, badWords)  

# strip white space
par_sentence <- stripWhitespace(par_sentence)


# prediction
######################
sentence_token <- unlist(strsplit(par_sentence, split = " "))

index_token <- dictionary[sentence_token]

# delete words that can't be found in the dictionary
index_token <- index_token[!is.na(index_token)]


n_word <- length(index_token)

if (n_word >= 3) {
    
    pred_word <- f_pred_4gram(index_token[(n_word - 2):n_word], 
                              dictionary, gram4)
    
    if(is.null(pred_word)) {
        
        index_token <- index_token[(n_word - 1):n_word]
        n_word <- 2
    }
    
}

if (n_word == 2) {
    
    pred_word <- f_pred_3gram(index_token, 
                              dictionary, gram3)
    
    if(is.null(pred_word)) {
        
        index_token <- index_token[n_word]
        n_word <- 1
    }
    
}

if (n_word == 1) {
    
    pred_word <- f_pred_2gram(index_token, 
                              dictionary, gram2)
    
}

print(pred_word)

end_time <- Sys.time()
print(end_time - start_time)