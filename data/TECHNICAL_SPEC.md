# Vision Research archive: technical data specification

This note is a handover guide to the files in [`vision-research.zip`](vision-research.zip), which was received as `Vision Research.zip` from Antje Nuthmann. It documents observed file structure and cautious interpretations of the legacy fields. It is not a reconstruction of the original EDF/ASC acquisition pipeline.

## 1. Scope and provenance

The archive has three processed data sets: `100_60` (Experiment 1), `100_20` (Experiment 2), and `BS` (Experiment 3). It contains event-message logs for Experiments 1 and 2, processed R data frames for all three sets, scene/trial support files, and the historical report. It does **not** contain EDF/ASC continuous gaze samples.

“Raw” should be qualified by level:

- `exp*_trial_time.txt` is event-level message output: it preserves a large stream of emitted/detected events before the report's analysis filters. It is rawer than the fixation analysis table, but is not raw eye-position samples.
- `processed_data_*` and `manipulate_only_*` are already processed, serialized tables. The report loads these tables; it does not derive them from the event logs or raw gaze samples.
- This archive does not include the source code that generated the processed fixation tables from the acquisition stream. The exact software/export settings and event-to-fixation construction cannot be independently reconstructed from the supplied files alone.

## 2. Event/message logs

### Files and size

| File | Rows | Participants/sessions | Distinct participant–trial pairs |
| --- | ---: | ---: | ---: |
| `Vision Research/exp1_trial_time.txt` | 387,970 | 22 | 2,313 |
| `Vision Research/exp2_trial_time.txt` | 293,407 | 18 | 1,872 |

Both are tab-separated text files with the same six columns:

| Column | Observed content | Interpretation / caution |
| --- | --- | --- |
| `RECORDING_SESSION_LABEL` | Coded strings such as `asy-###` | Recording/session identifier; the examples here mask the numeric suffix. |
| `CURRENT_MSG_TEXT` | Message text such as `SAC_ON ...`, `SHIFT_FROM_BASELINE ...`, or `Trial_Info ...` | Event marker plus any embedded values. This is a free-text field; parse by message type and retain the original string. |
| `TRIAL_INDEX` | Integer-like value stored as text | Trial index assigned in the event log. |
| `Condition` | Codes `1`–`4`; `.` also occurs | The supplied archive does not provide a complete codebook for these values. Preserve codes rather than guessing labels. |
| `CALIBRATION` | `0` or `1` | Calibration-related flag. Rows marked 1 have `Condition` set to `.` in the observed logs. |
| `CURRENT_MSG_TIME` | Integer-like value stored as text | Message timestamp. Keep separate from time values embedded inside `CURRENT_MSG_TEXT`; the archive does not define a complete conversion/reference scheme. |

The message stream contains (among others):

| Message prefix | Exp. 1 rows | Exp. 2 rows | Example (participant/trial masked) |
| --- | ---: | ---: | --- |
| `SAC_ON` | 113,754 | 91,245 | `SAC_ON 1 EL_TIME 10826125 OS_TIME 10826126` |
| `sacstart` | 113,754 | 91,246 | `sacstart 10826125 ( 0 - 0 = 0 )` |
| `SAC_OFF` | 113,386 | 90,977 | `SAC_OFF 1 EL_TIME 0 OS_TIME 10826172` |
| `SHIFT_FROM_BASELINE` | 8,964 | 7,177 | `SHIFT_FROM_BASELINE 0.8 -0.2` |
| `SHIFT_TO_BASELINE` | 8,939 | 7,146 | `SHIFT_TO_BASELINE 0.8 -0.2` |
| `Trial_Info` | 2,227 | 0 | `Trial_Info 61 1` (Exp. 1) |

Exp. 1 also includes `TRIALID`, `SYNCTIME`, `RECCFG`, `GAZE_COORDS`, `THRESHOLDS`, and other setup messages. Both experiments have `VIEW_START_T_GETSECS_MS`, `BLANK_SCREEN`, and `TRIAL_RESULT`: 2,287 of each in Exp. 1 and 1,872 of each in Exp. 2. The `exp2_trial_time.txt` message rows consist of saccade, shift, view-start, blank-screen, and trial-result messages; `Trial_Info` appears in the separate `asymfix_exp2_ind2num.txt` mapping file rather than this log.

These are **message rows, not one row per saccade or fixation**. In particular, `SAC_ON` and `sacstart` appear as separate messages around the same saccade start; do not count both as separate saccades. `SAC_ON` and `SAC_OFF` counts are not equal, so do not assume every marker has a matching partner without defining a pairing and handling incomplete records. The event messages indicate that the recording/acquisition pipeline emitted saccade markers; the archive does not include the continuous sample stream needed to re-detect events or validate them independently.

### Related event index files

`Vision Research/asymfix_exp1_ind2num.txt` and `asymfix_exp2_ind2num.txt` are tab-separated logs with `RECORDING_SESSION_LABEL`, `TRIAL_INDEX`, and `CURRENT_MSG_TEXT`. They contain message/event records and are used by the legacy report to derive trial identifiers from `Trial_Info` messages. Do not join any of these tables by row order.

## 3. Processed event/fixation tables

### Objects, counts, and trial coverage

The `.txt` files below are gzip-compressed R serialized objects, not text tables. Each contains a data frame whose object name matches the filename stem. Row counts below are rows in the saved table; trial counts are distinct `(SUBJECT, TRIAL_NUM)` pairs.

| Set | `processed_data_*` rows / trials | `manipulate_only_*` rows / trials | Distinct subjects in broad table |
| --- | ---: | ---: | ---: |
| `100_60` (Exp. 1) | 123,120 / 2,319 | 17,922 / 2,287 | 22 |
| `100_20` (Exp. 2) | 90,070 / 1,872 | 14,350 / 1,870 | 18 |
| `BS` (Exp. 3) | 129,285 / 2,377 | 17,762 / 2,302 | 23 |

Exp. 1 and 2 trial-time logs contain 2,313 and 1,872 participant–trial pairs, respectively. The Exp. 2 broad table matches the log's pair coverage; the Exp. 1 broad table contains all log pairs plus six additional pairs that are not in the included trial-time log. The source files do not explain this discrepancy. The `manipulate_only` objects are intentionally narrower and do not cover every trial pair. No corresponding `BS` trial-time log is present for a coverage comparison.

The six saved R data frames share this 14-column schema:

| Column | Imported type in R | Meaning supported by supplied files | Caveats |
| --- | --- | --- | --- |
| `SUBJECT` | factor | Coded participant/session ID. | Use with `TRIAL_NUM` for the trial key. |
| `PREVIOUS_FIX_DUR` | integer | Duration of the previous fixation. | Fixation durations are in milliseconds in the report. |
| `NEXT_FIX_DUR` | integer | Duration of the fixation following the current saccade/event. | Primary duration outcome; milliseconds. |
| `TRIAL_NUM` | integer | Recording trial index. | Matches event-log `TRIAL_INDEX` after subject/session normalization. |
| `SHIFT_TYPE` | factor | Event class: observed broad-table values are `NONE`, `BASELINE`, `MANIPULATION`. | In `manipulate_only_*`, all rows have `MANIPULATION`, including control-direction rows. |
| `SHIFT_DIRECTION` | factor | Observed codes in broad tables: `NONE`, `UP`, `DOWN`; manipulation tables also use `CONTROL`. | Report normalizes control/no-shift codes for comparisons. Check the object before recoding. |
| `MSG_TIME` | integer | Time associated with the shift/event record. | Unit/reference is not fully documented. |
| `CURRENT_SAC_AMPLITUDE` | numeric | Amplitude of the current saccade. | Unit is not documented; do not assume degrees or pixels. |
| `CURRENT_SAC_START_TIME` | integer | Current saccade start time. | Time origin/unit are not fully documented. |
| `CURRENT_SAC_END_TIME` | integer | Current saccade end time. | Time origin/unit are not fully documented. |
| `NEXT_FIX_BASELINE` | factor | Observed codes include `NONE` and `BASELINE`. | Exact operational definition is not documented. |
| `CURRENT_SAC_CONTAINS_BLINK` | logical | Whether a blink is marked within the current saccade. | In manipulation tables, control rows have missing values here. |
| `NEXT_FIX_BLINK_AROUND` | factor | Observed values `NONE`, `BEFORE`, `AFTER`, `BOTH`; may be missing. | Encodes blink adjacency around the next fixation; exact interval definition is not supplied. |
| `MS_PRIOR_SAC_END` | integer | Relative timing value used in the report's `>= 0` filter for shifted records. | The name indicates milliseconds, but the full reference event/derivation is not documented. |

The row is best understood as a **processed saccade/event-associated observation with adjacent fixation measurements**, not as an unambiguously complete, unique list of all tracker-detected fixations. `PREVIOUS_FIX_DUR` and `NEXT_FIX_DUR` describe the neighboring fixation durations; the `CURRENT_SAC_*` fields describe a saccade associated with the event. The saved files do not include gaze coordinates or sample-by-sample eye position.

### Broad table vs. manipulation table

The broad `processed_data_*` tables have these `SHIFT_TYPE` counts:

| Set | `NONE` | `BASELINE` | `MANIPULATION` | Total |
| --- | ---: | ---: | ---: | ---: |
| `100_60` (Exp. 1) | 106,978 | 7,181 | 8,961 | 123,120 |
| `100_20` (Exp. 2) | 77,057 | 5,838 | 7,175 | 90,070 |
| `BS` (Exp. 3) | 111,853 | 8,551 | 8,881 | 129,285 |
| **Total** | **295,888** | **21,570** | **25,017** | **342,475** |

These are event/fixation records, not distinct fixations or trials.

The manipulation-table direction counts are:

| Set | `CONTROL` | `UP` | `DOWN` | `NONE` | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| `100_60` (Exp. 1) | 8,961 | 4,473 | 4,488 | 0 | 17,922 |
| `100_20` (Exp. 2) | 7,175 | 3,625 | 3,550 | 0 | 14,350 |
| `BS` (Exp. 3) | 8,881 | 4,046 | 4,023 | 812 | 17,762 |

Thus “manipulate only” means rows selected for the manipulation analysis, including control observations; it does not mean only rows where a visible shift occurred. In the Exp. 1 `CONTROL` rows, current-saccade and prior-fixation fields are missing, while `NEXT_FIX_DUR` supplies the control outcome. Across Exp. 1 and 2 manipulation tables, `NEXT_FIX_DUR` is missing in two rows apiece.

## 4. Example records (identifiers masked)

An event-log row (Exp. 1; original message text retained, participant/trial IDs masked):

```text
RECORDING_SESSION_LABEL=asy-###
CURRENT_MSG_TEXT="SAC_ON 1 EL_TIME 10826125 OS_TIME 10826126"
TRIAL_INDEX=##  Condition=1  CALIBRATION=0  CURRENT_MSG_TIME=3225
```

A processed manipulation row (values copied from one saved record; subject/trial masked):

```text
SUBJECT=asy-###  TRIAL_NUM=##  SHIFT_TYPE=MANIPULATION  SHIFT_DIRECTION=DOWN
PREVIOUS_FIX_DUR=209  NEXT_FIX_DUR=273  MSG_TIME=5296
CURRENT_SAC_AMPLITUDE=9.89  CURRENT_SAC_START_TIME=5282  CURRENT_SAC_END_TIME=5335
NEXT_FIX_BASELINE=NONE  CURRENT_SAC_CONTAINS_BLINK=FALSE
NEXT_FIX_BLINK_AROUND=NONE  MS_PRIOR_SAC_END=39
```

The fixation durations are in milliseconds. The example's saccade amplitude and timing units should not be inferred from the numeric values.

## 5. Joins, filters, and safe use

- Match rows using IDs, never by row position. The report parses `Trial_Info` from `asymfix_exp*_ind2num.txt`, normalizes `RECORDING_SESSION_LABEL` to `SUBJECT` and `TRIAL_INDEX` to `TRIAL_NUM`, then joins on both keys. Scene labels come from `sceneid.txt` using subject and trial identifiers.
- Check key uniqueness and join multiplicity before interpreting merged counts. A participant–trial may have many event messages and many processed records.
- Preserve `CURRENT_MSG_TEXT` and original categorical codes. `Condition` code meanings and several timestamp/amplitude definitions are not fully documented.
- The historical publication path removes the first four trials per participant, excludes one Experiment 1 trial, applies blink/prior-saccade rules to shifted records (with baseline exceptions), and retains `NEXT_FIX_DUR > 50` and `< 1200` ms. The retained 14,174 Exp. 1 and 11,415 Exp. 2 observations are report-specific analysis counts, not the sizes of the supplied tables.
- Histograms in `_data/h_fixdur_exp1.mat` and `h_fixdur_exp2.mat` are aggregate outputs; they do not preserve participant-level distributions or uncertainty.

## 6. Loading examples

In R, load a compressed data frame by path; the object is created in the R environment:

```r
load("Vision Research/processed_data_100_60.txt")
dim(processed_data_100_60)
table(processed_data_100_60$SHIFT_TYPE, useNA = "ifany")
```

In Python, the third-party `rdata` package reads the R serialization into a mapping of object names to pandas data frames:

```python
import rdata

objects = rdata.read_rda("Vision Research/processed_data_100_60.txt")
df = objects["processed_data_100_60"]
print(df.shape)
print(df["SHIFT_TYPE"].value_counts(dropna=False))
```

The tab-separated event log can be read as text:

```python
import pandas as pd

events = pd.read_csv("Vision Research/exp1_trial_time.txt", sep="\t", dtype=str)
events["message_type"] = events["CURRENT_MSG_TEXT"].str.split().str[0]
print(events["message_type"].value_counts())
```
