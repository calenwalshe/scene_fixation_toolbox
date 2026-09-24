# Scene Fixation Toolbox

MATLAB code for simulating fixation durations during natural-scene viewing with a random-walk model.

## What is in this repository

- Model and experiment code, including `runSingleTrial.m` and the functions under `+lib/`, `+projects/`, and `+vis/`.
- Saved settings for Experiments 1 and 2 in `_data/settings_exp1.mat` and `_data/settings_exp2.mat`.
- Aggregated human fixation-duration distributions for Experiments 1 and 2 in `_data/h_fixdur_exp1.mat` and `_data/h_fixdur_exp2.mat`.

Each `h_fixdur` file contains a MATLAB variable named `human_data`. Its 60 rows represent 20 duration bins for each of three conditions. The columns are condition ID (1 = no change, 2 = up, 3 = down), proportion, and bin centre in milliseconds. The bins are 60 ms wide, with centres from 30 ms through 1,170 ms.

These files contain aggregated distributions. This repository does **not** include participant-level or trial-level fixation records, or raw eye-tracking recordings.

## Code status

This is a historical MATLAB source snapshot. It does not include a packaged installer or a top-level script that reproduces the full published analysis. The simulation functions require experiment settings and model parameters; inspect the included MATLAB files before adapting them to a new project.
