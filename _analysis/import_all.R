source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/import_matlab.R')
source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/parse_all.r')
source('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_analysis/fixation_durations.R')


all_data <- import_scene_exp()

all_events_nested <- f.parse.all(all_data)


model.human <- get_binned_fixations(all_data)

model.human.1 <- model.human %>% mutate(experiment_group = ifelse(grepl("exp1", experiment), "exp1", "exp2"),
                                        experiment       = ifelse(grepl("noencoding", experiment), "Encoding Reduced", ifelse(grepl("nosurprise", experiment), "Surprise Reduced", "Full")))
model.human.1$experiment_group <- factor(model.human.1$experiment_group, levels = c("exp1", "exp2"), labels = c("Experiment 1", "Experiment 2"))

model.human.1$condition <- factor(model.human.1$condition, levels = c("1", "2", "3"), labels = c("Baseline", "Luminance Increase", "Luminance Decrease"))
model.human <- model.human.1

all_events_nested <- all_events_nested %>% mutate(experiment_group = ifelse(grepl("exp1", experiment), "exp1", "exp2"),
                                        experiment       = ifelse(grepl("noencoding", experiment), "Encoding Reduced", ifelse(grepl("nosurprise", experiment), "Surprise Reduced", "Full")))

all_events_nested$experiment_group <- factor(all_events_nested$experiment_group, levels = c("exp1", "exp2"), labels = c("Experiment 1", "Experiment 2"))
all_events_nested <- all_events_nested %>% rename(condition = critical_fix_type)

all_events_nested$condition <- factor(all_events_nested$condition, levels = c("NOCHANGE", "UP", "DOWN"), labels = c("Baseline", "Luminance Increase", "Luminance Decrease"))




save(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/model.human.rdata', model.human)
save(file = '~/Dropbox/Calen/Work/ucm/scene_fixation_model/_data/all_events_nested.rdata', all_events_nested)

