# Vision Research data archive

[`vision-research.zip`](vision-research.zip) contains a cleaned copy of the historical Vision Research project archive. It preserves the substantive data, report, and helper files while omitting macOS Finder metadata and replacing three workstation-specific absolute paths in the report/helper script with comments. The measurement and analysis data files are otherwise unchanged.

## Contents

The archive includes:

- Processed fixation and event data for experiment sets `100_60`, `100_20`, and `BS`.
- Trial timing/variable tables, saccade counts, scene IDs, and per-subject scene metadata.
- The archived report and analysis helpers.

The tables include coded subject and trial identifiers, fixation durations, conditions, and saccade timing/event fields. The archive does not contain raw EDF/ASC eye-tracker recordings. The public histograms in the repository's `_data/` directory remain the aggregated distributions.

## Analysis summary

Applying the filters documented in the archived report gives 14,174 observations across 22 participants for Experiment 1 (`100_60`) and 11,415 across 18 participants for Experiment 2 (`100_20`). Experiment 3 (`BS`) is present in the archive but is not included in that report's publication analysis.

The Experiment 1 filtered durations reproduce the corresponding public histogram. Experiment 2 is close, with small bin-level differences that remain unexplained. The event logs contain saccade-on and saccade-off messages; the review found no explicit cancellation event labels.

These counts summarize one documented filtering path. The archived report contains legacy analysis code and is not a turnkey reproduction workflow.

## Reuse

No data-specific license is declared here. Contact the repository owner for reuse terms.
