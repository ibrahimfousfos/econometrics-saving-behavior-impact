# ==============================================================================
# 1. SETUP & DATA LOADING
# ==============================================================================

# Load the required libraries
library(dplyr)

# Load the dataset from the specified path into 'groupe_41'
groupe_41 <- read.csv("C:/Users/ibrah/OneDrive/Documents/école/S7/econometrie appliquee/projet/group41.csv")

# Simple commands to inspect the dataset
head(groupe_41)
dim(groupe_41)
summary(groupe_41)


# ==============================================================================
# 2. DATA SUBSETTING
# ==============================================================================

# Extract lines 100 to 200 and select specific columns: 
# ("id", "yincome", "savings", "retirement", "meeting")
subset_data = groupe_41[100:200 , c("id", "yincome", "savings", "retirement", "meeting")]
head(subset_data)


# ==============================================================================
# 3. METRICS & TRANSFORMATIONS
# ==============================================================================

# Calculate simple rate metrics without data transformation
subset_data$saving_rate = subset_data$savings / subset_data$yincome
subset_data$retirement_rate = subset_data$retirement / subset_data$yincome

# Apply logarithmic transformation to the data (adding 1 to avoid log(0))
subset_data$log_yincome = ifelse(subset_data$yincome == 0, log(subset_data$yincome + 1), log(subset_data$yincome))
subset_data$log_savings = ifelse(subset_data$savings == 0, log(subset_data$savings + 1), log(subset_data$savings))
subset_data$log_retirement = ifelse(subset_data$retirement == 0, log(subset_data$retirement + 1), log(subset_data$retirement))

# Calculate logarithmic rates
subset_data$log_saving_rate = subset_data$log_savings / subset_data$log_yincome
subset_data$log_retirement_rate = subset_data$log_retirement / subset_data$log_yincome
subset_data

# Summary of 'subset_data' focusing only on the newly created variables
summary(subset_data[, c("log_yincome", "log_savings", "log_retirement", "log_saving_rate", "log_retirement_rate")])


# ==============================================================================
# 4. EXOGENOUS VARIABLE ANALYSIS
# ==============================================================================

# Calculate the proportions/shares of the dummy exogenous variable ('meeting')
table(groupe_41$meeting)
prop.table(table(groupe_41$meeting))
