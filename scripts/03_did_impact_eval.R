# ==============================================================================
# LIBRARIES & DATA IMPORT
# ==============================================================================

library(dplyr)   # Data manipulation
library(ggplot2) # Plotting
library(plm)     # Panel data models
library(stargazer)

# Load database
data_base_pt3 <- read.csv("data/bank_clients_panel.csv")

head(data_base_pt3, 20)


# ==============================================================================
# DATA WRANGLING (PREPARATION FOR DIFFERENCE-IN-DIFFERENCES)
# ==============================================================================

# Creation of necessary variables for the Difference-in-Differences (DiD) analysis
df_did <- data_base_pt3 %>%
  mutate(
    # Post-Treatment Dummy Variable (1 if t >= 2, 0 otherwise)
    post = ifelse(time >= 2, 1, 0),
    
    # Conversion of TRUE/FALSE to 1/0 for the treatment variable
    treated = ifelse(meeting == "TRUE" | meeting == TRUE, 1, 0),
    
    # DiD Interaction Variable (This is the causal variable of interest)
    did_interaction = post * treated,
    
    # Logarithmic Transformation (log(x+1) to handle zeros)
    log_savings    = log(savings + 1),
    log_retirement = log(retirement + 1),
    log_yincome    = log(yincome + 1)
  )

# Declaration of the panel structure for the 'plm' package
pdf <- pdata.frame(df_did, index = c("id", "time"))


# ==============================================================================
# SECTION 2.1: PARALLEL TRENDS ASSUMPTION CHECK
# ==============================================================================

# Calculate means per period and per group
trend_data <- df_did %>%
  group_by(time, treated) %>%
  summarise(mean_savings = mean(log_savings, na.rm = TRUE), .groups = 'drop') %>%
  mutate(Group = ifelse(treated == 1, "Treated (Meeting)", "Control"))

# Create the plot to visually check parallel trends
p <- ggplot(trend_data, aes(x = time, y = mean_savings, color = Group)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 1.5, linetype = "dashed", color = "black") +
  labs(
    x = "Time Period",
    y = "Log(Total Savings)",
    caption = "Note: Treatment occurs at t=2. Trends must be parallel prior to this date."
  ) +
  theme_minimal() +
  scale_color_manual(values = c("grey40", "blue")) +
  annotate("text", x = 0.5, y = max(trend_data$mean_savings), label = "Pre-Treatment") +
  annotate("text", x = 3.5, y = max(trend_data$mean_savings), label = "Post-Treatment")
p

# ==============================================================================
# SECTION 2.2: MAIN RESULTS ESTIMATION
# ==============================================================================
# The equation is: log(Y) = c_i + lambda_t + delta * (Post * Treated) + controls
# We use the "within" model because we have panel data.

# 1. Estimation on Total Savings
model_savings <- plm(log_savings ~ did_interaction + post + log_yincome, 
                     data  = pdf, 
                     index = c("id", "time"), 
                     model = "within") 

# 2. Estimation on Retirement Savings
model_retirement <- plm(log_retirement ~ did_interaction + post + log_yincome, 
                        data  = pdf, 
                        index = c("id", "time"), 
                        model = "within")

# Output summaries
stargazer(model_savings, model_retirement, 
          type = "text",
          title = "Tableau 1 : Effet Causal du Meeting sur l'Épargne (Estimateur Within)",
          column.labels = c("Épargne Totale", "Épargne Retraite"),
          covariate.labels = c("Interaction DiD (ATT)", "Post (Tendance)", "Revenu (Log)"),
          keep.stat = c("n", "rsq", "adj.rsq", "f"), 
          digits = 3)


# ==============================================================================
# SECTION 2.3: ROBUSTNESS TESTS & HETEROGENEITY
# ==============================================================================

# 1. Heterogeneity Analysis
# Adding a triple interaction: did * female
m_hetero <- plm(log_savings ~ did_interaction * female + log_yincome, 
                data   = pdf, 
                model  = "within", 
                effect = "twoways")

summary(m_hetero)

# 2. Placebo Test
# We pretend the treatment happened at t=1 (instead of t=2)
# We only keep the data BEFORE the actual treatment (t=0 and t=1)
df_placebo <- df_did %>% 
  filter(time < 2) %>%
  mutate(
    post_fake = ifelse(time == 1, 1, 0),
    did_fake  = post_fake * treated
  )

m_placebo <- lm(log_savings ~ did_fake + post_fake + treated + log_yincome, 
                data = df_placebo)


stargazer(m_hetero, m_placebo, type = "text",
          title = "Tests de Robustesse",
          column.labels = c("Hétérogénéité Genre", "Test Placebo (t=0 vs t=1)"),

          covariate.labels = c("Interaction DiD", "Femme", "DiD x Femme", "DiD Placebo (Faux Traitement)"))

