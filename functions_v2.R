## functions for indexing grams, predicition using 4-, 3-, 2- or 1-gram models
## version 2

#################################################################################
f_WordToIndex3 <- function(gram_count, n_gram = 2, dictionary, split_by = "_") {
    
    gram <- sapply(names(gram_count), function(x) strsplit(x, split = split_by))
    
    index <- matrix(0, length(gram_count), n_gram)
    for (i in 1:n_gram) {
        index[ , i] <- dictionary[sapply(gram, function(x) x[[i]] )] 
    }
    
    colnames(index) <- paste0("w", 1:n_gram)
    
    index <- cbind(index, count = unname(gram_count))
    
    index <- index[order(index[ , n_gram + 1], decreasing = T), ]
    
    return(index)
    
}

#################################################################################
f_pred_4gram <- function(index_token, dictionary, gram4) {
    
    
    gram4_match <- matrix( gram4[(gram4[ , 1] == index_token[1]) & 
                                     (gram4[ , 2] == index_token[2]) & 
                                     (gram4[ , 3] == index_token[3]), ], ncol = 5 )
    
    if(nrow(gram4_match) > 0) {
        pred_word <- names(dictionary[gram4_match[1, 4]])
        print("prediction based on 4-gram model")
        return(pred_word)
    } else {
        return(NULL)
    }
    
}

#################################################################################
f_pred_3gram <- function(index_token, dictionary, gram3) {
    
    gram3_match <- matrix( gram3[(gram3[ , 1] == index_token[1]) & 
                                     (gram3[ , 2] == index_token[2]) , ], ncol = 4 )
    
    if(nrow(gram3_match) > 0) {
        pred_word <- names(dictionary[gram3_match[1,3]])
        print("prediction based on 3-gram model")
        return(pred_word)
    } else {
        return(NULL)
    }
}

#################################################################################
f_pred_2gram <- function(index_token, dictionary, gram2) {
    
    gram2_match <- matrix(gram2[(gram2[ , 1] == index_token[1]) , ], ncol = 3)
    
    if(nrow(gram2_match) > 0) {
        pred_word <- names(dictionary[gram2_match[1, 2]])
        print("prediction based on 2-gram model")
        return(pred_word)
    } else {
        print("prediction based on 1-gram model")
        return(names(dictionary[1]))
    }
}