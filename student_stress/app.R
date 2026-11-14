# Student Stress — lightweight Shiny companion to the static HTML dashboard.
# Prefer opening index.html for a no-server demo; use this for richer filtering.

library(shiny)
library(dplyr)
library(ggplot2)
library(bslib)

stress <- read.csv("student_stress.csv", check.names = FALSE, stringsAsFactors = FALSE)
names(stress) <- trimws(names(stress))

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  title = "Student Stress Dashboard",
  h2("Student Stress"),
  p("Interactive exploration of survey mental-stress levels. Static HTML twin: index.html."),
  layout_columns(
    selectInput("gender", "Gender", choices = c("All", sort(unique(stress$Gender))), selected = "All"),
    selectInput("coping", "Coping mechanism", choices = c("All", sort(unique(stress$`Stress Coping Mechanisms`))), selected = "All")
  ),
  layout_columns(
    card(card_header("Sample size"), textOutput("n")),
    card(card_header("Mean mental stress"), textOutput("mean_stress")),
    card(card_header("Median mental stress"), textOutput("median_stress"))
  ),
  card(
    card_header("Mental stress distribution"),
    plotOutput("hist", height = 320)
  ),
  card(
    card_header("Mean stress by coping (filtered)"),
    plotOutput("coping_plot", height = 360)
  )
)

server <- function(input, output, session) {
  filtered <- reactive({
    df <- stress
    if (input$gender != "All") {
      df <- df %>% filter(Gender == input$gender)
    }
    if (input$coping != "All") {
      df <- df %>% filter(`Stress Coping Mechanisms` == input$coping)
    }
    df
  })

  output$n <- renderText(nrow(filtered()))
  output$mean_stress <- renderText(sprintf("%.2f", mean(filtered()$`Mental Stress Level`, na.rm = TRUE)))
  output$median_stress <- renderText(sprintf("%.2f", median(filtered()$`Mental Stress Level`, na.rm = TRUE)))

  output$hist <- renderPlot({
    ggplot(filtered(), aes(`Mental Stress Level`)) +
      geom_histogram(binwidth = 1, fill = "#9a3412", color = "white") +
      theme_minimal(base_size = 13) +
      labs(x = "Mental stress level", y = "Count")
  })

  output$coping_plot <- renderPlot({
    filtered() %>%
      group_by(`Stress Coping Mechanisms`) %>%
      summarise(mean_stress = mean(`Mental Stress Level`, na.rm = TRUE), .groups = "drop") %>%
      ggplot(aes(reorder(`Stress Coping Mechanisms`, mean_stress), mean_stress)) +
      geom_col(fill = "#9a3412") +
      coord_flip() +
      theme_minimal(base_size = 13) +
      labs(x = NULL, y = "Mean mental stress")
  })
}

shinyApp(ui, server)
