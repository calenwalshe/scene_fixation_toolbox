# Vision Research data

This folder brings together the public aggregate histograms and a supporting archive of processed fixation records from the historical Vision Research project.

> **At a glance** · 3 experiment sets · coded participant and trial IDs · 61 files · 16.2 MB compressed<br />
> The archive contains processed fixation/event records and analysis materials. It does not contain raw EDF/ASC eye-tracker recordings.

[Download the archive](vision-research.zip) · [Verify its SHA-256 checksum](vision-research.zip.sha256)

## The published aggregate distributions

The figure below plots the two aggregate files already included in the repository. Each curve shows the proportion of observations in successive 60 ms fixation-duration bins; points mark the bin centres.

![Two-panel plot of aggregate fixation-duration distributions for Experiments 1 and 2, with no-change, luminance-up, and luminance-down conditions.](fixation-duration-distributions.png)

Each MATLAB file contains a `human_data` matrix with 60 rows: 20 duration bins for each condition. The columns are condition ID (`1` = no change, `2` = luminance up, `3` = luminance down), proportion, and bin centre in milliseconds. Bin centres run from 30 ms to 1,170 ms.

| Experiment | Condition code | Public histogram |
| --- | --- | --- |
| 1 (`100_60`) | 1 no change · 2 up · 3 down | [`h_fixdur_exp1.mat`](../_data/h_fixdur_exp1.mat) |
| 2 (`100_20`) | 1 no change · 2 up · 3 down | [`h_fixdur_exp2.mat`](../_data/h_fixdur_exp2.mat) |

The plotted data are aggregated proportions. They do not show participant-level variation or uncertainty intervals.

## What is in the supporting archive

[`vision-research.zip`](vision-research.zip) contains 61 substantive files across three archived experiment sets: `100_60` (Experiment 1), `100_20` (Experiment 2), and `BS` (Experiment 3).

| Files | Format | Contents |
| --- | --- | --- |
| `processed_data_*.txt`, `manipulate_only_*.txt` | Gzip-compressed R serialized objects, despite the `.txt` suffix | Processed fixation and manipulation records. Fields used in the report include coded `SUBJECT`, `TRIAL_ID`/`TRIAL_NUM`, `NEXT_FIX_DUR`, `SHIFT_DIRECTION`, and `SHIFT_TYPE`. |
| `exp1_*`, `exp2_*` timing, variable, and saccade-count files | Tab-separated text | Trial timing, event messages, trial variables, and saccade counts for Experiments 1 and 2. |
| `asymfix_exp*_ind2num.txt` | Tab-separated text | Event-log and trial-index mapping tables. |
| `sceneid.txt`, `SceneID/` | Text and MATLAB `.mat` files | Scene IDs and per-subject scene metadata. |
| `VR_report.Rmd`, `VR_report.md`, `summarySE.R` | R Markdown and R source | The archived report and analysis helpers. |

Experiment 3 (`BS`) is present in the archive, but the archived publication analysis focuses on Experiments 1 and 2.

## Analysis coverage

The archived report's filtering path produces these analysis counts. “Processed records” describes rows in the broader processed object; “retained fixations” is the smaller analysis subset after filtering.

| Experiment | Set | Processed records | Participants | Retained fixations |
| --- | --- | ---: | ---: | ---: |
| 1 | `100_60` | 123,120 | 22 | **14,174** |
| 2 | `100_20` | 90,070 | 18 | **11,415** |
| 3 | `BS` | 129,285 | 23 | Not included in this report's publication analysis |

For Experiments 1 and 2, the documented filters remove early trials, blink-adjacent observations, records without the required preceding saccade, and fixation durations outside 50–1,200 ms. Experiment 1 also excludes one participant's trial. Treat the retained counts as results of that specific historical filtering path, not as a general row count for the archive.

The Experiment 1 filtered durations reproduce the corresponding public histogram. Experiment 2 is close, with small bin-level differences that remain unexplained.

## Open and verify

From the repository root, list and extract the archive with:

```sh
unzip -l data/vision-research.zip
unzip data/vision-research.zip -d /path/to/output
```

Verify the published archive before unpacking:

```sh
cd data
sha256sum -c vision-research.zip.sha256
```

The `.txt` files named `processed_data_*` and `manipulate_only_*` are gzip-compressed R objects, not delimited text. In R, `load()` reads them:

```r
load("Vision Research/processed_data_100_60.txt")
```

The timing, variable, saccade-count, and mapping files are tab-separated text. The aggregate MATLAB histogram matrix can be loaded from the repository root with:

```matlab
load('_data/h_fixdur_exp1.mat');
size(human_data) % 60 rows: 20 bins for each of 3 conditions
```

Regenerate the figure with `python data/plot_public_histograms.py` (requires NumPy, SciPy, and Matplotlib).

## Scope and limitations

- The archive contains processed participant/trial-level fixation records and event logs. No raw EDF/ASC gaze recordings were present in the source archive.
- Saccade-on and saccade-off messages are present; the review found no explicit cancellation event labels.
- The archived report is legacy code, not a turnkey reproduction workflow. The release copy removes workstation-specific absolute paths; additional environment setup may be needed to rerun the analyses.
- The archive copy omits macOS Finder metadata. Its substantive data files are preserved; the three workstation-specific paths in the report/helper script were replaced with comments.

No data-specific license is declared. Contact the repository owner for reuse terms.
