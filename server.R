## Coursera Data Science Capstone
## Server of shiny app

## Instruction
##-----------------------------------------------------------
## create a directory, put all the .R files in it
## paste the sub directory "data" into that directory
## run Coursera_DSCapstone_Part1_GetNGram.R according to 
##            the instruction in the file
## before running the app
##          ** set par_sampleRate to the same one in **
##             Coursera_DSCapstone_Part1_GetNGram.R 
##
##-----------------------------------------------------------

library(shiny)
library(tm)
source(paste0(getwd(), "/functions_v2.R"))


shinyServer(function(input, output) {
    
    # parameters
    ##########################
    par_sampleRate <- 0.07
    
    # read files
    dir_input <- paste0(getwd(), "/data/en_US_grams_sample", par_sampleRate*100)
    badWords <-  readLines(paste0(getwd(), "/data/bad_words.txt"))
    dictionary <- readRDS(paste0(dir_input, "/dictionary.rds"))
    gram2 <- readRDS(paste0(dir_input, "/gram2_index.rds"))
    gram3 <- readRDS(paste0(dir_input, "/gram3_index.rds"))
    gram4 <- readRDS(paste0(dir_input, "/gram4_index.rds"))
    
    f_nextWord <- reactive({
        
        text_to_pred <- input$i_text
        
        # clean the text
        #################################
        if(text_to_pred == "") {
            return(list("",""))
        }
        
        # remove punctuations
        text_to_pred <- removePunctuation(text_to_pred)
        
        # remove numbers
        text_to_pred <- removeNumbers(text_to_pred)
        
        # remove url
        text_to_pred <- gsub("http[[:alnum:][:punct:]]*", "", text_to_pred)
        
        # remove non ASCII words
        text_to_pred <- iconv(text_to_pred, "latin1", "ASCII", sub="")
        
        # to lowercase
        text_to_pred <- tolower(text_to_pred)
        
        # remove profanity
        text_to_pred <- removeWords(text_to_pred, badWords)  
        
        # strip white space
        text_to_pred <- stripWhitespace(text_to_pred)
        
        
        # predict next word
        ###################################
        sentence_token <- unlist(strsplit(text_to_pred, split = " "))
        
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
            } else {
                algr <- "4-gram model"
            }
            
        }
        
        if (n_word == 2) {
            
            pred_word <- f_pred_3gram(index_token, 
                                      dictionary, gram3)
            
            if(is.null(pred_word)) {
                
                index_token <- index_token[n_word]
                n_word <- 1
            } else {
                algr <- "3-gram model"
            }
            
        }
        
        if (n_word == 1) {
            
            pred_word <- f_pred_2gram(index_token, 
                                      dictionary, gram2)
            algr <- "2-gram model"
            
        }
        
        
        if (n_word == 0) {
            
            pred_word <- "No valid texts/words provided, try another text."
            
            algr <- "No algorithm applied since no valid text input"
            
        }
        
        return(list(pred_word, algr))
        
    })
   
    output$o_nextWord <- renderText(f_nextWord()[[1]])
    output$o_algorithm <- renderText(f_nextWord()[[2]])

})
