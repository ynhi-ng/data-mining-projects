
# Data Journalism Dashboard — media & LLM theme exploration


# LOAD PACKAGES --
required_packages = c("shiny", "plotly", "dplyr", "tidyr", "DT",
                      "lubridate", "htmltools", "bslib", "scales")
missing_packages = required_packages[
  !(required_packages %in% installed.packages()[, "Package"])]
if (length(missing_packages) > 0) {
  message("Installing: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, dependencies = TRUE)
}
invisible(lapply(required_packages, library, character.only = TRUE))


# 1. DATA --
vol = read.csv("01_volume_monthly.csv",stringsAsFactors = FALSE)
growth = read.csv("02_growth_indexed.csv",stringsAsFactors = FALSE)
loess_df = read.csv("03_smooth_theme_share.csv",stringsAsFactors = FALSE)
llm = read.csv("04_llm_milestones.csv", stringsAsFactors = FALSE)
topic_ct = read.csv("05_topic_counts.csv",stringsAsFactors = FALSE)
topic_m = read.csv("06_topic_monthly.csv",stringsAsFactors = FALSE)
butter  = read.csv("07_butterfly.csv",stringsAsFactors = FALSE)
jac_m = read.csv("08a_jaccard_monthly.csv", stringsAsFactors = FALSE)
jac_a = read.csv("08b_jaccard_annual.csv",stringsAsFactors = FALSE)
sunburst = read.csv("09_sunburst.csv",stringsAsFactors = FALSE)
corr_m  = read.csv("10_rolling_pearson.csv", stringsAsFactors = FALSE)
corr_a  = read.csv("11_pearson_annual.csv",stringsAsFactors = FALSE)
scatter_p = read.csv("12_scatter_pearson.csv",stringsAsFactors = FALSE)
event_rsp = read.csv("13_event_response.csv",stringsAsFactors = FALSE)  
print("Data loaded successfully")

llm$date = as.Date(llm$date)

sunburst$parents = ifelse(is.na(sunburst$parents), "", sunburst$parents)


# 2. CONFIG --

# Colour encode
GROUP_COLOURS = c(
  public = "#C0397A",   
  news = "#326891", 
  research = "#4A3F8F")

MEAN_COL = "#B08A2E"   
MILESTONE_COL = "#B5491B" 

# Topic 
TOPIC_LABELS = c(
  LLM_foundations = "LLM foundations",
  GenAI_tools_products = "GenAI tools & products",
  Safety_alignment  = "Safety & alignment",
  Multimodal_generation = "Multimodal generation",
  GenAI_applications = "GenAI applications",
  Agents_reasoning = "Agents & reasoning",
  Deep_learning_methods   = "Deep learning methods",
  Computer_vision  = "Computer vision",
  NLP_speech   = "NLP & speech",
  AI_ethics_policy   = "AI ethics & policy",
  AI_industry_economy  = "AI industry & economy",
  AI_science_applications = "AI science applications"
)
# Date 
DATE_MIN = as.Date("2022-01-01")
DATE_MAX = as.Date("2025-12-01")

KEY_MILESTONE_NAMES = c("ChatGPT", "GPT-4", "Llama 2","Gemini 1.5 Pro", "Claude 3.5 Sonnet",
                        "DeepSeek R1", "GPT-5")

ym_to_date = function(ym) as.Date(paste0(ym, "-01"))

# Add milestone helper function 
add_milestone_vlines = function(p, ms_df) {
  if (nrow(ms_df) == 0) return(p)
  # draw a vertical line 
  shapes_list = lapply(seq_len(nrow(ms_df)), function(i) {
    list(type = "line",
         x0 = ms_df$date[i], x1 = ms_df$date[i],
         y0 = 0, y1 = 1, yref = "paper", xref = "x",
         line = list(color = MILESTONE_COL, width = 0.8, dash = "dot"),
         opacity = 0.6)
  })
  # add text labels
  ann_list = lapply(seq_len(nrow(ms_df)), function(i) {
    list(x = ms_df$date[i], y = 1.02, yref = "paper", xref = "x",
         text = ms_df$model_name[i], showarrow = FALSE,
         font = list(size = 8, color = "#993C1D"),
         textangle = 0, xanchor = "left")
  })
  # keep the current layout 
  cur  = p$x$layoutAttrs
  ex_s = if (!is.null(cur) && !is.null(cur[[1]]$shapes)) cur[[1]]$shapes  else list()
  ex_a = if (!is.null(cur) && !is.null(cur[[1]]$annotations)) cur[[1]]$annotations else list()
  p %>% layout(shapes = c(ex_s, shapes_list), annotations = c(ex_a, ann_list))
}


# 3. UI --

ui = fluidPage(
  theme = bs_theme(
    bootswatch   = "journal",
    bg  = "#FAF8F4",
    fg  = "#1A1A1A",
    primary  = "#326891",
    secondary  = "#666666",
    base_font = font_google("Source Serif 4"),
    heading_font = font_google("Source Serif 4"),
    code_font = font_google("Source Code Pro")
  ),
  
  tags$head(tags$style(HTML('
    body { background-color:#FAF8F4; font-size:14px; color:#1A1A1A;
           font-family:"Source Serif 4",Georgia,serif; min-width:1100px}
    .story-intro  { background:#FFF; border-top:3px solid #1A1A1A;
                    border-bottom:1px solid #D9D5CC;
                    padding:20px 24px 16px; margin-bottom:16px; }
    .story-tag { font-size:11px; font-weight:700; letter-spacing:.1em;
                    color:#666; text-transform:uppercase; margin-bottom:6px; }
    .story-title  { font-size:22px; font-weight:700; color:#1A1A1A;
                    line-height:1.25; margin-bottom:8px;
                    font-family:"Source Serif 4",Georgia,serif; }
    .story-sub { font-size:13px; color:#444; line-height:1.7; max-width:800px; }
    .pill-row { display:flex; gap:8px; margin-top:10px; flex-wrap:wrap; }
    .pill { font-size:11px; padding:4px 10px; border-radius:2px;
                    background:#F2EFE9; color:#444; border:1px solid #D9D5CC;
                    display:flex; align-items:center; gap:6px; }
    .scroll-section-header { margin-top:36px; margin-bottom:16px;
                              font-size:13px; font-weight:700; color:#1A1A1A;
                              letter-spacing:.08em; text-transform:uppercase;
                              border-bottom:2px solid #1A1A1A; padding-bottom:6px; }
    .section-card  { background:#FFF; border:1px solid #D9D5CC; border-radius:3px;
                     padding:16px; margin-bottom:12px; }
    .section-num   { font-size:10px; font-weight:700; color:#888;
                     letter-spacing:.08em; text-transform:uppercase; margin-bottom:4px; }
    .section-title { font-size:15px; font-weight:700; margin-bottom:6px;
                     font-family:"Source Serif 4",Georgia,serif; }
    .insight-box   { border-left:3px solid #326891; padding:8px 12px;
                     background:transparent; margin-top:10px; font-size:12px;
                     color:#444; line-height:1.6; font-style:italic; }
    .ctrl-panel { background:#F2EFE9; border:1px solid #D9D5CC; border-radius:3px;
                     padding:12px; margin-bottom:12px; position:sticky; top:10px;
                     max-height:92vh; overflow-y:auto; }
    .data-note  { font-size:10px; color:#888; margin-top:6px; font-style:italic; }
    .stat-grid  { display:grid; grid-template-columns:1fr 1fr 1fr;
                     gap:10px; margin-bottom:12px; }
    .stat-card { background:#F2EFE9; border-radius:3px; padding:10px 12px; }
    .stat-val { font-size:20px; font-weight:700;
                     font-family:"Source Serif 4",Georgia,serif; }
    .stat-lbl { font-size:10px; color:#6c757d; margin-top:2px; line-height:1.3; }
    .conclusion-full { background:#F2EFE9; border-top:2px solid #1A1A1A;
                       padding:24px 24px 20px; margin-top:20px; }
    .source-row { font-size:10px; color:#888; padding:10px 0 20px;
                     line-height:1.6; font-style:italic; }
    .dataTables_wrapper .dataTables_info { font-size:6px; color:#888; padding-top:4px; }
  '))),
  
  # HEADER 
  div(class = "story-intro",
      div(class = "story-tag", "DATA STORY"),
      div(class = "story-title",
          "Making sense of AI Wave - Three communities: General public, News journalists and Researchers",
          tags$br(),
          tags$span(style = "font-size:16px; font-weight:400; color:#444",
                    "Three Perspectives on AI Engagements and Responses")),
      div(class = "story-sub",
          "The launch of ChatGPT in late 2022 created a simultaneous response across the public,
           news and research communities. The following data story illustrates how these distinct communities 
           engaged with and responded to this technological phenomenon."),
      div(class = "pill-row",
          tags$span(class = "pill",
                    tags$span(style = "width:10px;height:10px;border-radius:50%;
                               background:#C0397A;flex-shrink:0;display:inline-block"),
                    "Public (Google Search Trends)"),
          tags$span(class = "pill",
                    tags$span(style = "width:10px;height:10px;border-radius:50%;
                               background:#326891;flex-shrink:0;display:inline-block"),
                    "News (The Guardian Articles)"),
          tags$span(class = "pill",
                    tags$span(style = "width:10px;height:10px;border-radius:50%;
                               background:#4A3F8F;flex-shrink:0;display:inline-block"),
                    "Research (arXiv Papers)")
      )
  ),
  
  # SECTION 1: OVERALL TRENDS 
  div(class = "scroll-section-header", "1 - OVERALL TRENDS (How do communities grow over time?)"),
  fluidRow(
    column(3,
           div(class = "ctrl-panel",
               h6("Filters", style = "font-weight:700"),
               sliderInput("date_range", "Date Range",
                           min = DATE_MIN, max = DATE_MAX,
                           value = c(DATE_MIN, DATE_MAX),
                           timeFormat = "%b %Y", step = 30, width = "100%"),
               hr(),
               checkboxGroupInput("groups", "Groups (Communities)",
                                  choices  = c("Public" = "public",
                                               "News"  = "news",
                                               "Research" = "research"),
                                  selected = c("public", "news", "research")), 
               hr(),
               radioButtons("ai_theme_filter", "AI Themes",
                            choices  = c("All" = "all",
                                         "GenAI" = "GenAI",
                                         "BroadAI" = "BroadAI"),
                            selected = "all"),
               hr(),
               checkboxInput("show_milestones", "Show LLM milestones", value = TRUE)
           )
    ),
    column(9,
           
           div(class = "section-card",
               div(class = "section-num", "01A"),
               div(class = "section-title",
                   "Trend line - Monthly counts (normalised) & Search scores"),
               div(class = "data-note",
                   "Public: Google Trends search score (0–100) on left axis.
                    News & Research: log10(count+1) normalisation on right axis to keep both lines
                    visible alongside public. Hover for raw value counts."),
               plotlyOutput("chart_01a", height = "360px")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "01B"),
               div(class = "section-title",
                   "Relative Growth Rate (log scale)- baseline Jan 2022"),
               plotlyOutput("chart_01b", height = "360px"),
               div(class = "insight-box",
                   "Insight: All three groups exhibit a consistent upward trajectory over time, 
                    but their growth rates show different speeds. Public interest spiked immediately and reacted ~10x faster after ChatGPT release.
                    Research sees a large overall volume growth, but showed no event-driven spikes."),
               hr(style = "margin:14px 0 10px"),
               h6("LLM Release Timeline - References",
                  style = "font-size:12px;font-weight:700"),
               div(class = "data-note", style = "margin-bottom:6px",
                   "Use Date Range Filter to select date preference. Scroll to view all entries."),
               DTOutput("llm_table")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "01C"),
               div(class = "section-title",
                   "GenAI vs BroadAI Share - Stacked bar with rolling mean (average) line"),
               radioButtons("loess_group", NULL,
                            choices  = c("Research (arXiv)" = "research",
                                         "News (Guardian)" = "news",
                                         "Public (Trends)" = "public"),
                            selected = "research", inline = TRUE),
               plotlyOutput("chart_01c", height = "260px"),
               div(class = "data-note",
                   "Bars show monthly counts (news/research) or search score (public).
                    GenAI share percentage % on right axis. Dashed amber line = rolling mean (average)
                    (12-month window) of total volume."),
               div(class = "insight-box",
                   "Insight: Research pivots heavily to GenAI. The Guardian news maintain BroadAI dominance throughout.")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "KEY EVENTS"),
               div(class = "section-title",
                   "How Each Group Respond To Key AI Events"),
               div(class = "data-note",
                   "Each panel = one event. Lines show how each group's ratio
                    changed in the 3 months before (T-1 to T-3) and 4 months after (T+1 to T+4)
                    the event. All lines are normalised to 1.0 at T-1 (the month before the event),
                    hence, lines are directly comparable across events regardless of absolute level."),
               plotlyOutput("chart_eventresponse", height = "320px"),
               div(class = "insight-box",
                   "Insight: Public reacts fast as the pink line shows a spike following the launch of ChatGPT and GPT-4.
                    News follows within 1-2 months. Research group fluctuates before and after event launch and shows almost no event-driven spikes.")
           )
    )
  ),
  
  # SECTION 2: AI THEMES 
  div(class = "scroll-section-header", "2 - AI THEMES AND COMMUNITIES COMPARISON (Which theme/topic do each community direct their attention to?)"),
  fluidRow(
    column(3,
           div(class = "ctrl-panel",
               h6("Sunburst Chart Filter", style = "font-weight:700"),
               radioButtons("circle_group", "Select Group",
                            choices  = c("News" = "news",
                                         "Research" = "research",
                                         "Public" = "public"),
                            selected = "news"),
               hr(),
               h6("Topic Rank Chart Filter", style = "font-weight:700"),
               radioButtons("bump_group", "Select group",
                            choices  = c("News" = "news",
                                         "Research" = "research",
                                         "Public" = "public"),
                            selected = "research"),
               sliderInput("bump_topn", "Top N topics", min = 3, max = 12, value = 6),
               hr(),
               h6("Butterfly Chart Filter", style = "font-weight:700"),
               radioButtons("butterfly_pair", "Compare pair",
                            choices  = c("News vs Research"  = "news_research",
                                         "Research vs Public" = "research_public",
                                         "News vs Public" = "news_public"),
                            selected = "news_research")
           )
    ),
    column(9,
           
           div(class = "section-card",
               div(class = "section-num", "02A"),
               div(class = "section-title",
                   "AI Themes to Topics to Keywords Hierarchy"),
               div(class = "data-note", style = "margin-bottom:6px",
                   "Segment size = mention count. Inner ring = AI theme (GenAI / BroadAI).
                    Middle ring = Topic. Click any topic segment to expand top 5 keywords."),
               plotlyOutput("chart_02a", height = "480px"),
               div(class = "insight-box",
                   HTML("Insight: News : dominated by Broad AI theme, focusing on industry/economy (economical/social aspect)
                    - Research: have a mix balanced between both themes, but dominated by AI architectures and LLM foundations (technical aspect)
                    - Public: GenAI tools release event mostly drives search interest.
                   <br><br> <b> *Note:</b> Unlike news and research, the public group has no article or paper text to extract keywords from. 
                   The keyword labels shown in the outer ring for public are sourced from the Google Trends keyword columns used to define each topic. 
                   Keywords that appear in the dataset as actual search terms (such as chatgpt, llm, openai, copilot etc)
                   reflect measured search volume. The remaining labels (summarization, code gen, retrieval etc)
                   are descriptive labels assigned to fill out topics that had few or no matching search columns. 
                   They represent the conceptual scope of the topic only.
                   Segment size in the public sunburst is based on the average Google Trends interest score for the topic, 
                   not keyword frequency."))
           ),
           
           div(class = "section-card",
               div(class = "section-num", "02B"),
               div(class = "section-title", "Topic Rank Over Time"),
               div(class = "data-note", style = "margin-bottom:6px",
                   "Rank 1 = highest topic share for that group that month. Date range Filter also applies - 
                   Adjust the Date in Section 1"),
               plotlyOutput("chart_02b", height = "320px"),
               div(class = "insight-box",
                   "Insight: Stable top topic ranks indicate priorities of each group.
                    Crossing lines signal topic shifts. - 
                    News : AI industry, economy and policy topic consistently has the top rank - 
                    Research : LLM foundations overtaking deep learning methods in research after 2023 -
                    Public : Several topics maintain a ranking in a long period of time.")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "02C"),
               div(class = "section-title", "Topic Share Comparison"),
               div(class = "data-note", style = "margin-bottom:6px",
                   "Bar length = proportion of group AI content."),
               plotlyOutput("chart_02c", height = "380px"),
               uiOutput("butterfly_insight_text")
           )
    )
  ), 
  
  # SECTION 3: CORRELATION AND SIMILARITY
  div(class = "scroll-section-header", "3 - CORRELATION AND SIMILARITY (How closely aligned are the attentions & responses/reactions?)"),
  fluidRow(
    column(3,
           div(class = "ctrl-panel",
               h6("Date Range", style = "font-weight:700"),
               div(class = "data-note", "Uses same Date Range slider as Section 1."),
               hr(),
               h6("Jaccard similarity score", style = "font-weight:700"),
               div(class = "data-note",
                   "The score tracks monthly alignment by looking at topics both groups focus most
                    in the same month. 0 = no overlap, 1 = identical."),
               hr(),
               h6("Pearson r - correlation charts", style = "font-weight:700"),
               div(class = "data-note",
                   HTML("This metric measures how closely two groups move together over time.
                    A value approaching +1 means when one group grows, the other tends to grow as well.
                    A value approaching 0 means the two groups move independently.<br><br>
                    <b>*Note on Limitations:</b> Because Pearson correlation is sensitive to extreme outliers, the ChatGPT launch month
                    may inflate results for pairs involving the public group.")),
               hr(),
               h6("Rolling line chart r: 12-month window", style = "font-weight:700"),
               div(class = "data-note",
                   "Chart 03B: Each point on this line shows correlation score calculated over
                    the preceding 12 months. An increasing line means the groups have been
                    moving more in the same direction recently."),
               hr(),
               h6("Scatter plot r: overall", style = "font-weight:700"),
               div(class = "data-note",
                   "Chart 03D: Each dot represents one month. The dotted line is a best fit trend.
                    The r value shows the overall Pearson correlation across all 48 months.")
           )
    ),
    column(9,
           
           div(class = "section-card",
               div(class = "section-num", "03 SUMMARY"),
               htmlOutput("jaccard_stat_cards")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "03A"),
               div(class = "section-title",
                   "Jaccard Topic Similarity - monthly, all three pairs"),
               plotlyOutput("chart_03a", height = "260px"),
               div(class = "insight-box",
                   HTML("Insight: Topic aligment is highly fluctuated over time.
                   Research vs Public alignment grows overtime, suggesting as AI wave is getting matured,
                   what the public might search for and what research group are publishing begin to overlap. -
                   News vs Research alignment slightly decrease, showing a shift in news coverage to approach more on economical aspect.<br>
                   <b>*Note: </b> The Research vs Public score is potentially driven by broad search terms such as deep learning or NLP, which is
                   already popular and inflate the public's interest focus on technical topics."))
           ),
           
           div(class = "section-card",
               div(class = "section-num", "03B"),
               div(class = "section-title",
                   "Rolling 12-month Pearson r - all three pairs"),
               plotlyOutput("chart_03b", height = "260px"),
               div(class = "insight-box",
                   HTML("<b>Chart interpretation:</b> Each month's r valie is the Pearson
                    correlation between two groups' monthly volume over the
                    preceding 12 months. A value near +1 means both groups
                    grew together in that window. A value near 0 means they moved independently.<br><br>
                    <b>Insight:</b> Research-Public move consistently together. - 
                    News-Research hovers near zero, news is event-driven, research output is not. -
                    News-Public attention move together during major AI release events, but not a sustained trend. 
                    <br><b>*Limitation:</b> With only 48 months of data total, each 12-month window is a small sample."))
           ),
           
           div(class = "section-card",
               div(class = "section-num", "03C"),
               div(class = "section-title",
                   "Annual Heatmaps - Jaccard similarity and Pearson r"),
               plotlyOutput("chart_03c", height = "300px"),
               div(class = "insight-box",
                   "Research-Public: improve consistently on both measures across all four years. - 
                   News-Public shows a sharp contrast between the two metrics. - 
                   News-Research is the most neutral pair on both heatmaps.")
           ),
           
           div(class = "section-card",
               div(class = "section-num", "03D"),
               div(class = "section-title",
                   "Monthly Volume Correlation - all three pairs"),
               div(class = "data-note", style = "margin-bottom:6px",
                   HTML("Each point = one month. Colour = year. Dotted line = best fit regression line.
                    r = Pearson correlation across all months shown. Closer to 1 means the two groups
                    grew more proportionally together.  <br><b>*Note:</b> the public group uses a relative search
                    score (0-100), not a raw count, so cross-group comparisons reflect trend direction
                    rather than absolute volume.")),
               plotlyOutput("chart_03d", height = "320px"),
               div(class = "insight-box",
                   HTML("<b>Reading the scatter:</b> Each dot is one month. A tight cluster
                    along the trend line means the two groups grew in proportion across
                    most months. Dots far from the line are months where one group
                    spiked without the other following - typically public-only event months
                    such as the ChatGPT launch.<br><br>
                    <b>Research-Public (r = 0.93)</b> is the tightest pair:
                    both have risen steadily together since 2022.
                    <b>News-Research (r = 0.69)</b> is the weakest: news is
                    event-driven while research follows its own publication cycle.<br>
                    <b>*Note: </b> The Research vs Public score is potentially driven by broad search terms such as deep learning or NLP, which is
                   already popular and inflate the public's interest focus on technical topics")
               )
           )
    )
  ),
  
  # CONCLUSION 
  tags$div(
    class = "conclusion-full",
    style = "margin-left:-15px; margin-right:-15px;",
    div(style = "padding:24px 32px 20px;",
        div(class = "section-num", "CONCLUSION"),
        uiOutput("conclusion_ui"),
        div(class = "source-row",
            "Data sources: The Guardian Open Platform API - arXiv (Cornell/Kaggle dataset) - Google Trends - LLM Timeline - 2022-2025",
            tags$br(),
            "Presented by: Nhi Nguyen")
    )
  )
  
) # end UI


# 4. SERVER --
server = function(input, output, session) {
  
  date_min_ym = reactive({ format(input$date_range[1], "%Y-%m") })
  date_max_ym = reactive({ format(input$date_range[2], "%Y-%m") })
  # reactive set up 
  llm_key = reactive({
    llm %>% filter(model_name %in% KEY_MILESTONE_NAMES,
                   date >= input$date_range[1], date <= input$date_range[2])
  })
  llm_filtered = reactive({
    llm %>% filter(date >= input$date_range[1], date <= input$date_range[2])
  })
  
  vol_filtered = reactive({
    d = vol %>%
      filter(group %in% input$groups,
             year_month >= date_min_ym(), year_month <= date_max_ym())
    if (input$ai_theme_filter != "all")
      d = d %>% filter(ai_theme == input$ai_theme_filter)
    d %>%
      group_by(year_month, group) %>%
      summarise(
        count     = sum(count, na.rm = TRUE),
        count_log = log10(sum(count, na.rm = TRUE) + 1),
        .groups   = "drop"
      ) %>%
      mutate(date = ym_to_date(year_month))
  })
  
  # 01A - line chart 
  output$chart_01a = renderPlotly({
    d = vol_filtered()
    if (nrow(d) == 0) return(plot_ly())
    
    p = plot_ly()
    
    if ("public" %in% input$groups) {
      sub = d %>% filter(group == "public")
      if (nrow(sub) > 0)
        p = p %>% add_lines(
          data = sub, x = ~date, y = ~count,
          name = "Public",
          line = list(color = GROUP_COLOURS["public"], width = 2),
          yaxis = "y",
          text = ~paste0("Public<br>Month: ", year_month,
                         "<br>Search score: ", round(count, 1)),
          hoverinfo = "text"
        )
    }
    
    for (grp in intersect(c("news", "research"), input$groups)) {
      sub = d %>% filter(group == grp)
      if (nrow(sub) == 0) next
      p = p %>% add_lines(
        data = sub, x = ~date, y = ~count_log,
        name = tools::toTitleCase(grp),
        line = list(color = GROUP_COLOURS[grp], width = 2),
        yaxis = "y2",
        text = ~paste0(tools::toTitleCase(grp),
                       "<br>Month: ", year_month,
                       "<br>log10(count+1): ", round(count_log, 3),
                       "<br>Raw count: ", round(count, 0)),
        hoverinfo = "text"
      )
    }
    
    if (input$show_milestones && nrow(llm_key()) > 0)
      p = add_milestone_vlines(p, llm_key())
    
    p %>% layout(
      yaxis  = list(title = "Search score (public)",
                    tickfont = list(size = 5),
                    color    = GROUP_COLOURS["public"],
                    range    = c(0, 130)),
      yaxis2 = list(title      = "log10(count+1)",
                    overlaying = "y", side = "right",
                    tickfont   = list(size = 5),
                    color      = "#555"),
      xaxis  = list(title = "", tickfont = list(size = 9)),
      legend = list(orientation = "h", x = 0, y = -0.18, font = list(size = 10)),
      plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 65, r = 65, t = 55, b = 55)
    )
  })
  
  # 01B - growth 
  output$chart_01b = renderPlotly({
    d = growth %>%
      filter(group %in% input$groups,
             year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(date = ym_to_date(year_month))
    
    if (input$ai_theme_filter != "all") {
      d_vol = vol %>%
        filter(group %in% input$groups, ai_theme == input$ai_theme_filter)
      baselines = d_vol %>%
        filter(year_month == "2022-01") %>%
        group_by(group) %>%
        summarise(base = sum(count, na.rm = TRUE), .groups = "drop")
      d = d_vol %>%
        filter(year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
        group_by(year_month, group) %>%
        summarise(count = sum(count, na.rm = TRUE), .groups = "drop") %>%
        left_join(baselines, by = "group") %>%
        mutate(indexed = ifelse(!is.na(base) & base > 0, count / base, NA),
               date    = ym_to_date(year_month))
    }
    
    if (nrow(d) == 0 || all(is.na(d$indexed))) return(plot_ly())
    
    d = d %>%
      mutate(
        grp_label = tools::toTitleCase(group),
        hover_info = paste0(grp_label,
                            "<br>Month: ", year_month,
                            "<br>Growth: ", round(indexed, 1), "x")
      )
    
    p = plot_ly()
    for (grp in intersect(c("public", "news", "research"), input$groups)) {
      sub = d %>% filter(group == grp, !is.na(indexed))
      if (nrow(sub) == 0) next
      
      p = p %>% add_lines(
        data = sub, x = ~date, y = ~indexed,
        name = sub$grp_label[1],
        line = list(color = GROUP_COLOURS[grp], width = 2),
        text = ~hover_info,
        hoverinfo = "text"
      )
    }
    
    if (input$show_milestones && nrow(llm_key()) > 0)
      p = add_milestone_vlines(p, llm_key())
    
    p %>% layout(
      yaxis  = list(type  = "log",
                    title = "Growth factor (x Jan 2022 baseline)",
                    tickfont = list(size = 5),
                    tickvals = c(0.5, 1, 2, 5, 10, 50, 100, 500, 1000),
                    ticktext = c("0.5x","1x","2x","5x","10x","50x","100x","500x","1000x")),
      xaxis  = list(title = "", tickfont = list(size = 10)),
      legend = list(orientation = "h", x = 0, y = -0.18, font = list(size = 10)),
      plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 70, r = 40, t = 40, b = 60)
    )
  })
  
  # LLM table 
  output$llm_table = renderDT({
    d = llm_filtered() %>%
      select(Date = date, Model = model_name, Company = company, Type = open_closed)
    datatable(d,
              options  = list(dom = "t", ordering = FALSE,
                              scrollY = "220px", scroller = TRUE, paging = FALSE),
              rownames = FALSE, class = "compact stripe", escape = FALSE
    ) %>%
      formatStyle("Type",
                  backgroundColor = styleEqual(c("OPEN","CLOSED","PARTIAL"),
                                               c("#EAF3DE","#FAECE7","#FAEEDA")),
                  color = styleEqual(c("OPEN","CLOSED","PARTIAL"),
                                               c("#3B6D11","#993C1D","#633806")),
                  fontWeight = "200")
  })
  
  # 01C - stacked bar + line 
  output$chart_01c = renderPlotly({
    grp = input$loess_group
    d = loess_df %>%
      filter(group == grp,
             year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(date = ym_to_date(year_month)) %>%
      arrange(date)
    
    genai_col = unname(GROUP_COLOURS[grp])
    y_title   = if (grp == "public") "Google Trends score" else "Monthly count"
    grp_label = switch(grp,
                       research = "arXiv (research)",
                       news = "Guardian (news)",
                       public = "Public search (Google Trends)")
    
    plot_ly(d) %>%
      add_bars(x = ~date, y = ~broadai_count, name = "BroadAI",
               marker = list(color = "#B5D4F4"), yaxis = "y") %>%
      add_bars(x = ~date, y = ~genai_count, name = "GenAI",
               marker = list(color = genai_col, opacity = 0.85), yaxis = "y") %>%
      add_lines(x = ~date, y = ~loess_total, name = "Rolling mean (average)",
                line   = list(color = MEAN_COL, width = 2, dash = "dash"),
                yaxis  = "y") %>%
      add_lines(x = ~date, y = ~genai_share, name = "GenAI share %",
                line   = list(color = "#888", width = 1.2, dash = "dot"),
                yaxis  = "y2") %>%
      layout(
        barmode = "stack",
        title = list(text = grp_label, font = list(size = 12)),
        xaxis = list(title = "", tickfont = list(size = 9)),
        yaxis = list(title = y_title, tickfont = list(size = 9)),
        yaxis2 = list(title = "GenAI share (%)", overlaying = "y", side = "right",
                       tickfont = list(size = 9), range = c(0, 100),
                       ticksuffix = "%"),
        legend  = list(orientation = "h", x = 0, y = -0.22, font = list(size = 10)),
        plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
        hovermode = "x unified",
        margin = list(l = 55, r = 65, t = 35, b = 60)
      )
  })
  
  # event line chart 
  output$chart_eventresponse = renderPlotly({
    d = event_rsp %>%
      filter(group %in% input$groups) %>%
      mutate(group_lbl = tools::toTitleCase(group))
    
    events_ordered = c("ChatGPT launch", "GPT-4 release",
                       "Llama 2 (open source)", "Gemini 1.5 Pro", "Claude 3.5 Sonnet", "DeepSeek R1")
    events_in_data = events_ordered[events_ordered %in% d$event]
    
    panels = lapply(seq_along(events_in_data), function(ei) {
      ev  = events_in_data[ei]
      sub = d %>% filter(event == ev) %>% arrange(month_offset)
      
      show_leg = (ei == 1)
      p = plot_ly()
      
      for (grp in intersect(c("public","news","research"), input$groups)) {
        s = sub %>% filter(group == grp)
        if (nrow(s) == 0) next
        gl = tools::toTitleCase(grp)
        p = p %>% add_lines(
          data = s,
          x   = ~month_offset,
          y   = ~relative,
          name = gl,
          line = list(color = GROUP_COLOURS[grp], width = 2),
          marker = list(color = GROUP_COLOURS[grp], size = 5),
          mode = "lines+markers",
          text = ~paste0(gl, "<br>", ev,
                         "<br>T", ifelse(month_offset >= 0,
                                         paste0("+", month_offset), month_offset),
                         "<br>Relative: ", round(relative, 2), "x"),
          hoverinfo = "text",
          showlegend = show_leg,
          legendgroup = gl
        )
      }
      
      p %>% layout(
        xaxis = list(
          title     = list(text = paste0("<b>", ev, "</b>"), font = list(size = 10, color = "#1A1A1A")), 
          tickvals  = c(-3,-2,-1,0,1,2,3,4),
          ticktext  = c("-3","-2","pre","T0","+1","+2","+3","+4"),
          tickfont  = list(size = 8),
          zeroline  = TRUE, zerolinecolor = "#ccc", zerolinewidth = 1,
          showgrid  = FALSE
        ),
        yaxis = list(
          title    = if (ei == 1) "Relative volume" else "",
          tickfont = list(size = 8),
          rangemode = "tozero"
        ),
        margin    = list(l = if (ei == 1) 40 else 10, r = 5, t = 10, b = 40), 
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
    })
    
    subplot(panels,
            nrows   = 1,
            shareY  = FALSE,
            titleX  = TRUE,
            titleY  = TRUE) %>%
      layout(
        legend = list(orientation = "h", x = 0, y = -0.15,
                      font = list(size = 10)),
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 45, r = 10, t = 15, b = 50),
        shapes = lapply(seq_along(events_in_data[-length(events_in_data)]), function(i) {
          list(type = "line",
               x0 = i / length(events_in_data),
               x1 = i / length(events_in_data),
               y0 = 0, y1 = 1,
               xref = "paper", yref = "paper",
               line = list(color = "#D9D5CC", width = 1))
        })
      )
  })
  
  # 02A - sunburst 
  output$chart_02a = renderPlotly({
    grp = input$circle_group
    d   = sunburst %>% filter(group == grp)
    if (nrow(d) == 0) return(plot_ly())
    
    theme_ids = d$ids[d$parents %in% c("Research","News","Public")]
    topic_ids = d$ids[d$parents %in% theme_ids]
    
    grp_col = unname(GROUP_COLOURS[grp])
    
    node_colours = vapply(seq_len(nrow(d)), function(i) {
      id  = d$ids[i]
      par = d$parents[i]
      if (par == "")  return(grp_col)
      if (par %in% c("Research","News","Public")) {
        return(if (grepl("GenAI", id)) "#C94A20" else "#1C5A8A")
      }
      if (par %in% theme_ids) {
        return(if (grepl("GenAI", par)) "#D4622A" else "#2A72A8")
      }
      if (par %in% d$ids[d$parents %in% theme_ids]) {
        topic_par_id = par
        theme_par_id = d$parents[d$ids == topic_par_id][1]
        return(if (grepl("GenAI", theme_par_id)) "#F0A882" else "#8DC4E2")
      }
      "#cccccc"
    }, character(1))
    
    hover_text = paste0(
      "<b>", d$labels, "</b><br>",
      format(round(d$values, 0), big.mark = ","), " items"
    )
    
    plot_ly(
      ids = d$ids,
      labels  = d$labels,
      parents = d$parents,
      values = d$values,
      type  = "sunburst",
      branchvalues = "remainder",
      marker  = list(colors = node_colours,line   = list(color = "white", width = 1.5)),
      textfont = list(color = "#FFFFFF", size = 11),
      hovertemplate = "%{customdata}<extra></extra>",
      customdata = hover_text,
      maxdepth = 3,
      insidetextorientation = "radial"
    ) %>%
      layout(
        title  = list(
          text = paste0("<b>", tools::toTitleCase(grp),
                        ":</b>  AI theme → Topic → Keyword (click to expand)"),
          font = list(size = 13), x = 0.01, xanchor = "left"),
        margin = list(l = 10, r = 10, t = 50, b = 10),
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
  })
  
  # 02B - bump
  output$chart_02b = renderPlotly({
    grp = input$bump_group
    n = input$bump_topn
    d = topic_m %>%
      filter(group == grp,
             year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(date = ym_to_date(year_month))
    
    top_t = d %>%
      group_by(topic) %>%
      summarise(s = sum(share), .groups = "drop") %>%
      arrange(desc(s)) %>%
      slice_head(n = n) %>%
      pull(topic)
    
    d = d %>%
      filter(topic %in% top_t) %>%
      group_by(date) %>%
      mutate(rank = rank(-share, ties.method = "first")) %>%
      ungroup() %>%
      mutate(tlbl = TOPIC_LABELS[topic])
    
    p  = plot_ly()
    tc = setNames(scales::hue_pal()(length(top_t)), top_t)
    
    for (tp in top_t) {
      sub = d %>% filter(topic == tp) %>% arrange(date)
      p = p %>% add_lines(
        data  = sub, x = ~date, y = ~rank,
        name = TOPIC_LABELS[tp], mode = "lines+markers",
        line = list(color = tc[tp], width = 2),
        marker = list(color = tc[tp], size = 4),
        text = ~paste0(tlbl, "<br>Rank: ", rank,"<br>Share: ", round(share * 100, 1), "%"),
        hoverinfo = "text"
      )
    }
    
    p %>% layout(
      yaxis  = list(autorange = "reversed", title = "Rank",
                    tickfont = list(size = 10), dtick = 1),
      xaxis  = list(title = "", tickfont = list(size = 10)),
      legend = list(orientation = "v", x = 1.02, y = 0.5,
                    font = list(size = 9), xanchor = "left"),
      plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 55, r = 150, t = 15, b = 40)
    )
  })
  
  # 02C - butterfly topic % 
  output$chart_02c = renderPlotly({
    pair  = input$butterfly_pair
    grps  = strsplit(pair, "_")[[1]]
    grp_l = grps[1]; grp_r = grps[2]
    
    d = butter %>%
      filter(group %in% c(grp_l, grp_r)) %>%
      select(topic, group, proportion)
    
    ld = d %>% filter(group == grp_l) %>% rename(lp = proportion) %>% select(topic, lp)
    rd = d %>% filter(group == grp_r) %>% rename(rp = proportion) %>% select(topic, rp)
    
    both = ld %>%
      inner_join(rd, by = "topic") %>%
      mutate(div  = abs(lp - rp),
             tlbl = TOPIC_LABELS[topic]) %>%
      arrange(div)
    
    plot_ly() %>%
      add_bars(data = both, x = ~(-lp), y = ~tlbl, orientation = "h",
               name = tools::toTitleCase(grp_l),
               marker  = list(color = GROUP_COLOURS[grp_l], opacity = 0.75),
               text = ~paste0(tools::toTitleCase(grp_l), ": ",
                                 round(lp * 100, 1), "%"),
               hoverinfo = "text") %>%
      add_bars(data = both, x = ~rp, y = ~tlbl, orientation = "h",
               name = tools::toTitleCase(grp_r),
               marker  = list(color = GROUP_COLOURS[grp_r], opacity = 0.75),
               text = ~paste0(tools::toTitleCase(grp_r), ": ",
                                 round(rp * 100, 1), "%"),
               hoverinfo = "text") %>%
      layout(
        barmode = "overlay",
        xaxis = list(title = "Proportion of AI-related topics", tickfont = list(size = 5),
                       tickformat = ".0%",
                       tickvals = c(-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4),
                       ticktext = c("40%","30%","20%","10%","0","10%","20%","30%","40%")),
        yaxis = list(title = "", tickfont = list(size = 10)),
        shapes = list(list(type = "line", x0 = 0, x1 = 0, y0 = 0, y1 = 1,
                            yref = "paper",
                            line = list(color = "#6c757d", width = 1))),
        legend  = list(orientation = "h", x = 0.3, y = -0.18, font = list(size = 10)),
        plot_bgcolor = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 160, r = 20, t = 15, b = 70)
      )
  })
  # text when filtering 
  output$butterfly_insight_text = renderUI({
    msgs = list(
      news_research = "Differences: LLM foundations (research) vs AI industry/economy (news).",
      research_public = "Both share Deep learning and GenAI focus but diverge on LLM foundations.",
      news_public = "Overlap on GenAI tools. However, the rest of the topic seems to diverege, for example : AI ethics/policy vs NLP/speech."
    )
    div(class = "insight-box", style = "margin-top:8px",
        msgs[[input$butterfly_pair]])
  })
  
  # Stats output - section 3 
  output$jaccard_stat_cards = renderUI({
    jd = jac_m  %>% filter(year_month >= date_min_ym(), year_month <= date_max_ym())
    pd = corr_m %>% filter(year_month >= date_min_ym(), year_month <= date_max_ym())
    HTML(sprintf('
      <div class="stat-grid">
        <div class="stat-card">
          <div class="stat-val" style="color:%s">J score: %s &nbsp; r: %s</div>
          <div class="stat-lbl">Research-Public - Highest alignment/similarity on both metrics</div>
        </div>
        <div class="stat-card">
          <div class="stat-val" style="color:%s">J score: %s &nbsp; r: %s</div>
          <div class="stat-lbl">News-Research - Lowest r value - Suggesting different perspective on outputs</div>
        </div>
        <div class="stat-card">
          <div class="stat-val" style="color:%s">J score: %s &nbsp; r: %s</div>
          <div class="stat-lbl">News-Public - Moderate alignment - Suggesting event-driven outputs</div>
        </div>
      </div>',
                 GROUP_COLOURS["research"],
                 round(mean(jd$research_public,na.rm = TRUE), 2),
                 round(mean(pd$research_public,na.rm = TRUE), 2),
                 GROUP_COLOURS["news"],
                 round(mean(jd$news_research,na.rm = TRUE), 2),
                 round(mean(pd$news_research,na.rm = TRUE), 2),
                 GROUP_COLOURS["public"],
                 round(mean(jd$news_public,na.rm = TRUE), 2),
                 round(mean(pd$news_public,na.rm = TRUE), 2)
    ))
  })
  
  # 03A - Jaccard line
  output$chart_03a = renderPlotly({
    d = jac_m %>%
      filter(year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(date = ym_to_date(year_month))
    
    p = plot_ly(d) %>%
      add_lines(x = ~date, y = ~research_public, name = "Research-Public",
                line = list(color = GROUP_COLOURS["research"], width = 2)) %>%
      add_lines(x = ~date, y = ~news_public, name = "News-Public",
                line = list(color = GROUP_COLOURS["public"], width = 2)) %>%
      add_lines(x = ~date, y = ~news_research, name = "News-Research",
                line = list(color = GROUP_COLOURS["news"], width = 2, dash = "dash"))

    ms3 = llm %>%
      filter(model_name %in% c("ChatGPT","GPT-4","Claude 3.5 Sonnet",
                               "DeepSeek R1","GPT-5"),
             date >= input$date_range[1], date <= input$date_range[2])
    if (nrow(ms3) > 0 && input$show_milestones)
      p = add_milestone_vlines(p, ms3)
    
    p %>% layout(
      yaxis  = list(title = "Jaccard similarity score", range = c(0, 1),
                    tickfont = list(size = 10)),
      xaxis  = list(title = "", tickfont = list(size = 10)),
      legend = list(orientation = "h", x = 0, y = -0.22, font = list(size = 10)),
      plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 60, r = 20, t = 15, b = 65)
    )
  })
  
  # 03B - r line 
  output$chart_03b = renderPlotly({
    d = corr_m %>%
      filter(year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(date = ym_to_date(year_month))
    
    p = plot_ly(d) %>%
      add_lines(x = ~date, y = ~research_public, name = "Research-Public",
                line = list(color = GROUP_COLOURS["research"], width = 2)) %>%
      add_lines(x = ~date, y = ~news_public,  name = "News-Public",
                line = list(color = GROUP_COLOURS["public"],   width = 2)) %>%
      add_lines(x = ~date, y = ~news_research, name = "News-Research",
                line = list(color = GROUP_COLOURS["news"], width = 2, dash = "dash")) %>%
      add_segments(x = min(d$date), xend = max(d$date), y = 0, yend = 0,
                   inherit = FALSE,
                   line = list(color = "#aaa", width = 0.6, dash = "dot"),
                   showlegend = FALSE)
    
    ms3 = llm %>%
      filter(model_name %in% c("ChatGPT","GPT-4","Claude 3.5 Sonnet",
                               "DeepSeek R1","GPT-5"),
             date >= input$date_range[1], date <= input$date_range[2])
    if (nrow(ms3) > 0 && input$show_milestones)
      p = add_milestone_vlines(p, ms3)
    
    p %>% layout(
      yaxis  = list(title = "Rolling 12-month r correlation",
                    range = c(-1, 1),
                    tickfont = list(size = 10), zeroline = TRUE),
      xaxis  = list(title = "", tickfont = list(size = 10)),
      legend = list(orientation = "h", x = 0, y = -0.22, font = list(size = 10)),
      plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 65, r = 20, t = 15, b = 65)
    )
  })
  
  # 03C - heat map
  output$chart_03c = renderPlotly({
    pair_labels = c(news_research = "News-Research",
                    news_public = "News-Public",
                    research_public = "Research-Public")
    
    jlong = jac_a %>%
      pivot_longer(c(news_research, news_public, research_public),
                   names_to = "pair", values_to = "value") %>%
      mutate(pair_label = pair_labels[pair], yr = as.character(year))
    
    plong = corr_a %>%
      pivot_longer(c(news_research, news_public, research_public),
                   names_to = "pair", values_to = "value") %>%
      mutate(pair_label = pair_labels[pair], yr = as.character(year))
    
    hj = plot_ly(jlong, x = ~yr, y = ~pair_label, z = ~round(value, 2),
                 type = "heatmap", colorscale = "Blues",
                 zmin = 0, zmax = 1, showscale = FALSE,
                 text = ~round(value, 2), texttemplate = "%{text}",
                 hovertemplate = "<b>%{y}</b><br>Year %{x}<br>Jaccard: %{z}<extra></extra>") %>%
      layout(xaxis = list(title = "Year", tickfont = list(size = 10)),
             yaxis = list(title = "", tickfont = list(size = 10)),
             margin = list(l = 0, r = 0, t = 0, b = 0))
    
    hp = plot_ly(plong, x = ~yr, y = ~pair_label, z = ~round(value, 2),
                 type = "heatmap", colorscale = "RdBu",
                 zmid = 0, zmin = -1, zmax = 1, showscale = FALSE,
                 text = ~round(value, 2), texttemplate = "%{text}",
                 hovertemplate = "<b>%{y}</b><br>Year %{x}<br>Pearson r: %{z}<extra></extra>") %>%
      layout(xaxis = list(title = "Year", tickfont = list(size = 10)),
             yaxis = list(title = "", tickfont = list(size = 10)),
             margin = list(l = 0, r = 0, t = 0, b = 0))
    
    subplot(hj, hp, nrows = 1, shareY = TRUE, titleX = TRUE) %>%
      layout(
        annotations = list(
          list(x = 0.22, y = 1.20, xref = "paper", yref = "paper",
               text = "<b>Jaccard similarity score </b>",
               showarrow = FALSE, font = list(size = 12, color = "#1A1A1A")),
          list(x = 0.78, y = 1.20, xref = "paper", yref = "paper",
               text = "<b>Pearson r (12-month rolling)</b>",
               showarrow = FALSE, font = list(size = 12, color = "#1A1A1A"))
        ),
        margin = list(l = 120, r = 10, t = 65, b = 40),
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
  })
  
  # 03D - scatter 
  output$chart_03d = renderPlotly({
    d = scatter_p %>%
      filter(year_month >= date_min_ym(), year_month <= date_max_ym()) %>%
      mutate(year = as.character(year))
    
    yr_cols = c("2022" = "#C8DBF0", "2023" = "#5E9FD0",
                "2024" = "#1E6FA8", "2025" = "#0C3D6A")
    
    panel_titles = c(news_research = "News vs Research",
                     news_public = "News vs Public",
                     research_public = "Research vs Public")
    x_titles     = c(news_research = "News",
                     news_public = "News",
                     research_public = "Research")
    y_titles     = c(news_research = "Research",
                     news_public = "Public",
                     research_public = "Public")
    # set up the panel 
    mk_panel = function(pair_id, show_leg = FALSE) {
      sub = d %>% filter(pair == pair_id)
      if (nrow(sub) == 0) return(plot_ly())
      r_val = sub$r[1]
      slope = sub$slope[1]
      intercept = sub$intercept[1]
      x_range = range(sub$x, na.rm = TRUE)
      reg_y  = slope * x_range + intercept
      y_max = max(sub$y, na.rm = TRUE)
      
      plot_ly() %>%
        add_markers(data = sub, x = ~x, y = ~y,
                    color = ~year, colors = yr_cols,
                    marker = list(size = 7, opacity = 0.72),
                    text = ~paste0(panel_titles[pair_id],
                                   "<br>Month: ", year_month,
                                   "<br>X: ", round(x, 1),
                                   "<br>Y: ", round(y, 1)),
                    hoverinfo = "text", showlegend = show_leg) %>%
        add_lines(x = x_range, y = reg_y, inherit = FALSE,
                  line = list(color = "#B5491B", width = 1.5, dash = "dot"),
                  showlegend = FALSE, hoverinfo = "none") %>%
        add_annotations(
          x = x_range[2], y = y_max,
          xanchor = "right", yanchor = "top",
          text = paste0("r = ", r_val),
          showarrow = FALSE,
          font = list(size = 11, color = "#B5491B")) %>%
        layout(
          xaxis = list(title = list(text = x_titles[pair_id],
                                        font = list(size = 11)),
                       tickfont  = list(size = 9), zeroline = FALSE),
          yaxis = list(title  = list(text = y_titles[pair_id],
                                        font = list(size = 11)),
                       tickfont  = list(size = 9),
                       showline  = FALSE, zeroline = FALSE),
          margin = list(l = 50, r = 15, t = 30, b = 45)
        )
    }
    
    my_pairs  = c("news_research", "news_public", "research_public")
    plot_list = lapply(seq_along(my_pairs), function(i) {
      mk_panel(pair_id = my_pairs[i], show_leg = (i == 1))
    })
    
    subplot(plot_list, nrows = 1, shareY = FALSE, titleX = TRUE, titleY = TRUE) %>%
      layout(
        annotations = list(
          list(x = 0.13, y = 1.06, xref = "paper", yref = "paper",
               text = "<b>News vs Research</b>", showarrow = FALSE,
               font = list(size = 11, color = "#1A1A1A")),
          list(x = 0.50, y = 1.06, xref = "paper", yref = "paper",
               text = "<b>News vs Public</b>", showarrow = FALSE,
               font = list(size = 11, color = "#1A1A1A")),
          list(x = 0.87, y = 1.06, xref = "paper", yref = "paper",
               text = "<b>Research vs Public</b>", showarrow = FALSE,
               font = list(size = 11, color = "#1A1A1A"))
        ),
        legend = list(title = list(text = "<b>Year</b>"),
                      orientation = "v", x = 1.02, y = 0.5,
                      font = list(size = 10)),
        plot_bgcolor  = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 10, r = 50, t = 45, b = 55),
        shapes = list(
          list(type = "line", x0 = 0.333, x1 = 0.333, y0 = 0, y1 = 1,
               xref = "paper", yref = "paper",
               line = list(color = "#D9D5CC", width = 1.5)),
          list(type = "line", x0 = 0.666, x1 = 0.666, y0 = 0, y1 = 1,
               xref = "paper", yref = "paper",
               line = list(color = "#D9D5CC", width = 1.5))
        )
      )
  })
  
  # Conclusion 
  output$conclusion_ui = renderUI({
    HTML('
    <h6 style="font-size:13px;font-weight:700;margin-bottom:12px;
               font-family:\'Source Serif 4\',Georgia,serif">
      Conclusion and Data Limitations
    </h6>
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;
                gap:14px;margin-bottom:14px">
      <div style="border-left:3px solid #C0397A;padding-left:10px">
        <div style="font-size:10px;font-weight:700;color:#C0397A;
                    letter-spacing:.06em;text-transform:uppercase;margin-bottom:4px">General Public</div>
        <div style="font-size:12px;line-height:1.6">
          Responds and reacts fastly to major AI product launches. ChatGPT event drives
          an approximately 10x spike increase in pubic interest. While engagement settles at a higher baseline post-launch event, 
          it gradually decays during the quiet periods between major product cycles.
        </div>
      </div>
      <div style="border-left:3px solid #326891;padding-left:10px">
        <div style="font-size:10px;font-weight:700;color:#326891;
                    letter-spacing:.06em;text-transform:uppercase;margin-bottom:4px">News</div>
        <div style="font-size:12px;line-height:1.6">
          Journalists and News coverage remains significantly more stable than public search trends. 
          Rather than analyzing underlying technical architectures, the media predominantly frames AI through broader societal 
          and industrial contexts, maintaining a consistent focus on high-level, overarching themes.
        </div>
      </div>
      <div style="border-left:3px solid #4A3F8F;padding-left:10px">
        <div style="font-size:10px;font-weight:700;color:#4A3F8F;
                    letter-spacing:.06em;text-transform:uppercase;margin-bottom:4px">Research</div>
        <div style="font-size:12px;line-height:1.6">
          Exhibits steady growth, not too much affected by major AI events, reflecting the nature of academic publishing. The proportion 
          of GenAI-focused output demonstrates a sustained, uninterrupted upward trajectory over the entire four-year period.
        </div>
      </div>
    </div>
    <div style="font-size:10px;color:#888;line-height:1.6;
                border-top:1px solid #D9D5CC;padding-top:8px;font-style:italic">
      <strong>Limitations:</strong>
      <br> Data Collection: Guardian data is a sample data (due to API quota capping). Google Trends scores are relative, not absolute count.
      arXiv theme and topic classification assumes mutual exclusivity.
      <br> Metrics: Pearson r is used for all correlation metrics; it is sensitive to extreme outliers, which may inflate results for pairs 
      involving the public group; therefore,treat the public-related correlation values with caution.
      Rolling window is 12 months on only 48 months of data total; interpret trends as
      indicative rather than conclusive. 
      <br> Context: All four data sources carry an implicit geographic
      and linguistic bias towards English language and Western institutional context.
    </div>')
  })
  
} # end server


# 5. RUN APP --
shinyApp(ui = ui, server = server)

# AI Declaration : 
#I used Claude to assisting in coding :
#(1) generate Python code for topic and keywords classification and aggregation methods in the
#first stage of technical implementation and (2) R code for (i) sunburst chart, (ii) helper function
#for adding the vertical line overlaying the charts and (3) assisting in debugs the error in server
#chart renders. Code output was tested and reviewed.