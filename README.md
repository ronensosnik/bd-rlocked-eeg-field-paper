# Altered early resting R-locked EEG field expression in bipolar depression

This repository accompanies the manuscript:

**Attenuated early resting heartbeat-locked EEG field expression in bipolar depression**

The repository contains MATLAB analysis code and paper-facing outputs for the resting EEG/ECG R-locked field analysis. The primary endpoint is the 100-200 ms R-locked distributed-field score, computed as a leave-one-subject-out, group-blind topographic projection orthogonalized to the peri-R cardiac-field/topography template.

## Repository layout

```text
src/                 MATLAB analysis scripts
manuscript/          Manuscript and supplementary material drafts
results/figures/     Paper figure PDFs
results/tables/      Paper-facing model, contrast, reliability, and summary tables
data/                Data-sharing notes and, in the full package only, derived outputs
docs/                Reproducibility notes, setup instructions, and data dictionary
```

## Included scripts

- `src/Rest_RLocked_Field_Analysis.m`: main analysis script, including metric loading, topographic scoring, model fitting, permutation inference, cluster localization, and figure generation.
- `src/Rest_RLocked_Field_Analysis_from_derived_outputs.m`: repository-oriented version configured to rerun models/figures from derived waveform outputs when those outputs are available under `data/derived_subject_level/`.
- `src/Summarize_noisy_channel_removal_and_ICA_component_rejection.m`: preprocessing QC summary script for noisy-channel removal and ICA-component rejection.

## Data availability and privacy

This study uses human EEG/ECG and clinical data. Do not make subject-level files public unless this is allowed by the ethics approval, participant consent, institutional policy, and journal requirements. The public GitHub version should normally contain code plus aggregate/paper-facing outputs only. Subject-level derived waveform and clinical tables should be kept private or deposited in a controlled-access or approved open-data repository only after review.

See `docs/DATA_SHARING_AND_PRIVACY.md` before making the repository public.

## Running the analysis

### From raw/preprocessed EEGLAB files

1. Install MATLAB and EEGLAB.
2. Place the preprocessed data in the expected project layout:

```text
Data/<Group>/Subject_X/Processed/Subject_X_rest_processed.set
```

3. Add EEGLAB to the MATLAB path.
4. Run:

```matlab
cd src
Rest_RLocked_Field_Analysis
```

### From derived outputs

If the full derived-output package is available, place derived CSV/MAT files under:

```text
data/derived_subject_level/
data/matlab/
```

Then run:

```matlab
cd src
Rest_RLocked_Field_Analysis_from_derived_outputs
```

This mode is intended to regenerate statistics and figures from the derived subject/channel/time waveform exports rather than from raw EEGLAB files.

## Dependencies

- MATLAB, tested with the script author's MATLAB environment.
- EEGLAB, including `topoplot` and `pop_loadset`.
- MATLAB Statistics and Machine Learning Toolbox functions used by the script, including distribution functions and ordinary least-squares utilities.
