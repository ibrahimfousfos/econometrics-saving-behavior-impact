# ==============================================================================
# DATA IMPORT
# ==============================================================================

# Import the dataset
data_base_pt2 <- read.csv("data/bank_clients_panel.csv")


# ==============================================================================
# Q1: SUMMARY STATISTICS (SAVINGS & RETIREMENT)
# ==============================================================================

# Choosing 2 variables of interest: savings and retirement
data_base_pt2 <- data_base_pt2 %>% mutate(meeting = as.integer(meeting)) 

sum_by_group <- _pt2 %>%
  group_by(meeting) %>%
  summarise(
    n = n(),
    mean_ret = mean(retirement, na.rm = TRUE), # na.rm = TRUE in case we have NAs
    sd_ret   = sd(retirement, na.rm = TRUE),
    p50_ret  = median(retirement, na.rm = TRUE),
    mean_sav = mean(savings, na.rm = TRUE),
    sd_sav   = sd(savings, na.rm = TRUE),
    p50_sav  = median(savings, na.rm = TRUE)
  )

print(sum_by_group)


# ==============================================================================
# Q2: DATA TRANSFORMATION
# ==============================================================================

# Logarithmic transformation (if variable = 0, log(variable + 1) is used to yield 0)
data_base_pt2$log_yincome <- ifelse(data_base_pt2$yincome == 0, log(data_base_pt2$yincome + 1), log(data_base_pt2$yincome))
data_base_pt2$log_savings <- ifelse(data_base_pt2$savings == 0, log(data_base_pt2$savings + 1), log(data_base_pt2$savings))
data_base_pt2$log_retirement <- ifelse(data_base_pt2$retirement == 0, log(data_base_pt2$retirement + 1), log(data_base_pt2$retirement))

# Simple rates of the 2 main variables
data_base_pt2$saving_rate <- data_base_pt2$savings / data_base_pt2$yincome
data_base_pt2$retirement_rate <- data_base_pt2$retirement / data_base_pt2$yincome

# Same transformation but for the post-treatment period (time > 1)
groupe_post_D <- subset(data_base_pt2, time > 1) 

groupe_post_D$log_yincome <- ifelse(groupe_post_D$yincome == 0, log(groupe_post_D$yincome + 1), log(groupe_post_D$yincome))
groupe_post_D$log_savings <- ifelse(groupe_post_D$savings == 0, log(groupe_post_D$savings + 1), log(groupe_post_D$savings))
groupe_post_D$log_retirement <- ifelse(groupe_post_D$retirement == 0, log(groupe_post_D$retirement + 1), log(groupe_post_D$retirement))

head(groupe_post_D)


# ==============================================================================
# Q3: HISTOGRAM OF YEARLY SAVINGS (PERIODS t > 1)
# ==============================================================================

# Create a common unit: mean savings of the 3 post-treatment periods (2, 3, 4)
unit_post_savings <- data_base_pt2 %>%
  filter(time >= 2) %>%
  group_by(id, meeting) %>%
  summarise(sav_post = mean(savings, na.rm = TRUE), .groups = "drop")

# A. Histogram per group
p1 <- ggplot(unit_post_savings, aes(x = sav_post, fill = factor(meeting))) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 30) +
  labs(x = "Savings post-treatment", fill = "Meeting") +
  theme_minimal()
p1

# B. Histogram per group with weights
weight_tab <- unit_post_savings %>%
  count(meeting, name = "n") %>%
  mutate(p = n / sum(n),
         w_equal = 1 / n,
         w_prop  = p / n)

unit_weighted <- unit_post_savings %>% left_join(weight_tab, by = "meeting")

p2 <- ggplot(unit_weighted, aes(x = sav_post, fill = factor(meeting))) +
  geom_histogram(aes(weight = w_equal), position = "identity", alpha = 0.5, bins = 30) +
  labs(title = "Distributions by treatment with weights", x = "Savings post-treatment", y = "Weighted count", fill = "Meeting") +
  theme_minimal()
p2


# ==============================================================================
# Q4: SCATTER PLOT
# ==============================================================================

# Since we have 3 periods, we use the mean and the log of the means
unit_post <- data_base_pt2 %>%
  filter(time >= 2) %>%
  group_by(id, meeting) %>%
  summarise(sav_post = mean(savings, na.rm = TRUE),
            inc_post = mean(yincome, na.rm = TRUE), .groups = "drop")

unit_post$log_inc_post <- log1p(unit_post$inc_post)
unit_post$log_sav_post <- log1p(unit_post$sav_post)

# Draw the scatter plot
SCATTER <- ggplot(unit_post, aes(x = log_inc_post, y = log_sav_post, color = factor(meeting))) +
  geom_point(alpha = 0.35) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Income–Savings Relationship (log–log), post-treatment period",
       x = "Log of yearly income post-treatment", 
       y = "Log of yearly savings post-treatment", 
       color = "Meeting") +
  theme_minimal()
SCATTER

# ==============================================================================
# Q5: PRE-TREATMENT COVARIATES & BALANCE CHECKS
# ==============================================================================

# Build PRE covariates at the unit level (t < 2)
pre_unit <- data_base_pt2 %>%
  filter(time < 2) %>%
  group_by(id, meeting, female) %>%
  summarise(
    inc_pre = mean(yincome,    na.rm = TRUE),
    sav_pre = mean(savings,    na.rm = TRUE),
    ret_pre = mean(retirement, na.rm = TRUE),
    .groups = "drop"
  )

# Probit regression
m_probit <- glm(meeting ~ inc_pre + sav_pre + ret_pre + female,
                data = pre_unit,
                family = binomial(link = "probit"))
summary(m_probit) 

# Average marginal effects (AME)
ame <- margins(m_probit)
summary(ame)

# Difference of means table
bal_table <- pre_unit %>%
  summarise(
    mean_inc_0 = mean(inc_pre[meeting == 0], na.rm = TRUE),
    mean_inc_1 = mean(inc_pre[meeting == 1], na.rm = TRUE),
    diff_inc   = mean_inc_1 - mean_inc_0,
    
    mean_sav_0 = mean(sav_pre[meeting == 0], na.rm = TRUE),
    mean_sav_1 = mean(sav_pre[meeting == 1], na.rm = TRUE),
    diff_sav   = mean_sav_1 - mean_sav_0,
    
    mean_ret_0 = mean(ret_pre[meeting == 0], na.rm = TRUE),
    mean_ret_1 = mean(ret_pre[meeting == 1], na.rm = TRUE),
    diff_ret   = mean_ret_1 - mean_ret_0,
    
    prop_fem_0 = mean(female[meeting == 0], na.rm = TRUE),
    prop_fem_1 = mean(female[meeting == 1], na.rm = TRUE),
    diff_fem   = prop_fem_1 - prop_fem_0
  )
print(bal_table)

# Simple tests of equality between groups (continuous variables)
t_inc <- t.test(inc_pre ~ meeting, data = pre_unit)
t_sav <- t.test(sav_pre ~ meeting, data = pre_unit)
t_ret <- t.test(ret_pre ~ meeting, data = pre_unit)

# Simple test of equality for limited variable (binary)
tab_f <- table(pre_unit$female, pre_unit$meeting)
chi_f <- chisq.test(tab_f)

print(t_inc)
print(t_sav)
print(t_ret)
print(chi_f)


# ==============================================================================
# Q6: SIMPLE OLS REGRESSION
# ==============================================================================

# Mean of savings post-treatment at t = 2, 3, 4
post_unit_6 <- data_base_pt2 %>%
  filter(time >= 2) %>%
  group_by(id, meeting) %>%
  summarise(
    Y_post = mean(.data[["savings"]], na.rm = TRUE),
    .groups = "drop"
  )

# Simple OLS: Y_post ~ meeting
m6 <- lm(Y_post ~ meeting, data = post_unit_6)
summary(m6)

# Plot "means by group" with 95% Confidence Intervals
m6_means <- post_unit_6 %>%
  group_by(meeting) %>%
  summarise(
    n  = n(),
    mu = mean(Y_post, na.rm = TRUE),
    se = sd(Y_post, na.rm = TRUE) / sqrt(n),
    ci_low  = mu - 1.96 * se,
    ci_high = mu + 1.96 * se,
    .groups = "drop"
  )

simple_ols <- ggplot(m6_means, aes(x = factor(meeting), y = mu)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.5) +
  labs(title = paste("Mean savings (post) by Meeting"),
       x = "Meeting (0=No, 1=Yes)", 
       y = paste("Mean savings (post)")) +
  theme_minimal()
simple_ols


# ==============================================================================
# Q7: EXTENDED OLS REGRESSION (ANCOVA)
# ==============================================================================

# Mean of variables post-treatment
post_unit_7 <- data_base_pt2 %>%
  filter(time >= 2) %>%
  group_by(id, meeting, female) %>%
  summarise(
    Y_post    = mean(.data[["savings"]], na.rm = TRUE),
    logY_post = mean(.data[["log_savings"]], na.rm = TRUE),
    .groups = "drop"
  )

# Mean of variables pre-treatment
pre_unit_7 <- data_base_pt2 %>%
  filter(time < 2) %>%
  group_by(id) %>%
  summarise(
    inc_pre     = mean(yincome, na.rm = TRUE),
    log_inc_pre = mean(log_yincome, na.rm = TRUE),
    Y_pre       = mean(.data[["savings"]], na.rm = TRUE),
    logY_pre    = mean(.data[["log_savings"]], na.rm = TRUE),
    .groups = "drop"
  )

# Intersection of the 2 tables to easily run the regression
dat7 <- left_join(post_unit_7, pre_unit_7, by = "id")

# 1) Level OLS
m7_levels <- lm(Y_post ~ meeting + inc_pre + Y_pre + female, data = dat7)
summary(m7_levels)

# 2) Log OLS
m7_logs <- lm(logY_post ~ meeting + log_inc_pre + logY_pre + female, data = dat7)
summary(m7_logs)

