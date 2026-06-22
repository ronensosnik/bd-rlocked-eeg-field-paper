# Data sharing and privacy note

This project involves human participants, clinical grouping, and physiological recordings. Before making any repository public, review whether each file is permitted for open release.

## Recommended public GitHub contents

Public GitHub should usually include:

- Analysis code.
- Paper-facing aggregate statistical result tables.
- Figures.
- Manuscript or accepted manuscript, if journal policy allows.
- Documentation and reproducibility notes.

## Files that need additional review before public release

Subject-level files may require additional ethical and institutional approval, even if direct identifiers have been removed. These include:

- Subject-level field-score tables.
- Metrics tables containing age, sex, symptoms, medication indicators, smoking, HRV, or QC values.
- Long channel x time waveform files.
- MAT files containing subject-level arrays, maps, templates, or clinical metadata.
- Preprocessing QC tables by subject.

## Recommended approach

- Keep the GitHub repository public only for code and aggregate outputs.
- Keep subject-level derived data private unless open release is explicitly allowed.
- If sharing subject-level derived data is approved, consider depositing it in Zenodo, OSF, OpenNeuro, or institutional storage with a clear data-use statement.
- Do not upload raw EEG/ECG files or clinical forms to GitHub.
