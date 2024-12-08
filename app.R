library(shiny)
library(ggplot2)

# Define UI for the app
ui <- fluidPage(
  titlePanel("Option Strategy Payout Diagrams"),
  sidebarLayout(
    sidebarPanel(
      selectInput("strategy", "Select Option Strategy:",
                  choices = c("Long Call", "Short Call", "Long Put", "Short Put", 
                              "Vertical Spread", "Straddle", "Strangle", "Iron Condor")),
      numericInput("strike1", "Strike Price 1:", value = 100, min = 0),
      numericInput("strike2", "Strike Price 2 (if applicable):", value = 110, min = 0),
      numericInput("premium1", "Premium 1:", value = 5, min = 0),
      numericInput("premium2", "Premium 2 (if applicable):", value = 3, min = 0),
      sliderInput("price_range", "Underlying Price Range:",
                  min = 50, max = 150, value = c(80, 120), step = 1),
      actionButton("plot_btn", "Generate Payout Diagram")
    ),
    mainPanel(
      plotOutput("payout_plot", hover = hoverOpts("plot_hover")),
      verbatimTextOutput("hover_info")
    )
  )
)

# Define server logic
server <- function(input, output) {
  payout_data <- eventReactive(input$plot_btn, {
    # Generate theoretical price range
    prices <- seq(input$price_range[1], input$price_range[2], by = 1)
    strategy <- input$strategy
    strike1 <- input$strike1
    strike2 <- input$strike2
    premium1 <- input$premium1
    premium2 <- input$premium2
    
    # Calculate profit/loss based on strategy
    pnl <- switch(strategy,
                  "Long Call" = pmax(0, prices - strike1) - premium1,
                  "Short Call" = -(pmax(0, prices - strike1) - premium1),
                  "Long Put" = pmax(0, strike1 - prices) - premium1,
                  "Short Put" = -(pmax(0, strike1 - prices) - premium1),
                  "Vertical Spread" = (pmax(0, prices - strike1) - pmax(0, prices - strike2)) - (premium1 - premium2),
                  "Straddle" = pmax(0, prices - strike1) + pmax(0, strike1 - prices) - 2 * premium1,
                  "Strangle" = pmax(0, prices - strike1) + pmax(0, strike2 - prices) - (premium1 + premium2),
                  "Iron Condor" = (pmax(0, prices - strike1) - pmax(0, prices - strike2)) -
                    (pmax(0, prices - (strike2 + 10)) - pmax(0, prices - (strike1 - 10))) - 
                    (premium1 - premium2)
    )
    data.frame(prices, pnl)
  })
  
  # Render plot
  output$payout_plot <- renderPlot({
    req(payout_data())
    ggplot(payout_data(), aes(x = prices, y = pnl)) +
      geom_line(color = "blue") +
      labs(title = paste("Payout Diagram:", input$strategy),
           x = "Underlying Price",
           y = "Profit/Loss") +
      theme_minimal()
  })
  
  # Display hover information
  output$hover_info <- renderText({
    hover <- input$plot_hover
    if (!is.null(hover)) {
      paste("Price:", round(hover$x, 2), 
            "Profit/Loss:", round(hover$y, 2))
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)
