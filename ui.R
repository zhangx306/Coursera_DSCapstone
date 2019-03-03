## Coursera Data Science Capstone
## UI of shiny app

## Instruction
##--------------------------------------------------------------
## create a directory, put all the .R files in it
## paste the sub directory "data" into that directory
## run Coursera_DSCapstone_Part1_GetNGram.R according to 
##            the instruction in the file
## before running the app, make the following change in server.R
##          ** set par_sampleRate to the same one in **
##             Coursera_DSCapstone_Part1_GetNGram.R 
##
##--------------------------------------------------------------

# run diagnostics - rsconnect::showLogs()

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Predicting Next Word with N-gram Model"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
       h3("Introduction"),
       p("This is app is used to predict the next word of the given text."),
       hr(),
       h3("Instruction"),
       p("Enter the text in the box below and click Submit"),
       h4(""),
       hr(),
       textInput("i_text", label = "Enter a text:", placeholder = "ex: This shiny app is the best I've ever"),
       submitButton("Submit")
    ),
    
    # MainPanel
    mainPanel(
        tabsetPanel(type = "pills", 
                    tabPanel("Prediction", h3("Next word is "),textOutput("o_nextWord")), 
                    tabPanel("Algorithm", h3("Algorithm used is "), textOutput("o_algorithm")),
                    tabPanel("Details", h3("Details of the algorithmm"),
                             h4("- Record the 4-, 3-, 2-, 1-grams and their counts using the randomly sampled 7% of texts."),
                             h4("- Use the n-gram model to predict the next word."),
                             p("   -- If available, take the last three words from the text, 
                                find the 4-gram's with the first three words matched, 
                                and use the last word of most frequent 4-gram for prediction."),
                             p("   -- If no 4-gram matched or the count of available word is less than 3, take the last two words from the text, 
                                find the 3-gram's with the first two words matched, 
                                and use the last word of most frequent 3-gram for prediction."),
                             p("   -- If no 3-gram matched or the count of available word is less than 2, take the last words from the text, 
                                find the 2-gram's with the first word matched, 
                                and use the last word of most frequent 2-gram for prediction."),
                             p("   -- Grams are indexed (using a dictionary built from 1-gram's) to save disk space and speed up computation."),
                             hr(),
                             tags$a("Source Code", href = "https://github.com/zhangx306/Coursera_DSCapstone", target = "_blank"))

                    )
        
    )
  )
))
