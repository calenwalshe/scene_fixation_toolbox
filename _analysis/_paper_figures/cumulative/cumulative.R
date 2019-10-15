rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)
library(ggthemes)

load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata')
load(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata')

###
# Comparison between human and model
theme_set(theme_clean(base_size = 12))

model.human.gather <- model.human %>% gather(key = type, value = p, model, human) %>%
  filter(!(experiment %in% c("Encoding Reduced", "Surprise Reduced") & (condition %in% c("Baseline")))) %>%
  filter(type != "human" | (type == "human" & !(experiment %in% setdiff(experiment, "Full")))) %>%
  mutate(experiment = ifelse(type == "human", "human", experiment))

model.human.gather$experiment <- factor(model.human.gather$experiment, levels = c("human", "Full", "Surprise Reduced", "Encoding Reduced"))

model.human.gather.1 <- model.human.gather %>% group_by(type, experiment_group, experiment, condition) %>% mutate(p = cumsum(p))

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]]
colours.fig <- palettes$`Tableau 10`

distribution.fig <- ggplot(model.human.gather.1,
                           aes(
                             x = duration,
                             y = p,
                             colour = experiment
                           )) +
  geom_point(size = .5) +
  geom_line(size = .5) +
  facet_grid(experiment_group ~ condition) +
  guides(linetype = FALSE, colour = guide_legend(title = element_blank())) +
  xlab("Fixation Duration") +
  ylab("Cumulative Probability") +
  theme(aspect.ratio = 1) +
  guides(colour = FALSE) +
  scale_x_continuous(breaks = c(seq(0, 1000, 250))) +
  scale_color_manual(labels = c("human", "Full", "Surprise Reduced", "Encoding Reduced"), values = c("black", colours.fig$value[1:3])) +
  theme(axis.text = element_text(size = 10), strip.text = element_text(size = 12), axis.title = element_text(size = 12))


plot(distribution.fig)

ggsave(plot = distribution.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/cumulative/cumulative.pdf", width = 8, useDingbats = FALSE)

distribution.fig.guide <- distribution.fig + guides(colour = guide_legend())
ggsave(plot = distribution.fig.guide, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/cumulative/cumulative_withguide.pdf", width = 4, useDingbats = FALSE)




