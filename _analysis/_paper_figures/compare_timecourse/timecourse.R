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

xlab.str <- "$log~\\frac{Pr(x~\\mid~model)}{Pr(x~\\mid~human)}$"

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]]
colours.fig <- palettes$`Tableau 10`

model.human.gather.1 <- model.human.gather %>%
  select(-type) %>%
  filter(condition != "Baseline") %>%
  spread(experiment, p) %>% data.frame() %>%
  mutate(Encoding.Reduced = log2((Encoding.Reduced/human)) * human,
         Surprise.Reduced = log2((Surprise.Reduced/human)) * human,
         Full = log2((Full/human))*human) %>%
  select(-human) %>%
  gather(type,p, c("Full", "Surprise.Reduced", "Encoding.Reduced"))

model.human.gather.1$type <- factor(model.human.gather.1$type, levels = unique(model.human.gather.1$type), labels = c("Full", "Surprise Reduced", "Encoding Reduced"))


timecourse.fig <- ggplot(model.human.gather.1,
                           aes(
                             x = duration,
                             y = p,
                             colour = type
                           )) +
  geom_point(size = .75) +
  geom_line(size = .5) +
  facet_grid(experiment_group ~ condition) +
  guides(linetype = FALSE, colour = FALSE) +
  scale_x_continuous(breaks = c(seq(0, 1000, 250))) +
  scale_color_manual(labels = c("Full", "Surprise Reduced", "Encoding Reduced"), values = c(colours.fig$value[1:3])) +
  xlab("Fixation Duration") +
  ylab("Normalized LLR") +
  theme(axis.text = element_text(size = 10), strip.text = element_text(size = 12), axis.title = element_text(size = 12), aspect.ratio = 1)

plot(timecourse.fig)

ggsave(plot = timecourse.fig, filename = "~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/_paper_figures/compare_timecourse/timecourse.pdf", width = 8, height = 5, useDingbats = FALSE)

