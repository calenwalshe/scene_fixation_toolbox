library(ggplot2)
library(dplyr)
library(moments)
library(tidyr)

source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/r_manuscript/R/import_parameters.R')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')


all_events_nested.1 <- all_events_nested %>% mutate(experiment_group = ifelse(grepl("Experiment 1", experiment), "exp1", "exp2"))

###
# Comparison between human and model
theme_set(theme_bw())
model.human <- model.human %>% mutate(experiment_group = ifelse(experiment_group == "Experiment 1", "exp1", "exp2"))

model.human.gather <- model.human %>% gather(key = type, value = p, model, human)

model.human.mean.binned <- model.human %>% 
  group_by(condition, experiment, experiment_group) %>%
  filter(!is.na(duration)) %>%
  mutate(human = duration * human, model = duration * model) %>%
  summarize(human = sum(human), model = sum(model)) %>%
  gather(d_type, duration, human, model)

mean.fig <- ggplot(model.human.mean.binned, aes(x = condition, y = duration, colour = d_type)) + geom_point() + facet_grid(experiment ~ experiment_group) + theme(aspect.ratio = 1)

ggsave(plot = mean.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/means/mean.pdf")

plot(mean.fig)

##