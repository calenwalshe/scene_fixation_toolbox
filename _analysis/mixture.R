library(mclust, quietly=TRUE)
library(purrrlyr)

raw.data <- get_raw_data()
raw.fixations <- get_raw_fixations()

mixture.fit <- raw.fixations %>%
  filter(d_type == "human") %>%
  group_by(condition, experiment) %>% 
  nest() %>%
  mutate(mixture = purrr::map(data, function(data) {
    
    fit = Mclust(data$duration, G=4, model="V")
    
  }))

mixture.mean <- purrr::map(mixture.fit$mixture, list("parameters", c("mean")))
mixture.sd   <- purrr::map(mixture.fit$mixture, list("parameters", "variance", "sigmasq"))

mixture.sd <- lapply(mixture.sd, sqrt)

mixture.fit$sd <- mixture.sd
mixture.fit$mean <- mixture.mean

mixture.fit <- 
  mixture.fit %>% 
  unnest(sd, mean, .drop = F) %>%
  group_by(condition, experiment) %>%
  mutate(N_cancel = 0:3) %>% 
  ungroup()

levels(mixture.fit$condition) <- c("NOCHANGE", "UP", "DOWN")

summary.stats.group <- summary.stats.group %>% rename(condition = type)

combined.stats <- left_join(mixture.fit, summary.stats.group, by = c("condition", "experiment", "N_cancel"))

combined.stats <- combined.stats %>% gather("measure", "value", mean, mean.dur, sd, sd.dur)

ggplot(combined.stats, aes(x = N_cancel, y = value, colour = measure)) + geom_point() + facet_grid(condition ~ experiment)


mixture.models <- mixture.fit %>% select(condition, experiment, mixture) %>% unique() 
