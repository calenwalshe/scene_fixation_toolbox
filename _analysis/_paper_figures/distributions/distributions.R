rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)
library(ggthemes)

load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')

###
# Comparison between human and model
theme_set(theme_clean())

model.human.gather <- model.human %>% gather(key = type, value = p, model, human) %>%
  filter(!(experiment %in% c("Encoding Reduced", "Surprise Reduced") & (condition %in% c("Baseline")))) %>%
  filter(type != "human" | (type == "human" & !(experiment %in% setdiff(experiment, "Full")))) %>%
  mutate(experiment = ifelse(type == "human", "human", experiment))

model.human.gather$experiment <- factor(model.human.gather$experiment, levels = c("human", "Full", "Surprise Reduced", "Encoding Reduced"))

distribution.fig <- ggplot(model.human.gather,
                           aes(
                             x = duration,
                             y = p,
                             colour = experiment,
                             linetype = type
                           )) +
  geom_point() +
  geom_line() +
  facet_grid(experiment_group ~ condition) +
  guides(linetype = FALSE, colour = guide_legend(title = element_blank())) +
  scale_colour_canva() +
  xlab("Fixation Duration") +
  ylab("Proportion")
  

plot(distribution.fig)

ggsave(plot = distribution.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/distributions/distributions.pdf", width = 8, height = 4)

