# two functions to calculate the confidence intervals
#
# https://community.rstudio.com/t/computing-confidence-intervals-with-dplyr/31868
# reproduced by Haiyang Jin (https://haiyangjin.github.io/)

# calculate the upper limit of Confidence Intervals (CI)

# Usage:

# df %>% 
#   group_by() %>% 
#   summarize(emmean = mean(DV), Count = n(), SE = sd(DV)/sqrt(Count)) %>% 
#   mutate(lower.CL = lower_ci(emmean, SE, Count),
#          upper.CL = upper_ci(emmean, SE, Count))

lower_ci <- function(mean, se, n, conf_level = 0.95){
  lower_ci <- mean - qt(1 - ((1 - conf_level) / 2), n - 1) * se
}

upper_ci <- function(mean, se, n, conf_level = 0.95){
  upper_ci <- mean + qt(1 - ((1 - conf_level) / 2), n - 1) * se
}
