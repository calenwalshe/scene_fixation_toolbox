rm(list = ls()) # clear the decks

# load packages
library(dplyr)
library(ggplot2)
library(ks)
library(tidyr)
library(purrr)
library(ggthemes)

# import data
source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/import_parameters.R')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')

# format data
all_events_nested.1 <- all_events_nested %>% mutate(experiment_group = ifelse(grepl("Experiment 1", experiment_group), "exp1", "exp2"))

# select data
## Scatter of fixation durations
all_events_nested.2 <- all_events_nested %>% filter(experiment == "Full")

# more selection and formatting
all_events_nested.2 %>% group_by(experiment, condition, experiment_group) %>% summarize(labile.on.prop = mean(labile.on)) 
all_events_nested.2 <- all_events_nested.2 %>% filter(N_cancel < 4) %>% 
  group_by(experiment_group, condition, N_cancel) %>% 
  filter(!is.na(fixation_duration) & !is.na(first_labile_duration))


all_events_nested.2.frac <- all_events_nested.2 %>% mutate(alpha = ifelse(N_cancel == 0, .1, 1)) %>% sample_frac(.2)

theme_set(theme_clean())
fig.1 <- ggplot(all_events_nested.2.frac, aes(x = first_labile_duration,
                                fixation_duration,
                                colour = as.factor(N_cancel)
                                )) + 
  geom_point(alpha = .2, size = .75) +
  stat_ellipse() +
  facet_grid(experiment_group~condition, scales = "fixed") +
  #scale_y_continuous(expand = expand_scale(mult = 0), 
  #                   breaks = function(x) {
  #                     if(x[2] > 2000) {
  #                        return(seq(0, 2000, 500))
  #                     } else
  #                        return(seq(0, 1200, 400))
  #                     }) +
  xlab("Labile Duration") +
  ylab("Fixation Duration") +
  scale_color_wsj() +
  #scale_fill_viridis_c() +
  guides(fill=guide_legend(title="Count"), colour = guide_legend(title="Number of cancellations")) +
  theme(aspect.ratio = 1)

plot(fig.1)

ggsave(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/scatter/labile_fixation_duration.pdf', plot = fig.1, width = 8, height = 4)
