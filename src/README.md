# MATLAB scripts

## `Rest_RLocked_Field_Analysis.m`

Main manuscript analysis script. This version is configured for the original project layout and can collect metrics from preprocessed EEGLAB datasets when `Collect_metrics = 1`.

## `Rest_RLocked_Field_Analysis_from_derived_outputs.m`

Repository-oriented script. This version is configured to skip raw metric collection and read derived waveform/metric exports from `data/derived_subject_level/`. Use this script when reproducing model tables and figures from the derived outputs package.

## `Summarize_noisy_channel_removal_and_ICA_component_rejection.m`

Preprocessing summary script for reporting noisy-channel removal and ICA-component rejection.
