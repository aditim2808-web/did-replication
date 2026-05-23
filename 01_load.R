# Institutional Delivery Rates, State Panel
# ============================================

library(readxl)
library(tidyverse)
library(fixest)
library(modelsummary)
library(gtsummary)

# ============================================
# 1. LOAD DATA
# ============================================

df <- read_excel("data/datafile.xls")

# ============================================
# 2. CLEAN & RESHAPE
# ============================================

df_clean <- df %>%
  rename(
    state = `India/States/UTs`,
    survey = Survey,
    area = Area,
    inst_delivery = `Delivery Care (for births in the 5 years before the survey) - Institutional births (%)`
  ) %>%
  filter(area == "Total") %>%
  filter(state != "India") %>%
  filter(survey %in% c("NFHS-3", "NFHS-4")) %>%
  mutate(inst_delivery = as.numeric(inst_delivery)) %>%
  mutate(post = ifelse(survey == "NFHS-4", 1, 0)) %>%
  select(state, survey, post, inst_delivery)

# ============================================
# 3. BUILD BALANCED PANEL + TREATMENT VAR
# ============================================

jsy_states <- c("Andhra Pradesh", "Bihar", "Chhattisgarh", "Jharkhand",
                "Madhya Pradesh", "Odisha", "Rajasthan",
                "Uttar Pradesh", "Uttarakhand", "Assam")

df_did <- df_clean %>%
  mutate(treated = ifelse(state %in% jsy_states, 1, 0)) %>%
  filter(!is.na(inst_delivery))

# Keep only states present in both rounds
balanced_states <- df_did %>%
  group_by(state) %>%
  filter(n() == 2) %>%
  ungroup()

# Check: should be 56 obs, 28 states, 8 treated
nrow(balanced_states)
n_distinct(balanced_states$state)
balanced_states %>% count(treated, post)

# ============================================
# 4. DESCRIPTIVE STATISTICS
# ============================================

balanced_states %>%
  mutate(group = ifelse(treated == 1, "JSY High-Focus", "Other States")) %>%
  tbl_summary(
    by = group,
    include = c(inst_delivery, post),
    statistic = all_continuous() ~ "{mean} ({sd})",
    label = list(
      inst_delivery ~ "Institutional Delivery Rate (%)",
      post ~ "NFHS-4 Round (post = 1)"
    )
  ) %>%
  add_p()

# ============================================
# 5. DiD REGRESSION
# ============================================

# Basic DiD
did_m1 <- feols(inst_delivery ~ treated + post + treated:post,
                cluster = ~state, data = balanced_states)

# Two-Way Fixed Effects (preferred)
did_m2 <- feols(inst_delivery ~ treated:post | state + post,
                cluster = ~state, data = balanced_states)

modelsummary(list("Basic DiD" = did_m1,
                  "Two-Way FE" = did_m2),
             stars = TRUE,
             output = "outputs/did_results.docx")

# ============================================
# 6. ROBUSTNESS CHECK — EXCLUDE NORTHEAST
# ============================================

northeast <- c("Assam", "Meghalaya", "Manipur", "Mizoram",
               "Nagaland", "Tripura", "Arunachal Pradesh", "Sikkim")

did_robust <- feols(
  inst_delivery ~ treated:post | state + post,
  cluster = ~state,
  data = balanced_states %>% filter(!state %in% northeast)
)

modelsummary(list("Two-Way FE (Full)" = did_m2,
                  "Excl. Northeast" = did_robust),
             stars = TRUE,
             output = "outputs/robustness_check.docx")

# ============================================
# 7. PRE/POST GROUP MEAN COMPARISON PLOT
# ============================================

plot_data <- balanced_states %>%
  group_by(treated, post) %>%
  summarise(mean_delivery = mean(inst_delivery), .groups = "drop") %>%
  mutate(
    group = ifelse(treated == 1, "JSY High-Focus States", "Other States"),
    round = ifelse(post == 1, "NFHS-4 (2015-16)", "NFHS-3 (2005-06)")
  )

ggplot(plot_data, aes(x = round, y = mean_delivery,
                      group = group, color = group)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Pre/Post Institutional Delivery Rates by Group",
    subtitle = "JSY High-Focus vs Other States (NFHS-3 to NFHS-4)",
    x = "Survey Round",
    y = "Mean Institutional Delivery Rate (%)",
    color = "Group"
  ) +
  theme_minimal()

ggsave("outputs/parallel_trends.png", width = 8, height = 6)
