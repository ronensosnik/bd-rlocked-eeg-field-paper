%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Study description (Introduction, Methods, Aims)
% ====================================
%
% 1. Introduction
% -------------------
%
% Affective states arise from coordinated activity across the central nervous system and the autonomic nervous system.
% Resting EEG/ECG can probe this coordination through heart-rate variability, heartbeat/R-locked cortical activity, and the temporal relation
% between cardiac events and neural state.
%
% Bipolar disorder is a mood disorder characterized by depressive, manic, or hypomanic episodes. Physiological alterations in bipolar
% disorder are often described in terms of neural dysconnectivity and altered autonomic regulation.
% Resting EEG/ECG provides a non-invasive way to examine spontaneous cardio-cortical dynamics in healthy controls, unaffected siblings
% of patients with bipolar disorder, and patients with bipolar disorder.
%
% The present script focuses on passive resting R-locked EEG scalp fields. It does not assume that the passive resting heartbeat-locked
% response is a classical frontal-only HEP. This distinction is important because many classical HEP studies used heartbeat-attention or
% heartbeat-counting tasks, whereas the present resting recording did not ask participants to attend to, count, or feel their heartbeats.
% Therefore, the endpoints generated here are interpreted as spontaneous resting R-locked EEG fields or resting cardio-cortical coupling,
% not as direct measures of conscious heartbeat awareness or instructed interoceptive attention.
%
% 2. Research questions
% ------------------------------
% The current paper asks several nested questions, ordered by inferential priority:
%
%   Primary question:
%   Is bipolar depressive state associated with altered expression of a passive resting 100-200 ms R-locked distributed EEG field, relative
%   to healthy controls, unaffected siblings, and euthymic bipolar patients, after accounting for age and sex?
%   The primary endpoint is constructed using weights orthogonalized to the peri-R cardiac-field/topography template. Subject-level peri-R
%   CFA-score covariate adjustment is treated as a prespecified sensitivity analysis rather than as part of the primary model.
%
%   Secondary questions:
%    - Is the alteration state-related rather than a general familial-risk or bipolar-diagnosis marker?
%    - Is the primary 100-200 ms field result specific to the R-locked timing, rather than reproducible around jittered pseudo-events?
%    - Does the primary field track MADRS depression severity or GAF functioning within BD after accounting for BD mood state?
%    - Are adjacent 200-300 ms and 300-400 ms post-R distributed-field endpoints altered, or is the effect concentrated in the primary window?
%    - Is the group-blind topographic template reliable across leave-one-subject-out, split-half, and bootstrap diagnostics?
%
% 3. Participants and grouping
% -------------------------------------
%
% Participants were healthy controls, unaffected siblings of patients with bipolar disorder, and patients with bipolar disorder.
% The six raw data folders are retained for file discovery and metadata:
% BP_I_Depressed, BP_II_Depressed, BP_I_Euthymic, BP_II_Euthymic, Siblings, HC
%
% The inferential grouping structure used by this paper is:
%  HC, Siblings, BD_Euthymic, BD_Depressed.
%
% BD subtype and original folder labels are retained as descriptive metadata but are not the primary grouping variable.
% Protocol-level exclusions related to color blindness or color weakness belong to the broader experimental protocol. They are not
% represented as analysis covariates or exclusion rules in this passive eyes-closed resting R-locked EEG analysis script.
%
% 4. Experimental paradigm
% ----------------------------------
%
% During the resting recording, participants closed their eyes and relaxed. They were not instructed to attend to, count, or feel their
% heartbeats. Thus, the R-locked EEG endpoints are interpreted as passive resting R-locked scalp-field measures.
% The analysis explicitly separates peri-R cardiac-field/topographic activity from post-R distributed EEG fields.
%
% 5. EEG/ECG preprocessing and beat marking
% -------------------------------------------------------------
%
% This standalone script can either run visual R-peak QC or collect the resting metrics needed for the present paper. The expected
% preprocessed resting files are located under each subject folder: Data\Group\Subject_X\Processed\Subject_X_rest_processed.set
%
% The preprocessed files are assumed to have undergone preprocessing pipeline:
%
%  * conversion from BrainVision/EEGLAB format
%  * EEG/EOG/ECG channel-type assignment
%  * EEG/EOG 0.5-40 Hz filtering
%  * bad-channel removal
%  * ICA on scalp EEG channels
%  * visual/component QC
%  * interpolation of removed EEG channels
%  * average referencing excluding EOG/ECG channels
%
% If Perform_visual_QC is enabled, the script opens the ECG beat-marking GUI. The GUI displays the ECG trace and permits
% manual deletion of falsely detected beats, insertion of missed beats, and marking of invalid ECG segments. These annotations are saved
% as sidecar MAT files. In the analysis mode used here, manual sidecars are mandatory. The manually corrected good R-peak sequence
% is treated as authoritative. No automatic physiological-range or MAD RR-interval rejection is applied after manual QC; only manually
% marked invalid ECG intervals remove RR intervals from HRV and post-R windows.
%
% 6. Metric and waveform extraction
% ---------------------------------------------
%
% If Collect_metrics is enabled, this script discovers subjects, loads CRF covariates, loads the preprocessed resting EEG file, applies the
% resting analysis low-pass filter of 20 Hz to EEG channels only, loads the manual R-peak sidecar, computes HRV metrics, and exports the
% subject-level all-channel R-locked waveforms needed for the present topographic-field analysis.
% The ECG channel is not low-pass filtered by the R-locked EEG analysis filter; R-peak annotations and HRV are therefore unchanged by
% the EEG analysis low-pass step.
%
% R-locked waveform QC definitions are relevant to all-channel waveform extraction:
%  * whole-epoch absolute amplitude threshold = 70 uV
%  * baseline-window absolute amplitude threshold = 70 uV
%  * analysis-window absolute amplitude threshold = 70 uV
%  * within-subject beat-level outlier threshold = 5 MAD
%
% The script implements an RR-adaptive forward-only pseudo-event negative-control analysis. Pseudo-events are generated within the same interbeat
% interval as the corresponding real R peak. For each interval R_i to R_{i+1}, the pseudo anchor is sampled from [R_i + 100 ms, R_{i+1} - 400 ms],
% so the tested pseudo 100-200 ms endpoint samples valid 100 ms windows from 200-300 ms after the current R through 300-200 ms before the next R.
% The primary pseudo-event control uses Monte Carlo sampling across many independent pseudo-event realizations. In each realization, pseudo-event
% maps are projected onto the same real R-locked 100-200 ms LOSO template weights used for the true R-locked endpoint; a separate pseudo-event
% template is not used.
%
% 7. Analyses
% ---------------
%
% The analysis is intentionally low-dimensional because the sample is modest. The primary endpoint is a subject-level, leave-one-subject-out,
% group-blind topographic projection of each subject's 100-200 ms scalp map onto a distributed field template orthogonalized to the peri-R
% cardiac-field template.
%
% The current analysis constructs group-blind distributed topographic field scores from subject-level all-channel R-locked waveforms:
%
%   * Peri-R cardiac-field/topography nuisance window: -25 to +25 ms.
%   * Main clinical distributed-field endpoint: 100 to 200 ms. The primary endpoint is a subject-level, leave-one-subject-out,
%     group-blind topographic projection of each subject's 100-200 ms scalp map onto a distributed field template orthogonalized to the peri-R
%     cardiac-field template.
%   * Two secondary/sensitivity endpoints: a) adjacent early post-R distributed-field sensitivity window, 200 to 300 ms; b) later post-R
%     distributed-field sensitivity window, 300 to 400 ms.
%     Because their field scores are also orthogonalized to the peri-R CFA template, all table labels explicitly say so.
%
% The exploratory channel-time cluster analysis is restricted to 100-400 ms only for localization within an early-to-mid post-R interval; it is not
% used to define the 100-200 ms endpoint. The cluster time grid is selected by explicit nearest-neighbor downsampling to the available
% waveform time grid, so the reported sampling step matches the actual samples used.
%
% The primary model family for the 100-200 ms field score is:
% RLocked100to200FieldScore_LOSO_uV ~ ClinicalStage + Age + Sex.
%
% The primary score sign is oriented after template construction so that the HC mean primary LOSO score is positive. Therefore, positive
% values indicate stronger expression of the group-blind, CFA-orthogonalized 100-200 ms field in the HC-positive orientation. This is a
% score-sign convention, not a claim about voltage polarity at any single electrode.
%
% All predefined window-average exports use start-inclusive, end-exclusive millisecond boundaries: [window_start, window_end). If a window
% would otherwise contain no samples because of an unusually sparse time grid, the function falls back to including the end point.
%
% The primary inference consists of a four-level ClinicalStage omnibus test, followed by planned ClinicalStage contrasts:
%
%   * BD_Depressed - HC
%   * BD_Depressed - BD_Euthymic
%   * BD_Depressed - Siblings
%   * Siblings - HC
%   * BD_Euthymic - HC
%
% Contrast p-values are computed with Freedman-Lane permutation. Holm-adjusted p-values are exported across the five planned contrasts.
%
% Primary sensitivity analyses test the primary ClinicalStage effect and the key BD-depressed contrasts after:
%   * peri-R CFA adjustment
%   * mean-HR adjustment
%   * lnRMSSD adjustment.
%
% A post hoc smoking-adjusted sensitivity analysis tests adjustment for cigarettes/day.
%
% BD-only MADRS and GAF exploratory analyses include BD mood state as a covariate, coded BD_Depressed = 1 and BD_Euthymic = 0.
%
% Template reliability diagnostics are implemented for the primary 100-200 ms template. The output includes LOSO-to-pooled weight stability,
% split-half stability, bootstrap weight stability, and bootstrap subject-score stability.
%
% 8. Output
% -------------
%
% Main outputs include:
% - healthy-control R-locked field topography
% - group early field maps
% - exploratory channel-time localization
% - artifact-control/robustness plots
% - Monte Carlo pseudo-event negative-control tables
% - template reliability tables
% - all-channel waveform supplements
% - all-window topographies
% - model result tables.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all force; clc; warning off;

%% =============================
%  1. User settings and execution switches
%  ==============================

cfg = struct();

% Execution switches

Perform_visual_QC = 0;
Collect_metrics = 0;
Models_and_statistics = 1;

% Project path discovery. Leave overrides empty for automatic inference from a standard project layout with Scripts, Data, and Analysis folders

cfg.projectRootOverride = "";
cfg.baseDirOverride = "";
cfg.analysisRootOverride = "";
cfg.metricRootOverride = "";
cfg.statsRootOverride = "";
cfg.inputDirOverride = "";
cfg.metricDirName = "Generated_Metrics";
cfg.statsDirName = "Model_Statistics";

thisFile = mfilename('fullpath');

if strlength(string(thisFile)) > 0
    cfg.scriptDir = string(fileparts(thisFile));
else
    cfg.scriptDir = string(pwd);
end

cfg.projectRoot = infer_project_root_standalone(cfg.scriptDir, cfg.projectRootOverride);

if strlength(string(cfg.baseDirOverride)) > 0
    cfg.baseDir = char(cfg.baseDirOverride);
else
    cfg.baseDir = char(fullfile(cfg.projectRoot, 'Data'));
end

if strlength(string(cfg.analysisRootOverride)) > 0
    cfg.analysisRoot = char(cfg.analysisRootOverride);
else
    cfg.analysisRoot = char(fullfile(cfg.projectRoot, 'Analysis'));
end

if strlength(string(cfg.metricRootOverride)) > 0
    cfg.metricDir = char(cfg.metricRootOverride);
else
    cfg.metricDir = char(fullfile(cfg.analysisRoot, char(cfg.metricDirName)));
end

if strlength(string(cfg.statsRootOverride)) > 0
    cfg.outputDir = char(cfg.statsRootOverride);
else
    cfg.outputDir = char(fullfile(cfg.analysisRoot, char(cfg.statsDirName)));
end

cfg.qcDir = fullfile(cfg.metricDir, 'QC');
cfg.tblDir = cfg.outputDir;
cfg.matDir = cfg.outputDir;
cfg.figDir = fullfile(cfg.outputDir, 'Figures');

% If metrics are collected in this standalone script, the downstream analysis reads from the subject-level output folder produced by collection

if strlength(string(cfg.inputDirOverride)) > 0
    cfg.inputDir = char(cfg.inputDirOverride);
else
    cfg.inputDir = char(cfg.metricDir);
end

cfg.stageOrder = {'HC', 'Siblings', 'BD_Euthymic', 'BD_Depressed'};
cfg.riskGradientValues = [0 1 2 3];

% Main windows. Use window averages for both figures and inferential scores

cfg.win.CFA_ms = [-25 25];
cfg.win.RLocked100to200_ms = [100 200];
cfg.win.Early_ms = [200 300];
cfg.win.Late_ms = [300 400];
cfg.win.LateTail_ms = [450 600];

% Exploratory mass-univariate cluster search window. The 100-400 ms interval avoids the most vulnerable peri-R period while retaining the
% 100-200 ms R-locked interval and adjacent early-to-mid post-R activity

cfg.cluster.searchWin_ms = [100 400];
cfg.cluster.timeStep_ms = 20;
cfg.cluster.timeSamplingMode = "nearestGrid";
cfg.cluster.effect = "BD_Depressed_vs_HC";
cfg.cluster.clusterFormingP = 0.05;
cfg.cluster.nPermutations = 10000;
cfg.cluster.run = true;

% Primary/secondary model permutation settings

cfg.model.nPermutationsPrimary = 100000;
cfg.model.nPermutationsSecondary = 100000;
cfg.model.nPermutationsSensitivity = 100000;
cfg.model.randomSeed = 13;
cfg.model.alpha = 0.05;
cfg.model.baseCovariates = {'Age', 'Sex'};

% Enhanced QC diagnostic thresholds. These flags are exported for audit and possible supplementary review;
% this manuscript script does not run QC-exclusion sensitivity models.

cfg.qc.manualBadPeakFracMax = 0.10;
cfg.qc.minRetainedRPeaks = 100;
cfg.qc.maxChannelAmpRejectedFrac = 0.20;
cfg.qc.maxFullWaveformAbs_uV = 20;

% Figure settings

cfg.fig.makeFigures = true;
cfg.fig.exportResolution = 300;
cfg.fig.visible = 'off';
cfg.fig.useTopoplotIfAvailable = true;
cfg.fig.suppTopoUseRowwiseClim = true;
cfg.fig.suppTopoRobustPrctile = 98;

% All manuscript table DOCX export settings

cfg.allTables.makeDocx = true;
cfg.allTables.outputFileOverride = "D:\Papers\2026\In preparation\Resting state brain heart coupling\Analysis\All_Tables.docx";
cfg.allTables.fileName = "All_Tables.docx";

% Template construction

cfg.template.useLeaveOneSubjectOut = true;
cfg.template.centerMapsAcrossChannels = true;
cfg.template.normalizeWeightsByL1 = true;
cfg.template.orientPrimaryScorePositiveInHC = true;
cfg.template.orientEarlyScorePositiveInHC = true;
cfg.template.primaryScoreSignConvention = "HC-positive orientation: positive values indicate stronger expression of the group-blind, CFA-orthogonalized 100-200 ms field; sign does not imply single-electrode voltage polarity";
cfg.template.nBootstrapReliability = 2000;
cfg.template.nSplitHalfReliability = 2000;
cfg.template.reliabilitySeed = 13013;

% Pseudo-event negative-control settings. Pseudo-events are forward-only and RR-adaptive.
% For each interval R_i to R_{i+1}, the pseudo anchor is sampled from [R_i + 100 ms, R_{i+1} - 400 ms].
% Because the tested endpoint is 100-200 ms after the pseudo anchor, this samples windows from [R_i + 200 ms, R_i + 300 ms] through [R_{i+1} - 300 ms, R_{i+1} - 200 ms].
% The main pseudo-event control is a Monte Carlo analysis across many pseudo-event realizations; the legacy single-realization analysis is disabled by default.

cfg.pseudo.run = true;
cfg.pseudo.method = "ForwardRRAdaptiveEndpointWindow";
cfg.pseudo.minEndpointStartAfterRealRSec = 0.200;
cfg.pseudo.minEndpointEndBeforeNextRSec = 0.200;
cfg.pseudo.maxAttemptsPerInterval = 100;
cfg.pseudo.randomSeed = 7319;
cfg.pseudo.useLegacySingleRealizationControl = false;
cfg.pseudo.monteCarlo = struct();
cfg.pseudo.monteCarlo.run = true;
cfg.pseudo.monteCarlo.nRealizations = 1000;
cfg.pseudo.monteCarlo.nModelPermutations = 5000;
cfg.pseudo.monteCarlo.randomSeed = 97319;
cfg.pseudo.monteCarlo.useParallel = true;
cfg.pseudo.monteCarlo.nWorkers = 8;
cfg.pseudo.monteCarlo.writeCheckpoint = true;
cfg.pseudo.monteCarlo.checkpointEverySubjects = 5;
cfg.pseudo.monteCarlo.saveSubjectScores = true;

% Channel adjacency for cluster permutation. If channel coordinates exist, the script builds an approximate nearest-neighbor graph

cfg.adj.minNeighbors = 4;
cfg.adj.distanceScale = 1.25;

rng(cfg.model.randomSeed, 'twister');

ensure_dir(cfg.metricDir);
ensure_dir(cfg.qcDir);
ensure_dir(cfg.outputDir);
ensure_dir(cfg.figDir);

fprintf('\nStandalone resting R-locked field analysis started.\nData root: %s\nAnalysis root: %s\nMetrics root: %s\nQC root: %s\nModel/statistics root: %s\n', cfg.baseDir, cfg.analysisRoot, cfg.metricDir, cfg.qcDir, cfg.outputDir);

if Perform_visual_QC
    metricSettings = build_standalone_metric_settings(cfg);
    Perform_visual_QC_ui(metricSettings.manualBadMissing, metricSettings.hep, metricSettings.hrv, metricSettings.ecgdet);
    return;
end

if Collect_metrics
    cfg = collect_standalone_resting_metrics_for_jad(cfg);
end

if ~Models_and_statistics
    fprintf('Models_and_statistics is disabled. Stopping after optional visual QC / metric collection.\n');
    return;
end

fprintf('Downstream input directory: %s\nModel/statistics output directory: %s\n', cfg.inputDir, cfg.outputDir);

%% ==========================
%  2. Load extracted waveform outputs
%  ===========================

files = struct();
files.long = find_analysis_file('Rest_RLocked_ChannelWaveforms_Long.csv', cfg, true);
files.groupSummary = find_analysis_file('Rest_RLocked_ChannelWaveforms_GroupSummary.csv', cfg, false);
files.endpoint = find_analysis_file('Rest_RLocked_ChannelWaveforms_EndpointBySubject.csv', cfg, false);
files.diagnostics = find_analysis_file('Rest_RLocked_ChannelWaveforms_Diagnostics.csv', cfg, false);
files.channelMat = find_analysis_file('Rest_RLocked_ChannelWaveforms.mat', cfg, true);
files.pseudoLong = find_analysis_file('Rest_PseudoEvent_ChannelWaveforms_Long.csv', cfg, false);
files.pseudoEndpoint = find_analysis_file('Rest_PseudoEvent_ChannelWaveforms_EndpointBySubject.csv', cfg, false);
files.pseudoDiagnostics = find_analysis_file('Rest_PseudoEvent_ChannelWaveforms_Diagnostics.csv', cfg, false);
files.pseudoChannelMat = find_analysis_file('Rest_PseudoEvent_ChannelWaveforms.mat', cfg, false);
files.metrics = find_analysis_file('Metrics_Resting.csv', cfg, true);
files.sampleCharacteristics = find_analysis_file('Table_SampleCharacteristics_ByClinicalStage.csv', cfg, false);
files.maxSeparation = find_analysis_file('Rest_RLocked_ChannelMaxSeparationSummary.csv', cfg, false);

fprintf('Loading R-locked waveform long table...\n');
Tlong = readtable(files.long, 'TextType', 'string');
Tmetrics = readtable(files.metrics, 'TextType', 'string');

if exist(files.groupSummary, 'file') == 2
    Tgroup = readtable(files.groupSummary, 'TextType', 'string');
else
    Tgroup = table();
end

if exist(files.endpoint, 'file') == 2
    Tendpoints = readtable(files.endpoint, 'TextType', 'string');
else
    Tendpoints = table();
end

if exist(files.diagnostics, 'file') == 2
    Tdiag = readtable(files.diagnostics, 'TextType', 'string');
else
    Tdiag = table();
end

Schan = load(files.channelMat, 'ChannelLocs', 'timeMs');
ChannelLocs = Schan.ChannelLocs;

if isfield(Schan, 'timeMs')
    timeMsFromMat = double(Schan.timeMs(:))';
else
    timeMsFromMat = [];
end

validate_required_columns(Tlong, {'Subject', 'ClinicalStage', 'Channel', 'TimeMs', 'Waveform_uV'}, 'Rest_RLocked_ChannelWaveforms_Long.csv');
validate_required_columns(Tmetrics, {'Subject'}, 'Metrics_Resting.csv');

Tlong.Subject = string(Tlong.Subject);
Tlong.ClinicalStage = string(Tlong.ClinicalStage);
Tlong.Channel = string(Tlong.Channel);
Tlong.TimeMs = double(Tlong.TimeMs);
Tlong.Waveform_uV = double(Tlong.Waveform_uV);

Tmetrics.Subject = string(Tmetrics.Subject);

if ~isempty(Tdiag)
    Tdiag.Subject = string(Tdiag.Subject);
    Tdiag.ClinicalStage = string(Tdiag.ClinicalStage);
    Tdiag.Channel = string(Tdiag.Channel);
end

if ~isempty(Tendpoints)
    Tendpoints.Subject = string(Tendpoints.Subject);
    Tendpoints.ClinicalStage = string(Tendpoints.ClinicalStage);
    Tendpoints.Channel = string(Tendpoints.Channel);
end

%% ============================
%  3. Build subject x channel x time array
%  =============================

fprintf('Building subject x channel x time waveform array...\n');

subjectInfo = unique(Tlong(:, {'Subject','ClinicalStage'}), 'rows', 'stable');
subjects = string(subjectInfo.Subject);
stage = string(subjectInfo.ClinicalStage);

% Enforce configured stage order

[stage, riskGradient] = normalize_stage_and_risk(stage, cfg.stageOrder, cfg.riskGradientValues);
subjectInfo.ClinicalStage = stage;
subjectInfo.RiskGradient = riskGradient;

% Channel order: prefer order in ChannelLocs; append any extra channels found in CSV

channelsCsv = unique(Tlong.Channel, 'stable');
chanLabelsFromLocs = channel_labels_from_locs(ChannelLocs);
channels = chanLabelsFromLocs(ismember(chanLabelsFromLocs, channelsCsv));
extraChannels = channelsCsv(~ismember(channelsCsv, channels));
channels = [channels(:); extraChannels(:)];
nCh = numel(channels);
locs = reorder_chanlocs(ChannelLocs, channels);

% Time order: use mat time vector when it matches the CSV; otherwise use CSV

timesCsv = unique(double(Tlong.TimeMs), 'stable');

if ~isempty(timeMsFromMat) && all(ismember(timeMsFromMat, timesCsv)) && numel(timeMsFromMat) == numel(timesCsv)
    timeMs = timeMsFromMat(:)';
else
    timeMs = sort(timesCsv(:))';
end

nT = numel(timeMs);
nS = numel(subjects);

[~, sIdx] = ismember(Tlong.Subject, subjects);
[~, cIdx] = ismember(Tlong.Channel, channels);
[~, tIdx] = ismember(double(Tlong.TimeMs), timeMs);

validRows = sIdx > 0 & cIdx > 0 & tIdx > 0 & isfinite(Tlong.Waveform_uV);
Y = nan(nS, nCh, nT);
linIdx = sub2ind([nS nCh nT], sIdx(validRows), cIdx(validRows), tIdx(validRows));
Y(linIdx) = Tlong.Waveform_uV(validRows);

fprintf('Array dimensions: %d subjects x %d channels x %d time points.\n', nS, nCh, nT);

% Optional pseudo-event negative-control waveforms. Initialize this struct even when pseudo-event files do not yet exist.

Pseudo = struct();
Pseudo.Available = false;
Pseudo.Y = [];
Pseudo.SourceFile = "";
Pseudo.NValidRows = 0;

if cfg.pseudo.run && cfg.pseudo.useLegacySingleRealizationControl && strlength(string(files.pseudoLong)) > 0 && exist(files.pseudoLong, 'file') == 2
    fprintf('Loading legacy single-realization pseudo-event waveform long table...\n');
    TpseudoLong = readtable(files.pseudoLong, 'TextType', 'string');
    validate_required_columns(TpseudoLong, {'Subject','ClinicalStage','Channel','TimeMs','Waveform_uV'}, 'Rest_PseudoEvent_ChannelWaveforms_Long.csv');
    TpseudoLong.Subject = string(TpseudoLong.Subject);
    TpseudoLong.ClinicalStage = string(TpseudoLong.ClinicalStage);
    TpseudoLong.Channel = string(TpseudoLong.Channel);
    TpseudoLong.TimeMs = double(TpseudoLong.TimeMs);
    TpseudoLong.Waveform_uV = double(TpseudoLong.Waveform_uV);
    [spIdx, cpIdx, tpIdx] = pseudo_waveform_indices(TpseudoLong, subjects, channels, timeMs);
    validPseudoRows = spIdx > 0 & cpIdx > 0 & tpIdx > 0 & isfinite(TpseudoLong.Waveform_uV);

    if any(validPseudoRows)
        Ypseudo = nan(nS, nCh, nT);
        linPseudoIdx = sub2ind([nS nCh nT], spIdx(validPseudoRows), cpIdx(validPseudoRows), tpIdx(validPseudoRows));
        Ypseudo(linPseudoIdx) = TpseudoLong.Waveform_uV(validPseudoRows);
        Pseudo.Available = true;
        Pseudo.Y = Ypseudo;
        Pseudo.SourceFile = string(files.pseudoLong);
        Pseudo.NValidRows = sum(validPseudoRows);
        fprintf('Pseudo-event array dimensions: %d subjects x %d channels x %d time points. Valid rows: %d.\n', nS, nCh, nT, Pseudo.NValidRows);
    else
        fprintf('Legacy single-realization pseudo-event waveform file was found, but no rows matched the R-locked subject/channel/time grid. Legacy pseudo-event control will be skipped.\n');
    end
else
    fprintf('Legacy single-realization pseudo-event waveform loading is disabled or the file was not found. Monte Carlo pseudo-event control will be handled from the continuous resting files.\n');
end

%% ======================
%  4. Merge covariates, HRV, QC
%  =======================

fprintf('Merging subject-level metrics/covariates...\n');
Tsub = subjectInfo;
Tsub = left_join_by_subject(Tsub, Tmetrics);
Tsub.Subject = subjects;
Tsub.ClinicalStage = categorical(stage, cfg.stageOrder, 'Ordinal', true);
Tsub.RiskGradient = double(riskGradient);
Tsub.BDMoodState_Depressed = nan(height(Tsub), 1);
bdMoodMask = ismember(string(Tsub.ClinicalStage), ["BD_Euthymic" "BD_Depressed"]);
Tsub.BDMoodState_Depressed(bdMoodMask) = double(string(Tsub.ClinicalStage(bdMoodMask)) == "BD_Depressed");

if ~ismember('CigsPerDay', Tsub.Properties.VariableNames)
    Tsub.CigsPerDay = nan(height(Tsub), 1);
end

% Make sure key covariates are numeric even when imported as strings/cells.

numVarsToCoerce = {'Age', 'Sex', 'CigsPerDay', 'Rest_MeanHR_BPM', 'Rest_lnRMSSD', 'Rest_QCReviewFlag', 'MADRS', 'YMRS', 'GAF', 'MedBurden'};

for v = 1:numel(numVarsToCoerce)
    vn = numVarsToCoerce{v};
    if ismember(vn, Tsub.Properties.VariableNames)
        Tsub.(vn) = to_double_column(Tsub.(vn));
    end
end

if ~ismember('MedBurden', Tsub.Properties.VariableNames)
    meds = zeros(height(Tsub), 1);
    medVars = {'AD', 'AP', 'MS', 'ANX', 'Other'};
    hasAnyMed = false(height(Tsub), 1);

    for m = 1: numel(medVars)
        if ismember(medVars{m}, Tsub.Properties.VariableNames)
            x = to_double_column(Tsub.(medVars{m}));
            meds = meds + replace_nan_with_zero(x);
            hasAnyMed = hasAnyMed | isfinite(x);
        end
    end

    meds(~hasAnyMed) = NaN;
    Tsub.MedBurden = meds;
end

%% ==================================
%  5. Window maps, GFP, templates, field scores
%  ===================================

fprintf('Computing window-averaged scalp maps and topographic scores...\n');

Maps = struct();
Maps.CFA = window_average_map(Y, timeMs, cfg.win.CFA_ms);
Maps.Early = window_average_map(Y, timeMs, cfg.win.Early_ms);
Maps.Late = window_average_map(Y, timeMs, cfg.win.Late_ms);
Maps.RLocked100to200 = window_average_map(Y, timeMs, cfg.win.RLocked100to200_ms);
Maps.LateTail = window_average_map(Y, timeMs, cfg.win.LateTail_ms);

if cfg.template.centerMapsAcrossChannels
    Maps.CFA_centered = center_rows(Maps.CFA);
    Maps.Early_centered = center_rows(Maps.Early);
    Maps.Late_centered = center_rows(Maps.Late);
    Maps.RLocked100to200_centered = center_rows(Maps.RLocked100to200);
    Maps.LateTail_centered = center_rows(Maps.LateTail);
else
    Maps.CFA_centered = Maps.CFA;
    Maps.Early_centered = Maps.Early;
    Maps.Late_centered = Maps.Late;
    Maps.RLocked100to200_centered = Maps.RLocked100to200;
    Maps.LateTail_centered = Maps.LateTail;
end

% Subject-level global field power for each window

Tsub.CFA_GFP_uV = row_gfp(Maps.CFA);
Tsub.EarlyGFP_200to300_uV = row_gfp(Maps.Early);
Tsub.LateGFP_300to400_uV = row_gfp(Maps.Late);
Tsub.RLocked100to200_GFP_uV = row_gfp(Maps.RLocked100to200);

% Time-resolved GFP by subject, used in Figure 1

GFP = time_resolved_gfp(Y);

% Group-blind pooled templates and leave-one-subject-out scores

Templates = build_templates_and_scores(Maps, Tsub, cfg);

Tsub.CFAScore_LOSO_uV = Templates.scores.CFA;
Tsub.EarlyFieldScore_LOSO_uV = Templates.scores.Early;
Tsub.LateFieldScore_LOSO_uV = Templates.scores.Late;
Tsub.RLocked100to200FieldScore_LOSO_uV = Templates.scores.RLocked100to200;
Tsub.RLocked100to200_CFA_MapCorr = rowwise_corr(Maps.RLocked100to200_centered, Maps.CFA_centered);
Tsub.Early_CFA_MapCorr = rowwise_corr(Maps.Early_centered, Maps.CFA_centered);
Tsub.Late_CFA_MapCorr = rowwise_corr(Maps.Late_centered, Maps.CFA_centered);
Tsub.NChannels_FieldScore = sum(isfinite(Maps.RLocked100to200_centered), 2);

% Orient score signs after LOSO template construction. The primary score is oriented so the HC mean is positive; this fixes the arbitrary
% template sign for interpretation and tables without changing any p-values. Positive primary scores indicate stronger expression of the
% group-blind, CFA-orthogonalized 100-200 ms field in the HC-positive orientation, not positive voltage at a specific electrode.

hcMask = string(Tsub.ClinicalStage) == "HC";

if cfg.template.orientPrimaryScorePositiveInHC
    if mean(Tsub.RLocked100to200FieldScore_LOSO_uV(hcMask), 'omitnan') < 0
        Tsub.RLocked100to200FieldScore_LOSO_uV = -Tsub.RLocked100to200FieldScore_LOSO_uV;
        Templates.weights.RLocked100to200 = -Templates.weights.RLocked100to200;
        Templates.weights.RLocked100to200LOSO = -Templates.weights.RLocked100to200LOSO;
    end
end

if cfg.template.orientEarlyScorePositiveInHC
    if mean(Tsub.EarlyFieldScore_LOSO_uV(hcMask), 'omitnan') < 0
        Tsub.EarlyFieldScore_LOSO_uV = -Tsub.EarlyFieldScore_LOSO_uV;
        Templates.weights.Early = -Templates.weights.Early;
        Templates.weights.EarlyLOSO = -Templates.weights.EarlyLOSO;
    end
end

Tsub.RLocked100to200FieldScore_SignConvention = repmat(string(cfg.template.primaryScoreSignConvention), height(Tsub), 1);
Templates.diagnostics.RLocked100to200FieldScore_SignConvention = string(cfg.template.primaryScoreSignConvention);

if cfg.pseudo.useLegacySingleRealizationControl && isfield(Pseudo, 'Available') && Pseudo.Available
    [Tsub, Pseudo] = add_pseudo_event_control_scores(Tsub, Pseudo, timeMs, cfg, Templates);
end

% Add enhanced subject-level QC summaries before exporting the subject table.
% These flags are used for sensitivity analyses, not for automatic primary exclusion.

Tsub = add_enhanced_qc_metrics(Tsub, Tdiag, Tendpoints, cfg);
writetable(build_qc_subject_flag_table(Tsub), fullfile(cfg.qcDir, 'Table_QC_EnhancedSubjectFlags.csv'));

% Save field-score table and template weights

TemplateWeights = build_template_weight_table(channels, locs, Templates, Maps, Tsub);
TemplateReliability = compute_template_reliability_diagnostics(Maps, Tsub, Templates, channels, cfg);
TsubOut = make_paper_facing_table(Tsub, true);
writetable(TsubOut, fullfile(cfg.tblDir, 'Table_FieldScores_BySubject.csv'));
writetable(make_paper_facing_table(TemplateWeights, false), fullfile(cfg.tblDir, 'Table_TopographicTemplateWeights.csv'));
writetable(make_paper_facing_table(TemplateReliability.Summary, false), fullfile(cfg.tblDir, 'Table_TemplateReliability_Summary.csv'));
writetable(make_paper_facing_table(TemplateReliability.ChannelBootstrap, false), fullfile(cfg.tblDir, 'Table_TemplateReliability_ChannelBootstrap.csv'));
writetable(make_paper_facing_table(TemplateReliability.SubjectScoreBootstrap, false), fullfile(cfg.tblDir, 'Table_TemplateReliability_SubjectScoreBootstrap.csv'));
save(fullfile(cfg.matDir, 'RLocked_FieldScores_Templates.mat'), 'cfg', 'Tsub', 'Maps', 'Templates', 'TemplateReliability', 'Pseudo', 'channels', 'locs', 'timeMs', 'GFP', '-v7.3');

%% =======================================
%  6. Primary, secondary, sensitivity, exploratory models
%  ========================================

fprintf('Running revised clinical-stage primary/secondary/sensitivity models...\n');

ModelRows = table();
Primary100Rows = table();
PrimaryContrastRows = table();
PseudoRows = table();
PseudoMC = struct();
PseudoMCDetailRows = table();
PseudoMCSubjectScores = table();
PseudoMCSubjectScoreSummary = table();

primaryOutcome = 'RLocked100to200FieldScore_LOSO_uV';
plannedContrasts = planned_clinicalstage_contrasts();
keySensitivityContrasts = ["BD_Depressed_vs_HC" "BD_Depressed_vs_BD_Euthymic" "BD_Depressed_vs_Siblings"];

% Revised primary family: ClinicalStage omnibus plus planned contrasts.

res = run_clinicalstage_omnibus(Tsub, primaryOutcome, cfg.model.baseCovariates, cfg.model.nPermutationsPrimary, cfg.model.randomSeed, cfg.stageOrder);
res.AnalysisTier = "PrimaryClinicalStageOmnibus";
res.Family = "PrimaryClinicalStage";
res.Contrast = "ClinicalStageOmnibus";
res.EndpointLabel = "Primary 100-200 ms distributed field score, four-level ClinicalStage omnibus";
ModelRows = append_rows(ModelRows, res);
Primary100Rows = append_rows(Primary100Rows, res);

for c = 1: height(plannedContrasts)
    w = plannedContrasts{c, {'Weight_HC','Weight_Siblings','Weight_BD_Euthymic','Weight_BD_Depressed'}};
    res = run_clinicalstage_contrast(Tsub, primaryOutcome, string(plannedContrasts.Name(c)), string(plannedContrasts.Label(c)), w, cfg.model.baseCovariates, cfg.model.nPermutationsPrimary, cfg.model.randomSeed + 10 + c, cfg.stageOrder);
    res.AnalysisTier = "PrimaryPlannedContrast";
    res.Family = "PrimaryClinicalStagePlannedContrasts";
    res.EndpointLabel = "Primary 100-200 ms distributed field score, planned ClinicalStage contrast";
    PrimaryContrastRows = append_rows(PrimaryContrastRows, res);
end

if ~isempty(PrimaryContrastRows)
    PrimaryContrastRows.HolmP = holm_adjust(PrimaryContrastRows.PermutationP);
    PrimaryContrastRows.HolmReject = PrimaryContrastRows.HolmP < cfg.model.alpha;
end

ModelRows = append_rows(ModelRows, PrimaryContrastRows);
Primary100Rows = append_rows(Primary100Rows, PrimaryContrastRows);

% Supportive trend test: retained for continuity, but no longer the primary biological claim.

res = run_ols_freedman_lane(Tsub, primaryOutcome, 'RiskGradient', cfg.model.baseCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 30);
res.AnalysisTier = "SupportiveOrdinalTrend";
res.Family = "OrdinalClinicalStageTrend";
res.Contrast = "HC_to_Siblings_to_BD_Euthymic_to_BD_Depressed";
res.EndpointLabel = "Supportive ordinal clinical-stage trend for the primary 100-200 ms field score";
ModelRows = append_rows(ModelRows, res);
Primary100Rows = append_rows(Primary100Rows, res);

% Primary artifact/physiology sensitivities for the revised primary effect.

sensSeed = cfg.model.randomSeed + 100;
SensitivityRows = table();
SensitivityRows = append_rows(SensitivityRows, run_primary_sensitivity_set(Tsub, primaryOutcome, [cfg.model.baseCovariates {'CFAScore_LOSO_uV'}], cfg.model.nPermutationsSensitivity, sensSeed + 1, cfg, plannedContrasts, keySensitivityContrasts, "PrimarySensitivity", "ArtifactControl", "Adjusted for peri-R CFA score", "CFA_adjustment"));

if ismember('Rest_MeanHR_BPM', Tsub.Properties.VariableNames)
    SensitivityRows = append_rows(SensitivityRows, run_primary_sensitivity_set(Tsub, primaryOutcome, [cfg.model.baseCovariates {'Rest_MeanHR_BPM'}], cfg.model.nPermutationsSensitivity, sensSeed + 10, cfg, plannedContrasts, keySensitivityContrasts, "PrimarySensitivity", "PhysiologyControl", "Adjusted for mean heart rate", "MeanHR_adjustment"));
end

if ismember('Rest_lnRMSSD', Tsub.Properties.VariableNames)
    SensitivityRows = append_rows(SensitivityRows, run_primary_sensitivity_set(Tsub, primaryOutcome, [cfg.model.baseCovariates {'Rest_lnRMSSD'}], cfg.model.nPermutationsSensitivity, sensSeed + 20, cfg, plannedContrasts, keySensitivityContrasts, "PrimarySensitivity", "PhysiologyControl", "Adjusted for lnRMSSD", "lnRMSSD_adjustment"));
end

if ismember('CigsPerDay', Tsub.Properties.VariableNames)
    smokingVals = to_double_column(Tsub.CigsPerDay);
    smokingVals = smokingVals(isfinite(smokingVals));

    if numel(smokingVals) >= 10 && numel(unique(smokingVals)) >= 2
        SensitivityRows = append_rows(SensitivityRows, run_primary_sensitivity_set(Tsub, primaryOutcome, [cfg.model.baseCovariates {'CigsPerDay'}], cfg.model.nPermutationsSensitivity, sensSeed + 30, cfg, plannedContrasts, keySensitivityContrasts, "PostHocSensitivity", "SmokingControl", "Post hoc adjustment for cigarettes per day", "CigsPerDay_adjustment"));
    end
end

ModelRows = append_rows(ModelRows, SensitivityRows);
Primary100Rows = append_rows(Primary100Rows, SensitivityRows);

% QC-exclusion sensitivity models are intentionally not run in this manuscript script.
% Enhanced QC flags are still exported for audit and possible supplementary reporting.

% Secondary endpoints. These test ClinicalStage omnibus effects. Holm correction is applied across the three secondary endpoint omnibus p-values.
% Adjacent-window planned contrasts are added as sensitivity rows for the 200-300 ms and 300-400 ms distributed field scores.

secondaryRows = table();
secondaryContrastRows = table();
secondaryDefs = table();
secondaryDefs.Endpoint = ["EarlyFieldScore_LOSO_uV"; "LateFieldScore_LOSO_uV"; "EarlyGFP_200to300_uV"];
secondaryDefs.Label = ["CFA-orthogonalized adjacent early post-R distributed field score, 200-300 ms"; "CFA-orthogonalized later post-R distributed field score, 300-400 ms"; "Adjacent early 200-300 ms global field power"];

for s = 1: height(secondaryDefs)
    res = run_clinicalstage_omnibus(Tsub, char(secondaryDefs.Endpoint(s)), cfg.model.baseCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 300 + s, cfg.stageOrder);
    res.AnalysisTier = "Secondary";
    res.Family = "SecondaryClinicalStageOmnibus";
    res.Contrast = "ClinicalStageOmnibus";
    res.EndpointLabel = string(secondaryDefs.Label(s));
    secondaryRows = append_rows(secondaryRows, res);
end

adjacentContrastNames = ["BD_Depressed_vs_HC" "BD_Depressed_vs_BD_Euthymic"];
adjacentDefs = secondaryDefs(1: 2, :);

for s = 1: height(adjacentDefs)
    for c = 1: numel(adjacentContrastNames)
        contrastIdx = find(strcmp(string(plannedContrasts.Name), adjacentContrastNames(c)), 1, 'first');

        if isempty(contrastIdx)
            continue;
        end

        w = plannedContrasts{contrastIdx, {'Weight_HC', 'Weight_Siblings', 'Weight_BD_Euthymic', 'Weight_BD_Depressed'}};
        res = run_clinicalstage_contrast(Tsub, char(adjacentDefs.Endpoint(s)), string(plannedContrasts.Name(contrastIdx)), string(plannedContrasts.Label(contrastIdx)), w, cfg.model.baseCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 320 + s * 10 + c, cfg.stageOrder);
        res.AnalysisTier = "SecondarySensitivity";
        res.Family = "AdjacentWindowPlannedContrasts";
        res.EndpointLabel = string(adjacentDefs.Label(s)) + ", planned contrast sensitivity";
        secondaryContrastRows = append_rows(secondaryContrastRows, res);
    end
end

if ~isempty(secondaryRows)
    secondaryRows.HolmP = holm_adjust(secondaryRows.PermutationP);
    secondaryRows.HolmReject = secondaryRows.HolmP < cfg.model.alpha;
end

if ~isempty(secondaryContrastRows)
    secondaryContrastRows.HolmP = holm_adjust(secondaryContrastRows.PermutationP);
    secondaryContrastRows.HolmReject = secondaryContrastRows.HolmP < cfg.model.alpha;
    secondaryRows = append_rows(secondaryRows, secondaryContrastRows);
end

ModelRows = append_rows(ModelRows, secondaryRows);

% Pseudo-event negative-control models. These test whether the same ClinicalStage pattern appears across many RR-adaptive pseudo-event placements.

pseudoOutcome = 'PseudoRLocked100to200FieldScore_RealTemplateLOSO_uV';

if cfg.pseudo.run && isfield(cfg.pseudo, 'monteCarlo') && cfg.pseudo.monteCarlo.run
    PseudoMC = run_pseudo_event_monte_carlo_control(Tsub, Templates, channels, cfg, plannedContrasts);

    if isfield(PseudoMC, 'SummaryRows')
        PseudoRows = PseudoMC.SummaryRows;
    end

    if isfield(PseudoMC, 'DetailRows')
        PseudoMCDetailRows = PseudoMC.DetailRows;
    end

    if isfield(PseudoMC, 'SubjectScoresLong')
        PseudoMCSubjectScores = PseudoMC.SubjectScoresLong;
    end

    if isfield(PseudoMC, 'SubjectScoreSummary')
        PseudoMCSubjectScoreSummary = PseudoMC.SubjectScoreSummary;
    end

    ModelRows = append_rows(ModelRows, PseudoRows);
elseif cfg.pseudo.useLegacySingleRealizationControl && ismember(pseudoOutcome, Tsub.Properties.VariableNames)
    res = run_clinicalstage_omnibus(Tsub, pseudoOutcome, cfg.model.baseCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 360, cfg.stageOrder);
    res.AnalysisTier = "PseudoEventControl";
    res.Family = "PseudoEventClinicalStage";
    res.Contrast = "ClinicalStageOmnibus";
    res.EndpointLabel = "Legacy single-realization pseudo-event 100-200 ms field score projected onto the real R-locked LOSO template, four-level ClinicalStage omnibus";
    PseudoRows = append_rows(PseudoRows, res);

    for c = 1: height(plannedContrasts)
        w = plannedContrasts{c, {'Weight_HC', 'Weight_Siblings', 'Weight_BD_Euthymic', 'Weight_BD_Depressed'}};
        res = run_clinicalstage_contrast(Tsub, pseudoOutcome, string(plannedContrasts.Name(c)), string(plannedContrasts.Label(c)), w, cfg.model.baseCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 370 + c, cfg.stageOrder);
        res.AnalysisTier = "PseudoEventControl";
        res.Family = "PseudoEventClinicalStagePlannedContrasts";
        res.EndpointLabel = "Legacy single-realization pseudo-event 100-200 ms field score projected onto the real R-locked LOSO template, planned ClinicalStage contrast";
        PseudoRows = append_rows(PseudoRows, res);
    end

    if ~isempty(PseudoRows) && any(strcmp(string(PseudoRows.Family), "PseudoEventClinicalStagePlannedContrasts"))
        PseudoRows.HolmP = nan(height(PseudoRows), 1);
        PseudoRows.HolmReject = false(height(PseudoRows), 1);
        plannedMaskPseudo = strcmp(string(PseudoRows.Family), "PseudoEventClinicalStagePlannedContrasts");
        PseudoRows.HolmP(plannedMaskPseudo) = holm_adjust(PseudoRows.PermutationP(plannedMaskPseudo));
        PseudoRows.HolmReject(plannedMaskPseudo) = PseudoRows.HolmP(plannedMaskPseudo) < cfg.model.alpha;
    end

    ModelRows = append_rows(ModelRows, PseudoRows);
end

% BD-only clinical exploratory models.

BDRows = table();
bdMask = ismember(string(Tsub.ClinicalStage), ["BD_Euthymic" "BD_Depressed"]);
Tbd = Tsub(bdMask, :);
bdPredictors = {'MADRS', 'YMRS', 'GAF', 'MedBurden'};

for p = 1: numel(bdPredictors)
    pred = bdPredictors{p};

    if ismember(pred, Tbd.Properties.VariableNames) && sum(isfinite(to_double_column(Tbd.(pred)))) >= 10
        bdCovariates = cfg.model.baseCovariates;

        if ismember(pred, {'MADRS', 'GAF'}) && ismember('BDMoodState_Depressed', Tbd.Properties.VariableNames)
            bdCovariates = [bdCovariates {'BDMoodState_Depressed'}];
        end

        res = run_ols_freedman_lane(Tbd, primaryOutcome, pred, bdCovariates, cfg.model.nPermutationsSecondary, cfg.model.randomSeed + 400 + p);
        res.AnalysisTier = "ExploratoryBDOnly";
        res.Family = "BDClinical";
        res.Contrast = string(pred);

        if ismember(pred, {'MADRS', 'GAF'})
            res.EndpointLabel = "BD-only association with primary 100-200 ms distributed field score adjusted for BD mood state";
        else
            res.EndpointLabel = "BD-only association with primary 100-200 ms distributed field score";
        end

        BDRows = append_rows(BDRows, res);
    end
end

if ~isempty(BDRows)
    BDRows.FDR_BH_Q = bh_fdr(BDRows.PermutationP);
end

ModelRows = append_rows(ModelRows, BDRows);

% Write model tables

ModelRowsOut = make_paper_facing_table(ModelRows, true);
writetable(ModelRowsOut, fullfile(cfg.tblDir, 'Table_FieldScore_ModelResults.csv'));
table2Mask = ismember(string(ModelRows.AnalysisTier), ["PrimaryClinicalStageOmnibus" "PrimaryPlannedContrast" "SupportiveOrdinalTrend" "PrimarySensitivity" "PostHocSensitivity" "Secondary" "SecondarySensitivity" "PseudoEventControl"]);
writetable(make_paper_facing_table(ModelRows(table2Mask, :), true), fullfile(cfg.tblDir, 'Table2_PrimarySecondarySensitivity_Models.csv'));

if ~isempty(PrimaryContrastRows)
    writetable(make_paper_facing_table(PrimaryContrastRows, true), fullfile(cfg.tblDir, 'Table_PrimaryClinicalStage_PlannedContrasts.csv'));
end

if exist('Primary100Rows', 'var') && ~isempty(Primary100Rows)
    writetable(make_paper_facing_table(Primary100Rows, true), fullfile(cfg.tblDir, 'Table_RLocked100to200_Distributed_Robustness.csv'));
end

if ~isempty(PseudoRows)
    writetable(make_paper_facing_table(PseudoRows, true), fullfile(cfg.tblDir, 'Table_PseudoEvent_Control_Models.csv'));
end

if ~isempty(PseudoMCDetailRows)
    writetable(make_paper_facing_table(PseudoMCDetailRows, true), fullfile(cfg.tblDir, 'Table_PseudoEvent_MonteCarlo_RealizationModels.csv'));
end

if ~isempty(PseudoMCSubjectScores)
    writetable(make_paper_facing_table(PseudoMCSubjectScores, true), fullfile(cfg.tblDir, 'Table_PseudoEvent_MonteCarlo_SubjectScores.csv'));
end

if ~isempty(PseudoMCSubjectScoreSummary)
    writetable(make_paper_facing_table(PseudoMCSubjectScoreSummary, true), fullfile(cfg.tblDir, 'Table_PseudoEvent_MonteCarlo_SubjectScoreSummary.csv'));
end

if isstruct(PseudoMC) && isfield(PseudoMC, 'Available') && PseudoMC.Available
    save(fullfile(cfg.matDir, 'PseudoEvent_MonteCarlo_Control.mat'), 'PseudoMC', '-v7.3');
end

if ~isempty(BDRows)
    writetable(make_paper_facing_table(BDRows, true), fullfile(cfg.tblDir, 'Table_BDOnly_Clinical_Exploratory.csv'));
end

% Copy or regenerate Table 1

if exist(files.sampleCharacteristics, 'file') == 2
    copyfile(files.sampleCharacteristics, fullfile(cfg.tblDir, 'Table1_SampleCharacteristics_ByClinicalStage.csv'));
else
    Tsample = build_sample_characteristics(Tsub, cfg.stageOrder);
    writetable(make_paper_facing_table(Tsample, true), fullfile(cfg.tblDir, 'Table1_SampleCharacteristics_ByClinicalStage.csv'));
end

%% ====================================
%  7. Exploratory channel x time cluster permutation
%  =====================================

Cluster = struct();
Cluster.Table = table();
Cluster.Tmap = [];
Cluster.ClusterMask = [];

if cfg.cluster.run
    fprintf('Running exploratory channel x time cluster permutation (%d permutations)...\n', cfg.cluster.nPermutations);
    try
        Cluster = run_cluster_permutation(Y, Tsub, channels, locs, timeMs, cfg);
        writetable(make_paper_facing_table(Cluster.Table, true), fullfile(cfg.tblDir, 'Table_Exploratory_ChannelTime_ClusterPermutation.csv'));
        save(fullfile(cfg.matDir, 'Exploratory_ChannelTime_ClusterPermutation.mat'), 'Cluster', '-v7.3');
    catch ME
        warning('Cluster permutation failed: %s', ME.message);
        Cluster.Error = ME.message;
        save(fullfile(cfg.matDir, 'Exploratory_ChannelTime_ClusterPermutation_FAILED.mat'), 'Cluster');
    end
end

%% ===========================
%  8. Export manuscript tables to DOCX
%  ============================

if cfg.allTables.makeDocx
    try
        export_all_tables_docx(cfg, Tsub, Tdiag, Tendpoints, Primary100Rows, secondaryRows, BDRows, PseudoRows, TemplateReliability, Cluster);
    catch ME
        warning('All_Tables.docx export failed: %s', ME.message);
    end
end

%% =======
%  9. Figures
%  ========

if cfg.fig.makeFigures
    fprintf('Generating figures...\n');
    make_figure1_hc_topography(Y, GFP, Maps, Tsub, channels, locs, timeMs, cfg);
    make_figure2_group_early_field(Maps, Tsub, ModelRows, channels, locs, cfg);
    make_figure3_cluster_localization(Y, Cluster, Tsub, channels, locs, timeMs, cfg);
    make_figure4_artifact_robustness(Tsub, ModelRows, cfg);

   % make_supplementary_figures(Y, GFP, Maps, Tsub, Tdiag, Tendpoints, Tgroup, channels, locs, timeMs, files, cfg);
end

%%%%%%%%%
% Local functions
%%%%%%%%%

function projectRoot = infer_project_root_standalone(scriptDir, projectRootOverride)

if strlength(string(projectRootOverride)) > 0
    projectRoot = string(projectRootOverride);
    return;
end

scriptDir = string(scriptDir);
[parentPath, leaf] = fileparts(char(scriptDir));

if strcmpi(leaf, 'Scripts')
    projectRoot = string(parentPath);
else
    projectRoot = string(scriptDir);
end

end

function S = build_standalone_metric_settings(cfg)

S = struct();
S.baseDir = char(cfg.baseDir);
S.resultsDir = char(cfg.metricDir);
S.groups = {'BP_I_Depressed', 'BP_II_Depressed', 'BP_I_Euthymic', 'BP_II_Euthymic', 'Siblings', 'HC'};
S.groupOrder = {'HC', 'Siblings', 'BD_Euthymic', 'BD_Depressed'};
S.processedFolderName = 'Processed';
S.restFolderName = '';

% Resting preprocessed files are now stored directly under Subject_X/Processed, not Subject_X/Processed/Rest.

S.hrv = struct();
S.hrv.flagMeanHRLowBpm = 40;
S.hrv.flagMeanHRHighBpm = 180;
S.hrv.flagRRRejectedFrac = 0.30;

S.hep = struct();
S.hep.tmin = -0.20;
S.hep.tmax = 0.60;
S.hep.baseWin = [-0.150 -0.050];
S.hep.hepWin = [0.100 0.200];
S.hep.windowSource = "FixedPredefined100to200ms";
S.hep.windowBoundaryConvention = "start_inclusive_end_exclusive_ms";
S.hep.cfaWin = [-0.025 0.025];
S.hep.minEpochs = 30;
S.hep.epochAbsMax_uV = 70;
S.hep.baseAbsMax_uV = 70;
S.hep.hepWinAbsMax_uV = 70;
S.hep.beatOutlierMAD = 5;
S.hep.minFiniteHEPForOutlierFilter = 10;
S.hep.analysisLowpassHz = 20;
S.hep.analysisLowpassOrder = 4;
S.hep.pseudo = cfg.pseudo;

S.robust = struct();
S.robust.beatRobustOpts = 'bisquare';
S.robust.hepOutlierMAD = 5;
S.robust.minFiniteHEPForOutlierFilter = 10;
S.robust.minSubjectsForModel = 10;
S.robust.minRowsForLME = 20;

S.covarFields = {'Age', 'Sex', 'Gender', 'CigsPerDay', 'GAF', 'MADRS', 'YMRS', 'AD', 'AP', 'MS', 'ANX', 'Other'};

S.ecgset = struct();
S.ecgset.enable = false;
S.ecgset.outputDir = fullfile(cfg.metricDir, 'ECG_Augmented_SET');

S.manualBadMissing = struct();
S.manualBadMissing.outputSuffix = '_BadMissingR.mat';
S.manualBadMissing.defaultWindowSec = 20;
S.manualBadMissing.defaultYHalfRange = [];
S.manualBadMissing.clickToleranceSec = 0.080;
S.manualBadMissing.addBeatSearchWindowSec = 0.120;
S.manualBadMissing.invalidSegmentMinDurationSec = 0.050;
S.manualBadMissing.initialDir = S.baseDir;

S.ecgdet = struct();
S.ecgdet.bandpassHz = [1 20];
S.ecgdet.minPeakDistanceSec = 0.35;
S.ecgdet.envSmoothSec = 0.150;
S.ecgdet.primaryMAD = 3;
S.ecgdet.fallbackMAD = 2;
S.ecgdet.refineWindowSec = 0.05;
S.ecgdet.rawSnapWindowSec = 0.015;
S.ecgdet.lowConfEdgeMarginSec = 0.002;
S.ecgdet.lowConfAmpFrac = 0.08;
S.ecgdet.lowConfCompetingFrac = 0.98;
S.ecgdet.lowConfCompetingAmpFrac = 0.50;
S.ecgdet.forcePolarity = 'negative';

end

function cfg = collect_standalone_resting_metrics_for_jad(cfg)

S = build_standalone_metric_settings(cfg);
outDirs = ensure_analysis_output_dirs(S.resultsDir);

if exist('eeglab', 'file') ~= 2
    error('EEGLAB not found on MATLAB path. Add EEGLAB before running Collect_metrics.');
end

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab('nogui');
close all force;

Subj = discover_subjects(S.baseDir, S.groups, S.processedFolderName, S.restFolderName);

if isempty(Subj)
    error('No processed resting datasets found. Check Data/Group/Subject_X/Processed file structure.');
end

RestMetricSettingsSignature = make_metric_settings_signature("Rest", S.hrv, S.hep, S.robust, S.covarFields);
restMetrics = repmat(init_rest_record_template(), 0, 1);

for i = 1: numel(Subj)
    fprintf('Collecting subject %s (%s)\n', Subj(i).Subject, Subj(i).Group);
    cov = load_covariates(Subj(i).CRFFile, S.covarFields);
    desc = derive_group_descriptors(Subj(i).Group);
    restRec = init_rest_record(Subj(i), cov, desc);
    restShouldCollect = strlength(Subj(i).RestFile) > 0 && exist(Subj(i).RestFile, 'file');

    if restShouldCollect
        restRec.Rest_MetricsSourceSignature = make_subject_source_signature(Subj(i), "Rest");
        restRec.Rest_MetricsSettingsSignature = RestMetricSettingsSignature;
        restRec.Rest_MetricsCollectedAt = current_timestamp_string();
        clear EEG;
        EEG = load_eeg_file(Subj(i).RestFile);

        if ~isempty(EEG)
            restRec = process_rest_subject(EEG, restRec, S.hep, S.hrv, S.robust, S.ecgdet, S.ecgset);
            restRec.Rest_MetricsSourceSignature = make_subject_source_signature(Subj(i), "Rest");
            restRec.Rest_MetricsSettingsSignature = RestMetricSettingsSignature;
            restRec.Rest_MetricsCollectedAt = current_timestamp_string();
            restMetrics(end + 1, 1) = restRec;
        end
    end
end

Trest = struct_array_to_table(restMetrics, init_rest_record_template());
Tall = finalize_subject_table(Trest, S.groupOrder);
Trest = add_resting_review_flags(Trest);
Tall = add_resting_review_flags(Tall);

if ~isempty(Trest)
    TrestSupport = hydrate_metric_table_paths_from_subjects(Trest, Subj);
    export_rest_channel_waveform_support(TrestSupport, S.hep, outDirs.SubjectLevel);

    if isfield(S.hep, 'pseudo') && isfield(S.hep.pseudo, 'run') && S.hep.pseudo.run
        export_pseudo_event_channel_waveform_support(TrestSupport, S.hep, outDirs.SubjectLevel);
    end

    QC_exceptions_restMetrics(Trest, outDirs.QC);
end

Trest = sanitize_analysis_output_table(Trest);
Tall = sanitize_analysis_output_table(Tall);
RLockedWindowSettings = struct();
RLockedWindowSettings.WindowStartSec = S.hep.hepWin(1);
RLockedWindowSettings.WindowEndSec = S.hep.hepWin(2);
RLockedWindowSettings.Method = string(S.hep.windowSource);
RLockedWindowSettings.AnalysisLowpassHz = get_hep_field_default(S.hep, 'analysisLowpassHz', NaN);
RLockedWindowSettings.WindowBoundaryConvention = "start_inclusive_end_exclusive_ms";

save(fullfile(outDirs.SubjectLevel, 'Metrics_SubjectLevel.mat'), 'Trest', 'Tall', 'RLockedWindowSettings');
writetable(Trest, fullfile(outDirs.SubjectLevel, 'Metrics_Resting.csv'));

cfg.inputDir = outDirs.SubjectLevel;
fprintf('Metric collection complete. Downstream input directory set to %s\n', cfg.inputDir);

end

function ensure_dir(p)

if exist(p, 'dir') ~= 7
    mkdir(p);
end

end

function p = find_analysis_file(fileName, cfg, required)

fileName = char(fileName);
if nargin < 3
    required = false;
end

searchDirs = unique_existing_dirs([string(cfg.inputDir); string(cfg.metricDir); string(cfg.outputDir); string(cfg.tblDir); string(cfg.matDir); string(cfg.figDir); string(cfg.analysisRoot); string(pwd)]);

for i = 1: numel(searchDirs)
    candidate = fullfile(char(searchDirs(i)), fileName);
    if exist(candidate, 'file') == 2
        p = candidate;
        return;
    end
end

if required
    searched = strjoin(searchDirs, newline);
    error('Required input file not found: %s\nSearched folders:\n%s\n\nRun Collect_metrics = 1 or set cfg.inputDirOverride to the folder that contains the extracted R-locked exports.', fileName, searched);
else
    p = '';
end
end

function dirs = unique_existing_dirs(dirsIn)

dirsIn = string(dirsIn(:));
keep = false(size(dirsIn));

for i = 1:numel(dirsIn)
    keep(i) = strlength(dirsIn(i)) > 0 && ~ismissing(dirsIn(i)) && exist(char(dirsIn(i)), 'dir') == 7;
end
dirs = unique(dirsIn(keep), 'stable');
end

function validate_required_columns(T, cols, name)

for i = 1: numel(cols)
    if ~ismember(cols{i}, T.Properties.VariableNames)
        error('%s is missing required column: %s', name, cols{i});
    end
end

end

function labels = channel_labels_from_locs(locs)

labels = strings(0, 1);

if isempty(locs)
    return;
end

labels = strings(numel(locs), 1);

for i = 1: numel(locs)
    if isfield(locs(i), 'labels')
        labels(i) = string(locs(i).labels);
    else
        labels(i) = "";
    end
end

labels = labels(strlength(labels) > 0);
end

function locsOut = reorder_chanlocs(locsIn, channels)

labels = channel_labels_from_locs(locsIn);

if isempty(locsIn)
    template = struct('labels', '', 'X', NaN, 'Y', NaN, 'Z', NaN, 'theta', NaN, 'radius', NaN);
else
    template = locsIn(1);
end

locsOut = repmat(template, numel(channels), 1);

for c = 1: numel(channels)
    idx = find(strcmpi(labels, channels(c)), 1, 'first');
    
    if ~isempty(idx)
        locsOut(c) = locsIn(idx);
    else
        % Preserve the ChannelLocs field structure while marking missing geometry

        if isfield(locsOut(c), 'labels')
            locsOut(c).labels = char(channels(c));
        end

        if isfield(locsOut(c), 'X')
            locsOut(c).X = NaN;
        end

        if isfield(locsOut(c), 'Y')
            locsOut(c).Y = NaN;
        end

        if isfield(locsOut(c), 'Z')
            locsOut(c).Z = NaN;
        end

        if isfield(locsOut(c), 'theta')
            locsOut(c).theta = NaN;
        end

        if isfield(locsOut(c), 'radius')
            locsOut(c).radius = NaN;
        end

    end
end
end

function [stageOut, risk] = normalize_stage_and_risk(stageIn, stageOrder, riskValues)

stageOut = strings(size(stageIn));
risk = nan(size(stageIn));

for i = 1: numel(stageIn)
    s = string(stageIn(i));
    s = strrep(s, " ", "_");
    s = strrep(s, "BD Euthymic", "BD_Euthymic");
    s = strrep(s, "BD Depressed", "BD_Depressed");

    if strcmpi(s, "BDEuthymic")
        s = "BD_Euthymic";
    elseif strcmpi(s, "BDDepressed") || strcmpi(s, "BDD")
        s = "BD_Depressed";
    end

    idx = find(strcmpi(s, string(stageOrder)), 1, 'first');
    if isempty(idx)
        stageOut(i) = s;
        risk(i) = NaN;
    else
        stageOut(i) = string(stageOrder{idx});
        risk(i) = riskValues(idx);
    end
end
end

function Tout = left_join_by_subject(Tleft, Tright)

Tout = Tleft;

if isempty(Tright) || ~ismember('Subject', Tright.Properties.VariableNames)
    return;
end

rightSubjects = string(Tright.Subject);
vars = Tright.Properties.VariableNames;
vars = vars(~strcmp(vars, 'Subject'));

for v = 1: numel(vars)
    vn = vars{v};

    if ismember(vn, Tout.Properties.VariableNames)
        continue;
    end

    sample = Tright.(vn);

    if isnumeric(sample) || islogical(sample)
        Tout.(vn) = nan(height(Tout), 1);
    elseif isstring(sample) || iscellstr(sample) || ischar(sample)
        Tout.(vn) = strings(height(Tout), 1);
    elseif iscategorical(sample)
        Tout.(vn) = categorical(strings(height(Tout), 1));
    else
        Tout.(vn) = strings(height(Tout), 1);
    end

    for i = 1: height(Tout)
        idx = find(rightSubjects == string(Tout.Subject(i)), 1, 'first');
        if ~isempty(idx)
            try
                Tout.(vn)(i) = Tright.(vn)(idx);
            catch
                Tout.(vn)(i) = string(Tright.(vn)(idx));
            end
        end
    end
end
end

function x = to_double_column(v)

if isnumeric(v) || islogical(v)
    x = double(v(:));

elseif iscell(v)
    x = nan(numel(v), 1);

    for i = 1:numel(v)
        x(i) = str2double(string(v{i}));
    end

elseif isstring(v) || ischar(v)
    x = str2double(string(v(:)));

elseif iscategorical(v)
    x = str2double(string(v(:)));

else
    try
        x = double(v(:));
    catch
        x = nan(numel(v), 1);
    end
end
end

function x = replace_nan_with_zero(x)

x(~isfinite(x)) = 0;

end

function M = window_average_map(Y, timeMs, winMs)

mask = time_window_mask_ms(timeMs, winMs);

if ~any(mask)
    error('No time points found in window [%g %g] ms.', winMs(1), winMs(2));
end

M = squeeze(mean(Y(:, :, mask), 3, 'omitnan'));
end

function mask = time_window_mask_ms(timeMs, winMs)

% Shared window-boundary convention for all predefined window averages and endpoint exports:
% start inclusive, end exclusive: [window_start, window_end). If no samples fall in that interval, include the end point as a sparse-grid fallback.

timeMs = double(timeMs(:))';
winMs = double(winMs(:))';
winMs = sort(winMs);
mask = timeMs >= winMs(1) & timeMs < winMs(2);

if ~any(mask)
    mask = timeMs >= winMs(1) & timeMs <= winMs(2);
end

end

function Xc = center_rows(X)

rowMean = mean(X, 2, 'omitnan');
Xc = X - rowMean;

end

function g = row_gfp(X)

Xc = center_rows(X);
g = sqrt(mean(Xc.^2, 2, 'omitnan'));

end

function GFP = time_resolved_gfp(Y)

chanMean = mean(Y, 2, 'omitnan');
Yc = Y - chanMean;
GFP = squeeze(sqrt(mean(Yc.^2, 2, 'omitnan')));

end

function r = rowwise_corr(A, B)

r = nan(size(A, 1), 1);

for i = 1:size(A, 1)
    a = A(i, :)'; b = B(i, :)';
    ok = isfinite(a) & isfinite(b);
    if sum(ok) >= 5 && std(a(ok)) > 0 && std(b(ok)) > 0
        r(i) = corr(a(ok), b(ok));
    end
end

end

function Templates = build_templates_and_scores(Maps, Tsub, cfg)

nS = height(Tsub);
nC = size(Maps.Early_centered, 2);

Templates = struct();
Templates.weights = struct();
Templates.scores = struct();
Templates.diagnostics = struct();

% Pooled group-blind templates

pooledCFA = center_vector(mean(Maps.CFA_centered, 1, 'omitnan'));
pooledEarly = center_vector(mean(Maps.Early_centered, 1, 'omitnan'));
pooledLate = center_vector(mean(Maps.Late_centered, 1, 'omitnan'));
pooledRLocked100to200 = center_vector(mean(Maps.RLocked100to200_centered, 1, 'omitnan'));

Templates.raw.CFA = pooledCFA;
Templates.raw.Early = pooledEarly;
Templates.raw.Late = pooledLate;
Templates.raw.RLocked100to200 = pooledRLocked100to200;

Templates.weights.CFA = normalize_weight_vector(pooledCFA, cfg.template.normalizeWeightsByL1);
Templates.weights.Early = make_orthogonal_weight(pooledEarly, pooledCFA, cfg.template.normalizeWeightsByL1);
Templates.weights.Late = make_orthogonal_weight(pooledLate, pooledCFA, cfg.template.normalizeWeightsByL1);
Templates.weights.RLocked100to200 = make_orthogonal_weight(pooledRLocked100to200, pooledCFA, cfg.template.normalizeWeightsByL1);

Templates.diagnostics.PooledEarlyCFA_TopographicR = safe_corr(pooledEarly, pooledCFA);
Templates.diagnostics.PooledLateCFA_TopographicR = safe_corr(pooledLate, pooledCFA);
Templates.diagnostics.PooledRLocked100to200CFA_TopographicR = safe_corr(pooledRLocked100to200, pooledCFA);

% Leave-one-subject-out weights and scores

scoreCFA = nan(nS, 1);
scoreEarly = nan(nS, 1);
scoreLate = nan(nS, 1);
scoreRLocked100to200 = nan(nS, 1);
WEarly = nan(nS, nC);
WLate = nan(nS, nC);
WCFA = nan(nS, nC);
WRLocked100 = nan(nS, nC);

for s = 1: nS

    if cfg.template.useLeaveOneSubjectOut && nS > 2
        idx = setdiff(1:nS, s);
    else
        idx = 1: nS;
    end

    cfa = center_vector(mean(Maps.CFA_centered(idx,:), 1, 'omitnan'));
    early = center_vector(mean(Maps.Early_centered(idx,:), 1, 'omitnan'));
    late = center_vector(mean(Maps.Late_centered(idx,:), 1, 'omitnan'));
    hep100 = center_vector(mean(Maps.RLocked100to200_centered(idx, :), 1, 'omitnan'));
    wCFA = normalize_weight_vector(cfa, cfg.template.normalizeWeightsByL1);
    wEarly = make_orthogonal_weight(early, cfa, cfg.template.normalizeWeightsByL1);
    wLate = make_orthogonal_weight(late, cfa, cfg.template.normalizeWeightsByL1);
    wRLocked100 = make_orthogonal_weight(hep100, cfa, cfg.template.normalizeWeightsByL1);

    % Orient LOSO weights to pooled weights for sign stability

    if safe_dot(wEarly, Templates.weights.Early) < 0
        wEarly = -wEarly;
    end

    if safe_dot(wLate, Templates.weights.Late) < 0
        wLate = -wLate;
    end

    if safe_dot(wRLocked100, Templates.weights.RLocked100to200) < 0
        wRLocked100 = -wRLocked100;
    end

    if safe_dot(wCFA, Templates.weights.CFA) < 0
        wCFA = -wCFA;
    end

    mapCFA = center_vector(Maps.CFA_centered(s, :));
    mapEarly = center_vector(Maps.Early_centered(s, :));
    mapLate = center_vector(Maps.Late_centered(s, :));
    mapRLocked100 = center_vector(Maps.RLocked100to200_centered(s, :));

    scoreCFA(s) = weighted_projection(mapCFA, wCFA);
    scoreEarly(s) = weighted_projection(mapEarly, wEarly);
    scoreLate(s) = weighted_projection(mapLate, wLate);
    scoreRLocked100to200(s) = weighted_projection(mapRLocked100, wRLocked100);

    WCFA(s,:) = wCFA;
    WEarly(s,:) = wEarly;
    WLate(s,:) = wLate;
    WRLocked100(s, :) = wRLocked100;
end

Templates.scores.CFA = scoreCFA;
Templates.scores.Early = scoreEarly;
Templates.scores.Late = scoreLate;
Templates.scores.RLocked100to200 = scoreRLocked100to200;
Templates.weights.CFALOSO = WCFA;
Templates.weights.EarlyLOSO = WEarly;
Templates.weights.LateLOSO = WLate;
Templates.weights.RLocked100to200LOSO = WRLocked100;

end

function v = center_vector(v)

v = double(v(:))';
ok = isfinite(v);

if any(ok)
    v(ok) = v(ok) - mean(v(ok), 'omitnan');
end

end

function w = normalize_weight_vector(v, normalizeByL1)

w = center_vector(v);
ok = isfinite(w);
w(~ok) = 0;

if nargin < 2 || normalizeByL1
    denom = sum(abs(w));
else
    denom = sqrt(sum(w.^2));
end

if isfinite(denom) && denom > eps
    w = w / denom;
else
    w(:) = NaN;
end
end

function w = make_orthogonal_weight(signalTemplate, nuisanceTemplate, normalizeByL1)

s = center_vector(signalTemplate);
n = center_vector(nuisanceTemplate);
ok = isfinite(s) & isfinite(n);
s2 = s;

if sum(ok) >= 5 && sum(n(ok).^2) > eps
    s2(ok) = s(ok) - (sum(s(ok).*n(ok)) / sum(n(ok).^2)) * n(ok);
end

w = normalize_weight_vector(s2, normalizeByL1);
end

function d = safe_dot(a,b)

a = a(:); b = b(:); ok = isfinite(a) & isfinite(b);

if sum(ok) < 2
    d = NaN;
else
    d = sum(a(ok).*b(ok));
end

end

function r = safe_corr(a,b)

a = a(:);
b = b(:); 
ok = isfinite(a) & isfinite(b);

if sum(ok) < 5 || std(a(ok)) == 0 || std(b(ok)) == 0
    r = NaN;
else
    r = corr(a(ok), b(ok));
end

end

function s = weighted_projection(map, w)

map = map(:)';
w = w(:)';
ok = isfinite(map) & isfinite(w);

if sum(ok) < 5
    s = NaN;
else
    s = sum(map(ok).*w(ok));
end

end

function TT = build_template_weight_table(channels, locs, Templates, Maps, Tsub)

nC = numel(channels);
TT = table();
TT.Channel = channels(:);
[x,y,z] = locs_xyz(locs);
TT.X = x(:); TT.Y = y(:); TT.Z = z(:);
TT.CFAWeight = Templates.weights.CFA(:);
TT.EarlyOrthWeight = Templates.weights.Early(:);
TT.LateOrthWeight = Templates.weights.Late(:);
TT.RLocked100to200OrthWeight = Templates.weights.RLocked100to200(:);
TT.PooledCFA_Template_uV = Templates.raw.CFA(:);
TT.PooledEarly_Template_uV = Templates.raw.Early(:);
TT.PooledLate_Template_uV = Templates.raw.Late(:);
TT.PooledRLocked100to200_Template_uV = Templates.raw.RLocked100to200(:);
TT.HC_EarlyMean_uV = mean(Maps.Early_centered(string(Tsub.ClinicalStage) == "HC", :), 1, 'omitnan')';
TT.HC_RLocked100to200Mean_uV = mean(Maps.RLocked100to200_centered(string(Tsub.ClinicalStage) == "HC", :), 1, 'omitnan')';
TT.HC_CFA_Mean_uV = mean(Maps.CFA_centered(string(Tsub.ClinicalStage) == "HC", :), 1, 'omitnan')';

if height(TT) ~= nC
    error('Template weight table channel mismatch.');
end
end

function Reliability = compute_template_reliability_diagnostics(Maps, Tsub, Templates, channels, cfg)

nS = height(Tsub);
nC = size(Maps.RLocked100to200_centered, 2);
nBoot = max(0, round(cfg.template.nBootstrapReliability));
nSplit = max(0, round(cfg.template.nSplitHalfReliability));
rng(cfg.template.reliabilitySeed, 'twister');

pooledWeight = Templates.weights.RLocked100to200(:)';
losoWeights = Templates.weights.RLocked100to200LOSO;
losoCorr = nan(nS, 1);

for s = 1: nS
    losoCorr(s) = safe_corr(losoWeights(s, :), pooledWeight);
end

bootWeights = nan(nBoot, nC);
bootWeightCorr = nan(nBoot, 1);
bootScores = nan(nS, nBoot);
subjectMaps = Maps.RLocked100to200_centered;

for b = 1: nBoot
    idx = randi(nS, nS, 1);
    cfa = center_vector(mean(Maps.CFA_centered(idx, :), 1, 'omitnan'));
    sig = center_vector(mean(Maps.RLocked100to200_centered(idx, :), 1, 'omitnan'));
    w = make_orthogonal_weight(sig, cfa, cfg.template.normalizeWeightsByL1);

    if safe_dot(w, pooledWeight) < 0
        w = -w;
    end

    bootWeights(b, :) = w;
    bootWeightCorr(b, 1) = safe_corr(w, pooledWeight);

    for s = 1:nS
        bootScores(s, b) = weighted_projection(center_vector(subjectMaps(s, :)), w);
    end
end

splitCorr = nan(nSplit, 1);
splitCorrToPooledA = nan(nSplit, 1);
splitCorrToPooledB = nan(nSplit, 1);

for r = 1: nSplit
    idx = randperm(nS);
    nA = floor(nS / 2);
    idxA = idx(1: nA);
    idxB = idx((nA + 1): end);
    wA = primary_weight_from_subject_indices(Maps, idxA, cfg);
    wB = primary_weight_from_subject_indices(Maps, idxB, cfg);

    if safe_dot(wA, pooledWeight) < 0
        wA = -wA;
    end

    if safe_dot(wB, pooledWeight) < 0
        wB = -wB;
    end

    splitCorr(r, 1) = safe_corr(wA, wB);
    splitCorrToPooledA(r, 1) = safe_corr(wA, pooledWeight);
    splitCorrToPooledB(r, 1) = safe_corr(wB, pooledWeight);
end

Reliability = struct();
Reliability.Summary = table();
Reliability.Summary.Metric = ["LOSO_weight_corr_with_pooled_mean"; "LOSO_weight_corr_with_pooled_sd"; "LOSO_weight_corr_with_pooled_min"; "Bootstrap_weight_corr_with_pooled_mean"; "Bootstrap_weight_corr_with_pooled_sd"; "Bootstrap_weight_corr_with_pooled_CI95_low"; "Bootstrap_weight_corr_with_pooled_CI95_high"; "SplitHalf_weight_corr_between_halves_mean"; "SplitHalf_weight_corr_between_halves_sd"; "SplitHalf_weight_corr_between_halves_CI95_low"; "SplitHalf_weight_corr_between_halves_CI95_high"; "SplitHalf_halfA_corr_with_pooled_mean"; "SplitHalf_halfB_corr_with_pooled_mean"];
Reliability.Summary.Value = [mean(losoCorr, 'omitnan'); std(losoCorr, 0, 'omitnan'); min(losoCorr, [], 'omitnan'); mean(bootWeightCorr, 'omitnan'); std(bootWeightCorr, 0, 'omitnan'); percentile_omitnan(bootWeightCorr, 2.5); percentile_omitnan(bootWeightCorr, 97.5); mean(splitCorr, 'omitnan'); std(splitCorr, 0, 'omitnan'); percentile_omitnan(splitCorr, 2.5); percentile_omitnan(splitCorr, 97.5); mean(splitCorrToPooledA, 'omitnan'); mean(splitCorrToPooledB, 'omitnan')];
Reliability.ChannelBootstrap = table();
Reliability.ChannelBootstrap.Channel = channels(:);
Reliability.ChannelBootstrap.PooledWeight = pooledWeight(:);
Reliability.ChannelBootstrap.BootstrapMeanWeight = mean(bootWeights, 1, 'omitnan')';
Reliability.ChannelBootstrap.BootstrapSDWeight = std(bootWeights, 0, 1, 'omitnan')';
Reliability.ChannelBootstrap.BootstrapCI95Low = col_percentile_omitnan(bootWeights, 2.5)';
Reliability.ChannelBootstrap.BootstrapCI95High = col_percentile_omitnan(bootWeights, 97.5)';
Reliability.SubjectScoreBootstrap = table();
Reliability.SubjectScoreBootstrap.Subject = string(Tsub.Subject(:));
Reliability.SubjectScoreBootstrap.ClinicalStage = string(Tsub.ClinicalStage(:));
Reliability.SubjectScoreBootstrap.FieldScore_LOSO_uV = Tsub.RLocked100to200FieldScore_LOSO_uV(:);
Reliability.SubjectScoreBootstrap.BootstrapMeanScore_uV = mean(bootScores, 2, 'omitnan');
Reliability.SubjectScoreBootstrap.BootstrapSDScore_uV = std(bootScores, 0, 2, 'omitnan');
Reliability.SubjectScoreBootstrap.BootstrapCI95Low_uV = row_percentile_omitnan(bootScores, 2.5);
Reliability.SubjectScoreBootstrap.BootstrapCI95High_uV = row_percentile_omitnan(bootScores, 97.5);

end

function w = primary_weight_from_subject_indices(Maps, idx, cfg)

cfa = center_vector(mean(Maps.CFA_centered(idx, :), 1, 'omitnan'));
sig = center_vector(mean(Maps.RLocked100to200_centered(idx, :), 1, 'omitnan'));
w = make_orthogonal_weight(sig, cfa, cfg.template.normalizeWeightsByL1);

end

function q = percentile_omitnan(x, pct)

x = double(x(:));
x = x(isfinite(x));

if isempty(x)
    q = NaN;
else
    q = prctile(x, pct);
end

end

function q = col_percentile_omitnan(X, pct)

q = nan(1, size(X, 2));

for c = 1:size(X, 2)
    q(1, c) = percentile_omitnan(X(:, c), pct);
end

end

function q = row_percentile_omitnan(X, pct)

q = nan(size(X, 1), 1);

for r = 1: size(X, 1)
    q(r, 1) = percentile_omitnan(X(r, :), pct);
end

end

function [spIdx, cpIdx, tpIdx] = pseudo_waveform_indices(TpseudoLong, subjects, channels, timeMs)

[~, spIdx] = ismember(TpseudoLong.Subject, subjects);
[~, cpIdx] = ismember(TpseudoLong.Channel, channels);
[~, tpIdx] = ismember(double(TpseudoLong.TimeMs), timeMs);

end

function [Tsub, Pseudo] = add_pseudo_event_control_scores(Tsub, Pseudo, timeMs, cfg, Templates)

Pseudo.Maps = struct();
Pseudo.Maps.CFA = window_average_map(Pseudo.Y, timeMs, cfg.win.CFA_ms);
Pseudo.Maps.Early = window_average_map(Pseudo.Y, timeMs, cfg.win.Early_ms);
Pseudo.Maps.Late = window_average_map(Pseudo.Y, timeMs, cfg.win.Late_ms);
Pseudo.Maps.RLocked100to200 = window_average_map(Pseudo.Y, timeMs, cfg.win.RLocked100to200_ms);
Pseudo.Maps.LateTail = window_average_map(Pseudo.Y, timeMs, cfg.win.LateTail_ms);

if cfg.template.centerMapsAcrossChannels
    Pseudo.Maps.CFA_centered = center_rows(Pseudo.Maps.CFA);
    Pseudo.Maps.Early_centered = center_rows(Pseudo.Maps.Early);
    Pseudo.Maps.Late_centered = center_rows(Pseudo.Maps.Late);
    Pseudo.Maps.RLocked100to200_centered = center_rows(Pseudo.Maps.RLocked100to200);
    Pseudo.Maps.LateTail_centered = center_rows(Pseudo.Maps.LateTail);
else
    Pseudo.Maps.CFA_centered = Pseudo.Maps.CFA;
    Pseudo.Maps.Early_centered = Pseudo.Maps.Early;
    Pseudo.Maps.Late_centered = Pseudo.Maps.Late;
    Pseudo.Maps.RLocked100to200_centered = Pseudo.Maps.RLocked100to200;
    Pseudo.Maps.LateTail_centered = Pseudo.Maps.LateTail;
end

% Primary pseudo-event negative control: apply the same real R-locked 100-200 ms LOSO template weights to the pseudo-event maps.
% This avoids deriving a separate pseudo-event template and makes the control directly comparable to the true R-locked primary score.

pseudoScores = apply_real_rlocked_template_to_pseudo_maps(Pseudo.Maps.RLocked100to200_centered, Templates);

Tsub.PseudoRLocked100to200_GFP_uV = row_gfp(Pseudo.Maps.RLocked100to200);
Tsub.PseudoRLocked100to200FieldScore_RealTemplateLOSO_uV = pseudoScores;
Tsub.PseudoRLocked100to200_PseudoCFA_MapCorr = rowwise_corr(Pseudo.Maps.RLocked100to200_centered, Pseudo.Maps.CFA_centered);

Pseudo.TemplateSource = "Real R-locked 100-200 ms LOSO template weights";

if isfield(Templates, 'weights') && isfield(Templates.weights, 'RLocked100to200')
    Pseudo.ReferenceWeights.RLocked100to200 = Templates.weights.RLocked100to200;
end

if isfield(Templates, 'weights') && isfield(Templates.weights, 'RLocked100to200LOSO')
    Pseudo.ReferenceWeights.RLocked100to200LOSO = Templates.weights.RLocked100to200LOSO;
end

end

function scores = apply_real_rlocked_template_to_pseudo_maps(pseudoMapsCentered, Templates)

nS = size(pseudoMapsCentered, 1);
scores = nan(nS, 1);

if ~isfield(Templates, 'weights')
    return;
end

useLOSO = isfield(Templates.weights, 'RLocked100to200LOSO') && size(Templates.weights.RLocked100to200LOSO, 1) == nS && size(Templates.weights.RLocked100to200LOSO, 2) == size(pseudoMapsCentered, 2);
usePooled = isfield(Templates.weights, 'RLocked100to200') && numel(Templates.weights.RLocked100to200) == size(pseudoMapsCentered, 2);

for s = 1: nS

    mapS = center_vector(pseudoMapsCentered(s, :));

    if useLOSO
        w = center_vector(Templates.weights.RLocked100to200LOSO(s, :));
    elseif usePooled
        w = center_vector(Templates.weights.RLocked100to200(:)');
    else
        w = nan(1, size(pseudoMapsCentered, 2));
    end

    scores(s) = weighted_projection(mapS, w);
end

end

function poolObj = ensure_parallel_pool(nWorkers)

poolObj = [];
nWorkers = max(1, round(nWorkers));

if exist('parpool', 'file') ~= 2
    warning('Parallel Computing Toolbox function parpool was not found. Continuing serially.');
    return;
end

try
    poolObj = gcp('nocreate');

    if isempty(poolObj)
        poolObj = parpool('local', nWorkers);
    elseif poolObj.NumWorkers ~= nWorkers
        fprintf('Existing parallel pool has %d workers; requested %d workers. Reusing the existing pool.\n', poolObj.NumWorkers, nWorkers);
    end
catch ME
    warning('Could not start or access a parallel pool: %s. Continuing serially.', ME.message);
    poolObj = [];
end

end

function PseudoMC = run_pseudo_event_monte_carlo_control(Tsub, Templates, channels, cfg, plannedContrasts)

PseudoMC = struct();
PseudoMC.Available = false;
PseudoMC.DetailRows = table();
PseudoMC.SummaryRows = table();
PseudoMC.SubjectScoresLong = table();
PseudoMC.SubjectScoreSummary = table();
PseudoMC.SubjectStatus = table();
PseudoMC.Settings = struct();

if ~isfield(cfg, 'pseudo') || ~isfield(cfg.pseudo, 'monteCarlo') || ~cfg.pseudo.monteCarlo.run
    return;
end

mc = cfg.pseudo.monteCarlo;
nRealizations = max(1, round(get_pseudo_field_default(mc, 'nRealizations', 1000)));
nModelPermutations = max(0, round(get_pseudo_field_default(mc, 'nModelPermutations', 5000)));
baseSeed = round(get_pseudo_field_default(mc, 'randomSeed', cfg.pseudo.randomSeed + 90000));
writeCheckpoint = isfield(mc, 'writeCheckpoint') && logical(mc.writeCheckpoint);
checkpointEverySubjects = max(1, round(get_pseudo_field_default(mc, 'checkpointEverySubjects', 5)));
useParallel = isfield(mc, 'useParallel') && logical(mc.useParallel);
nWorkers = max(1, round(get_pseudo_field_default(mc, 'nWorkers', 8)));

if useParallel
    poolObj = ensure_parallel_pool(nWorkers);
    useParallel = ~isempty(poolObj);
else
    poolObj = [];
end

PseudoMC.Settings.NRealizations = nRealizations;
PseudoMC.Settings.NModelPermutations = nModelPermutations;
PseudoMC.Settings.RandomSeed = baseSeed;
PseudoMC.Settings.UseParallel = useParallel;
PseudoMC.Settings.NWorkersRequested = nWorkers;

if ~isempty(poolObj)
    PseudoMC.Settings.NWorkersActual = poolObj.NumWorkers;
else
    PseudoMC.Settings.NWorkersActual = 0;
end

PseudoMC.Settings.TemplateSource = "Real R-locked 100-200 ms LOSO template weights";
PseudoMC.Settings.Endpoint = "Pseudo-event 100-200 ms field score projected onto real R-locked LOSO template weights";

fprintf('Running Monte Carlo pseudo-event control: %d pseudo-event realizations, %d model permutations per realization. Parallel = %d, workers = %d.\n', nRealizations, nModelPermutations, useParallel, PseudoMC.Settings.NWorkersActual);

S = build_standalone_metric_settings(cfg);
hep = S.hep;
nS = height(Tsub);
Scores = nan(nS, nRealizations);
PseudoGFP = nan(nS, nRealizations);
NPseudoEvents = nan(nS, nRealizations);
StatusRows = table();

if useParallel
    SubjectResults = cell(nS, 1);

    parfor i = 1:nS
        SubjectResults{i} = compute_pseudo_mc_subject_result(i, Tsub, Templates, channels, cfg, hep, nRealizations, baseSeed);
    end

    for i = 1:nS
        result = SubjectResults{i};
        Scores(i, :) = result.Scores;
        PseudoGFP(i, :) = result.PseudoGFP;
        NPseudoEvents(i, :) = result.NPseudoEvents;
        StatusRows = append_rows(StatusRows, result.StatusRow);
    end

    if writeCheckpoint
        checkpointFile = fullfile(cfg.matDir, 'PseudoEvent_MonteCarlo_Checkpoint.mat');
        checkpointSubjectIndex = nS;
        save(checkpointFile, 'Scores', 'PseudoGFP', 'NPseudoEvents', 'StatusRows', 'checkpointSubjectIndex', 'cfg', '-v7.3');
    end
else
    for i = 1:nS
        result = compute_pseudo_mc_subject_result(i, Tsub, Templates, channels, cfg, hep, nRealizations, baseSeed);
        Scores(i, :) = result.Scores;
        PseudoGFP(i, :) = result.PseudoGFP;
        NPseudoEvents(i, :) = result.NPseudoEvents;
        StatusRows = append_rows(StatusRows, result.StatusRow);

        if writeCheckpoint && (mod(i, checkpointEverySubjects) == 0 || i == nS)
            checkpointFile = fullfile(cfg.matDir, 'PseudoEvent_MonteCarlo_Checkpoint.mat');
            checkpointSubjectIndex = i;
            save(checkpointFile, 'Scores', 'PseudoGFP', 'NPseudoEvents', 'StatusRows', 'checkpointSubjectIndex', 'cfg', '-v7.3');
        end
    end
end

PseudoMC.Available = any(isfinite(Scores(:)));
PseudoMC.Scores = Scores;
PseudoMC.GFP = PseudoGFP;
PseudoMC.NPseudoEvents = NPseudoEvents;
PseudoMC.SubjectStatus = StatusRows;
PseudoMC.SubjectScoresLong = build_pseudo_mc_subject_score_long_table(Tsub, Scores, PseudoGFP, NPseudoEvents, cfg);
PseudoMC.SubjectScoreSummary = build_pseudo_mc_subject_score_summary(Tsub, Scores, PseudoGFP, NPseudoEvents);
PseudoMC.DetailRows = run_pseudo_mc_model_rows(Tsub, Scores, cfg, plannedContrasts, nModelPermutations, baseSeed);
PseudoMC.SummaryRows = summarize_pseudo_mc_model_rows(PseudoMC.DetailRows, cfg, nRealizations, nModelPermutations, baseSeed);

fprintf('Monte Carlo pseudo-event control complete: %d/%d subject-realization scores were finite.\n', sum(isfinite(Scores(:))), numel(Scores));

end

function result = compute_pseudo_mc_subject_result(i, Tsub, Templates, channels, cfg, hep, nRealizations, baseSeed)

scores = nan(1, nRealizations);
pseudoGFPVec = nan(1, nRealizations);
nPseudoEventsVec = nan(1, nRealizations);
subject = string(Tsub.Subject(i));
stageLabel = string(Tsub.ClinicalStage(i));
restFile = resolve_rest_file_for_tsub_subject(Tsub, i, cfg);
subjectStatus = "not_started";
warningText = "";
nFiniteScores = 0;
nFiniteChannelsLast = NaN;

fprintf('Monte Carlo pseudo-events: subject %d/%d, %s.\n', i, height(Tsub), subject);

if strlength(restFile) == 0 || exist(restFile, 'file') ~= 2
    subjectStatus = "missing_rest_file";
else
    try
        EEG = load_eeg_file(restFile);

        if isempty(EEG)
            subjectStatus = "could_not_load_rest_file";
        else
            ch = identify_channels(EEG, {}, true);
            [EEG, ~] = apply_rest_analysis_lowpass_filter(EEG, ch.eegIdx, hep);

            if isempty(ch.eegIdx)
                subjectStatus = "missing_scalp_eeg_channels";
            else
                chIdxOrdered = map_analysis_channels_to_eeg_indices(EEG, ch.eegIdx, channels);
                [goodRSamp, statusAnn, ann] = get_good_rest_rpeaks_from_manual_sidecar(restFile, EEG);

                if strlength(statusAnn) > 0
                    subjectStatus = statusAnn;
                else
                    for r = 1:nRealizations
                        pseudoSeed = pseudo_subject_realization_seed(subject, baseSeed, r);
                        pseudoSamp = make_pseudo_event_samples(goodRSamp, EEG.srate, EEG.pnts, ann.invalidSegmentsSamp, hep, hep.pseudo, pseudoSeed);

                        if isempty(pseudoSamp)
                            continue;
                        end

                        [pseudoMap, pseudoGFP, nEvents, nFiniteChannels] = compute_pseudo_primary_map_from_eeg(EEG, chIdxOrdered, pseudoSamp, hep, ann.invalidSegmentsSamp);
                        nFiniteChannelsLast = nFiniteChannels;

                        if nFiniteChannels >= 5
                            scores(r) = weighted_projection(center_vector(pseudoMap), Templates.weights.RLocked100to200LOSO(i, :));
                            pseudoGFPVec(r) = pseudoGFP;
                            nPseudoEventsVec(r) = nEvents;
                        end
                    end

                    nFiniteScores = sum(isfinite(scores));

                    if nFiniteScores > 0
                        subjectStatus = "included";
                    else
                        subjectStatus = "no_valid_pseudo_scores";
                    end
                end
            end
        end
    catch ME
        subjectStatus = "failed";
        warningText = string(ME.message);
    end
end

result = struct();
result.Scores = scores;
result.PseudoGFP = pseudoGFPVec;
result.NPseudoEvents = nPseudoEventsVec;
result.StatusRow = table(subject, stageLabel, string(restFile), string(subjectStatus), string(warningText), nFiniteScores, nRealizations, nFiniteChannelsLast, 'VariableNames', {'Subject', 'ClinicalStage', 'RestFile', 'Status', 'Warning', 'NFiniteScores', 'NRealizations', 'NFiniteChannelsLast'});

end

function restFile = resolve_rest_file_for_tsub_subject(Tsub, rowIdx, cfg)

restFile = "";
subject = string(Tsub.Subject(rowIdx));
stageLabel = string(Tsub.ClinicalStage(rowIdx));

if ismember('RestFile', Tsub.Properties.VariableNames)
    candidate = string(Tsub.RestFile(rowIdx));

    if strlength(candidate) > 0 && exist(candidate, 'file') == 2
        restFile = candidate;
        return;
    end
end

if ismember('SubjectDir', Tsub.Properties.VariableNames)
    subjectDir = string(Tsub.SubjectDir(rowIdx));

    if strlength(subjectDir) > 0 && exist(subjectDir, 'dir') == 7
        restFile = first_existing_file({fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.mat', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', subject))});

        if strlength(restFile) > 0
            return;
        end
    end
end

rawGroups = candidate_raw_groups_for_stage(stageLabel);

for g = 1:numel(rawGroups)
    subjectDir = fullfile(cfg.baseDir, char(rawGroups(g)), char(subject));
    restFile = first_existing_file({fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.mat', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', subject))});

    if strlength(restFile) > 0
        return;
    end
end

allGroups = {'BP_I_Depressed', 'BP_II_Depressed', 'BP_I_Euthymic', 'BP_II_Euthymic', 'Siblings', 'HC'};

for g = 1:numel(allGroups)
    subjectDir = fullfile(cfg.baseDir, allGroups{g}, char(subject));
    restFile = first_existing_file({fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.mat', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', subject))});

    if strlength(restFile) > 0
        return;
    end
end

end

function rawGroups = candidate_raw_groups_for_stage(stageLabel)

stageLabel = string(stageLabel);

if stageLabel == "HC"
    rawGroups = "HC";
elseif stageLabel == "Siblings"
    rawGroups = "Siblings";
elseif stageLabel == "BD_Depressed"
    rawGroups = ["BP_I_Depressed", "BP_II_Depressed"];
elseif stageLabel == "BD_Euthymic"
    rawGroups = ["BP_I_Euthymic", "BP_II_Euthymic"];
else
    rawGroups = strings(0, 1);
end

end

function chIdxOrdered = map_analysis_channels_to_eeg_indices(EEG, eegIdx, channels)

chIdxOrdered = nan(numel(channels), 1);
labels = strings(numel(eegIdx), 1);

for c = 1:numel(eegIdx)
    labels(c) = string(EEG.chanlocs(eegIdx(c)).labels);
end

for c = 1:numel(channels)
    idx = find(strcmpi(labels, string(channels(c))), 1, 'first');

    if ~isempty(idx)
        chIdxOrdered(c) = eegIdx(idx);
    end
end

end

function [pseudoMap, pseudoGFP, nEventsMedian, nFiniteChannels] = compute_pseudo_primary_map_from_eeg(EEG, chIdxOrdered, pseudoSamp, hep, invalidSegmentsSamp)

nCh = numel(chIdxOrdered);
pseudoMap = nan(1, nCh);
nEventsByChannel = nan(1, nCh);

for c = 1:nCh
    if ~isfinite(chIdxOrdered(c))
        continue;
    end

    chIdx = round(chIdxOrdered(c));
    [eventMat, ~, ~, epochQC] = extract_rest_hep_single_channel_epochs_with_qc(EEG, pseudoSamp, chIdx, hep, invalidSegmentsSamp);

    if isempty(eventMat) || epochQC.nInput == 0
        continue;
    end

    fs = EEG.srate;
    winIdx = round((hep.hepWin - hep.tmin) * fs) + 1;
    winIdx = max(1, min(size(eventMat, 2), winIdx));
    meanAmpPerEpoch = mean(eventMat(:, winIdx(1):winIdx(2)), 2, 'omitnan');
    [keepOutlierMask, ~] = apply_rest_hep_beat_outlier_qc(meanAmpPerEpoch, hep);
    eventMat = eventMat(keepOutlierMask, :);
    nEvents = size(eventMat, 1);
    nEventsByChannel(c) = nEvents;

    if nEvents >= hep.minEpochs
        subjWave = mean(eventMat, 1, 'omitnan');
        pseudoMap(c) = mean(subjWave(winIdx(1):winIdx(2)), 'omitnan');
    end
end

nFiniteChannels = sum(isfinite(pseudoMap));
nEventsMedian = median(nEventsByChannel, 'omitnan');
pseudoGFP = row_gfp(pseudoMap);

end

function seed = pseudo_subject_realization_seed(subject, baseSeed, realization)

seedLabel = string(subject) + "_MC_" + string(realization);
seed = pseudo_subject_seed(seedLabel, double(baseSeed) + double(realization));

end

function DetailRows = run_pseudo_mc_model_rows(Tsub, Scores, cfg, plannedContrasts, nModelPermutations, baseSeed)

DetailRows = table();
nRealizations = size(Scores, 2);
useParallel = isfield(cfg, 'pseudo') && isfield(cfg.pseudo, 'monteCarlo') && isfield(cfg.pseudo.monteCarlo, 'useParallel') && logical(cfg.pseudo.monteCarlo.useParallel);
nWorkers = 8;

if isfield(cfg, 'pseudo') && isfield(cfg.pseudo, 'monteCarlo')
    nWorkers = max(1, round(get_pseudo_field_default(cfg.pseudo.monteCarlo, 'nWorkers', 8)));
end

if useParallel
    poolObj = ensure_parallel_pool(nWorkers);
    useParallel = ~isempty(poolObj);
end

if useParallel
    DetailRowCells = cell(nRealizations, 1);

    parfor r = 1:nRealizations
        DetailRowCells{r} = run_pseudo_mc_model_rows_single(Tsub, Scores(:, r), cfg, plannedContrasts, nModelPermutations, baseSeed, r);
    end

    for r = 1:nRealizations
        DetailRows = append_rows(DetailRows, DetailRowCells{r});
    end
else
    for r = 1:nRealizations
        realizationRows = run_pseudo_mc_model_rows_single(Tsub, Scores(:, r), cfg, plannedContrasts, nModelPermutations, baseSeed, r);
        DetailRows = append_rows(DetailRows, realizationRows);
    end
end

end

function realizationRows = run_pseudo_mc_model_rows_single(Tsub, scoreVector, cfg, plannedContrasts, nModelPermutations, baseSeed, r)

realizationRows = table();
endpointName = 'PseudoMonteCarloRLocked100to200FieldScore_RealTemplateLOSO_uV';
Ttmp = Tsub;
Ttmp.(endpointName) = scoreVector;

if sum(isfinite(scoreVector)) < 10
    return;
end

res = run_clinicalstage_omnibus(Ttmp, endpointName, cfg.model.baseCovariates, nModelPermutations, baseSeed + 100000 + r, cfg.stageOrder);
res.AnalysisTier = "PseudoEventMonteCarlo";
res.Family = "PseudoEventMonteCarloClinicalStage";
res.Contrast = "ClinicalStageOmnibus";
res.EndpointLabel = "Monte Carlo pseudo-event 100-200 ms field score projected onto real R-locked LOSO template, four-level ClinicalStage omnibus";
res.Realization = r;
realizationRows = append_rows(realizationRows, res);
contrastRows = table();

for c = 1:height(plannedContrasts)
    w = plannedContrasts{c, {'Weight_HC', 'Weight_Siblings', 'Weight_BD_Euthymic', 'Weight_BD_Depressed'}};
    res = run_clinicalstage_contrast(Ttmp, endpointName, string(plannedContrasts.Name(c)), string(plannedContrasts.Label(c)), w, cfg.model.baseCovariates, nModelPermutations, baseSeed + 110000 + r * 10 + c, cfg.stageOrder);
    res.AnalysisTier = "PseudoEventMonteCarlo";
    res.Family = "PseudoEventMonteCarloPlannedContrasts";
    res.EndpointLabel = "Monte Carlo pseudo-event 100-200 ms field score projected onto real R-locked LOSO template, planned ClinicalStage contrast";
    res.Realization = r;
    contrastRows = append_rows(contrastRows, res);
end

if ~isempty(contrastRows)
    contrastRows.HolmP = holm_adjust(contrastRows.PermutationP);
    contrastRows.HolmReject = contrastRows.HolmP < cfg.model.alpha;
    realizationRows = append_rows(realizationRows, contrastRows);
end

end

function SummaryRows = summarize_pseudo_mc_model_rows(DetailRows, cfg, nRealizations, nModelPermutations, baseSeed)

SummaryRows = table();

if isempty(DetailRows)
    return;
end

keyTable = unique(DetailRows(:, {'Family', 'Contrast'}), 'rows', 'stable');

for k = 1:height(keyTable)
    mask = string(DetailRows.Family) == string(keyTable.Family(k)) & string(DetailRows.Contrast) == string(keyTable.Contrast(k)) & string(DetailRows.Status) == "OK";
    R = DetailRows(mask, :);

    if isempty(R)
        continue;
    end

    row = init_model_row();
    row.AnalysisTier = "PseudoEventMonteCarloSummary";
    row.Family = string(keyTable.Family(k));
    row.Endpoint = string(R.Endpoint(1));
    row.EndpointLabel = "Monte Carlo pseudo-event negative-control summary across RR-adaptive pseudo-event placements";
    row.Predictor = string(R.Predictor(1));
    row.Contrast = string(keyTable.Contrast(k));
    row.ContrastLabel = string(R.ContrastLabel(1));
    row.ModelFormula = string(R.ModelFormula(1));
    row.CovariatesIncluded = string(R.CovariatesIncluded(1));
    row.N = median(double(R.N), 'omitnan');
    row.DF = median(double(R.DF), 'omitnan');
    row.NPermutations = nModelPermutations;
    row.RandomSeed = baseSeed;
    row.Status = "OK";
    row.IsMonteCarloSummary = true;
    row.NRealizationsPlanned = nRealizations;
    row.NRealizationsUsable = height(R);
    [row.Estimate, row.CI95_Low, row.CI95_High, row.MC_EstimateSD] = monte_carlo_summary_numbers(R.Estimate);
    [row.T, row.MC_StatisticCI95_Low, row.MC_StatisticCI95_High, row.MC_StatisticSD] = monte_carlo_summary_numbers(R.T);
    [row.PermutationP, row.MC_PermP_CI95_Low, row.MC_PermP_CI95_High, row.MC_PermP_SD] = monte_carlo_summary_numbers(R.PermutationP);
    [row.HolmP, row.MC_HolmP_CI95_Low, row.MC_HolmP_CI95_High, row.MC_HolmP_SD] = monte_carlo_summary_numbers(R.HolmP);
    row.MC_EstimateMedian = row.Estimate;
    row.MC_EstimateCI95_Low = row.CI95_Low;
    row.MC_EstimateCI95_High = row.CI95_High;
    row.MC_StatisticMedian = row.T;
    row.MC_PermP_Median = row.PermutationP;
    row.MC_HolmP_Median = row.HolmP;
    permVals = double(R.PermutationP);
    holmVals = double(R.HolmP);
    row.MC_PermP_Lt_0_05_Percent = monte_carlo_percent_below_alpha(permVals, cfg.model.alpha);
    row.MC_HolmP_Lt_0_05_Percent = monte_carlo_percent_below_alpha(holmVals, cfg.model.alpha);
    row.MC_EstimateMin = min(double(R.Estimate), [], 'omitnan');
    row.MC_EstimateMax = max(double(R.Estimate), [], 'omitnan');
    row.MC_PermP_Min = min(double(R.PermutationP), [], 'omitnan');
    row.MC_PermP_Max = max(double(R.PermutationP), [], 'omitnan');
    SummaryRows = append_rows(SummaryRows, row);
end

end

function pct = monte_carlo_percent_below_alpha(x, alpha)

x = double(x(:));
x = x(isfinite(x));

if isempty(x)
    pct = NaN;
else
    pct = 100 * mean(x < alpha);
end

end

function [mid, lo, hi, sdVal] = monte_carlo_summary_numbers(x)

x = double(x(:));
x = x(isfinite(x));

if isempty(x)
    mid = NaN;
    lo = NaN;
    hi = NaN;
    sdVal = NaN;
    return;
end

mid = median(x, 'omitnan');
lo = percentile_omitnan(x, 2.5);
hi = percentile_omitnan(x, 97.5);
sdVal = std(x, 0, 'omitnan');

end

function T = build_pseudo_mc_subject_score_long_table(Tsub, Scores, PseudoGFP, NPseudoEvents, cfg)

T = table();

if isfield(cfg.pseudo.monteCarlo, 'saveSubjectScores') && ~cfg.pseudo.monteCarlo.saveSubjectScores
    return;
end

[nS, nRealizations] = size(Scores);
Subject = repmat(string(Tsub.Subject(:)), nRealizations, 1);
ClinicalStage = repmat(string(Tsub.ClinicalStage(:)), nRealizations, 1);
Realization = repelem((1:nRealizations)', nS);
PseudoFieldScore_RealTemplateLOSO_uV = Scores(:);
PseudoGFP_100to200_uV = PseudoGFP(:);
MedianPseudoEventsPerChannel = NPseudoEvents(:);
T = table(Subject, ClinicalStage, Realization, PseudoFieldScore_RealTemplateLOSO_uV, PseudoGFP_100to200_uV, MedianPseudoEventsPerChannel);

end

function T = build_pseudo_mc_subject_score_summary(Tsub, Scores, PseudoGFP, NPseudoEvents)

T = table();
nS = height(Tsub);
Subject = string(Tsub.Subject(:));
ClinicalStage = string(Tsub.ClinicalStage(:));
NFiniteRealizations = nan(nS, 1);
ScoreMedian = nan(nS, 1);
ScoreCI95Low = nan(nS, 1);
ScoreCI95High = nan(nS, 1);
ScoreSD = nan(nS, 1);
GFPMedian = nan(nS, 1);
NPseudoEventsMedian = nan(nS, 1);

for i = 1:nS
    x = Scores(i, :);
    NFiniteRealizations(i) = sum(isfinite(x));
    ScoreMedian(i) = median(x, 'omitnan');
    ScoreCI95Low(i) = percentile_omitnan(x, 2.5);
    ScoreCI95High(i) = percentile_omitnan(x, 97.5);
    ScoreSD(i) = std(x, 0, 'omitnan');
    GFPMedian(i) = median(PseudoGFP(i, :), 'omitnan');
    NPseudoEventsMedian(i) = median(NPseudoEvents(i, :), 'omitnan');
end

T = table(Subject, ClinicalStage, NFiniteRealizations, ScoreMedian, ScoreCI95Low, ScoreCI95High, ScoreSD, GFPMedian, NPseudoEventsMedian);

end


function [x, y, z] = locs_xyz(locs)

n = numel(locs);
x = nan(n, 1);
y = nan(n, 1);
z = nan(n, 1);

for i = 1: n
    if isfield(locs(i), 'X')
        x(i) = double(locs(i).X);
    end

    if isfield(locs(i), 'Y')
        y(i) = double(locs(i).Y);
    end

    if isfield(locs(i), 'Z')
        z(i) = double(locs(i).Z);
    end
end
end

function Tout = run_ols_freedman_lane(T, outcome, target, covariates, nPerm, seed)

if nargin < 6
    seed = 13;
end

if nargin < 5 || isempty(nPerm)
    nPerm = 10000;
end

Tout = init_model_row();
Tout.Endpoint = string(outcome);
Tout.Predictor = string(target);
Tout.NPermutations = double(nPerm);
Tout.RandomSeed = double(seed);

vars = [{outcome, target}, covariates(:)'];
vars = vars(ismember(vars, T.Properties.VariableNames));

if ~ismember(outcome, vars) || ~ismember(target, vars)
    Tout.Status = "MissingOutcomeOrTarget";
    return;
end

% Keep only usable numeric covariates.

usableCov = {};

for i = 1: numel(covariates)
    cv = covariates{i};

    if ismember(cv, T.Properties.VariableNames)
        x = to_double_column(T.(cv));

        if sum(isfinite(x)) >= 10 && numel(unique(x(isfinite(x)))) >= 2
            usableCov{end + 1} = cv;
        end

    end
end

[y, X, varNames, ok] = design_matrix_numeric(T, outcome, target, usableCov);
Tout.N = sum(ok);
Tout.ModelFormula = string(compose_formula(outcome, [{target} usableCov]));
Tout.CovariatesIncluded = string(strjoin(usableCov, '|'));

if Tout.N < max(10, numel(varNames) + 3)
    Tout.Status = "TooFewCompleteCases";
    return;
end

[b, se, tStat, pVal, ciLow, ciHigh, hc3se, hc3t, hc3p, hc3Low, hc3High, df, r2] = ols_stats(y, X);
idxTarget = find(strcmp(varNames, target), 1, 'first');

if isempty(idxTarget)
    Tout.Status = "TargetNotInModel";
    return;
end

Tout.Estimate = b(idxTarget);
Tout.SE = se(idxTarget);
Tout.T = tStat(idxTarget);
Tout.ParametricP = pVal(idxTarget);
Tout.CI95_Low = ciLow(idxTarget);
Tout.CI95_High = ciHigh(idxTarget);
Tout.HC3_SE = hc3se(idxTarget);
Tout.HC3_T = hc3t(idxTarget);
Tout.HC3_P = hc3p(idxTarget);
Tout.HC3_CI95_Low = hc3Low(idxTarget);
Tout.HC3_CI95_High = hc3High(idxTarget);
Tout.DF = df;
Tout.R2 = r2;

Tout.PermutationP = freedman_lane_pvalue(y, X, idxTarget, nPerm, seed, abs(tStat(idxTarget)));
Tout.Status = "OK";
end

function T = init_model_row()

T = table();
T.AnalysisTier = strings(1,1);
T.Family = strings(1,1);
T.Endpoint = strings(1,1);
T.EndpointLabel = strings(1,1);
T.Predictor = strings(1,1);
T.Contrast = strings(1,1);
T.ContrastLabel = strings(1,1);
T.QCSensitivityRule = strings(1,1);
T.ModelFormula = strings(1,1);
T.CovariatesIncluded = strings(1,1);
T.N = NaN;
T.NExcluded = NaN;
T.Estimate = NaN;
T.SE = NaN;
T.T = NaN;
T.ParametricP = NaN;
T.PermutationP = NaN;
T.CI95_Low = NaN;
T.CI95_High = NaN;
T.HC3_SE = NaN;
T.HC3_T = NaN;
T.HC3_P = NaN;
T.HC3_CI95_Low = NaN;
T.HC3_CI95_High = NaN;
T.DF = NaN;
T.R2 = NaN;
T.NPermutations = NaN;
T.RandomSeed = NaN;
T.HolmP = NaN;
T.HolmReject = false;
T.FDR_BH_Q = NaN;
T.Status = strings(1,1);
end

function T = append_rows(T, row)

if isempty(row)
    return;
end

if isempty(T) || height(T) == 0
    T = row;
else
    T = harmonize_and_append(T, row);
end
end

function T = harmonize_and_append(A, B)

varsA = A.Properties.VariableNames;
varsB = B.Properties.VariableNames;
allVars = unique([varsA varsB], 'stable');

for i = 1: numel(allVars)
    v = allVars{i};

    if ~ismember(v, varsA)
        A.(v) = missing_column_like(B.(v), height(A));
    end

    if ~ismember(v, varsB)
        B.(v) = missing_column_like(A.(v), height(B));
    end
end

T = [A(:, allVars); B(:, allVars)];
end

function col = missing_column_like(example, n)

if isnumeric(example) || islogical(example)
    col = nan(n, 1);

    if islogical(example)
 col = false(n, 1);
    end

elseif isstring(example)
    col = strings(n, 1);
elseif iscategorical(example)
    col = categorical(strings(n, 1));
else
    col = strings(n, 1);
end
end

function [y, X, varNames, ok] = design_matrix_numeric(T, outcome, target, covariates)

yAll = to_double_column(T.(outcome));
tAll = to_double_column(T.(target));
Xall = [ones(height(T), 1), tAll];
varNames = {'Intercept', target};

for i = 1: numel(covariates)
    cv = covariates{i};

    if ismember(cv, T.Properties.VariableNames)
        x = to_double_column(T.(cv));
        Xall = [Xall, x]; 
        varNames{end+1} = cv; 
    end
end

ok = isfinite(yAll) & all(isfinite(Xall), 2);
y = yAll(ok);
X = Xall(ok, :);

% Remove rank-deficient covariate columns but preserve intercept/target when possible.

keep = true(1, size(X, 2));

for j = size(X, 2): -1: 3
    if numel(unique(X(:, j))) < 2
        keep(j) = false;
    end
end

X = X(:, keep);
varNames = varNames(keep);

% If still rank deficient, remove later covariates until estimable.

while rank(X) < size(X, 2) && size(X, 2) > 2
    X(:, end) = [];
    varNames(end) = [];
end
end

function formula = compose_formula(outcome, terms)
formula = sprintf('%s ~ %s', outcome, strjoin(terms, ' + '));
end

function [b, se, tStat, pVal, ciLow, ciHigh, hc3se, hc3t, hc3p, hc3Low, hc3High, df, r2] = ols_stats(y, X)

n = size(X, 1); 
p = size(X, 2);
df = n - p;
b = X \ y;
yhat = X * b;
r = y - yhat;
sse = sum(r.^2);
sst = sum((y - mean(y)).^2);

if sst > 0
    r2 = 1 - sse/sst;
else
    r2 = NaN;
end

XtXinv = pinv(X' * X);
residVariance = sse / max(df, 1);
se = sqrt(diag(XtXinv) * residVariance);
tStat = b ./ se;
pVal = 2 * tcdf(-abs(tStat), max(df, 1));
tcrit = tinv(0.975, max(df, 1));
ciLow = b - tcrit * se;
ciHigh = b + tcrit * se;

% HC3 robust SE

h = sum((X * XtXinv) .* X, 2);
adj = r ./ max(1 - h, eps);
Vhc3 = XtXinv * (X' * diag(adj.^2) * X) * XtXinv;
hc3se = sqrt(diag(Vhc3));
hc3t = b ./ hc3se;
hc3p = 2 * tcdf(-abs(hc3t), max(df,1));
hc3Low = b - tcrit * hc3se;
hc3High = b + tcrit * hc3se;
end

function p = freedman_lane_pvalue(y, X, targetIdx, nPerm, seed, absTobs)

if nargin < 6 || ~isfinite(absTobs)
    [~, ~, t] = ols_stats_minimal(y, X);
    absTobs = abs(t(targetIdx));
end

if nPerm <= 0
    p = NaN;
    return;
end

rng(seed, 'twister');
Xred = X;
Xred(:, targetIdx) = [];
bred = Xred \ y;
yhatRed = Xred * bred;
residRed = y - yhatRed;
count = 0;

for pidx = 1: nPerm
    yp = yhatRed + residRed(randperm(numel(residRed)));
    [~,~,tP] = ols_stats_minimal(yp, X);

    if abs(tP(targetIdx)) >= absTobs
        count = count + 1;
    end
end
p = (count + 1) / (nPerm + 1);
end

function C = planned_clinicalstage_contrasts()

C = table();
C.Name = ["BD_Depressed_vs_HC"; "BD_Depressed_vs_BD_Euthymic"; "BD_Depressed_vs_Siblings"; "Siblings_vs_HC"; "BD_Euthymic_vs_HC"];
C.Label = ["BD Depressed - HC"; "BD Depressed - BD Euthymic"; "BD Depressed - Siblings"; "Siblings - HC"; "BD Euthymic - HC"];
C.Weight_HC = [-1; 0; 0; -1; -1];
C.Weight_Siblings = [0; 0; -1; 1; 0];
C.Weight_BD_Euthymic = [0; -1; 0; 0; 1];
C.Weight_BD_Depressed = [1; 1; 1; 0; 0];
end

function rows = run_primary_sensitivity_set(T, outcome, covariates, nPerm, seed, cfg, plannedContrasts, keyContrastNames, analysisTier, family, endpointLabel, ruleName)

rows = table();

if nargin < 12
    ruleName = "";
end

res = run_clinicalstage_omnibus(T, outcome, covariates, nPerm, seed, cfg.stageOrder);
res.AnalysisTier = string(analysisTier);
res.Family = string(family);
res.Contrast = "ClinicalStageOmnibus";
res.EndpointLabel = string(endpointLabel) + ": ClinicalStage omnibus for primary 100-200 ms field score";
res.QCSensitivityRule = string(ruleName);
rows = append_rows(rows, res);

for c = 1: height(plannedContrasts)

    if ~ismember(string(plannedContrasts.Name(c)), string(keyContrastNames))
        continue;
    end

    w = plannedContrasts{c, {'Weight_HC', 'Weight_Siblings', 'Weight_BD_Euthymic', 'Weight_BD_Depressed'}};
    res = run_clinicalstage_contrast(T, outcome, string(plannedContrasts.Name(c)), string(plannedContrasts.Label(c)), w, covariates, nPerm, seed + 100 + c, cfg.stageOrder);
    res.AnalysisTier = string(analysisTier);
    res.Family = string(family);
    res.EndpointLabel = string(endpointLabel) + ": planned ClinicalStage contrast for primary 100-200 ms field score";
    res.QCSensitivityRule = string(ruleName);
    rows = append_rows(rows, res);
end
end

function Tsub = add_enhanced_qc_metrics(Tsub, Tdiag, Tendpoints, cfg)

subjects = string(Tsub.Subject);

if ismember('Rest_ManualBadPeakFrac', Tsub.Properties.VariableNames)
    Tsub.QC_ManualBadPeakFrac = to_double_column(Tsub.Rest_ManualBadPeakFrac);
else
    Tsub.QC_ManualBadPeakFrac = nan(height(Tsub), 1);
end

if ismember('Rest_Rpeaks_N', Tsub.Properties.VariableNames)
    Tsub.QC_Rpeaks_N = to_double_column(Tsub.Rest_Rpeaks_N);
else
    Tsub.QC_Rpeaks_N = nan(height(Tsub), 1);
end

Tsub.QC_MaxChannelAmpRejectedFrac = subject_aggregate_metric(Tdiag, subjects, 'AmpRejectedFrac', 'max');
Tsub.QC_MeanChannelAmpRejectedFrac = subject_aggregate_metric(Tdiag, subjects, 'AmpRejectedFrac', 'mean');
Tsub.QC_MaxFullWaveformAbs_uV = subject_aggregate_metric(Tendpoints, subjects, 'FullWaveformMaxAbs_uV', 'max');

Tsub.QC_Flag_ManualBadPeakFrac = double(isfinite(Tsub.QC_ManualBadPeakFrac) & Tsub.QC_ManualBadPeakFrac > cfg.qc.manualBadPeakFracMax);
Tsub.QC_Flag_LowRetainedRPeaks = double(isfinite(Tsub.QC_Rpeaks_N) & Tsub.QC_Rpeaks_N < cfg.qc.minRetainedRPeaks);
Tsub.QC_Flag_HighChannelAmpRejectedFrac = double(isfinite(Tsub.QC_MaxChannelAmpRejectedFrac) & Tsub.QC_MaxChannelAmpRejectedFrac > cfg.qc.maxChannelAmpRejectedFrac);
Tsub.QC_Flag_HighFullWaveformAbs = double(isfinite(Tsub.QC_MaxFullWaveformAbs_uV) & Tsub.QC_MaxFullWaveformAbs_uV > cfg.qc.maxFullWaveformAbs_uV);
Tsub.QC_EnhancedExclusionFlag = double(Tsub.QC_Flag_ManualBadPeakFrac == 1 | Tsub.QC_Flag_LowRetainedRPeaks == 1 | Tsub.QC_Flag_HighChannelAmpRejectedFrac == 1 | Tsub.QC_Flag_HighFullWaveformAbs == 1);
Tsub.QC_EnhancedReasons = strings(height(Tsub), 1);

for i = 1:height(Tsub)
    reasons = strings(0, 1);
    if Tsub.QC_Flag_ManualBadPeakFrac(i) == 1
        reasons(end + 1, 1) = sprintf('ManualBadPeakFrac_gt_%g', cfg.qc.manualBadPeakFracMax);
    end
    if Tsub.QC_Flag_LowRetainedRPeaks(i) == 1
        reasons(end + 1, 1) = sprintf('Rpeaks_lt_%g', cfg.qc.minRetainedRPeaks); 
    end
    if Tsub.QC_Flag_HighChannelAmpRejectedFrac(i) == 1
        reasons(end + 1, 1) = sprintf('MaxChannelAmpRejectedFrac_gt_%g', cfg.qc.maxChannelAmpRejectedFrac); 
    end
    if Tsub.QC_Flag_HighFullWaveformAbs(i) == 1
        reasons(end + 1, 1) = sprintf('MaxFullWaveformAbs_gt_%g_uV', cfg.qc.maxFullWaveformAbs_uV); 
    end
    Tsub.QC_EnhancedReasons(i) = strjoin(reasons, '; ');
end
end

function Tout = build_qc_subject_flag_table(Tsub)

preferred = {'Subject', 'ClinicalStage', 'QC_ManualBadPeakFrac', 'QC_Rpeaks_N', 'QC_MaxChannelAmpRejectedFrac', 'QC_MeanChannelAmpRejectedFrac', 'QC_MaxFullWaveformAbs_uV', 'Rest_QCReviewFlag', 'QC_Flag_ManualBadPeakFrac', 'QC_Flag_LowRetainedRPeaks', 'QC_Flag_HighChannelAmpRejectedFrac', 'QC_Flag_HighFullWaveformAbs', 'QC_EnhancedExclusionFlag', 'QC_EnhancedReasons'};
vars = preferred(ismember(preferred, Tsub.Properties.VariableNames));
Tout = Tsub(:, vars);

end

function vals = subject_aggregate_metric(T, subjects, varName, modeName)

vals = nan(numel(subjects), 1);

if isempty(T) || ~istable(T) || ~ismember('Subject', T.Properties.VariableNames) || ~ismember(varName, T.Properties.VariableNames)
    return;
end

subj = string(T.Subject);
xAll = to_double_column(T.(varName));

for i = 1:numel(subjects)
    x = xAll(subj == string(subjects(i)) & isfinite(xAll));

    if isempty(x)
        continue;
    end

    switch lower(string(modeName))
        case "max"
            vals(i) = max(x);
        case "mean"
            vals(i) = mean(x, 'omitnan');
        otherwise
            vals(i) = NaN;
    end
end
end

function Tout = run_clinicalstage_contrast(T, outcome, contrastName, contrastLabel, stageWeights, covariates, nPerm, seed, stageOrder)

Tout = init_model_row();
Tout.Endpoint = string(outcome);
Tout.Predictor = "ClinicalStageContrast";
Tout.Contrast = string(contrastName);
Tout.ContrastLabel = string(contrastLabel);
Tout.NPermutations = double(nPerm);
Tout.RandomSeed = double(seed);
Tout.ModelFormula = string(sprintf('%s ~ ClinicalStage + %s', outcome, strjoin(covariates, ' + ')));

[y, X, varNames, ok] = clinicalstage_design_matrix(T, outcome, covariates, stageOrder);
Tout.N = sum(ok);
Tout.CovariatesIncluded = string(strjoin(varNames(5: end), '|'));

if Tout.N < size(X, 2) + 5 || rank(X) < size(X, 2)
    Tout.Status = "TooFewOrRankDeficient";
    return;
end

stageWeights = double(stageWeights(:)');

if numel(stageWeights) ~= numel(stageOrder)
    Tout.Status = "InvalidContrastWeights";
    return;
end

L = [sum(stageWeights), stageWeights(2: end), zeros(1, size(X, 2) - numel(stageWeights))];

if numel(L) ~= size(X, 2) || all(abs(L) < eps)
    Tout.Status = "InvalidContrastVector";
    return;
end

[estimate, se, tStat, pVal, ciLow, ciHigh, hc3se, hc3t, hc3p, hc3Low, hc3High, df, r2] = ols_contrast_stats(y, X, L);
Tout.Estimate = estimate;
Tout.SE = se;
Tout.T = tStat;
Tout.ParametricP = pVal;
Tout.PermutationP = freedman_lane_contrast_pvalue(y, X, L, nPerm, seed, abs(tStat));
Tout.CI95_Low = ciLow;
Tout.CI95_High = ciHigh;
Tout.HC3_SE = hc3se;
Tout.HC3_T = hc3t;
Tout.HC3_P = hc3p;
Tout.HC3_CI95_Low = hc3Low;
Tout.HC3_CI95_High = hc3High;
Tout.DF = df;
Tout.R2 = r2;
Tout.Status = "OK";
end

function [y, X, varNames, ok] = clinicalstage_design_matrix(T, outcome, covariates, stageOrder)

yAll = to_double_column(T.(outcome));
st = string(T.ClinicalStage);
D = zeros(height(T), numel(stageOrder) - 1);

for k = 2: numel(stageOrder)
    D(:, k - 1) = strcmp(st, string(stageOrder{k}));
end

Xall = [ones(height(T), 1), D];
varNames = {'Intercept'};

for k = 2: numel(stageOrder)
    varNames{end + 1} = ['Stage_' stageOrder{k}]; 
end

for i = 1: numel(covariates)
    cv = covariates{i};

    if ismember(cv, T.Properties.VariableNames)
        x = to_double_column(T.(cv));

        if sum(isfinite(x)) >= 10 && numel(unique(x(isfinite(x)))) >= 2
            Xall = [Xall, x]; 
            varNames{end + 1} = cv;
        end
    end
end

ok = isfinite(yAll) & all(isfinite(Xall), 2) & ismember(st, string(stageOrder));
y = yAll(ok);
X = Xall(ok, :);

end

function [estimate, se, tStat, pVal, ciLow, ciHigh, hc3se, hc3t, hc3p, hc3Low, hc3High, df, r2] = ols_contrast_stats(y, X, L)

n = size(X, 1);
p = size(X, 2);
df = max(n - p, 1);
b = X \ y;
yhat = X*b;
r = y - yhat;
sse = sum(r.^2);
sst = sum((y - mean(y)).^2);

if sst > 0
    r2 = 1 - sse/sst;
else
    r2 = NaN;
end

XtXinv = pinv(X' * X);
contrastVar = L * XtXinv * L';

if contrastVar <= eps || ~isfinite(contrastVar)
    estimate = NaN; 
    se = NaN;
    tStat = NaN; 
    pVal = NaN; 
    ciLow = NaN; 
    ciHigh = NaN;
    hc3se = NaN; 
    hc3t = NaN; 
    hc3p = NaN; 
    hc3Low = NaN;
    hc3High = NaN;
    return;
end

mse = sse / df;
estimate = L * b;
se = sqrt(mse * contrastVar);
tStat = estimate / se;
pVal = 2 * tcdf(-abs(tStat), df);
tcrit = tinv(0.975, df);
ciLow = estimate - tcrit * se;
ciHigh = estimate + tcrit * se;

h = sum((X * XtXinv) .* X, 2);
adj = r ./ max(1 - h, eps);
Vhc3 = XtXinv * (X' * diag(adj.^2) * X) * XtXinv;
hc3var = L * Vhc3 * L';
hc3se = sqrt(hc3var);
hc3t = estimate / hc3se;
hc3p = 2 * tcdf(-abs(hc3t), df);
hc3Low = estimate - tcrit * hc3se;
hc3High = estimate + tcrit * hc3se;
end

function p = freedman_lane_contrast_pvalue(y, X, L, nPerm, seed, absTobs)

if nPerm <= 0
    p = NaN;
    return;
end

if nargin < 6 || ~isfinite(absTobs)
    [~, ~, tObs] = ols_contrast_stats_minimal(y, X, L);
    absTobs = abs(tObs);
end

Xred = restricted_design_from_contrast(X, L);
bred = Xred \ y;
yhatRed = Xred * bred;
residRed = y - yhatRed;
rng(seed, 'twister');
count = 0;

for pidx = 1: nPerm

    yp = yhatRed + residRed(randperm(numel(residRed)));
    [~,~,tP] = ols_contrast_stats_minimal(yp, X, L);

    if abs(tP) >= absTobs
        count = count + 1;
    end
end
p = (count + 1) / (nPerm + 1);
end

function Xred = restricted_design_from_contrast(X, L)

L = double(L(:)');
N = null(L);

if isempty(N)
    Xred = ones(size(X, 1), 1);
else
    Xred = X * N;
end

if rank(Xred) < size(Xred, 2)
    [Q, R] = qr(Xred, 0);
    keep = abs(diag(R)) > max(size(Xred)) * eps(max(abs(diag(R))));
    Xred = Q(:, keep);

    if isempty(Xred)
        Xred = ones(size(X, 1), 1);
    end
end
end

function [estimate,se,tStat] = ols_contrast_stats_minimal(y, X, L)

n = size(X, 1); 
p = size(X, 2);
df = max(n - p, 1);
b = X \ y;
r = y - X*b;
XtXinv = pinv(X'*X);
mse = sum(r.^2) / df;
contrastVar = L * XtXinv * L';
estimate = L*b;
se = sqrt(mse * contrastVar);
tStat = estimate / se;
end

function [b,se,t] = ols_stats_minimal(y, X)

n = size(X, 1);
p = size(X, 2); 
df = max(n - p, 1);
b = X \ y;
r = y - X*b;
residVariance = sum(r.^2) / df;
se = sqrt(diag(pinv(X'*X)) * residVariance);
t = b ./ se;

end

function pAdj = holm_adjust(p)

p = double(p(:));
pAdj = nan(size(p));
ok = isfinite(p);
pok = p(ok);
[ps, ord] = sort(pok);
m = numel(ps);
adjSorted = nan(m, 1);

for i = 1: m
    adjSorted(i) = min(1, (m - i + 1) * ps(i));
end

% Enforce monotonicity.

for i = 2: m
    adjSorted(i) = max(adjSorted(i), adjSorted(i - 1));
end

tmp = nan(m,1);
tmp(ord) = adjSorted;
pAdj(ok) = tmp;

end

function q = bh_fdr(p)

p = double(p(:));
q = nan(size(p));
ok = isfinite(p);
pok = p(ok);
[ps, ord] = sort(pok);
m = numel(ps);
qs = ps .* m ./ (1:m)';

for i = m-1: -1: 1
    qs(i) = min(qs(i), qs(i + 1));
end

qs = min(qs, 1);
tmp = nan(m,1);
tmp(ord) = qs;
q(ok) = tmp;

end

function Tout = run_clinicalstage_omnibus(T, outcome, covariates, nPerm, seed, stageOrder)

Tout = init_model_row();
Tout.Endpoint = string(outcome);
Tout.Predictor = "ClinicalStage";
Tout.NPermutations = double(nPerm);
Tout.RandomSeed = double(seed);
Tout.ModelFormula = string(sprintf('%s ~ ClinicalStage + %s', outcome, strjoin(covariates, ' + ')));

% Dummy-code stage with HC as reference and test the 3 stage dummy columns jointly.

yAll = to_double_column(T.(outcome));
st = string(T.ClinicalStage);
D = zeros(height(T), numel(stageOrder) - 1);

for k = 2: numel(stageOrder)
    D(:, k - 1) = strcmp(st, string(stageOrder{k}));
end

Xall = [ones(height(T), 1), D];
varNames = {'Intercept'};

for k = 2: numel(stageOrder)
 varNames{end + 1} = ['Stage_' stageOrder{k}];
end 

for i = 1: numel(covariates)
    cv = covariates{i};

    if ismember(cv, T.Properties.VariableNames)
        x = to_double_column(T.(cv));

        if sum(isfinite(x)) >= 10 && numel(unique(x(isfinite(x)))) >= 2
            Xall = [Xall, x]; 
            varNames{end + 1} = cv; 
        end

         end
end

ok = isfinite(yAll) & all(isfinite(Xall), 2) & ismember(st, string(stageOrder));
y = yAll(ok); 
X = Xall(ok, :);
Tout.N = sum(ok);
Tout.CovariatesIncluded = string(strjoin(varNames(5: end), '|'));

if Tout.N < size(X, 2) + 5 || rank(X) < size(X, 2)
    Tout.Status = "TooFewOrRankDeficient";
    return;
end

% Partial F for stage dummies.

q = numel(stageOrder) - 1;
Xred = X(:, [1, (q+2):size(X, 2)]);
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, dfFull, r2Full] = ols_stats(y, X);
bred = Xred \ y;
rRed = y - Xred*bred;
rFull = y - X*(X\y);
sseRed = sum(rRed.^2);
sseFull = sum(rFull.^2);
Fobs = ((sseRed - sseFull)/q) / (sseFull / max(dfFull, 1));
Tout.Estimate = NaN;
Tout.T = Fobs;
Tout.ParametricP = 1 - fcdf(Fobs, q, max(dfFull, 1));
Tout.R2 = r2Full;
Tout.DF = dfFull;

rng(seed, 'twister');
yhatRed = Xred*bred; residRed = y - yhatRed;
count = 0;

for pi = 1: nPerm
    yp = yhatRed + residRed(randperm(numel(residRed)));
    bFullP = X \ yp;
    rFullP = yp - X*bFullP;
    bRedP = Xred \ yp; 
    rRedP = yp - Xred*bRedP;
    sseFullP = sum(rFullP.^2);
    sseRedP = sum(rRedP.^2);
    Fp = ((sseRedP - sseFullP)/q) / (sseFullP / max(dfFull, 1));

    if Fp >= Fobs
        count = count + 1;
    end
end

Tout.PermutationP = (count + 1) / (nPerm + 1);
Tout.Status = "OK";
end

function s = std_omitnan(x)

x = double(x(:));
x = x(isfinite(x));

if numel(x) <= 1
    s = NaN;
else
    s = std(x, 0);
end
end

function T = build_sample_characteristics(Tsub, stageOrder)

T = table();
row = 0;

for g = 1: numel(stageOrder)
    mask = strcmp(string(Tsub.ClinicalStage), string(stageOrder{g}));
    row = row + 1;
    T.Factor(row, 1) = "ClinicalStage";
    T.Level(row, 1) = string(stageOrder{g});
    T.N(row, 1) = sum(mask);
    vars = {'Age', 'Sex', 'CigsPerDay', 'MedBurden', 'MADRS', 'YMRS', 'GAF'};

    for v = 1: numel(vars)
        vn = vars{v};
        if ismember(vn, Tsub.Properties.VariableNames)
            x = to_double_column(Tsub.(vn));
            x = x(mask & isfinite(x));
        else
            x = [];
        end

        T.([vn '_Mean'])(row, 1) = mean(x, 'omitnan');
        T.([vn '_SD'])(row, 1) = std_omitnan(x);
        T.([vn '_N'])(row, 1) = numel(x);
    end
end
end

function Cluster = run_cluster_permutation(Y, Tsub, channels, locs, timeMs, cfg)

[timeIdx, requestedGrid] = select_cluster_time_indices(timeMs, cfg.cluster.searchWin_ms, cfg.cluster.timeStep_ms);
timeSearch = timeMs(timeIdx);
Ysearch = Y(:,:,timeIdx);
[nS,nC,nT] = size(Ysearch);
YmatAll = reshape(Ysearch, nS, nC*nT);

% Revised localization target: the main planned clinical-stage contrast BD_Depressed - HC, adjusted for the same base covariates as the
% primary model. This mirrors the revised primary research question. The RiskGradient trend remains in the model tables as a supportive
% test but is not the default localization target.

plannedContrasts = planned_clinicalstage_contrasts();
contrastName = string(cfg.cluster.effect);
idxContrast = find(string(plannedContrasts.Name) == contrastName, 1, 'first');

if isempty(idxContrast)
    error('Unknown cluster contrast effect: %s', char(contrastName));
end

stageWeights = plannedContrasts{idxContrast, {'Weight_HC', 'Weight_Siblings', 'Weight_BD_Euthymic', 'Weight_BD_Depressed'}};

[yDummy, Xcomplete, varNames, okDesign] = clinicalstage_design_matrix(Tsub, 'RLocked100to200FieldScore_LOSO_uV', cfg.model.baseCovariates, cfg.stageOrder);
stageWeights = double(stageWeights(:)');
Lall = [sum(stageWeights), stageWeights(2: end), zeros(1, size(Xcomplete, 2) - numel(stageWeights))];

YmatComplete = YmatAll(okDesign, :);
okY = all(isfinite(YmatComplete), 2);
X = Xcomplete(okY, :);
Ymat = YmatComplete(okY, :);
L = Lall;

if rank(X) < size(X, 2)
    error('Cluster design matrix is rank deficient.');
end

[tObs, df] = mass_univariate_contrast_tmap(Ymat, X, L);
tMap = reshape(tObs, nC, nT);
tcrit = tinv(1 - cfg.cluster.clusterFormingP/2, df);
chAdj = channel_adjacency_from_locs(locs, cfg.adj.minNeighbors, cfg.adj.distanceScale);
clusters = find_clusters_2d(tMap, tcrit, chAdj, timeSearch, channels);

% Freedman-Lane permutation for max cluster mass under the selected contrast.

Xred = restricted_design_from_contrast(X, L);
Bred = Xred \ Ymat;
YhatRed = Xred * Bred;
ResidRed = Ymat - YhatRed;
maxMass = zeros(cfg.cluster.nPermutations, 1);
rng(cfg.model.randomSeed + 1000, 'twister');

for p = 1: cfg.cluster.nPermutations
    permIdx = randperm(size(Ymat, 1));
    Yp = YhatRed + ResidRed(permIdx, :);
    [tP, ~] = mass_univariate_contrast_tmap(Yp, X, L);
    tPmap = reshape(tP, nC, nT);
    cP = find_clusters_2d(tPmap, tcrit, chAdj, timeSearch, channels);

    if ~isempty(cP)
        maxMass(p) = max([cP.Mass]);
    end
end

Tcl = clusters_to_table(clusters, maxMass, cfg.cluster.nPermutations);

if ~isempty(Tcl)
    Tcl.Effect = repmat(contrastName, height(Tcl), 1);
    Tcl.EffectLabel = repmat(string(plannedContrasts.Label(idxContrast)), height(Tcl), 1);
end

Cluster = struct();
Cluster.Table = Tcl;
Cluster.Tmap = tMap;
Cluster.TimeMs = timeSearch;
Cluster.Channels = channels;
Cluster.Tcrit = tcrit;
Cluster.DF = df;
Cluster.ChannelAdjacency = chAdj;
Cluster.MaxNullClusterMass = maxMass;
Cluster.NSubjects = size(Ymat, 1);
Cluster.Effect = contrastName;
Cluster.EffectLabel = string(plannedContrasts.Label(idxContrast));
Cluster.RequestedGridMs = requestedGrid;
Cluster.RequestedTimeStep_ms = cfg.cluster.timeStep_ms;

if numel(timeSearch) >= 2
    Cluster.ActualMedianTimeStep_ms = median(diff(timeSearch), 'omitnan');
else
    Cluster.ActualMedianTimeStep_ms = NaN;
end
Cluster.TimeSamplingMode = cfg.cluster.timeSamplingMode;
end

function [idx, requestedGrid] = select_cluster_time_indices(timeMs, searchWin, requestedStepMs)

inside = find(timeMs >= searchWin(1) & timeMs <= searchWin(2));

if isempty(inside)
    error('No time points found in cluster search window [%g %g] ms.', searchWin(1), searchWin(2));
end

if nargin < 3 || ~isfinite(requestedStepMs) || requestedStepMs <= 0
    idx = inside(:)';
    requestedGrid = timeMs(idx);
    return;
end

requestedGrid = searchWin(1): requestedStepMs: searchWin(2);
idx = nan(size(requestedGrid));

for k = 1: numel(requestedGrid)
    [~, localIdx] = min(abs(timeMs(inside) - requestedGrid(k)));
    idx(k) = inside(localIdx);
end

idx = unique(idx, 'stable');

if numel(idx) < 2
    idx = inside(:)';
end
end

function [t, df] = mass_univariate_contrast_tmap(Y, X, L)

n = size(X, 1);
p = size(X, 2); 
df = max(n - p, 1);
B = X \ Y;
R = Y - X*B;
residVarVec = sum(R.^2, 1) ./ df;
XtXinv = pinv(X'*X);
contrastVar = L * XtXinv * L';
se = sqrt(residVarVec .* contrastVar);
t = (L * B) ./ se;

end

function [t, df] = mass_univariate_tmap(Y, X, idxTarget)

n = size(X, 1); 
p = size(X, 2); 
df = max(n - p, 1);
B = X \ Y;
R = Y - X * B;
residVarVec = sum(R.^2, 1) ./ df;
XtXinv = pinv(X'*X);
se = sqrt(residVarVec .* XtXinv(idxTarget, idxTarget));
t = B(idxTarget, :) ./ se;

end

function Adj = channel_adjacency_from_locs(locs, minNeighbors, distanceScale)

[x,y,z] = locs_xyz(locs);
coords = [x y z];

if any(~isfinite(coords(:)))
    coords = locs_2d(locs);
end

n = size(coords, 1);
D = squareform_local(pdist_local(coords));
D(1: n + 1: end) = Inf;
nearest = sort(D, 2, 'ascend');
refDist = median(nearest(:, min(minNeighbors, n-1)), 'omitnan') * distanceScale;
Adj = D <= refDist;
Adj = Adj | Adj';
Adj(1: n + 1: end) = false;

end

function Dv = pdist_local(X)

n = size(X, 1);
Dv = zeros(n*(n-1) / 2, 1); 
k = 0;

for i = 1: n - 1
    for j = i + 1: n
        k = k + 1;
        d = X(i, :) - X(j, :);
        Dv(k) = sqrt(sum(d.^2, 'omitnan'));
    end
end
end

function D = squareform_local(v)

m = numel(v);
n = (1 + sqrt(1 + 8 * m))/2;
n = round(n);
D = zeros(n, n);
k = 0;

for i = 1: n - 1
    for j = i + 1: n
        k = k + 1;
        D(i, j) = v(k);
        D(j, i) = v(k);
    end
end
end

function xy = locs_2d(locs)

n = numel(locs); xy = nan(n, 2);
for i = 1: n
    if isfield(locs(i), 'theta') && isfield(locs(i), 'radius') && isfinite(double(locs(i).theta)) && isfinite(double(locs(i).radius))
        th = deg2rad(double(locs(i).theta)); r = double(locs(i).radius);
        xy(i,:) = [r*cos(th), r*sin(th)];
    elseif isfield(locs(i), 'X') && isfield(locs(i), 'Y')
        xy(i,:) = [double(locs(i).X), double(locs(i).Y)];
    else
        xy(i,:) = [cos(2 * pi * i / n), sin(2 * pi * i / n)];
    end
end
end

function clusters = find_clusters_2d(tMap, tcrit, chAdj, timeMs, channels)

clusters = struct('ID', {}, 'Sign',{}, 'Mass', {}, 'Size', {}, 'StartMs', {}, 'EndMs', {}, 'PeakT', {}, 'PeakChannel', {}, 'Channels', {}, 'Mask', {});
id = 0;

for sg = [-1 1]
    if sg > 0
        mask = tMap >= tcrit;
    else
        mask = tMap <= -tcrit;
    end

    visited = false(size(mask));

    for c = 1: size(mask, 1)
        for t = 1: size(mask, 2)
            if ~mask(c, t) || visited(c, t)
                continue;
            end

            id = id + 1;
            [nodesC, nodesT, visited] = bfs_cluster(mask, visited, c, t, chAdj);
            lin = sub2ind(size(mask), nodesC, nodesT);
            vals = tMap(lin);
            [~, pkIdx] = max(abs(vals));
            clMask = false(size(mask)); clMask(lin) = true;
            clusters(id).ID = id;
            clusters(id).Sign = sg;
            clusters(id).Mass = sum(abs(vals), 'omitnan');
            clusters(id).Size = numel(vals);
            clusters(id).StartMs = min(timeMs(nodesT));
            clusters(id).EndMs = max(timeMs(nodesT));
            clusters(id).PeakT = vals(pkIdx);
            clusters(id).PeakChannel = channels(nodesC(pkIdx));
            clusters(id).Channels = strjoin(unique(channels(nodesC), 'stable'), '|');
            clusters(id).Mask = clMask;
        end
    end
end
end

function [nodesC, nodesT, visited] = bfs_cluster(mask, visited, c0, t0, chAdj)

qC = c0; 
qT = t0;
head = 1;
visited(c0,t0) = true;
nodesC = [];
nodesT = [];

while head <= numel(qC)

    c = qC(head);
    t = qT(head); head = head + 1;
    nodesC(end + 1, 1) = c; 
    nodesT(end + 1, 1) = t; 
    neigh = [];

    if t > 1
 neigh = [neigh; c, t-1];
    end 

    if t < size(mask, 2)
 neigh = [neigh; c, t + 1]; 
    end 

    chN = find(chAdj(c, :));

    for k = 1: numel(chN)
        neigh = [neigh; chN(k), t]; 
    end

    for k = 1: size(neigh, 1)
        cc = neigh(k, 1);
        tt = neigh(k, 2);

        if mask(cc, tt) && ~visited(cc,tt)
            visited(cc, tt) = true;
            qC(end + 1, 1) = cc; 
            qT(end + 1, 1) = tt; 
        end
    end
end
end

function T = clusters_to_table(clusters, maxNullMass, nPerm)

T = table();

for i = 1: numel(clusters)
    T.ClusterID(i, 1) = clusters(i).ID;
    T.Sign(i, 1) = clusters(i).Sign;
    T.Mass(i, 1) = clusters(i).Mass;
    T.Size(i, 1) = clusters(i).Size;
    T.StartMs(i, 1) = clusters(i).StartMs;
    T.EndMs(i, 1) = clusters(i).EndMs;
    T.PeakT(i, 1) = clusters(i).PeakT;
    T.PeakChannel(i, 1) = string(clusters(i).PeakChannel);
    T.Channels(i, 1) = string(clusters(i).Channels);
    T.ClusterP_FWER(i, 1) = (1 + sum(maxNullMass >= clusters(i).Mass)) / (nPerm + 1);
    T.InferenceTier(i,1 ) = "ExploratoryChannelTimeCluster";
end

if ~isempty(T)
    T = sortrows(T, 'ClusterP_FWER', 'ascend');
end
end

%% Figure functions

function make_figure1_hc_topography(Y, GFP, Maps, Tsub, channels, locs, timeMs, cfg)

hc = strcmp(string(Tsub.ClinicalStage), 'HC');
fig = figure('Color', [1 1 1], 'Visible', cfg.fig.visible, 'Position', [100 100 1500 850]);
set(fig, 'InvertHardcopy', 'off');
set(fig, 'Renderer', 'painters');
colormap(fig, jet(256));

% Panel A: healthy-control R-locked global field power

axA = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.08 0.61 0.86 0.31], 'Color', [1 1 1]);
hold(axA, 'on');
mu = mean(GFP(hc, :), 1, 'omitnan');
se = std(GFP(hc, :), 0, 1, 'omitnan') ./ sqrt(max(sum(hc), 1));
yVals = [mu - se, mu + se];
yVals = yVals(isfinite(yVals));

if isempty(yVals)
    yVals = [0 1];
end

yRange = max(yVals) - min(yVals);

if ~isfinite(yRange) || yRange <= 0
    yRange = max(abs(yVals));
end

if ~isfinite(yRange) || yRange <= 0
    yRange = 1;
end

axes(axA);
xlim(axA, [-200 600]);
ylim(axA, [min(yVals) - 0.08 * yRange, max(yVals) + 0.08 * yRange]);
shade_window(cfg.win.CFA_ms, [0.90 0.90 0.90]);
shade_window(cfg.win.RLocked100to200_ms, [0.80 0.90 1.00]);
shade_window(cfg.win.Early_ms, [0.88 0.84 1.00]);
shade_window(cfg.win.Late_ms, [0.90 0.90 0.90]);
fill_between(timeMs, mu - se, mu + se, [0.85 0.85 0.85]);
plot(axA, timeMs, mu, 'k-', 'LineWidth', 3);
xline(axA, 0, 'k--');
xlabel(axA, 'Time from R peak (ms)');
ylabel(axA, 'Global field power (uV)');
set(axA, 'Layer', 'top', 'Color', [1 1 1], 'Box', 'off');

% Panel B: healthy-control scalp topographies

mapCFA = mean(Maps.CFA_centered(hc, :), 1, 'omitnan');
mapRLocked100 = mean(Maps.RLocked100to200_centered(hc, :), 1, 'omitnan');
mapEarly = mean(Maps.Early_centered(hc, :), 1, 'omitnan');
mapLate = mean(Maps.Late_centered(hc, :), 1, 'omitnan');
mapList = {mapCFA, mapRLocked100, mapEarly, mapLate};
titleList = {'B. Peri-R CFA (-25 to +25 ms)', 'Primary 100-200 ms', 'Adjacent 200-300 ms', 'Later 300-400 ms'};
cl = symmetric_clim([mapCFA mapRLocked100 mapEarly mapLate]);
axTopo = gobjects(1, 4);
topoPositions = [0.070 0.145 0.165 0.300; 0.285 0.145 0.165 0.300; 0.500 0.145 0.165 0.300; 0.715 0.145 0.165 0.300];

for t = 1: 4
    axTopo(t) = axes('Parent', fig, 'Units', 'normalized', 'Position', topoPositions(t, :), 'Color', [1 1 1]);
    axes(axTopo(t));
    plot_scalp_map_no_colorbar(mapList{t}, locs, channels, cl, titleList{t}, cfg);
    set(axTopo(t), 'Units', 'normalized', 'Position', topoPositions(t, :), 'Color', [1 1 1]);
    caxis(axTopo(t), cl);
end

drawnow;

for t = 1: 4
    set(axTopo(t), 'Units', 'normalized', 'Position', topoPositions(t, :), 'Color', [1 1 1]);
end

axCB = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.905 0.170 0.018 0.255], 'Color', [1 1 1]);
cbVals = linspace(cl(1), cl(2), 256)';
imagesc(axCB, 1, cbVals, cbVals);
set(axCB, 'YDir', 'normal', 'XTick', [], 'YAxisLocation', 'right', 'Box', 'off', 'Color', [1 1 1]);
ylim(axCB, cl);
caxis(axCB, cl);
ylabel(axCB, 'uV');

sgtitle(fig, 'Figure 1. Healthy-control passive resting R-locked EEG field is spatially distributed');
set(fig, 'Color', [1 1 1]);
set(findall(fig, 'Type', 'axes'), 'Color', [1 1 1]);
savefig(fig, fullfile(cfg.figDir, 'Figure1_HC_RLocked_Field_Topography.fig'));
close(fig);
end

function make_figure2_group_early_field(Maps, Tsub, ModelRows, channels, locs, cfg)

fig = figure('Color', [1 1 1], 'Visible', cfg.fig.visible, 'Position', [100 100 1500 1050]);
set(fig, 'InvertHardcopy', 'off');
set(fig, 'Renderer', 'painters');
colormap(fig, jet(256));
stages = cfg.stageOrder;

% Panel A: group maps for the main 100-200 ms distributed-field endpoint

groupMaps = nan(numel(stages), numel(channels));

for g = 1: numel(stages)
    mask = strcmp(string(Tsub.ClinicalStage), string(stages{g}));
    groupMaps(g, :) = mean(Maps.RLocked100to200_centered(mask, :), 1, 'omitnan');
end

cl = symmetric_clim(groupMaps(:));
axW = 0.135;
axH = 0.205;
yA = 0.665;
xA = [0.170 0.365 0.560 0.755];
axA = gobjects(1, numel(stages));

annotation(fig, 'textbox', [0.065 0.905 0.870 0.045], 'String', 'A. Group-average 100-200 ms R-locked scalp maps', 'EdgeColor', 'none', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', 'none');

for g = 1: numel(stages)
    pos = [xA(g), yA, axW, axH];
    axA(g) = axes('Parent', fig, 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
    axes(axA(g));
    plot_scalp_map_no_colorbar(groupMaps(g, :), locs, channels, cl, char(label_stage(stages{g})), cfg);
    set(axA(g), 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
    caxis(axA(g), cl);
end

drawnow;

for g = 1: numel(stages)
    set(axA(g), 'Units', 'normalized', 'Position', [xA(g), yA, axW, axH], 'Color', [1 1 1]);
end

draw_manual_colorbar(fig, [0.110 0.685 0.016 0.165], cl, 'uV', 'left');

% Panel B: descriptive difference maps versus healthy controls

hcMap = groupMaps(1, :);
diffStages = stages(2: end);
diffMaps = groupMaps(2: end, :) - hcMap;
cld = symmetric_clim(diffMaps(:));
yB = 0.415;
xB = [0.250 0.465 0.680];
axB = gobjects(1, numel(diffStages));

annotation(fig, 'textbox', [0.065 0.655 0.870 0.045], 'String', 'B. Descriptive group-minus-HC difference maps', 'EdgeColor', 'none', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', 'none');

for g = 1: numel(diffStages)
    pos = [xB(g), yB, axW, axH];
    axB(g) = axes('Parent', fig, 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
    axes(axB(g));
    plot_scalp_map_no_colorbar(diffMaps(g, :), locs, channels, cld, sprintf('%s - HC', char(label_stage(diffStages{g}))), cfg);
    set(axB(g), 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
    caxis(axB(g), cld);
end

drawnow;

for g = 1: numel(diffStages)
    set(axB(g), 'Units', 'normalized', 'Position', [xB(g), yB, axW, axH], 'Color', [1 1 1]);
end

draw_manual_colorbar(fig, [0.190 0.435 0.016 0.165], cld, 'uV', 'left');

% Panel C: subject-level primary field scores

axC = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.110 0.080 0.400 0.250], 'Color', [1 1 1]);
axes(axC);
strip_by_group(Tsub, 'RLocked100to200FieldScore_LOSO_uV', stages);
ylabel(axC, '100-200 ms field score (uV-weighted projection)');
title(axC, 'C. Primary subject-level distributed field score');
set(axC, 'Color', [1 1 1], 'Box', 'off');

sgtitle(fig, 'Figure 2. Clinical-stage differences in the 100-200 ms distributed R-locked field');
set(fig, 'Color', [1 1 1]);
set(findall(fig, 'Type', 'axes'), 'Color', [1 1 1]);
savefig(fig, fullfile(cfg.figDir, 'Figure2_Group_RLocked100to200_Distributed_Field.fig'));
close(fig);

end

function draw_manual_colorbar(fig, pos, climVals, labelText, yAxisLocation)

if nargin < 5
    yAxisLocation = 'left';
end

axCB = axes('Parent', fig, 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
cbVals = linspace(climVals(1), climVals(2), 256)';
imagesc(axCB, 1, cbVals, cbVals);
set(axCB, 'YDir', 'normal', 'XTick', [], 'YAxisLocation', yAxisLocation, 'Box', 'off', 'Color', [1 1 1]);
ylim(axCB, climVals);
caxis(axCB, climVals);
ylabel(axCB, labelText);

end

function make_figure4_artifact_robustness(Tsub, ModelRows, cfg)
fig = figure('Color','w','Visible',cfg.fig.visible,'Position',[100 100 1350 850]);
tl = tiledlayout(fig, 2, 3, 'TileSpacing','compact','Padding','compact');
stages = cfg.stageOrder;

nexttile(tl,1);
strip_by_group(Tsub, 'CFAScore_LOSO_uV', stages);
ylabel('Peri-R CFA score (uV)'); title('A. Peri-R field score by group');

nexttile(tl,2);
x = Tsub.CFAScore_LOSO_uV; y = Tsub.RLocked100to200FieldScore_LOSO_uV;
gscatter_no_legend(x, y, string(Tsub.ClinicalStage), stages);
xlabel('Peri-R CFA score (uV)'); ylabel('100-200 ms field score (uV)');
title(sprintf('B. Primary score vs CFA score, r = %.2f', safe_corr(x,y)));
box off;

nexttile(tl,3);
if ismember('RLocked100to200_CFA_MapCorr', Tsub.Properties.VariableNames)
    strip_by_group(Tsub, 'RLocked100to200_CFA_MapCorr', stages);
    ylabel('Subject map correlation'); ylim([-1 1]);
    title('C. Within-subject 100-200-vs-CFA map correlation');
else
    axis off;
end

nexttile(tl,4,[1 3]);
plot_robustness_forest(ModelRows);
title('D. Robustness of BD Depressed - HC estimate for 100-200 ms field score');

sgtitle('Figure 4. Peri-R artifact control and primary 100-200 ms robustness analyses');
set(fig, 'Visible', 'on');
force_white_figure_background(fig);
set(fig, 'Visible', 'on');
savefig(fig, fullfile(cfg.figDir, 'Figure4_Artifact_Control_Robustness.fig'));

if isgraphics(fig, 'figure')
    close(fig);
end

end

function make_figure3_cluster_localization(Y, Cluster, Tsub, channels, locs, timeMs, cfg)

if ~isfield(Cluster, 'Tmap') || isempty(Cluster.Tmap)
    return;
end

fig = figure('Color', [1 1 1], 'Visible', cfg.fig.visible, 'Position', [100 100 1500 900]);
set(fig, 'InvertHardcopy', 'off');

[frontalIdx, posteriorIdx] = split_channels_frontal_posterior(channels, locs);
cl = symmetric_clim(Cluster.Tmap(:));

axA1 = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.080 0.100 0.165 0.800], 'Color', [1 1 1]);
imagesc(Cluster.TimeMs, 1:numel(frontalIdx), Cluster.Tmap(frontalIdx, :));
set(axA1, 'YTick', 1:numel(frontalIdx), 'YTickLabel', cellstr(channels(frontalIdx)), 'FontSize', 6, 'CLim', cl);
xlabel('Time from R peak (ms)'); ylabel('Frontal channels');
title('A. Frontal channels');
xline(0, 'k--'); xline(cfg.win.RLocked100to200_ms(1), 'k:'); xline(cfg.win.RLocked100to200_ms(2), 'k:');

axA2 = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.295 0.100 0.165 0.800], 'Color', [1 1 1]);
imagesc(Cluster.TimeMs, 1:numel(posteriorIdx), Cluster.Tmap(posteriorIdx, :));
set(axA2, 'YTick', 1:numel(posteriorIdx), 'YTickLabel', cellstr(channels(posteriorIdx)), 'FontSize', 6, 'CLim', cl);
xlabel('Time from R peak (ms)'); ylabel('Posterior channels');
title('Posterior channels');
xline(0, 'k--'); xline(cfg.win.RLocked100to200_ms(1), 'k:'); xline(cfg.win.RLocked100to200_ms(2), 'k:');
cbA = colorbar(axA2);
set(cbA, 'Units', 'normalized', 'Position', [0.472 0.100 0.012 0.800]);
set(axA1, 'Position', [0.080 0.100 0.165 0.800]);
set(axA2, 'Position', [0.295 0.100 0.165 0.800]);

axB = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.570 0.520 0.355 0.355], 'Color', [1 1 1]);

if ~isempty(Cluster.Table)
    sig = Cluster.Table.ClusterP_FWER < 0.05;

    if any(sig)
        firstID = Cluster.Table.ClusterID(find(sig, 1, 'first'));
    else
        firstID = Cluster.Table.ClusterID(1);
    end

    mask = false(size(Cluster.Tmap));
    % Recreate selected cluster mask from current t map using cluster finder.
    chAdj = Cluster.ChannelAdjacency;
    clusters = find_clusters_2d(Cluster.Tmap, Cluster.Tcrit, chAdj, Cluster.TimeMs, channels);
    idx = find([clusters.ID] == firstID, 1, 'first');

    if ~isempty(idx)
        mask = clusters(idx).Mask;
        clusterTimeMask = any(mask, 1);
        clusterChannelMask = any(mask, 2);
        topo = mean(Cluster.Tmap(:, clusterTimeMask), 2, 'omitnan');
        clTopo = symmetric_clim(topo);
        plot_scalp_map_white_markers(topo, locs, channels, clTopo, sprintf('B. Cluster %d topography', firstID), cfg, clusterChannelMask);
        set(axB, 'Units', 'normalized', 'Position', [0.570 0.520 0.355 0.355], 'Color', [1 1 1]);
        draw_manual_colorbar(fig, [0.935 0.570 0.012 0.255], clTopo, 't', 'right');
        set(axB, 'Units', 'normalized', 'Position', [0.570 0.520 0.355 0.355], 'Color', [1 1 1]);
    else
        axis off; text(0, 0.5, 'No cluster mask available');
    end
else
    axis off; text(0, 0.5, 'No clusters passed cluster-forming threshold');
end

axC = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.555 0.100 0.405 0.335], 'Color', [1 1 1]);
plot_cluster_waveform_if_available(Y, Cluster, Tsub, channels, timeMs, cfg);
set(axC, 'Color', [1 1 1]);

sgtitle('Figure 3. Exploratory spatiotemporal localization of the revised primary contrast');
set(fig, 'Visible', 'on');
force_white_figure_background(fig);
set(fig, 'Visible', 'on');
savefig(fig, fullfile(cfg.figDir, 'Figure3_Exploratory_ChannelTime_ClusterLocalization.fig'));

if isgraphics(fig, 'figure')
    close(fig);
end

end

function [frontalIdx, posteriorIdx] = split_channels_frontal_posterior(channels, locs)

[x, y, ~] = locs_xyz(locs);
anterior = x(:);
lateral = y(:);

if numel(anterior) ~= numel(channels) || sum(isfinite(anterior)) < ceil(numel(channels) / 2)
    xy = locs_2d(locs);
    anterior = xy(:, 2);
    lateral = xy(:, 1);
end

if numel(anterior) ~= numel(channels)
    anterior = (numel(channels):-1:1)';
    lateral = zeros(numel(channels), 1);
end

finiteAnterior = anterior(isfinite(anterior));

if isempty(finiteAnterior)
    anterior = (numel(channels):-1:1)';
else
    anterior(~isfinite(anterior)) = min(finiteAnterior) - 1;
end

lateral(~isfinite(lateral)) = 0;
[~, splitOrder] = sort(anterior, 'descend');
nFrontal = floor(numel(channels) / 2);
frontalIdx = splitOrder(1:nFrontal);
posteriorIdx = splitOrder(nFrontal + 1: end);
frontalIdx = order_anatomical_channel_subset(frontalIdx, anterior, lateral);
posteriorIdx = order_anatomical_channel_subset(posteriorIdx, anterior, lateral);

end

function idx = order_anatomical_channel_subset(idx, anterior, lateral)

idx = idx(:);
anteriorBin = round(anterior(idx) / 5) * 5;
[~, orderIdx] = sortrows([-anteriorBin, -lateral(idx)]);
idx = idx(orderIdx);

end

function make_supplementary_figures(Y, GFP, Maps, Tsub, Tdiag, Tendpoints, Tgroup, channels, locs, timeMs, files, cfg)
make_supp_fig_all_channel_waveforms(Tgroup, Y, Tsub, channels, timeMs, cfg);
make_supp_fig_group_topography_windows(Maps, Tsub, channels, locs, cfg);
make_supp_fig_qc(Tsub, Tdiag, Tendpoints, cfg);
if exist(files.maxSeparation, 'file') == 2
    make_supp_fig_max_separation(files.maxSeparation, cfg);
end
end

function make_supp_fig_all_channel_waveforms(Tgroup, Y, Tsub, channels, timeMs, cfg)

fig = figure('Color','w','Visible',cfg.fig.visible,'Position',[50 50 1600 1200]);
nCh = numel(channels); nr = 8; nc = 8;
tl = tiledlayout(fig, nr, nc, 'TileSpacing','compact','Padding','compact');
stages = cfg.stageOrder;

for c = 1: nCh
    nexttile(tl,c); hold on;

    for g = 1: numel(stages)
        mask = strcmp(string(Tsub.ClinicalStage), string(stages{g}));
        mu = squeeze(mean(Y(mask,c,:), 1, 'omitnan'));
        plot(timeMs, mu, 'LineWidth', 0.8);
    end

    xline(0,'k:'); xlim([min(timeMs) max(timeMs)]);
    title(channels(c), 'FontSize', 7); set(gca,'FontSize',6);
end

legend(label_stage(stages), 'Location','bestoutside');
sgtitle('Supplementary Figure S1. All-channel R-locked group-mean waveforms');
set(fig, 'Visible', 'on');
force_white_figure_background(fig);
set(fig, 'Visible', 'on');
savefig(fig, fullfile(cfg.figDir, 'Figure_S1_AllChannel_RLocked_Waveforms.fig'));

if isgraphics(fig, 'figure')
    close(fig);
end

end

function make_supp_fig_group_topography_windows(Maps, Tsub, channels, locs, cfg)

fig = figure('Color','w','Visible',cfg.fig.visible,'Position',[100 100 1500 1300]);
set(fig, 'InvertHardcopy', 'off');
stages = cfg.stageOrder;
winNames = {'CFA -25 to +25 ms','R-locked 100-200 ms','Adjacent early 200-300 ms','Later post-R 300-400 ms','Late tail 450-600 ms'};
mapFields = {'CFA_centered','RLocked100to200_centered','Early_centered','Late_centered','LateTail_centered'};
groupMaps = cell(numel(mapFields), numel(stages));

for f = 1: numel(mapFields)
    for g = 1:numel(stages)
        mask = strcmp(string(Tsub.ClinicalStage), string(stages{g}));
        groupMaps{f, g} = mean(Maps.(mapFields{f})(mask,:), 1, 'omitnan');
    end
end

allGroupVals = [];

for f = 1:numel(mapFields)
    for g = 1:numel(stages)
        allGroupVals = [allGroupVals; groupMaps{f, g}(:)]; %#ok<AGROW>
    end
end

commonCl = robust_symmetric_clim(allGroupVals, get_optional_fig_field(cfg, 'suppTopoRobustPrctile', 98));
nRows = numel(winNames);
nCols = numel(stages);
leftMargin = 0.055;
rightMargin = 0.035;
topMargin = 0.075;
bottomMargin = 0.055;
gapX = 0.035;
gapY = 0.035;
axW = (1 - leftMargin - rightMargin - (nCols - 1) * gapX) / nCols;
axH = (1 - topMargin - bottomMargin - (nRows - 1) * gapY) / nRows;

for f = 1:numel(mapFields)
    rowVals = [];

    for g = 1:numel(stages)
        rowVals = [rowVals; groupMaps{f, g}(:)]; %#ok<AGROW>
    end

    if isfield(cfg.fig, 'suppTopoUseRowwiseClim') && cfg.fig.suppTopoUseRowwiseClim
        cl = robust_symmetric_clim(rowVals, get_optional_fig_field(cfg, 'suppTopoRobustPrctile', 98));
    else
        cl = commonCl;
    end

    for g = 1:numel(stages)
        x0 = leftMargin + (g - 1) * (axW + gapX);
        y0 = 1 - topMargin - f * axH - (f - 1) * gapY;
        axes('Parent', fig, 'Position', [x0, y0, axW, axH]);
        plot_scalp_map(groupMaps{f, g}, locs, channels, cl, sprintf('%s | %s', label_stage(stages{g}), winNames{f}), cfg);
    end
end

if isfield(cfg.fig, 'suppTopoUseRowwiseClim') && cfg.fig.suppTopoUseRowwiseClim
    sgtitle('Supplementary Figure S2. Group topographies across predefined windows; color limits are row-wise across group means');
else
    sgtitle('Supplementary Figure S2. Group topographies across predefined windows; common color limits across group means');
end

set(fig, 'Visible', 'on');
force_white_figure_background(fig);
set(fig, 'Visible', 'on');
savefig(fig, fullfile(cfg.figDir, 'Figure_S2_GroupTopographies_AllWindows.fig'));

if isgraphics(fig, 'figure')
    close(fig);
end

end

function make_supp_fig_qc(Tsub, Tdiag, Tendpoints, cfg)

fig = figure('Color','w','Visible',cfg.fig.visible,'Position',[100 100 1350 900]);
tl = tiledlayout(fig, 2, 2, 'TileSpacing','compact','Padding','compact');
stages = cfg.stageOrder;
nexttile(tl,1);

if ismember('Rest_Rpeaks_N', Tsub.Properties.VariableNames)
    strip_by_group(Tsub, 'Rest_Rpeaks_N', stages); ylabel('Good R peaks'); title('A. R peaks by group');
else
    axis off;
end

nexttile(tl,2);

if ismember('Rest_ManualBadPeakFrac', Tsub.Properties.VariableNames)
    strip_by_group(Tsub, 'Rest_ManualBadPeakFrac', stages); ylabel('Manual bad R-peak fraction'); title('B. Manual R-peak QC');
elseif ismember('Rest_NNIntervalRejectedFrac', Tsub.Properties.VariableNames)
    strip_by_group(Tsub, 'Rest_NNIntervalRejectedFrac', stages); ylabel('NN interval rejected fraction'); title('B. NN interval QC');
else
    axis off;
end

nexttile(tl,3);

if ~isempty(Tdiag) && ismember('AmpRejectedFrac', Tdiag.Properties.VariableNames)
    boxchart_by_group(Tdiag, 'AmpRejectedFrac', cfg.stageOrder); ylabel('Channel amp rejection fraction'); title('C. Channel-level rejection fractions');
else
    axis off;
end

nexttile(tl,4);

if ~isempty(Tendpoints) && ismember('FullWaveformMaxAbs_uV', Tendpoints.Properties.VariableNames)
    boxchart_by_group(Tendpoints, 'FullWaveformMaxAbs_uV', cfg.stageOrder); ylabel('Full waveform max abs (uV)'); title('D. Channel full-waveform amplitude');
else
    axis off;
end

sgtitle('Supplementary Figure S4. Waveform and beat-level QC diagnostics');
export_figure(fig, fullfile(cfg.qcDir, 'Figure_S4_QC_Diagnostics.pdf'), cfg);
end

function make_supp_fig_max_separation(maxSepFile, cfg)

T = readtable(maxSepFile, 'TextType','string');
fig = figure('Color','w','Visible',cfg.fig.visible,'Position',[100 100 1200 700]);
tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
nexttile(tl,1);
bar(categorical(T.Channel), T.MaxFStatistic); ylabel('Max descriptive F'); xtickangle(90); title('A. Max separation by channel');
nexttile(tl,2);
histogram(T.MaxSepTimeMs, 'BinWidth', 50); xlabel('Peak separation time (ms)'); ylabel('# channels'); title('B. Distribution of peak times');
sgtitle('Supplementary Figure S3. Descriptive channel maximum-separation summary');
export_figure(fig, fullfile(cfg.figDir, 'Figure_S3_ChannelMaxSeparationSummary.pdf'), cfg);

end

%% Plot helper functions

function shade_window(win, col)

if nargin < 2 || isempty(col)
    col = [0.9 0.9 0.9];
end

yl = ylim;

if win == [-25 25]
    patch([win(1) win(2) win(2) win(1)], [yl(1) yl(1) yl(2) yl(2)], 'r', 'EdgeColor','none', 'FaceAlpha',0.1);
elseif win == [300 400]
    patch([win(1) win(2) win(2) win(1)], [yl(1) yl(1) yl(2) yl(2)], [0 1 0], 'EdgeColor','none', 'FaceAlpha',0.1);
else

    patch([win(1) win(2) win(2) win(1)], [yl(1) yl(1) yl(2) yl(2)], col, 'EdgeColor','none', 'FaceAlpha',0.4);
end

try
    uistack(findobj(gca, 'Type', 'line'), 'top');
catch
end
end

function fill_between(x, yLower, yUpper, col)

if nargin < 4 || isempty(col)
    col = [0.8 0.8 0.8];
end

x = double(x(:)');
yLower = double(yLower(:)');
yUpper = double(yUpper(:)');
n = min([numel(x), numel(yLower), numel(yUpper)]);

if n < 2
    return;
end

x = x(1: n);
yLower = yLower(1: n);
yUpper = yUpper(1: n);
ok = isfinite(x) & isfinite(yLower) & isfinite(yUpper);

if sum(ok) < 2
    return;
end

x = x(ok);
yLower = yLower(ok);
yUpper = yUpper(ok);
fill([x fliplr(x)], [yLower fliplr(yUpper)], col, 'EdgeColor', 'none', 'FaceAlpha', 0.9);

end

function cl = symmetric_clim(vals)
vals = vals(isfinite(vals));
if isempty(vals)
    cl = [-1 1];
else
    m = max(abs(vals));
    if m <= 0 || ~isfinite(m)
        m = 1;
    end
    cl = [-m m];
end
end

function cl = robust_symmetric_clim(vals, pct)

vals = double(vals(:));
vals = vals(isfinite(vals));

if isempty(vals)
    cl = [-1 1];
    return;
end

if nargin < 2 || ~isfinite(pct)
    pct = 98;
end

pct = max(50, min(100, pct));

try
    m = prctile(abs(vals), pct);
catch
    valsAbs = sort(abs(vals));
    idx = max(1, min(numel(valsAbs), round((pct / 100) * numel(valsAbs))));
    m = valsAbs(idx);
end
m = max(m, 0.25);
if ~isfinite(m) || m <= 0
    m = max(abs(vals));
end
if ~isfinite(m) || m <= 0
    m = 1;
end
cl = [-m m];
end

function val = get_optional_fig_field(cfg, fieldName, defaultValue)
val = defaultValue;
if isfield(cfg, 'fig') && isfield(cfg.fig, fieldName)
    candidate = cfg.fig.(fieldName);
    if ~isempty(candidate)
        val = candidate;
    end
end
end

function force_white_figure_background(fig)

if isempty(fig) || ~isgraphics(fig, 'figure')
    return;
end

set(fig, 'Color', [1 1 1]);

if isprop(fig, 'InvertHardcopy')
    set(fig, 'InvertHardcopy', 'off');
end

if isprop(fig, 'PaperColor')
    set(fig, 'PaperColor', [1 1 1]);
end

ax = findall(fig, 'Type', 'axes');

for i = 1: numel(ax)
    if isprop(ax(i), 'Color')
        set(ax(i), 'Color', [1 1 1]);
    end
end

objs = findall(fig, '-property', 'BackgroundColor');

for i = 1: numel(objs)
    try
        set(objs(i), 'BackgroundColor', [1 1 1]);
    catch
    end
end

end

function plot_scalp_map_white_markers(values, locs, channels, climVals, ttl, cfg, clusterChannelMask)

values = double(values(:));

if nargin < 7 || isempty(clusterChannelMask)
    clusterChannelMask = false(size(values));
end

clusterChannelMask = logical(clusterChannelMask(:));
clusterIdx = find(clusterChannelMask);

if cfg.fig.useTopoplotIfAvailable && exist('topoplot','file') == 2
    try
        warnState = warning;
        cleanupObj = onCleanup(@() warning(warnState));
        warning('off', 'all');

        if ~isempty(clusterIdx)
            topoplot(values, locs, 'maplimits', climVals, 'electrodes', 'on', 'emarker', {'.', 'k', 14, 1}, 'emarker2', {clusterIdx, '.', 'w', 24, 1});
        else
            topoplot(values, locs, 'maplimits', climVals, 'electrodes', 'on', 'emarker', {'.', 'k', 14, 1});
        end

        title(ttl, 'Interpreter','none');
        caxis(climVals);
        clear cleanupObj;
        return;
    catch
        if exist('cleanupObj', 'var')
            clear cleanupObj;
        end
        % fallback below
    end
end
xy = locs_2d(locs);
scatter(xy(:,1), xy(:,2), 120, values, 'filled', 'MarkerEdgeColor',[0.2 0.2 0.2]);
hold on;
scatter(xy(:,1), xy(:,2), 28, 'k', 'filled', 'MarkerEdgeColor', [0 0 0]);
if numel(clusterChannelMask) == size(xy, 1) && any(clusterChannelMask)
    scatter(xy(clusterChannelMask, 1), xy(clusterChannelMask, 2), 54, 'w', 'filled', 'MarkerEdgeColor', [0 0 0], 'LineWidth', 1.0);
end
plot_head_outline();
axis equal off;
caxis(climVals);
title(ttl, 'Interpreter','none');
end

function plot_scalp_map_no_colorbar(values, locs, channels, climVals, ttl, cfg)

values = double(values(:));

if cfg.fig.useTopoplotIfAvailable && exist('topoplot', 'file') == 2
    try
        warnState = warning;
        cleanupObj = onCleanup(@() warning(warnState));
        warning('off', 'all');
        topoplot(values, locs, 'maplimits', climVals, 'electrodes', 'on');
        title(ttl, 'Interpreter', 'none');
        caxis(climVals);
        clear cleanupObj;
        return;
    catch
        if exist('cleanupObj', 'var')
            clear cleanupObj;
        end
    end
end

xy = locs_2d(locs);
scatter(xy(:, 1), xy(:, 2), 120, values, 'filled', 'MarkerEdgeColor', [0.2 0.2 0.2]);
hold on;
plot_head_outline();
axis equal off;
caxis(climVals);
title(ttl, 'Interpreter', 'none');

for i = 1: numel(channels)
    text(xy(i, 1), xy(i, 2), char(channels(i)), 'FontSize', 5, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

end

function plot_scalp_map(values, locs, channels, climVals, ttl, cfg)
values = double(values(:));
if cfg.fig.useTopoplotIfAvailable && exist('topoplot','file') == 2
    try
        warnState = warning;
        cleanupObj = onCleanup(@() warning(warnState));
        warning('off', 'all');
        topoplot(values, locs, 'maplimits', climVals, 'electrodes','on');
        title(ttl, 'Interpreter','none'); colorbar;
        clear cleanupObj;
        return;
    catch
        if exist('cleanupObj', 'var')
            clear cleanupObj;
        end
        % fallback below
    end
end
xy = locs_2d(locs);
scatter(xy(:,1), xy(:,2), 120, values, 'filled', 'MarkerEdgeColor',[0.2 0.2 0.2]);
hold on;
plot_head_outline();
axis equal off;
caxis(climVals); colorbar;
title(ttl, 'Interpreter','none');
for i = 1:numel(channels)
    text(xy(i,1), xy(i,2), char(channels(i)), 'FontSize',5, 'HorizontalAlignment','center', 'VerticalAlignment','middle');
end
end

function plot_head_outline()
th = linspace(0,2*pi,200);
plot(cos(th)*0.55, sin(th)*0.55, 'k-', 'LineWidth',1);
plot([0 0.04 -0.04 0], [0.55 0.62 0.62 0.55], 'k-', 'LineWidth',1);
end

function strip_by_group(T, varName, stages)

hold on;
stageColors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560];

for g = 1: numel(stages)
    mask = strcmp(string(T.ClinicalStage), string(stages{g}));
    y = to_double_column(T.(varName));
    y = y(mask);

    xBase = 1 + (g - 1) * 0.72;
    x = xBase + (rand(size(y)) - 0.5) * 0.12;

    scatter(x, y, 40, 'filled', 'MarkerFaceColor', stageColors(g, :), 'MarkerFaceAlpha', 0.65, 'MarkerEdgeColor', [0.2 0.2 0.2]);

    m = mean(y, 'omitnan');
    se = std_omitnan(y) / sqrt(sum(isfinite(y)));

    plot([xBase - 0.16 xBase + 0.16], [m m], 'k-', 'LineWidth', 2);
    plot([xBase xBase], [m - 1.96 * se m + 1.96 * se], 'k-', 'LineWidth', 1.5);
end

xTickPos = 1 + ((1: numel(stages)) - 1) * 0.72;
xlim([xTickPos(1) - 0.45 xTickPos(end) + 0.45]);
set(gca, 'XTick', xTickPos, 'XTickLabel', label_stage(stages));
xtickangle(20);
box off;

end
function boxchart_by_group(T, varName, stages)
y = to_double_column(T.(varName));
group = categorical(string(T.ClinicalStage), string(stages), string(label_stage(stages)));
ok = isfinite(y) & ~isundefined(group);
if ~any(ok)
    axis off;
    return;
end
if exist('boxchart', 'file') == 2 || exist('boxchart', 'builtin') == 5
    boxchart(group(ok), y(ok));
else
    Ttmp = T(ok, :);
    Ttmp.(varName) = y(ok);
    strip_by_group(Ttmp, varName, stages);
end
box off;

end

function gscatter_no_legend(x, y, group, stages)

hold on;

for g = 1:numel(stages)
    mask = strcmp(group, string(stages{g}));
    scatter(x(mask), y(mask), 45, 'filled', 'MarkerFaceAlpha', 0.7);
end

ok = isfinite(x) & isfinite(y);

if sum(ok) >= 3
    p = polyfit(x(ok), y(ok), 1);
    xx = linspace(min(x(ok)), max(x(ok)), 100);
    plot(xx, polyval(p,xx), 'k-', 'LineWidth',1.5);
end
legend(label_stage(stages), 'Location','best');
end

function lab = label_stage(stages)
lab = string(stages);
lab = strrep(lab, 'BD_Euthymic', 'BD Euthymic');
lab = strrep(lab, 'BD_Depressed', 'BD Depressed');
end

function forest_single(est, lo, hi, p, labelText)
hold on;
plot([lo hi], [1 1], 'k-', 'LineWidth',2);
scatter(est, 1, 80, 'filled');
xline(0, 'k--');
yticks(1); yticklabels({labelText});
ylim([0.5 1.5]);
xlabel('Estimate (uV weighted projection)');
txt = sprintf('estimate = %.4g, 95%% CI [%.4g, %.4g], perm p = %.4g', est, lo, hi, p);
title(txt);
box off;
end

function plot_robustness_forest(ModelRows)

rowMask = strcmp(string(ModelRows.Endpoint), "RLocked100to200FieldScore_LOSO_uV") & strcmp(string(ModelRows.Contrast), "BD_Depressed_vs_HC") & ismember(string(ModelRows.AnalysisTier), ["PrimaryPlannedContrast" "PrimarySensitivity"]);
rows = ModelRows(rowMask, :);
rows = rows(strcmp(string(rows.Status), "OK"), :);

if isempty(rows)
    axis off;
    text(0,0.5,'No BD Depressed - HC robustness rows available');
    return;
end

% Keep the figure readable by showing the primary row and the physiology/artifact rows.

keepPrimary = strcmp(string(rows.AnalysisTier), "PrimaryPlannedContrast");
keepArtifact = strcmp(string(rows.Family), "ArtifactControl");
keepPhysiology = strcmp(string(rows.Family), "PhysiologyControl");
keep = keepPrimary | keepArtifact | keepPhysiology;

if any(keep)
    rows = rows(keep,:);
end

n = height(rows);
hold on;

for i = 1: n
    y = n - i + 1;
    plot([rows.CI95_Low(i) rows.CI95_High(i)], [y y], 'k-', 'LineWidth',1.5);
    scatter(rows.Estimate(i), y, 60, 'filled');
end

xline(0,'k--');
labels = string(rows.EndpointLabel);
labels(strcmp(string(rows.AnalysisTier), "PrimaryPlannedContrast")) = "Primary planned contrast: BD Depressed - HC";
labels = regexprep(labels, '^Adjusted for ', 'Adj. ');
labels = regexprep(labels, ': planned ClinicalStage contrast for primary 100-200 ms field score', '');
labels = regexprep(labels, ': ClinicalStage omnibus for primary 100-200 ms field score', '');
yticks(1:n); yticklabels(flipud(labels));
xlabel('BD Depressed - HC estimate (uV)'); ylim([0 n+1]); box off;
end

function plot_cluster_waveform_if_available(Y, Cluster, Tsub, channels, timeMs, cfg)

if ~isfield(Cluster,'Table') || isempty(Cluster.Table)
    axis off;
    text(0,0.5,'No clusters passed the cluster-forming threshold');
    return;
end

% Use best cluster by corrected p.

best = Cluster.Table(1, :);
clusters = find_clusters_2d(Cluster.Tmap, Cluster.Tcrit, Cluster.ChannelAdjacency, Cluster.TimeMs, channels);
idx = find([clusters.ID] == best.ClusterID, 1, 'first');

if isempty(idx)
    axis off;
    return;
end

chMask = any(clusters(idx).Mask, 2);

if ~any(chMask)
    axis off;
    return;
end

wave = squeeze(mean(Y(:,chMask, :), 2, 'omitnan'));
hold on;
stages = cfg.stageOrder;
stageColors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560];

for g = 1: numel(stages)
    m = strcmp(string(Tsub.ClinicalStage), string(stages{g}));
    mu = mean(wave(m,:), 1, 'omitnan');
    plot(timeMs, mu, 'LineWidth', 3, 'Color', stageColors(g, :));
end

shade_window([best.StartMs best.EndMs]);
xline(0, 'k--');
xlabel('Time from R peak (ms)'); ylabel('Cluster-channel mean amplitude (uV)');
title(sprintf('C. Best exploratory cluster waveform'));
end

function export_figure(fig, outFile, cfg)

try
    set(fig, 'Color', [1 1 1]);
    set(fig, 'InvertHardcopy', 'off');
    exportgraphics(fig, outFile, 'ContentType', 'image', 'Resolution', cfg.fig.exportResolution, 'BackgroundColor', [1 1 1]);
    [p, n, ~] = fileparts(outFile);
    exportgraphics(fig, fullfile(p, [n '.png']), 'Resolution', cfg.fig.exportResolution, 'BackgroundColor', [1 1 1]);
catch
    saveas(fig, outFile);
end

close(fig);
end

function write_manifest(manifestFile, cfg, files, Cluster)
if nargin < 4
    Cluster = struct();
end
fid = fopen(manifestFile, 'w');
if fid < 0, return; end
fprintf(fid, 'Rest_RLocked_Field_Analysis output manifest\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));
fprintf(fid, 'Input directory: %s\n', cfg.inputDir);
fprintf(fid, 'Metric directory: %s\n', cfg.metricDir);
fprintf(fid, 'QC directory: %s\n', cfg.qcDir);
fprintf(fid, 'Model/statistics output directory: %s\n', cfg.outputDir);
fprintf(fid, 'Figure directory: %s\n\n', cfg.figDir);
fprintf(fid, 'Revised primary question: Is the predefined passive resting 100-200 ms R-locked distributed EEG field altered in bipolar depression relative to HC, siblings, and euthymic BD?\n');
fprintf(fid, 'Primary endpoint: RLocked100to200FieldScore_LOSO_uV, 100-200 ms R-locked window, CFA-orthogonalized distributed field.\n');
fprintf(fid, 'Primary score sign convention: HC-positive orientation; positive values indicate stronger expression of the group-blind CFA-orthogonalized 100-200 ms field, not single-electrode voltage polarity.\n');
fprintf(fid, 'Window boundary convention: start-inclusive, end-exclusive millisecond windows [start, end), with end-inclusive sparse-grid fallback only if no samples are otherwise available.\n');
fprintf(fid, 'Primary model family: RLocked100to200FieldScore_LOSO_uV ~ ClinicalStage + Age + Sex. CFA-score covariate adjustment is a prespecified sensitivity analysis.\n');
fprintf(fid, 'Primary tests: four-level ClinicalStage omnibus plus planned contrasts BD_Depressed-HC, BD_Depressed-BD_Euthymic, BD_Depressed-Siblings, Siblings-HC, and BD_Euthymic-HC.\n');
fprintf(fid, 'Supportive trend test: RiskGradient retained as an ordinal trend, not as the primary biological claim.\n');
fprintf(fid, 'Primary 100-200 ms distributed-field robustness models are exported to Table_RLocked100to200_Distributed_Robustness.csv.\n');
fprintf(fid, 'Monte Carlo pseudo-event negative-control summaries are exported to Table_PseudoEvent_Control_Models.csv, with realization-level source rows in Table_PseudoEvent_MonteCarlo_RealizationModels.csv.\n');
fprintf(fid, 'Post hoc smoking-adjusted sensitivity model is exported with primary 100-200 ms robustness models when CigsPerDay is available.\n');
fprintf(fid, 'Enhanced QC subject flags are exported to the QC directory for audit; QC-exclusion sensitivity models are not run in this manuscript script.\n');
fprintf(fid, 'Exploratory cluster localization target: %s. Search window [%g %g] ms. Requested sampling step %g ms using %s selection.\n', char(cfg.cluster.effect), cfg.cluster.searchWin_ms, cfg.cluster.timeStep_ms, char(cfg.cluster.timeSamplingMode));
if isstruct(Cluster) && isfield(Cluster, 'ActualMedianTimeStep_ms')
    fprintf(fid, 'Exploratory cluster actual median time step used: %.6g ms.\n', Cluster.ActualMedianTimeStep_ms);
end
fprintf(fid, 'Supplementary Figure S2 uses group-mean based color limits to avoid compression by individual-subject topographic outliers.\n');
fprintf(fid, 'Windows: CFA [%g %g] ms, PrimaryRLocked [%g %g] ms, AdjacentEarly [%g %g] ms, LaterPostR [%g %g] ms.\n\n', cfg.win.CFA_ms, cfg.win.RLocked100to200_ms, cfg.win.Early_ms, cfg.win.Late_ms);
fprintf(fid, 'Input files:\n');
fn = fieldnames(files);
for i = 1:numel(fn)
    fprintf(fid, '  %s: %s\n', fn{i}, files.(fn{i}));
end
fclose(fid);
end

%% ===== Metric-extraction and visual-QC local functions imported from Brain_Heart_coupling_analyses.m =====

function [goodRSamp, status, ann] = get_good_rest_rpeaks_from_manual_sidecar(restFile, EEG)

goodRSamp = [];
status = "";
ann = load_manual_continuous_beat_annotations(restFile);
contextLabel = sprintf('resting analyses for %s', char(pathless_file_label(restFile)));

if ~ann.hasFile
    error('Missing manual beat sidecar for %s: %s', contextLabel, char(manual_bad_mat_file(restFile)));
end

if isempty(ann.allRSamp)
    error('Manual beat sidecar contains no allRSamp beats for %s: %s', contextLabel, char(manual_bad_mat_file(restFile)));
end

ann.allRSamp = unique(double(ann.allRSamp(:)));
ann.badRSamp = unique(double(ann.badRSamp(:)));
ann.addedRSamp = unique(double(ann.addedRSamp(:)));
ann.allRSamp = merge_added_continuous_beats(ann.allRSamp, ann.addedRSamp);
ann.invalidSegmentsSamp = normalize_invalid_segments_samp(ann.invalidSegmentsSamp, EEG.pnts);
[ann, ~] = apply_invalid_segments_to_continuous_annotations(ann, EEG.pnts);

if ~isempty(ann.badRSamp) && ~all(ismember(double(ann.badRSamp(:)), double(ann.allRSamp(:))))
    error('Manual beat sidecar contains badRSamp values that are not present in allRSamp for %s: %s', contextLabel, char(manual_bad_mat_file(restFile)));
end

goodRSamp = setdiff(double(ann.allRSamp(:)), double(ann.badRSamp(:)), 'stable');

if isempty(goodRSamp)
    error('Manual beat sidecar leaves no good R peaks after manual QC for %s: %s', contextLabel, char(manual_bad_mat_file(restFile)));
end

end

function S = init_subject_template()

S = struct();
S.Group = "";
S.Subject = "";
S.SubjectDir = "";
S.RestFile = "";
S.CRFFile = "";

end

function Subj = discover_subjects(baseDir, groups, processedFolderName, restFolderName)

Subj = repmat(init_subject_template(), 0, 1);

for g = 1: numel(groups)
    groupDir = fullfile(baseDir, groups{g});

    if ~exist(groupDir, 'dir')
        continue;
    end

    subjDirs = dir(fullfile(groupDir, 'Subject_*'));
    subjDirs = subjDirs([subjDirs.isdir]);

    for s = 1: numel(subjDirs)
        subjName = string(subjDirs(s).name);
        subjDir = string(fullfile(groupDir, subjName));
        processedDir = processed_rest_dir(subjDir, processedFolderName, restFolderName);
        restFile = first_existing_file({fullfile(processedDir, sprintf('%s_rest_processed.set', subjName)), fullfile(processedDir, sprintf('%s_rest_processed.mat', subjName))});

        if strlength(restFile) == 0
            legacyRestDir = fullfile(subjDir, processedFolderName, 'Rest');
            restFile = first_existing_file({fullfile(legacyRestDir, sprintf('%s_rest_processed.set', subjName)), fullfile(legacyRestDir, sprintf('%s_rest_processed.mat', subjName))});
        end

        if strlength(restFile) == 0
            continue;
        end

        crfFile = find_first_file(subjDir, '*CRF*.mat');
        rec = init_subject_template();
        rec.Group = string(groups{g});
        rec.Subject = subjName;
        rec.SubjectDir = subjDir;
        rec.RestFile = restFile;
        rec.CRFFile = crfFile;
        Subj(end + 1, 1) = rec;
    end
end

end

function T = hydrate_metric_table_paths_from_subjects(T, Subj)

% Reattach file-system paths from the discovered subject manifest before support waveform export.
% Compact output tables intentionally omit these paths, so unchanged cached metrics need this hydration step.

if isempty(T) || isempty(Subj) || ~ismember('Subject', T.Properties.VariableNames)
    return;
end

pathVars = {'SubjectDir', 'RestFile'};

for v = 1: numel(pathVars)
    if ~ismember(pathVars{v}, T.Properties.VariableNames)
        T.(pathVars{v}) = strings(height(T), 1);
    end
end

if ~ismember('Group', T.Properties.VariableNames)
    T.Group = strings(height(T), 1);
end

if ~ismember('ClinicalStage', T.Properties.VariableNames)
    T.ClinicalStage = strings(height(T), 1);
end

if ~ismember('RiskGradient', T.Properties.VariableNames)
    T.RiskGradient = nan(height(T), 1);
end

subjNames = strings(numel(Subj), 1);

for i = 1: numel(Subj)
    subjNames(i) = string(Subj(i).Subject);
end

for r = 1: height(T)
    subject = string(T.Subject(r));
    idx = find(subjNames == subject, 1, 'first');

    if isempty(idx)
        continue;
    end

    T.SubjectDir(r) = string(Subj(idx).SubjectDir);
    T.RestFile(r) = string(Subj(idx).RestFile);

    if isfield(Subj, 'Group') && (strlength(string(T.Group(r))) == 0 || ismissing(string(T.Group(r))))
        T.Group(r) = string(Subj(idx).Group);
    end

    if isfield(Subj, 'ClinicalStage') && (strlength(string(T.ClinicalStage(r))) == 0 || ismissing(string(T.ClinicalStage(r))))
        T.ClinicalStage(r) = string(Subj(idx).ClinicalStage);
    end

    if isfield(Subj, 'RiskGradient') && ~isfinite(double(T.RiskGradient(r)))
        T.RiskGradient(r) = double(Subj(idx).RiskGradient);
    end

    if (strlength(string(T.ClinicalStage(r))) == 0 || ismissing(string(T.ClinicalStage(r)))) && ismember('Group', T.Properties.VariableNames)
        T.ClinicalStage(r) = four_group_label_from_raw_group(T.Group(r));
    end
end

end

function label = four_group_label_from_raw_group(groupName)

g = string(groupName);
label = string(missing);

if g == "HC"
    label = "HC";
elseif g == "Siblings"
    label = "Siblings";
elseif contains(g, 'Euthymic')
    label = "BD_Euthymic";
elseif contains(g, 'Depressed')
    label = "BD_Depressed";
end

end

function p = processed_rest_dir(subjDir, processedFolderName, restFolderName)

if strlength(string(restFolderName)) > 0
    p = fullfile(subjDir, processedFolderName, restFolderName);
else
    p = fullfile(subjDir, processedFolderName);
end

end

function f = first_existing_file(candidates)

f = "";

for i = 1: numel(candidates)
    if exist(candidates{i}, 'file')
        f = string(candidates{i});
        return;
    end
end

end

function rec = init_rest_record_template()

base = init_record_base();
rec = base;
rec.Rest_MetricsSourceSignature = "";
rec.Rest_MetricsSettingsSignature = "";
rec.Rest_MetricsCollectedAt = "";
rec.Rest_DurationSec = NaN;
rec.Rest_Srate = NaN;
rec.Rest_EEG_AnalysisLowpassHz = NaN;
rec.Rest_EEG_AnalysisLowpassOrder = NaN;
rec.Rest_EEG_AnalysisLowpassApplied = false;
rec.Rest_EEG_AnalysisLowpassNChannels = NaN;
rec.Rest_Rpeaks_N = NaN;
rec.Rest_Rpeaks_AllMarked_N = NaN;
rec.Rest_Rpeaks_BadMarked_N = NaN;
rec.Rest_Rpeaks_Added_N = NaN;
rec.Rest_ManualBadPeakFrac = NaN;
rec.Rest_ManualAddedPeakFrac = NaN;
rec.Rest_ManualInvalidSegment_N = NaN;
rec.Rest_ManualInvalidSegment_TotalSec = NaN;
rec.Rest_Rpeaks_InvalidSegmentRemoved_N = NaN;
rec.Rest_NNIntervals_ManualInvalid_N = NaN;
rec.Rest_MeanHR_BPM = NaN;
rec.Rest_SDNN_ms = NaN;
rec.Rest_RRIntervals_N = NaN;
rec.Rest_NNIntervals_N = NaN;
rec.Rest_NNIntervalValidFrac = NaN;
rec.Rest_NNIntervalRejectedFrac = NaN;
rec.Rest_HRV_QCFlag_LowOrHighHR = NaN;
rec.Rest_HRV_QCFlag_HighRejectedFrac = NaN;
rec.Rest_HRV_QCFlag = NaN;
rec.Rest_lnRMSSD = NaN;

end

function base = init_record_base()

base = struct();
base.Group = "";
base.Subject = "";
base.SubjectDir = "";
base.RestFile = "";
base.CRFFile = "";
base.MoodState = "";
base.Subtype = "";

fn = {'Age', 'Sex', 'Gender', 'CigsPerDay', 'GAF', 'MADRS', 'YMRS', 'AD', 'AP', 'MS', 'ANX', 'Other'};

for i = 1: numel(fn)
    base.(fn{i}) = NaN;
end

base.Gender = "";

end


function rec = init_rest_record(S, cov, desc)

rec = init_rest_record_template();
rec = populate_common_record(rec, S, cov, desc);

end

function rec = populate_common_record(rec, S, cov, desc)

rec.Group = string(S.Group);
rec.Subject = string(S.Subject);
rec.SubjectDir = string(S.SubjectDir);

if isfield(S, 'RestFile')
    rec.RestFile = string(S.RestFile);
else
    rec.RestFile = "";
end

rec.CRFFile = string(S.CRFFile);
rec.MoodState = string(desc.MoodState);
rec.Subtype = string(desc.Subtype);

fn = fieldnames(cov);

for i = 1: numel(fn)
    rec.(fn{i}) = cov.(fn{i});
end

if contains(rec.Group, 'HC') || contains(rec.Group, 'Siblings')
    rec.MADRS = NaN;
    rec.YMRS = NaN;
    rec.GAF = NaN;
end

end

function desc = derive_group_descriptors(groupName)

g = string(groupName);
desc = struct();
desc.MoodState = "NA";
desc.Subtype = "NA";

if contains(g, 'Depressed')
    desc.MoodState = "Depressed";
elseif contains(g, 'Euthymic')
    desc.MoodState = "Euthymic";
end

if contains(g, 'BP_II')
    desc.Subtype = "II";
elseif contains(g, 'BP_I')
    desc.Subtype = "I";
end

end

function f = find_first_file(rootDir, pattern)

f = "";

if strlength(string(rootDir)) == 0 || ~exist(rootDir, 'dir')
    return;
end

d = dir(fullfile(rootDir, '**', pattern));

if ~isempty(d)
    f = string(fullfile(d(1).folder, d(1).name));
end

end

function cov = load_covariates(crfFile, covarFields)

cov = struct();

for i = 1: numel(covarFields)
    cov.(covarFields{i}) = NaN;
end

if ismember('Gender', covarFields)
    cov.Gender = "";
end

if strlength(string(crfFile)) == 0 || ~exist(crfFile, 'file')
    return;
end

S = load(crfFile);
st = get_first_struct(S);

gen = get_struct_field(st, {'General_info', 'general_info', 'GeneralInfo', 'general'});
meds = get_struct_field(st, {'meds', 'Meds', 'medications', 'Medications'});

gafStruct = get_struct_field(st, {'GAF'});
madrsStruct = get_struct_field(st, {'MADRS'});
ymrsStruct = get_struct_field(st, {'MARS', 'YMRS'});

cov.Age = get_field_num(gen, {'Age_at_examination', 'Age', 'age', 'AgeAtExamination'});
[cov.Sex, cov.Gender] = parse_sex_gender(gen, st);
cigs = get_field_num(gen, {'Average_number_of_daily_cigarettes', 'AverageNumDailyCigarettes', 'cigarettesPerDay', 'CigsPerDay', 'cigsPerDay'});

if isnan(cigs)
    smk = get_field_num(gen, {'smoker', 'Smoker', 'smoking', 'Smoking'});

    if isnan(smk)
        smk = get_field_num(st, {'smoker', 'Smoker', 'smoking', 'Smoking'});
    end

    if ~isnan(smk) && smk == 0
        cigs = 0;
    end
end

cov.CigsPerDay = cigs;
cov.GAF = get_field_num(gafStruct, {'score', 'Score'});
cov.MADRS = sum_numeric_fields(madrsStruct);
cov.YMRS = sum_numeric_fields(ymrsStruct);
cov.AD = get_field_num(meds, {'AD'});
cov.AP = get_field_num(meds, {'AP'});
cov.MS = get_field_num(meds, {'MS'});
cov.ANX = get_field_num(meds, {'ANX'});
cov.Other = get_field_num(meds, {'OTHER', 'Other'});

end

function st = get_first_struct(S)

st = struct();

if isempty(S)
    return;
end

if isstruct(S) && isscalar(S)
    fn = fieldnames(S);

    for i = 1: numel(fn)
        if isstruct(S.(fn{i}))
            st = S.(fn{i});
            return;
        end
    end

    st = S;
end

end

function out = get_struct_field(st, names)

out = struct();

if ~isstruct(st)
    return;
end

for i = 1: numel(names)
    if isfield(st, names{i}) && isstruct(st.(names{i}))
        out = st.(names{i});
        return;
    end
end

end

function v = get_field_num(st, names)

v = NaN;

if ~isstruct(st)
    return;
end

for i = 1: numel(names)
    nm = names{i};

    if isfield(st, nm)
        x = st.(nm);

        if iscell(x) && isscalar(x)
            x = x{1};
        end

        if ischar(x) || isstring(x)
            x = str2double(string(x));
        end

        if isnumeric(x) && isscalar(x)
            v = double(x);
            return;
        end
    end
end

end

function x = get_field_any(st, names)

x = [];

if ~isstruct(st)
    return;
end

for i = 1: numel(names)
    if isfield(st, names{i})
        x = st.(names{i});
        return;
    end
end

end

function s = sum_numeric_fields(st)

s = NaN;

if ~isstruct(st)
    return;
end

fn = fieldnames(st);
vals = [];

for i = 1: numel(fn)
    x = st.(fn{i});

    if ischar(x) || isstring(x)
        x = str2double(string(x));
    end

    if isnumeric(x) && isscalar(x)
        vals(end + 1, 1) = double(x);
    end
end

if ~isempty(vals)
    s = sum(vals, 'omitnan');
end

end

function [sexCode, genderLabel] = parse_sex_gender(gen, st)

% Sex is coded for modeling as Male = 1 and Female = 0 when recoverable from the CRF.
% GenderLabel is retained for auditability and future descriptive tables.

sexCode = NaN;
genderLabel = "";
x = get_field_any(gen, {'Gender', 'gender', 'Sex', 'sex', 'BiologicalSex', 'biologicalSex'});

if isempty(x)
    x = get_field_any(st, {'Gender', 'gender', 'Sex', 'sex', 'BiologicalSex', 'biologicalSex'});
end

if isempty(x)
    return;
end

if iscell(x) && ~isempty(x)
    x = x{1};
end

if isnumeric(x) && isscalar(x)
    val = double(x);

    if ismember(val, [0 1])
        sexCode = val;
    elseif val == 2
        sexCode = 0;
    end
elseif ischar(x) || isstring(x) || iscategorical(x)
    sx = lower(strtrim(string(x)));

    if any(sx == ["m" "male" "man" "masculin" "homme"])
        sexCode = 1;
        genderLabel = "Male";
    elseif any(sx == ["f" "female" "woman" "feminin" "feminine" "femme"])
        sexCode = 0;
        genderLabel = "Female";
    else
        maybeNum = str2double(sx);

        if isfinite(maybeNum)
            if maybeNum == 1
                sexCode = 1;
            elseif maybeNum == 0 || maybeNum == 2
                sexCode = 0;
            end
        end
    end
end

if strlength(genderLabel) == 0 && isfinite(sexCode)
    if sexCode == 1
        genderLabel = "Male";
    elseif sexCode == 0
        genderLabel = "Female";
    end
end

end

function EEG = load_eeg_file(filePath)

EEG = [];

if strlength(string(filePath)) == 0 || ~exist(filePath, 'file')
    return;
end

[~, ~, ext] = fileparts(char(filePath));

try
    switch lower(ext)
        case '.set'
            EEG = pop_loadset(char(filePath));
            EEG = eeg_checkset(EEG);
        case '.mat'
            EEG = load_eeg_from_mat(char(filePath));
            EEG = normalize_eeg_struct(EEG);
        otherwise
            warning('Unsupported EEG file extension: %s', ext);
    end
catch ME
    warning('Could not load %s: %s', char(filePath), ME.message);
    EEG = [];
end

end

function EEG = load_eeg_from_mat(matFile)

EEG = [];

S = load(matFile);

if isfield(S, 'EEG')
    EEG = S.EEG;
    return;
end

fn = fieldnames(S);

for i = 1: numel(fn)
    v = S.(fn{i});

    if isstruct(v) && isfield(v, 'data') && isfield(v, 'srate')
        EEG = v;
        return;
    end
end

end

function EEG = normalize_eeg_struct(EEG)

if isempty(EEG)
    return;
end

if ~isfield(EEG, 'data') || ~isfield(EEG, 'srate')
    EEG = [];
    return;
end

EEG.data = double(EEG.data);
EEG.nbchan = size(EEG.data, 1);

if ndims(EEG.data) == 2
    EEG.pnts = size(EEG.data, 2);
    EEG.trials = 1;
elseif ndims(EEG.data) == 3
    EEG.pnts = size(EEG.data, 2);
    EEG.trials = size(EEG.data, 3);
else
    EEG = [];
    return;
end

if ~isfield(EEG, 'chanlocs') || isempty(EEG.chanlocs)
    EEG.chanlocs = repmat(struct('labels', '', 'type', ''), EEG.nbchan, 1);
end

if ~isfield(EEG, 'event')
    EEG.event = struct([]);
end

if ~isfield(EEG, 'xmin') || isempty(EEG.xmin) || ~isnumeric(EEG.xmin)
    EEG.xmin = 0;
end

if ~isfield(EEG, 'xmax') || isempty(EEG.xmax) || ~isnumeric(EEG.xmax)
    EEG.xmax = EEG.xmin + (EEG.pnts - 1) / EEG.srate;
end

end

function ch = identify_channels(EEG, roiLabels, allowROIFallback)

if nargin < 3 || isempty(allowROIFallback)
    allowROIFallback = false;
end

emptyCh = struct('ecgIdx', [], 'eogIdx', [], 'eegIdx', [], 'roiIdx', [], 'roiActualLabels', strings(0, 1), 'roiRequestedLabels', string(roiLabels(:)), 'roiMissingLabels', string(roiLabels(:)), 'roiUsedFallback', false, 'roiNRequested', numel(roiLabels), 'roiNActual', 0, 'roiComplete', false);

if isempty(EEG) || ~isfield(EEG, 'nbchan')
    ch = emptyCh;
    return;
end

labels = strings(EEG.nbchan, 1);
types = strings(EEG.nbchan, 1);

for i = 1: EEG.nbchan
    if numel(EEG.chanlocs) >= i
        if isfield(EEG.chanlocs(i), 'labels') && ~isempty(EEG.chanlocs(i).labels)
            labels(i) = upper(string(EEG.chanlocs(i).labels));
        end
        if isfield(EEG.chanlocs(i), 'type') && ~isempty(EEG.chanlocs(i).type)
            types(i) = upper(string(EEG.chanlocs(i).type));
        end
    end
end

ecgIdx = find(contains(labels, 'ECG') | contains(labels, 'EKG') | types == "ECG", 1);

if isempty(ecgIdx) && EEG.nbchan >= 65
    ecgIdx = 65;
end

eogIdx = find(contains(labels, 'EOG') | types == "EOG");

if isempty(eogIdx) && EEG.nbchan >= 64
    eogIdx = intersect((63: 64)', (1: EEG.nbchan)');
end

auxIdx = unique([ecgIdx; eogIdx(:)]);
eegIdx = setdiff((1: EEG.nbchan)', auxIdx);
roiIdx = [];
roiUsedFallback = false;

for i = 1: numel(roiLabels)
    idx = find(strcmpi(string({EEG.chanlocs.labels}), roiLabels{i}), 1);

    if ~isempty(idx)
        roiIdx(end + 1, 1) = idx;
    end
end

if isempty(roiIdx) && allowROIFallback
    fallback = {'Cz', 'FCz', 'Fz'};

    for i = 1: numel(fallback)
        idx = find(strcmpi(string({EEG.chanlocs.labels}), fallback{i}), 1);

        if ~isempty(idx)
            roiIdx(end + 1, 1) = idx;
        end
    end

    roiUsedFallback = ~isempty(roiIdx);
end

roiActualLabels = strings(numel(roiIdx), 1);

for i = 1: numel(roiIdx)
    if numel(EEG.chanlocs) >= roiIdx(i) && isfield(EEG.chanlocs(roiIdx(i)), 'labels')
        roiActualLabels(i, 1) = string(EEG.chanlocs(roiIdx(i)).labels);
    end
end

roiRequestedLabels = string(roiLabels(:));
roiMissingLabels = roiRequestedLabels(~ismember(upper(roiRequestedLabels), upper(roiActualLabels)));
roiComplete = isempty(roiMissingLabels);

if ~allowROIFallback && ~isempty(roiRequestedLabels) && ~roiComplete
    error('Planned R-locked ROI is incomplete. Missing channel labels: %s. No partial ROI or fallback ROI is allowed.', char(strjoin(roiMissingLabels, ', ')));
end

ch = struct('ecgIdx', ecgIdx, 'eogIdx', eogIdx, 'eegIdx', eegIdx, 'roiIdx', roiIdx, 'roiActualLabels', roiActualLabels, 'roiRequestedLabels', roiRequestedLabels, 'roiMissingLabels', roiMissingLabels, 'roiUsedFallback', roiUsedFallback, 'roiNRequested', numel(roiLabels), 'roiNActual', numel(roiIdx), 'roiComplete', roiComplete);

end


function [EEG, info] = apply_rest_analysis_lowpass_filter(EEG, eegIdx, hep)

info = struct('lowpassHz', NaN, 'order', NaN, 'applied', false, 'nChannels', 0);
lowpassHz = get_hep_field_default(hep, 'analysisLowpassHz', NaN);

if ~isfinite(lowpassHz) || lowpassHz <= 0
    return;
end

filterOrder = get_hep_field_default(hep, 'analysisLowpassOrder', 4);
filterOrder = max(1, round(double(filterOrder)));
info.lowpassHz = double(lowpassHz);
info.order = double(filterOrder);

if isempty(EEG) || ~isfield(EEG, 'data') || ~isfield(EEG, 'srate') || isempty(eegIdx)
    return;
end

fs = double(EEG.srate);

if ~isfinite(fs) || fs <= 0
    return;
end

nyqHz = fs / 2;

if lowpassHz >= nyqHz
    warning('Requested resting analysis low-pass cutoff %.3f Hz is at or above Nyquist %.3f Hz; skipping filter.', lowpassHz, nyqHz);
    return;
end

eegIdx = double(eegIdx(:));
eegIdx = eegIdx(isfinite(eegIdx));
eegIdx = round(eegIdx);
eegIdx = eegIdx(eegIdx >= 1 & eegIdx <= size(EEG.data, 1));
eegIdx = unique(eegIdx, 'stable');

if isempty(eegIdx)
    return;
end

[b, a] = butter(filterOrder, lowpassHz / nyqHz, 'low');
padRequirement = 3 * (max(numel(a), numel(b)) - 1);

if size(EEG.data, 2) <= padRequirement
    warning('Resting EEG data are too short for the requested analysis low-pass filter; skipping filter.');
    return;
end

for i = 1: numel(eegIdx)
    chIdx = eegIdx(i);
    x = double(EEG.data(chIdx, :));

    if any(~isfinite(x))
        x = fillmissing(x, 'linear', 'EndValues', 'nearest');
    end

    if all(isfinite(x)) && std(x, 0, 'omitnan') > 0
        EEG.data(chIdx, :) = filtfilt(b, a, x);
        info.nChannels = info.nChannels + 1;
    end
end

info.applied = info.nChannels > 0;

try
    EEG = eeg_checkset(EEG);
catch
end

end


function restRec = process_rest_subject(EEG, restRec, hep, hrv, robust, ecgdet, ecgset)

EEG = eeg_checkset(EEG);
restRec.Rest_DurationSec = EEG.pnts / EEG.srate;
restRec.Rest_Srate = EEG.srate;

ch = identify_channels(EEG, {}, true);

[EEG, analysisLowpassInfo] = apply_rest_analysis_lowpass_filter(EEG, ch.eegIdx, hep);
restRec.Rest_EEG_AnalysisLowpassHz = analysisLowpassInfo.lowpassHz;
restRec.Rest_EEG_AnalysisLowpassOrder = analysisLowpassInfo.order;
restRec.Rest_EEG_AnalysisLowpassApplied = analysisLowpassInfo.applied;
restRec.Rest_EEG_AnalysisLowpassNChannels = analysisLowpassInfo.nChannels;

if isfield(restRec, 'RestFile')
    restFilePath = string(restRec.RestFile);
else
    restFilePath = "";
end

if strlength(restFilePath) == 0 || exist(char(restFilePath), 'file') ~= 2
    restFilePath = first_existing_file({fullfile(restRec.SubjectDir, 'Processed', sprintf('%s_rest_processed.set', char(restRec.Subject))), fullfile(restRec.SubjectDir, 'Processed', sprintf('%s_rest_processed.mat', char(restRec.Subject)))});
end

if strlength(restFilePath) == 0
    restFilePath = first_existing_file({fullfile(restRec.SubjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', char(restRec.Subject))), fullfile(restRec.SubjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', char(restRec.Subject)))});
end

ann = load_manual_continuous_beat_annotations(restFilePath);

if ~ann.hasFile
    error('Missing manual beat sidecar for subject %s: %s', char(restRec.Subject), char(manual_bad_mat_file(restFilePath)));
end

if isempty(ann.allRSamp)
    error('Manual beat sidecar contains no allRSamp beats for subject %s: %s', char(restRec.Subject), char(manual_bad_mat_file(restFilePath)));
end

if ~isempty(ann.badRSamp) && ~all(ismember(double(ann.badRSamp(:)), double(ann.allRSamp(:))))
    error('Manual beat sidecar contains badRSamp values that are not present in allRSamp for subject %s: %s', char(restRec.Subject), char(manual_bad_mat_file(restFilePath)));
end

ann.allRSamp = unique(double(ann.allRSamp(:)));
ann.badRSamp = unique(double(ann.badRSamp(:)));
ann.addedRSamp = unique(double(ann.addedRSamp(:)));
ann.allRSamp = merge_added_continuous_beats(ann.allRSamp, ann.addedRSamp);
ann.invalidSegmentsSamp = normalize_invalid_segments_samp(ann.invalidSegmentsSamp, EEG.pnts);
[ann, invalidPeakInfo] = apply_invalid_segments_to_continuous_annotations(ann, EEG.pnts);

if ~isempty(ann.badRSamp) && ~all(ismember(double(ann.badRSamp(:)), double(ann.allRSamp(:))))
    error('Manual beat sidecar contains badRSamp values that are not present in allRSamp after invalid-segment filtering for subject %s: %s', char(restRec.Subject), char(manual_bad_mat_file(restFilePath)));
end

if isempty(setdiff(double(ann.allRSamp(:)), double(ann.badRSamp(:)), 'stable'))
    error('Manual beat sidecar leaves no good R peaks after manual QC for subject %s: %s', char(restRec.Subject), char(manual_bad_mat_file(restFilePath)));
end

restRec.Rest_Rpeaks_AllMarked_N = invalidPeakInfo.nAllInput;
restRec.Rest_Rpeaks_BadMarked_N = invalidPeakInfo.nBadInput;
restRec.Rest_Rpeaks_Added_N = invalidPeakInfo.nAddedInput;
restRec.Rest_Rpeaks_InvalidSegmentRemoved_N = invalidPeakInfo.nAllRemoved;
restRec.Rest_ManualInvalidSegment_N = size(ann.invalidSegmentsSamp, 1);
restRec.Rest_ManualInvalidSegment_TotalSec = sum(diff(ann.invalidSegmentsSamp, 1, 2), 'omitnan') / EEG.srate;

if restRec.Rest_Rpeaks_AllMarked_N > 0
    restRec.Rest_ManualBadPeakFrac = restRec.Rest_Rpeaks_BadMarked_N / restRec.Rest_Rpeaks_AllMarked_N;
end

rSampMaster = ann.allRSamp;
badMaskMerged = ismember(double(rSampMaster(:)), double(ann.badRSamp(:)));

% For resting analyses, manually marked bad beats are excluded and manually added missed beats are included from the resting
% sidecar file. The final NN series must be computed from the corrected good R sequence, not from all detected candidates, because false
% S/QRS detections can sit between two valid manually added R peaks.

[rSamp, rrSec, hrvFeat, nnInfo] = exclude_suspicious_rest_rpeaks(rSampMaster, badMaskMerged, EEG.srate, hrv, ann.invalidSegmentsSamp);

restRec.Rest_Rpeaks_N = numel(rSamp);

if restRec.Rest_Rpeaks_N > 0
    restRec.Rest_ManualAddedPeakFrac = restRec.Rest_Rpeaks_Added_N / restRec.Rest_Rpeaks_N;
end

restRec.Rest_MeanHR_BPM = hrvFeat.meanHR;
restRec.Rest_SDNN_ms = hrvFeat.SDNNms;
restRec.Rest_RRIntervals_N = numel(nnInfo.rrSecAll);
restRec.Rest_NNIntervals_N = sum(nnInfo.validIntervalMask);

if isfield(nnInfo, 'manualInvalidIntervalMask')
    restRec.Rest_NNIntervals_ManualInvalid_N = sum(nnInfo.manualInvalidIntervalMask);
end

if restRec.Rest_RRIntervals_N > 0
    restRec.Rest_NNIntervalValidFrac = restRec.Rest_NNIntervals_N / restRec.Rest_RRIntervals_N;
    restRec.Rest_NNIntervalRejectedFrac = 1 - restRec.Rest_NNIntervalValidFrac;
end

if isfinite(restRec.Rest_MeanHR_BPM)
    restRec.Rest_HRV_QCFlag_LowOrHighHR = restRec.Rest_MeanHR_BPM < hrv.flagMeanHRLowBpm | restRec.Rest_MeanHR_BPM > hrv.flagMeanHRHighBpm;
end

if isfinite(restRec.Rest_NNIntervalRejectedFrac)
    restRec.Rest_HRV_QCFlag_HighRejectedFrac = restRec.Rest_NNIntervalRejectedFrac > hrv.flagRRRejectedFrac;
end

if ~isnan(restRec.Rest_HRV_QCFlag_LowOrHighHR) || ~isnan(restRec.Rest_HRV_QCFlag_HighRejectedFrac)
    restRec.Rest_HRV_QCFlag = any([restRec.Rest_HRV_QCFlag_LowOrHighHR restRec.Rest_HRV_QCFlag_HighRejectedFrac] == 1);
end

if ~isnan(hrvFeat.RMSSDms)
    restRec.Rest_lnRMSSD = log(max(hrvFeat.RMSSDms, eps));
end


end

function [rSamp, rrSec, hrvFeat, qc, lowConfMask] = compute_hrv_from_ecg(EEG, ecgIdx, hrv, ecgdet)

qc = struct('rrInvalidOrOutlierRate', NaN);
hrvFeat = struct('meanHR', NaN, 'SDNNms', NaN, 'RMSSDms', NaN);
rSamp = [];
rrSec = [];
lowConfMask = [];

if isempty(ecgIdx)
    return;
end

ecg = double(EEG.data(ecgIdx, :));
fs = EEG.srate;
[rSamp, lowConfMask] = detect_rpeaks_from_ecg(ecg, fs, ecgdet);

if numel(rSamp) < 10
    qc.rrInvalidOrOutlierRate = 1;
    return;
end

rrSec = diff(rSamp) / fs;
qc.rrInvalidOrOutlierRate = NaN;
rrClean = rrSec;

if numel(rrClean) < 10
    return;
end

hrvFeat.meanHR = 60 / mean(rrClean, 'omitnan');
hrvFeat.SDNNms = 1000 * std(rrClean, 0, 'omitnan');
drr = diff(rrClean);
hrvFeat.RMSSDms = 1000 * sqrt(mean(drr .^ 2, 'omitnan'));

end

function [rSampClean, rrSecClean, hrvFeat, nnInfo] = exclude_suspicious_rest_rpeaks(rSampAll, lowConfMask, fs, hrv, invalidSegmentsSamp)

rSampClean = [];
rrSecClean = [];
hrvFeat = struct('meanHR', NaN, 'SDNNms', NaN, 'RMSSDms', NaN);

if nargin < 5
    invalidSegmentsSamp = [];
end

nnInfo = build_clean_nn_series_from_annotations(rSampAll, lowConfMask, fs, hrv, invalidSegmentsSamp);

if isempty(nnInfo.rSampAll)
    return;
end

rSampClean = nnInfo.goodRSamp;
rrSecClean = nnInfo.rrSecAll(nnInfo.validIntervalMask);
hrvFeat = nnInfo.hrvFeat;

end

function nnInfo = build_clean_nn_series_from_annotations(rSampAll, badBeatMask, fs, hrv, invalidSegmentsSamp)

nnInfo = struct('rSampAll', [], 'goodRSamp', [], 'badBeatMask', [], 'rrSecAll', [], 'rrPeakSamp', [], 'validIntervalMask', [], 'manualInvalidIntervalMask', [], 'invalidSegmentsSamp', [], 'hrvFeat', struct('meanHR', NaN, 'SDNNms', NaN, 'RMSSDms', NaN));

if nargin < 5
    invalidSegmentsSamp = [];
end

invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp);
nnInfo.invalidSegmentsSamp = invalidSegmentsSamp;

if isempty(rSampAll)
    return;
end

rSampAll = double(rSampAll(:));
badBeatMask = logical(badBeatMask(:));

if isempty(badBeatMask) || numel(badBeatMask) ~= numel(rSampAll)
    badBeatMask = false(size(rSampAll));
end

goodRSamp = rSampAll(~badBeatMask);
goodRSamp = unique(goodRSamp(:), 'stable');

nnInfo.rSampAll = goodRSamp;
nnInfo.goodRSamp = goodRSamp;
nnInfo.badBeatMask = false(size(goodRSamp));

if numel(goodRSamp) < 2
    return;
end

rrSecAll = diff(goodRSamp) / fs;
intervalStartSamp = goodRSamp(1: end - 1);
intervalEndSamp = goodRSamp(2: end);
manualInvalidIntervalMask = intervals_overlap_invalid_segments(intervalStartSamp, intervalEndSamp, invalidSegmentsSamp);
validIntervalMask = ~manualInvalidIntervalMask;

nnInfo.rrSecAll = rrSecAll;
nnInfo.rrPeakSamp = goodRSamp(2: end);
nnInfo.validIntervalMask = validIntervalMask;
nnInfo.manualInvalidIntervalMask = manualInvalidIntervalMask;
nnInfo.hrvFeat = compute_hrv_features_from_valid_intervals(rrSecAll, validIntervalMask);

end

function hrvFeat = compute_hrv_features_from_valid_intervals(rrSecAll, validIntervalMask)

hrvFeat = struct('meanHR', NaN, 'SDNNms', NaN, 'RMSSDms', NaN);

if isempty(rrSecAll) || isempty(validIntervalMask)
    return;
end

rrSecAll = double(rrSecAll(:));
validIntervalMask = logical(validIntervalMask(:));

if numel(validIntervalMask) ~= numel(rrSecAll)
    return;
end

validIdx = find(validIntervalMask);

if numel(validIdx) < 10
    return;
end

rrValid = rrSecAll(validIdx);
hrvFeat.meanHR = 60 / mean(rrValid, 'omitnan');
hrvFeat.SDNNms = 1000 * std(rrValid, 0, 'omitnan');

if numel(validIdx) >= 2
    consecMask = diff(validIdx) == 1;
    drr = diff(rrValid);
    drr = drr(consecMask);

    if ~isempty(drr)
        hrvFeat.RMSSDms = 1000 * sqrt(mean(drr .^ 2, 'omitnan'));
    end
end

end

function [rSamp, lowConfMask] = detect_rpeaks_from_ecg(ecg, fs, ecgdet)

rSamp = [];
lowConfMask = [];

if isempty(ecg)
    return;
end

ecgRaw = double(ecg(:)');
qrs = filter_ecg_for_rpeak_detection(ecgRaw, fs, ecgdet);
env = qrs .^ 2;
env = movmean(env, max(1, round(ecgdet.envSmoothSec * fs)));

thr = median(env, 'omitnan') + ecgdet.primaryMAD * mad(env, 1);
minDist = round(ecgdet.minPeakDistanceSec * fs);

[~, locs] = findpeaks(env, 'MinPeakDistance', minDist, 'MinPeakHeight', thr);
rSamp = locs(:);

if numel(rSamp) < 10
    thr = median(env, 'omitnan') + ecgdet.fallbackMAD * mad(env, 1);
    [~, locs] = findpeaks(env, 'MinPeakDistance', minDist, 'MinPeakHeight', thr);
    rSamp = locs(:);
end

if isempty(rSamp)
    return;
end

[rSamp, ~] = refine_rpeaks_to_local_extremum(ecgRaw, qrs, rSamp, fs, ecgdet);
lowConfMask = false(size(rSamp));

end

function qrs = filter_ecg_for_rpeak_detection(ecg, fs, ecgdet)

qrs = double(ecg(:)');
qrs = qrs - median(qrs, 'omitnan');

loHz = ecgdet.bandpassHz(1);
hiHz = ecgdet.bandpassHz(2);

if hiHz >= fs / 2
    hiHz = fs / 2 - eps;
end

if loHz <= 0 || hiHz <= loHz
    return;
end

try
    [b, a] = butter(2, [loHz hiHz] / (fs / 2), 'bandpass');
    qrs = filtfilt(b, a, qrs);
catch
end

end

function domPolarity = estimate_ecg_dominant_polarity(ecgFilt, coarseSamp, fs, ecgdet)

domPolarity = -1;

if isfield(ecgdet, 'forcePolarity') && ~isempty(ecgdet.forcePolarity)
    pol = lower(string(ecgdet.forcePolarity));

    if pol == "negative"
        domPolarity = -1;
        return;
    elseif pol == "positive"
        domPolarity = 1;
        return;
    end
end

if isempty(coarseSamp)
    return;
end

nSamp = numel(ecgFilt);
refineHalfWin = max(1, round(ecgdet.refineWindowSec * fs));
signedAmp = nan(numel(coarseSamp), 1);

for i = 1: numel(coarseSamp)
    c = coarseSamp(i);
    s0 = max(1, c - refineHalfWin);
    s1 = min(nSamp, c + refineHalfWin);
    segFilt = ecgFilt(s0: s1);

    if isempty(segFilt) || all(~isfinite(segFilt))
        continue;
    end

    [peakVal, ~] = max(segFilt);
    [troughVal, ~] = min(segFilt);

    if abs(troughVal) >= abs(peakVal)
        signedAmp(i) = troughVal;
    else
        signedAmp(i) = peakVal;
    end
end

signedAmp = signedAmp(isfinite(signedAmp));

if isempty(signedAmp)
    return;
end

if median(signedAmp, 'omitnan') > 0
    domPolarity = 1;
else
    domPolarity = -1;
end

end

function [rSamp, lowConfMask] = refine_rpeaks_to_local_extremum(ecgRaw, ecgFilt, coarseSamp, fs, ecgdet)

rSamp = coarseSamp(:);
lowConfMask = false(size(rSamp));

if isempty(rSamp)
    return;
end

nSamp = numel(ecgRaw);
refineHalfWin = max(1, round(ecgdet.refineWindowSec * fs));
rawSnapHalfWin = max(1, round(ecgdet.rawSnapWindowSec * fs));
edgeMargin = max(1, round(ecgdet.lowConfEdgeMarginSec * fs));
peakAmp = nan(numel(rSamp), 1);
nearEdgeMask = false(numel(rSamp), 1);
compRatio = nan(numel(rSamp), 1);
domPolarity = estimate_ecg_dominant_polarity(ecgFilt, rSamp, fs, ecgdet);

for i = 1: numel(rSamp)
    c = rSamp(i);
    s0 = max(1, c - refineHalfWin);
    s1 = min(nSamp, c + refineHalfWin);

    segFilt = ecgFilt(s0: s1);

    [peakVal, peakRel] = max(segFilt);
    [troughVal, troughRel] = min(segFilt);

    if domPolarity < 0
        domIdx = s0 + troughRel - 1;
        domSign = -1;
        domAmp = abs(troughVal);
    else
        domIdx = s0 + peakRel - 1;
        domSign = 1;
        domAmp = abs(peakVal);
    end

    r0 = max(1, domIdx - rawSnapHalfWin);
    r1 = min(nSamp, domIdx + rawSnapHalfWin);
    segRaw = ecgRaw(r0: r1);

    if domSign >= 0
        [~, rawRel] = max(segRaw);
    else
        [~, rawRel] = min(segRaw);
    end

    refinedIdx = r0 + rawRel - 1;
    rSamp(i) = refinedIdx;
    peakAmp(i) = domAmp;

    nearEdge = (domIdx - s0) <= edgeMargin || (s1 - domIdx) <= edgeMargin;

    compSeg = abs(segFilt);
    domLocal = domIdx - s0 + 1;
    comp0 = max(1, domLocal - max(1, round(0.010 * fs)));
    comp1 = min(numel(compSeg), domLocal + max(1, round(0.010 * fs)));
    compSeg(comp0: comp1) = -Inf;
    secondAmp = max(compSeg, [], 'omitnan');

    if ~isfinite(secondAmp)
        secondAmp = 0;
    end

    nearEdgeMask(i) = nearEdge;
    peakAmp(i) = domAmp;

    if domAmp > 0 && secondAmp > 0
        compRatio(i) = secondAmp / domAmp;
    else
        compRatio(i) = 0;
    end
end

if any(isfinite(peakAmp))
    ampMed = median(peakAmp(isfinite(peakAmp)), 'omitnan');

    if isfinite(ampMed) && ampMed > 0
        lowAmpMask = peakAmp < ecgdet.lowConfAmpFrac * ampMed;
        competingMask = compRatio >= ecgdet.lowConfCompetingFrac & peakAmp < ecgdet.lowConfCompetingAmpFrac * ampMed;
        lowConfMask = nearEdgeMask | lowAmpMask | competingMask;
    else
        lowConfMask = nearEdgeMask;
    end
else
    lowConfMask = nearEdgeMask;
end

[rSamp, keepMask] = enforce_rpeak_refractory(rSamp, ecgFilt, round(ecgdet.minPeakDistanceSec * fs));
lowConfMask = lowConfMask(keepMask);

end

function [rSamp, keepMask] = enforce_rpeak_refractory(rSamp, ecgFilt, minDistSamp)

rSamp = rSamp(:);
keepMask = true(size(rSamp));

if isempty(rSamp)
    return;
end

[~, ord] = sort(rSamp);
rSorted = rSamp(ord);
keepSorted = true(size(rSorted));

i = 2;

while i <= numel(rSorted)
    if (rSorted(i) - rSorted(i - 1)) < minDistSamp
        prev0 = max(1, rSorted(i - 1) - 1);
        prev1 = min(numel(ecgFilt), rSorted(i - 1) + 1);
        curr0 = max(1, rSorted(i) - 1);
        curr1 = min(numel(ecgFilt), rSorted(i) + 1);
        ampPrev = max(abs(ecgFilt(prev0: prev1)));
        ampCurr = max(abs(ecgFilt(curr0: curr1)));

        if ampPrev >= ampCurr
            keepSorted(i) = false;
        else
            keepSorted(i - 1) = false;
        end
    end

    i = i + 1;
end

keepMask(ord(~keepSorted)) = false;
rSamp = rSorted(keepSorted);

end


function value = get_hep_field_default(hep, fieldName, defaultValue)

value = defaultValue;

if isstruct(hep) && isfield(hep, fieldName) && ~isempty(hep.(fieldName)) && isfinite(hep.(fieldName))
    value = hep.(fieldName);
end

end

function x = finite_max_abs(v)

v = abs(double(v(:)));
v = v(isfinite(v));

if isempty(v)
    x = NaN;
else
    x = max(v);
end

end

function sig = make_metric_settings_signature(branchName, hrv, hep, robust, covarFields)

branchName = string(branchName);
parts = strings(0, 1);
parts(end + 1, 1) = "SignatureVersion|MetricSettings_RLockedField_v1";
parts(end + 1, 1) = "Branch|" + branchName;
parts(end + 1, 1) = "Covariates|" + canonical_value_string(covarFields);

if branchName == "Rest"
    parts(end + 1, 1) = "hrv|" + canonical_value_string(hrv);
    parts(end + 1, 1) = "hep|" + canonical_value_string(hep);
    parts(end + 1, 1) = "robustMetric|" + canonical_value_string(metric_robust_settings_for_signature(robust));
else
    parts(end + 1, 1) = "UnknownBranch";
end

sig = strjoin(parts, "||");

end

function S = metric_robust_settings_for_signature(robust)

S = struct();

if isstruct(robust)
    if isfield(robust, 'beatRobustOpts')
        S.beatRobustOpts = robust.beatRobustOpts;
    end

    if isfield(robust, 'hepOutlierMAD')
        S.hepOutlierMAD = robust.hepOutlierMAD;
    end

    if isfield(robust, 'minFiniteHEPForOutlierFilter')
        S.minFiniteHEPForOutlierFilter = robust.minFiniteHEPForOutlierFilter;
    end
end

end

function s = canonical_value_string(x)

try
    s = string(jsonencode(orderfields_recursive(x)));
catch
    try
        s = string(evalc('disp(x)'));
        s = regexprep(s, '\s+', ' ');
    catch
        s = "UNSERIALIZABLE";
    end
end

end

function y = orderfields_recursive(x)

if isstruct(x)
    y = orderfields(x);
    fn = fieldnames(y);

    for i = 1: numel(fn)
        y.(fn{i}) = orderfields_recursive(y.(fn{i}));
    end
elseif iscell(x)
    y = x;

    for i = 1: numel(x)
        y{i} = orderfields_recursive(x{i});
    end
else
    y = x;
end

end



function sig = make_subject_source_signature(S, branchName)

branchName = string(branchName);
parts = strings(0, 1);

if branchName == "Rest"
    parts(end + 1, 1) = source_file_signature_part("RestFile", S.RestFile);
    parts(end + 1, 1) = source_file_signature_part("RestSidecar", manual_bad_mat_file(S.RestFile));
    parts(end + 1, 1) = source_file_signature_part("CRFFile", S.CRFFile);
else
    parts(end + 1, 1) = "UnknownBranch";
end

sig = strjoin(parts, "||");

end

function part = source_file_signature_part(label, filePath)

label = string(label);
filePath = string(filePath);

if strlength(filePath) == 0 || ismissing(filePath)
    part = label + "|EMPTY";
    return;
end

if exist(char(filePath), 'file') ~= 2
    part = label + "|MISSING|" + filePath;
    return;
end

d = dir(char(filePath));
part = label + "|" + filePath + "|" + string(sprintf('%.12f', d.datenum)) + "|" + string(d.bytes);

end

function stamp = current_timestamp_string()

stamp = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));

end


function T = finalize_subject_table(T, groupOrder)

if isempty(T)
    return;
end

T = add_gradient_variables(T);
T.GroupFactor = categorical(string(T.ClinicalStage), groupOrder, 'Ordinal', true);
T.Subject = string(T.Subject);

if ismember('MoodState', T.Properties.VariableNames)
    T.MoodState = categorical(string(T.MoodState));
end

if ismember('Subtype', T.Properties.VariableNames)
    T.Subtype = categorical(string(T.Subtype));
end

if ismember('Gender', T.Properties.VariableNames)
    T.Gender = string(T.Gender);
end

if ismember('Sex', T.Properties.VariableNames)
    T.Sex = double(T.Sex);
end

T.ClinicalStage = categorical(string(T.ClinicalStage), {'HC', 'Siblings', 'BD_Euthymic', 'BD_Depressed'}, 'Ordinal', true);
medVars = {'AD', 'AP', 'MS', 'ANX', 'Other'};
T.MedBurden = compute_med_burden_preserve_all_missing(T, medVars);

if ismember('CigsPerDay', T.Properties.VariableNames)
    T.CigsPerDay = double(T.CigsPerDay);
    T.CigsPerDay(T.CigsPerDay < 0) = NaN;
else
    T.CigsPerDay = nan(height(T), 1);
end

end

function T = add_gradient_variables(T)

if isempty(T) || width(T) == 0
    return;
end

oldClinicalStage = strings(height(T), 1);

if ismember('ClinicalStage', T.Properties.VariableNames)
    oldClinicalStage = string(T.ClinicalStage);
end

T.ClinicalStage = strings(height(T), 1);

for i = 1: height(T)
    g = "";

    if ismember('Group', T.Properties.VariableNames)
        gCandidate = string(T.Group(i));

        if ~ismissing(gCandidate) && strlength(gCandidate) > 0
            g = gCandidate;
        end
    end

    if strlength(g) == 0 && strlength(oldClinicalStage(i)) > 0 && ~ismissing(oldClinicalStage(i))
        g = oldClinicalStage(i);
    end

    if g == "HC"
        T.ClinicalStage(i) = "HC";
        T.RiskGradient(i, 1) = 0;
    elseif g == "Siblings"
        T.ClinicalStage(i) = "Siblings";
        T.RiskGradient(i, 1) = 1;
    elseif contains(g, 'Euthymic') || g == "BD_Euthymic"
        T.ClinicalStage(i) = "BD_Euthymic";
        T.RiskGradient(i, 1) = 2;
    elseif contains(g, 'Depressed') || g == "BD_Depressed"
        T.ClinicalStage(i) = "BD_Depressed";
        T.RiskGradient(i, 1) = 3;
    else
        T.ClinicalStage(i) = string(missing);
        T.RiskGradient(i, 1) = NaN;
    end
end

T.IsBD = double(ismember(string(T.ClinicalStage), ["BD_Euthymic" "BD_Depressed"]));

end


function medBurden = compute_med_burden_preserve_all_missing(T, medVars)

% Medication burden is the sum of known medication-category counts. If all
% medication-category fields are missing for a subject, burden remains NaN
% rather than being recoded as zero.

medBurden = nan(height(T), 1);

if isempty(T) || width(T) == 0 || isempty(medVars)
    return;
end

present = ismember(medVars, T.Properties.VariableNames);

if ~any(present)
    return;
end

medMat = nan(height(T), sum(present));
cols = find(present);

for j = 1: numel(cols)
    v = medVars{cols(j)};
    medMat(:, j) = double(T.(v));
end

medBurden = nansum(medMat, 2);
allMissing = all(isnan(medMat), 2);
medBurden(allMissing) = NaN;

end

function T = refresh_med_burden_preserve_all_missing(T)

if isempty(T) || width(T) == 0
    return;
end

medVars = {'AD', 'AP', 'MS', 'ANX', 'Other'};

if any(ismember(medVars, T.Properties.VariableNames))
    T.MedBurden = compute_med_burden_preserve_all_missing(T, medVars);
end

end

function T = sanitize_analysis_output_table(T)

% Remove raw acquisition-folder labels and file-path provenance from saved outputs.
% Output tables use the four-level ClinicalStage variable only.

if isempty(T) || width(T) == 0
    return;
end

T = refresh_med_burden_preserve_all_missing(T);

if ismember('ClinicalStage', T.Properties.VariableNames)
    T.ClinicalStage = categorical(string(T.ClinicalStage), {'HC', 'Siblings', 'BD_Euthymic', 'BD_Depressed'}, 'Ordinal', true);
end

dropVars = {'Group', 'GroupFactor', 'BDMood', 'BDSubtype', 'SubjectDir', 'CRFFile', 'RestFile', 'CGI_S'};
for i = 1: numel(dropVars)
    if ismember(dropVars{i}, T.Properties.VariableNames)
        T.(dropVars{i}) = [];
    end
end


end


function T = add_resting_review_flags(T)

if isempty(T) || ~istable(T)
    return;
end

if ~ismember('Rest_QCReviewFlag', T.Properties.VariableNames)
    T.Rest_QCReviewFlag = nan(height(T), 1);
end

if ~ismember('Rest_QCReviewReasons', T.Properties.VariableNames)
    T.Rest_QCReviewReasons = strings(height(T), 1);
end

for i = 1: height(T)
    reasons = strings(0, 1);

    if table_value_or_nan(T, 'Rest_HRV_QCFlag', i) == 1
        reasons(end + 1, 1) = "HRV_QCFlag";
    end

    if table_value_or_nan(T, 'Rest_NNIntervalRejectedFrac', i) > 0.20
        reasons(end + 1, 1) = "High_NN_rejection_fraction";
    end


    T.Rest_QCReviewFlag(i) = ~isempty(reasons);
    T.Rest_QCReviewReasons(i) = strjoin(reasons, '; ');
end

end

function QC_exceptions_restMetrics(Trest, outDir)

% Export a strict typed review table for resting metrics. The goal is to separate valid but extreme physiological values from cases that may
% reflect signal problems or incomplete analysis, rather than treating all flagged rows as equivalent "exceptions".
% Review flags are prompts for manual inspection, not automatic exclusion decisions. This file is intentionally stricter than
% Table_Resting_QCReviewCases, which is a broader paper-facing manual-review table.

if isempty(Trest)
    writetable(table(), fullfile(outDir, 'QC_exceptions_restMetrics_with_subject_clinicalstage.csv'));
    return;
end

flag = false(height(Trest), 1);
reviewTypes = strings(height(Trest), 1);
reviewNotes = strings(height(Trest), 1);
reviewDisposition = strings(height(Trest), 1);

for i = 1: height(Trest)
    types = strings(0, 1);
    notes = strings(0, 1);
    disposition = strings(0, 1);

    % HRV QC flags identify subjects whose retained NN intervals may not provide a reliable autonomic endpoint. These are manual-review
    % flags rather than automatic exclusions, because the correct decision depends on the ECG trace, R-peak sidecar, and artifact pattern.

    if ismember('Rest_HRV_QCFlag_LowOrHighHR', Trest.Properties.VariableNames) && Trest.Rest_HRV_QCFlag_LowOrHighHR(i) == 1
        types(end + 1, 1) = "review_hrv_mean_hr_out_of_range";
        notes(end + 1, 1) = "Rest_MeanHR_BPM outside predefined QC range";
        disposition(end + 1, 1) = "inspect_ECG_R_peaks_and_manual_sidecar__retain_only_if_beat_series_is_valid";
    end

    if ismember('Rest_HRV_QCFlag_HighRejectedFrac', Trest.Properties.VariableNames) && Trest.Rest_HRV_QCFlag_HighRejectedFrac(i) == 1
        types(end + 1, 1) = "review_hrv_high_rejected_fraction";
        notes(end + 1, 1) = "Rest_NNIntervalRejectedFrac exceeds predefined QC threshold";
        disposition(end + 1, 1) = "inspect_ECG_R_peaks_and_manual_sidecar__consider_exclusion_from_HRV_if_rejection_reflects_artifact";
    end



    if ~isempty(types)
        flag(i) = true;
        reviewTypes(i) = strjoin(types, '; ');
        reviewNotes(i) = strjoin(notes, '; ');
        reviewDisposition(i) = strjoin(unique(disposition, 'stable'), '; ');
    end
end

if ~any(flag)
    writetable(table(), fullfile(outDir, 'QC_exceptions_restMetrics_with_subject_clinicalstage.csv'));
    return;
end

Tqc = Trest(flag, :);

if ismember('ClinicalStage', Tqc.Properties.VariableNames)
    clinicalStage = string(Tqc.ClinicalStage);
elseif ismember('Group', Tqc.Properties.VariableNames)
    clinicalStage = strings(height(Tqc), 1);

    for i = 1: height(Tqc)
        clinicalStage(i) = four_group_label_from_raw_group(Tqc.Group(i));
    end
else
    clinicalStage = strings(height(Tqc), 1);
end

Tout = table();
Tout.ClinicalStage = categorical(clinicalStage, {'HC', 'Siblings', 'BD_Euthymic', 'BD_Depressed'}, 'Ordinal', true);
Tout.QCReviewScope = repmat("Strict_QC_exceptions", height(Tqc), 1);

copyVars = {'Subject', 'Rest_DurationSec', 'Rest_Rpeaks_N', 'Rest_MeanHR_BPM', 'Rest_SDNN_ms', 'Rest_RRIntervals_N', 'Rest_NNIntervals_N', 'Rest_NNIntervalValidFrac', 'Rest_NNIntervalRejectedFrac', 'Rest_NNIntervals_ManualInvalid_N', 'Rest_HRV_QCFlag_LowOrHighHR', 'Rest_HRV_QCFlag_HighRejectedFrac', 'Rest_HRV_QCFlag', 'Rest_lnRMSSD'};

for j = 1: numel(copyVars)
    if ismember(copyVars{j}, Tqc.Properties.VariableNames)
        Tout.(copyVars{j}) = Tqc.(copyVars{j});
    end
end

Tout.ReviewType = reviewTypes(flag);
Tout.ReviewNotes = reviewNotes(flag);
Tout.RecommendedDisposition = reviewDisposition(flag);
writetable(Tout, fullfile(outDir, 'QC_exceptions_restMetrics_with_subject_clinicalstage.csv'));

end


function segments = normalize_invalid_segments_samp(segments, nSamp)

if nargin < 2
    nSamp = [];
end

if isempty(segments)
    segments = zeros(0, 2);
    return;
end

segments = double(segments);

if isvector(segments)
    segments = segments(:);

    if mod(numel(segments), 2) ~= 0
        segments = segments(1: end - 1);
    end

    segments = reshape(segments, 2, [])';
end

if size(segments, 2) > 2
    segments = segments(:, 1: 2);
elseif size(segments, 2) < 2
    segments = zeros(0, 2);
    return;
end

segments = round(segments);
segments = sort(segments, 2);
ok = all(isfinite(segments), 2) & segments(:, 2) > segments(:, 1);
segments = segments(ok, :);

if isempty(segments)
    segments = zeros(0, 2);
    return;
end

if ~isempty(nSamp) && isfinite(nSamp) && nSamp > 0
    segments(:, 1) = max(1, min(round(nSamp), segments(:, 1)));
    segments(:, 2) = max(1, min(round(nSamp), segments(:, 2)));
    segments = segments(segments(:, 2) > segments(:, 1), :);
end

if isempty(segments)
    segments = zeros(0, 2);
    return;
end

segments = sortrows(segments, 1);
merged = segments(1, :);

for i = 2: size(segments, 1)
    if segments(i, 1) <= merged(end, 2) + 1
        merged(end, 2) = max(merged(end, 2), segments(i, 2));
    else
        merged(end + 1, :) = segments(i, :); 
    end
end

segments = merged;

end

function mask = intervals_overlap_invalid_segments(intervalStartSamp, intervalEndSamp, invalidSegmentsSamp)

intervalStartSamp = double(intervalStartSamp(:));
intervalEndSamp = double(intervalEndSamp(:));
mask = false(size(intervalStartSamp));

invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp);

if isempty(invalidSegmentsSamp) || isempty(mask)
    return;
end

for i = 1: size(invalidSegmentsSamp, 1)
    seg0 = invalidSegmentsSamp(i, 1);
    seg1 = invalidSegmentsSamp(i, 2);
    mask = mask | (intervalStartSamp <= seg1 & intervalEndSamp >= seg0);
end

end

function [ann, invalidPeakInfo] = apply_invalid_segments_to_continuous_annotations(ann, nSamp)

if nargin < 2
    nSamp = [];
end

if ~isfield(ann, 'allRSamp') || isempty(ann.allRSamp)
    ann.allRSamp = [];
end

if ~isfield(ann, 'badRSamp') || isempty(ann.badRSamp)
    ann.badRSamp = [];
end

if ~isfield(ann, 'addedRSamp') || isempty(ann.addedRSamp)
    ann.addedRSamp = [];
end

if ~isfield(ann, 'invalidSegmentsSamp') || isempty(ann.invalidSegmentsSamp)
    ann.invalidSegmentsSamp = [];
end

ann.allRSamp = unique(double(ann.allRSamp(:)), 'stable');
ann.badRSamp = unique(double(ann.badRSamp(:)), 'stable');
ann.addedRSamp = unique(double(ann.addedRSamp(:)), 'stable');
ann.invalidSegmentsSamp = normalize_invalid_segments_samp(ann.invalidSegmentsSamp, nSamp);
ann.invalidIntervalsSamp = ann.invalidSegmentsSamp;

invalidPeakInfo = struct();
invalidPeakInfo.nAllInput = numel(ann.allRSamp);
invalidPeakInfo.nBadInput = numel(ann.badRSamp);
invalidPeakInfo.nAddedInput = numel(ann.addedRSamp);
invalidPeakInfo.nAllRemoved = 0;
invalidPeakInfo.nBadRemoved = 0;
invalidPeakInfo.nAddedRemoved = 0;
invalidPeakInfo.removedAllRSamp = [];
invalidPeakInfo.removedBadRSamp = [];
invalidPeakInfo.removedAddedRSamp = [];

if isempty(ann.invalidSegmentsSamp)
    ann.goodRSamp = setdiff(ann.allRSamp, ann.badRSamp, 'stable');
    return;
end

removeAll = samples_inside_invalid_segments(ann.allRSamp, ann.invalidSegmentsSamp);
removeBad = samples_inside_invalid_segments(ann.badRSamp, ann.invalidSegmentsSamp);
removeAdded = samples_inside_invalid_segments(ann.addedRSamp, ann.invalidSegmentsSamp);

invalidPeakInfo.nAllRemoved = sum(removeAll);
invalidPeakInfo.nBadRemoved = sum(removeBad);
invalidPeakInfo.nAddedRemoved = sum(removeAdded);
invalidPeakInfo.removedAllRSamp = ann.allRSamp(removeAll);
invalidPeakInfo.removedBadRSamp = ann.badRSamp(removeBad);
invalidPeakInfo.removedAddedRSamp = ann.addedRSamp(removeAdded);

ann.allRSamp = ann.allRSamp(~removeAll);
ann.badRSamp = ann.badRSamp(~removeBad);
ann.addedRSamp = ann.addedRSamp(~removeAdded);
ann.goodRSamp = setdiff(ann.allRSamp, ann.badRSamp, 'stable');

end

function mask = samples_inside_invalid_segments(samples, invalidSegmentsSamp)

samples = double(samples(:));
mask = false(size(samples));
invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp);

if isempty(samples) || isempty(invalidSegmentsSamp)
    return;
end

for i = 1: size(invalidSegmentsSamp, 1)
    mask = mask | (samples >= invalidSegmentsSamp(i, 1) & samples <= invalidSegmentsSamp(i, 2));
end

end

function badMatFile = manual_bad_mat_file(eegFilePath)

badMatFile = "";

if strlength(string(eegFilePath)) == 0
    return;
end

[p, n, ~] = fileparts(char(eegFilePath));
nameLower = lower(string(n));
subjectToken = regexp(char(n), 'Subject[_\s-]*(\d+)', 'tokens', 'once');

% Resting-state sidecars are saved with the canonical final-analysis name even when
% the GUI is run on an intermediate preprocessing file such as
% Subject_18_rest_processed_unclean_Not_interpolated_Not_referenced.set. This keeps
% the analysis loader and the GUI save target aligned.

if ~isempty(subjectToken) && contains(nameLower, "rest")
    badMatFile = string(fullfile(p, sprintf('Subject_%s_rest_processed_BadMissingR.mat', subjectToken{1})));
else
    badMatFile = string(fullfile(p, [n '_BadMissingR.mat']));
end

end

function ann = load_manual_continuous_beat_annotations(eegFilePath)

ann = struct('hasFile', false, 'allRSamp', [], 'badRSamp', [], 'goodRSamp', [], 'addedRSamp', [], 'invalidSegmentsSamp', [], 'invalidIntervalsSamp', [], 'forcePolarity', "negative");

badMatFile = manual_bad_mat_file(eegFilePath);

if strlength(badMatFile) == 0 || ~exist(badMatFile, 'file')
    return;
end

S = load(char(badMatFile));
ann.hasFile = true;

if isfield(S, 'allRSamp') && isnumeric(S.allRSamp)
    ann.allRSamp = unique(double(S.allRSamp(:)));
elseif isfield(S, 'detectedRSamp') && isnumeric(S.detectedRSamp)
    ann.allRSamp = unique(double(S.detectedRSamp(:)));

    if isfield(S, 'addedRSamp') && isnumeric(S.addedRSamp)
        ann.allRSamp = unique([ann.allRSamp; double(S.addedRSamp(:))]);
    end
end

if isfield(S, 'badRSamp') && isnumeric(S.badRSamp)
    ann.badRSamp = unique(double(S.badRSamp(:)));
elseif isfield(S, 'badAbsR') && isnumeric(S.badAbsR)
    ann.badRSamp = unique(double(S.badAbsR(:)));
end

if isfield(S, 'addedRSamp') && isnumeric(S.addedRSamp)
    ann.addedRSamp = unique(double(S.addedRSamp(:)));
elseif isfield(S, 'addedAbsR') && isnumeric(S.addedAbsR)
    ann.addedRSamp = unique(double(S.addedAbsR(:)));
end

% Manually added missed beats are part of the authoritative R-peak sequence.
% Merge them explicitly even when a sidecar already contains allRSamp, so older
% or partially saved review files cannot silently omit added peaks from analysis.

if ~isempty(ann.addedRSamp)
    ann.allRSamp = unique([double(ann.allRSamp(:)); double(ann.addedRSamp(:))]);
end

if isfield(S, 'invalidSegmentsSamp') && isnumeric(S.invalidSegmentsSamp)
    ann.invalidSegmentsSamp = normalize_invalid_segments_samp(S.invalidSegmentsSamp);
elseif isfield(S, 'invalidIntervalsSamp') && isnumeric(S.invalidIntervalsSamp)
    ann.invalidSegmentsSamp = normalize_invalid_segments_samp(S.invalidIntervalsSamp);
elseif isfield(S, 'invalidSegmentSamp') && isnumeric(S.invalidSegmentSamp)
    ann.invalidSegmentsSamp = normalize_invalid_segments_samp(S.invalidSegmentSamp);
end

ann.invalidIntervalsSamp = ann.invalidSegmentsSamp;

if isfield(S, 'forcePolarity') && ~isempty(S.forcePolarity)
    ann.forcePolarity = lower(string(S.forcePolarity));
end

if ~isempty(ann.allRSamp)
    ann.goodRSamp = setdiff(ann.allRSamp, ann.badRSamp, 'stable');
end

end

function rSampMerged = merge_added_continuous_beats(rSampAll, addedRSamp)

rSampMerged = double(rSampAll(:));

if isempty(addedRSamp)
    return;
end

rSampMerged = unique([rSampMerged; double(addedRSamp(:))]);

end

function Perform_visual_QC_ui(manualBadMissing, hep, hrv, ecgdet)

currentDir = char(manualBadMissing.initialDir);

while true
    [fileName, filePath] = uigetfile({'*.set', 'EEGLAB .set files'}, 'Choose the continuous resting .set file for manual beat marking', currentDir);

    if isequal(fileName, 0)
        disp('Manual beat marking canceled.');
        return;
    end

    currentDir = filePath;
    setFile = string(fullfile(filePath, fileName));
    EEG = pop_loadset(char(setFile));
    EEG = eeg_checkset(EEG);

    if EEG.trials > 1
        errordlg('Please choose a continuous resting .set file.', 'Invalid file');
        continue;
    end

    ch = identify_channels(EEG, {});
    if isempty(ch.ecgIdx)
        errordlg('Could not identify an ECG channel in the selected dataset.', 'Missing ECG');
        continue;
    end

    ecgData = double(EEG.data(ch.ecgIdx, :));
    badMatFile = manual_bad_mat_file(setFile);
    ann = load_manual_continuous_beat_annotations(setFile);

    if ann.hasFile && ~isempty(ann.allRSamp)
        rSamp = ann.allRSamp;
        badMask = ismember(double(rSamp(:)), double(ann.badRSamp(:)));
        addedRSamp = ann.addedRSamp;
        invalidSegmentsSamp = normalize_invalid_segments_samp(ann.invalidSegmentsSamp, EEG.pnts);
        initialPolarity = ann.forcePolarity;
        allowRedetect = false;
    else
        ecgdetLocal = ecgdet;
        ecgdetLocal.forcePolarity = 'negative';
        [rSamp, ~, ~, ~, ~] = compute_hrv_from_ecg(EEG, ch.ecgIdx, hrv, ecgdetLocal);
        badMask = false(size(rSamp));
        addedRSamp = [];
        invalidSegmentsSamp = [];
        initialPolarity = "negative";
        allowRedetect = true;
    end

    action = manual_bad_beat_viewer(ecgData, EEG.srate, rSamp, badMask, addedRSamp, invalidSegmentsSamp, manualBadMissing, setFile, ch.ecgIdx, badMatFile, ecgdet, initialPolarity, allowRedetect);

    if strcmp(action, 'exit')
        return;
    end
end

end

function action = manual_bad_beat_viewer(ecgData, fs, rSamp, badMask, addedRSamp, invalidSegmentsSamp, manualBadMissing, setFile, ecgIdx, badMatFile, ecgdet, initialPolarity, allowRedetect)

if isempty(rSamp)
    error('No R peaks were detected in the selected dataset.');
end

action = 'exit';
ecgData = double(ecgData(:)');
rSamp = double(rSamp(:));
badMask = logical(badMask(:));

if numel(badMask) ~= numel(rSamp)
    badMask = false(size(rSamp));
end

if isempty(addedRSamp)
    addedRSamp = [];
else
    addedRSamp = unique(double(addedRSamp(:)));
end

invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp, numel(ecgData));
pendingInvalidStartSamp = [];
markMode = "bad";
guiPolarity = lower(string(initialPolarity));

if strlength(guiPolarity) == 0
    guiPolarity = "negative";
end

nSamp = numel(ecgData);
tSec = (0: nSamp - 1) / fs;
windowSec = manualBadMissing.defaultWindowSec;

if ~isfield(manualBadMissing, 'invalidSegmentMinDurationSec') || isempty(manualBadMissing.invalidSegmentMinDurationSec) || ~isfinite(manualBadMissing.invalidSegmentMinDurationSec)
    manualBadMissing.invalidSegmentMinDurationSec = 0.050;
end

if isempty(manualBadMissing.defaultYHalfRange)
    yHalfRange = 3 * std(ecgData, 0, 'omitnan');

    if ~isfinite(yHalfRange) || yHalfRange <= 0
        yHalfRange = max(abs(ecgData), [], 'omitnan');

        if ~isfinite(yHalfRange) || yHalfRange <= 0
            yHalfRange = 1;
        end
    end
else
    yHalfRange = manualBadMissing.defaultYHalfRange;
end

startSec = 0;
clickTolSec = manualBadMissing.clickToleranceSec;

fh = figure('Color', 'w', 'Name', sprintf('Manual resting beat marking [layout v2]: %s', char(setFile)), 'NumberTitle', 'off', 'WindowState', 'maximized');
ax = axes('Parent', fh, 'Position', [0.05 0.16 0.92 0.78]);

uicontrol(fh, 'Style', 'text', 'String', 'Window (s)', 'Units', 'normalized', 'Position', [0.030 0.080 0.060 0.040], 'BackgroundColor', 'w');
hWin = uicontrol(fh, 'Style', 'edit', 'String', num2str(windowSec), 'Units', 'normalized', 'Position', [0.090 0.080 0.045 0.045], 'Callback', @applyWindow);
uicontrol(fh, 'Style', 'text', 'String', 'Y half-range', 'Units', 'normalized', 'Position', [0.140 0.080 0.070 0.040], 'BackgroundColor', 'w');
hY = uicontrol(fh, 'Style', 'edit', 'String', num2str(yHalfRange), 'Units', 'normalized', 'Position', [0.210 0.080 0.045 0.045], 'Callback', @applyYRange);
uicontrol(fh, 'Style', 'text', 'String', 'Mode', 'Units', 'normalized', 'Position', [0.260 0.080 0.035 0.040], 'BackgroundColor', 'w');
hMode = uicontrol(fh, 'Style', 'popupmenu', 'String', {'Bad-R', 'Add-R', 'Invalid interval'}, 'Units', 'normalized', 'Position', [0.295 0.080 0.105 0.050], 'Callback', @changeMode);
uicontrol(fh, 'Style', 'text', 'String', 'Polarity', 'Units', 'normalized', 'Position', [0.405 0.080 0.050 0.040], 'BackgroundColor', 'w');
hPol = uicontrol(fh, 'Style', 'popupmenu', 'String', {'negative', 'positive', 'auto'}, 'Units', 'normalized', 'Position', [0.455 0.080 0.065 0.050], 'Callback', @changePolarity);

if guiPolarity == "positive"
    set(hPol, 'Value', 2);
elseif guiPolarity == "auto"
    set(hPol, 'Value', 3);
else
    set(hPol, 'Value', 1);
end

if ~allowRedetect
    set(hPol, 'Enable', 'off');
end

uicontrol(fh, 'Style', 'pushbutton', 'String', '<<', 'Units', 'normalized', 'Position', [0.535 0.080 0.045 0.050], 'Callback', @goPrev);
uicontrol(fh, 'Style', 'pushbutton', 'String', '>>', 'Units', 'normalized', 'Position', [0.590 0.080 0.045 0.050], 'Callback', @goNext);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Time -', 'Units', 'normalized', 'Position', [0.655 0.080 0.055 0.050], 'Callback', @timeZoomIn);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Time +', 'Units', 'normalized', 'Position', [0.720 0.080 0.055 0.050], 'Callback', @timeZoomOut);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Amp -', 'Units', 'normalized', 'Position', [0.785 0.080 0.055 0.050], 'Callback', @ampZoomIn);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Amp +', 'Units', 'normalized', 'Position', [0.850 0.080 0.055 0.050], 'Callback', @ampZoomOut);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Exit', 'Units', 'normalized', 'Position', [0.915 0.080 0.065 0.050], 'Callback', @exitGui);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Clear bad in view', 'Units', 'normalized', 'Position', [0.64 0.02 0.08 0.05], 'Callback', @clearBadInView);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Clear added in view', 'Units', 'normalized', 'Position', [0.73 0.02 0.08 0.05], 'Callback', @clearAddedInView);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Clear invalid in view', 'Units', 'normalized', 'Position', [0.82 0.02 0.08 0.05], 'Callback', @clearInvalidInView);
uicontrol(fh, 'Style', 'pushbutton', 'String', 'Save + next', 'Units', 'normalized', 'Position', [0.91 0.02 0.08 0.05], 'Callback', @saveAndNext);

set(ax, 'ButtonDownFcn', @toggleNearestBeat);
set(fh, 'WindowButtonDownFcn', @toggleNearestBeat);

renderView();
uiwait(fh);

    function renderView()
        stopSec = min(startSec + windowSec, tSec(end));
        startSec = max(0, stopSec - windowSec);
        idx0 = max(1, floor(startSec * fs) + 1);
        idx1 = min(nSamp, ceil(stopSec * fs) + 1);

        cla(ax);
        hold(ax, 'on');
        plot(ax, tSec(idx0:idx1), ecgData(idx0:idx1), 'k-', 'LineWidth', 1.0, 'HitTest', 'off');

        inView = rSamp >= idx0 & rSamp <= idx1;
        goodMask = inView & ~badMask;
        badViewMask = inView & badMask;
        addedViewMask = addedRSamp >= idx0 & addedRSamp <= idx1;

        if any(goodMask)
            plot(ax, rSamp(goodMask) / fs, ecgData(rSamp(goodMask)), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 5, 'HitTest', 'off');
        end
        if any(badViewMask)
            plot(ax, rSamp(badViewMask) / fs, ecgData(rSamp(badViewMask)), 'rx', 'LineWidth', 2, 'MarkerSize', 8, 'HitTest', 'off');
        end
        if any(addedViewMask)
            plot(ax, addedRSamp(addedViewMask) / fs, ecgData(addedRSamp(addedViewMask)), 'b*', 'LineWidth', 1.5, 'MarkerSize', 8, 'HitTest', 'off');
        end

        xlim(ax, [startSec stopSec]);
        centerIdx = max(idx0, min(idx1, round((idx0 + idx1) / 2)));
        centerVal = ecgData(centerIdx);

        if ~isfinite(centerVal)
            centerVal = 0;
        end

        ylim(ax, [centerVal - yHalfRange centerVal + yHalfRange]);

        yLimPatch = get(ax, 'YLim');
        segInView = invalidSegmentsSamp(:, 1) <= idx1 & invalidSegmentsSamp(:, 2) >= idx0;

        for sg = find(segInView(:))'
            x0 = max(startSec, invalidSegmentsSamp(sg, 1) / fs);
            x1 = min(stopSec, invalidSegmentsSamp(sg, 2) / fs);
            hp = patch(ax, [x0 x1 x1 x0], [yLimPatch(1) yLimPatch(1) yLimPatch(2) yLimPatch(2)], [1.0 0.85 0.20], 'FaceAlpha', 0.25, 'EdgeColor', [0.75 0.50 0.00], 'HitTest', 'off');
            uistack(hp, 'bottom');
        end

        if ~isempty(pendingInvalidStartSamp)
            xPend = pendingInvalidStartSamp / fs;
            plot(ax, [xPend xPend], yLimPatch, 'm--', 'LineWidth', 1.5, 'HitTest', 'off');
        end

        xlabel(ax, 'Time (s)');
        ylabel(ax, sprintf('ECG channel %d', ecgIdx));
        title(ax, sprintf('%s | blue = R, red x = Bad-R, blue * = Added R, yellow = invalid interval | mode: %s | polarity: %s | bad: %d / %d | added: %d | invalid: %d', char(setFile), char(markMode), char(guiPolarity), sum(badMask), numel(rSamp), numel(addedRSamp), size(invalidSegmentsSamp, 1)), 'Interpreter', 'none');
        grid(ax, 'on');
        box(ax, 'off');
    end

    function applyWindow(~, ~)
        v = str2double(get(hWin, 'String'));
        if isfinite(v) && v > 0.5
            windowSec = v;
        end
        set(hWin, 'String', num2str(windowSec));
        renderView();
    end

    function applyYRange(~, ~)
        v = str2double(get(hY, 'String'));
        if isfinite(v) && v > 0
            yHalfRange = v;
        end
        set(hY, 'String', num2str(yHalfRange));
        renderView();
    end

    function changeMode(src, ~)
        pendingInvalidStartSamp = [];
        modeValue = get(src, 'Value');

        if modeValue == 2
            markMode = "add";
        elseif modeValue == 3
            markMode = "invalid";
        else
            markMode = "bad";
        end

        renderView();
    end

    function changePolarity(src, ~)
        if ~allowRedetect
            return;
        end

        opts = string(get(src, 'String'));
        guiPolarity = lower(opts(get(src, 'Value')));
        ecgdetLocal = ecgdet;
        ecgdetLocal.forcePolarity = char(guiPolarity);
        [rNew, ~] = detect_rpeaks_from_ecg(ecgData, fs, ecgdetLocal);
        rSamp = double(rNew(:));
        badMask = false(size(rSamp));
        addedRSamp = [];
        invalidSegmentsSamp = [];
        pendingInvalidStartSamp = [];
        renderView();
    end

    function goPrev(~, ~)
        startSec = max(0, startSec - 0.8 * windowSec);
        renderView();
    end

    function goNext(~, ~)
        startSec = min(max(tSec(end) - windowSec, 0), startSec + 0.8 * windowSec);
        renderView();
    end

    function timeZoomIn(~, ~)
        windowSec = max(1, windowSec / 1.5);
        set(hWin, 'String', num2str(windowSec));
        renderView();
    end

    function timeZoomOut(~, ~)
        windowSec = min(tSec(end), windowSec * 1.5);
        renderView();
    end

    function ampZoomIn(~, ~)
        yHalfRange = max(eps, yHalfRange / 1.5);
        set(hY, 'String', num2str(yHalfRange));
        renderView();
    end

    function ampZoomOut(~, ~)
        yHalfRange = yHalfRange * 1.5;
        renderView();
    end

    function clearBadInView(~, ~)
        stopSec = min(startSec + windowSec, tSec(end));
        idx0 = max(1, floor(startSec * fs) + 1);
        idx1 = min(nSamp, ceil(stopSec * fs) + 1);
        inView = rSamp >= idx0 & rSamp <= idx1;
        badMask(inView) = false;
        renderView();
    end

    function clearAddedInView(~, ~)
        stopSec = min(startSec + windowSec, tSec(end));
        idx0 = max(1, floor(startSec * fs) + 1);
        idx1 = min(nSamp, ceil(stopSec * fs) + 1);
        addedRSamp = addedRSamp(~(addedRSamp >= idx0 & addedRSamp <= idx1));
        renderView();
    end

    function clearInvalidInView(~, ~)
        stopSec = min(startSec + windowSec, tSec(end));
        idx0 = max(1, floor(startSec * fs) + 1);
        idx1 = min(nSamp, ceil(stopSec * fs) + 1);

        if ~isempty(invalidSegmentsSamp)
            keepSeg = ~(invalidSegmentsSamp(:, 1) <= idx1 & invalidSegmentsSamp(:, 2) >= idx0);
            invalidSegmentsSamp = invalidSegmentsSamp(keepSeg, :);
        end

        pendingInvalidStartSamp = [];
        renderView();
    end

    function toggleNearestBeat(~, ~)
        cp = get(ax, 'CurrentPoint');
        clickX = cp(1, 1);
        clickY = cp(1, 2);
        xlimNow = get(ax, 'XLim');
        ylimNow = get(ax, 'YLim');

        if clickX < xlimNow(1) || clickX > xlimNow(2) || clickY < ylimNow(1) || clickY > ylimNow(2)
            return;
        end

        if markMode == "bad"
            [minDist, idx] = min(abs((rSamp / fs) - clickX));
            if isempty(idx) || ~isfinite(minDist) || minDist > clickTolSec
                return;
            end
            badMask(idx) = ~badMask(idx);
        elseif markMode == "invalid"
            cand = max(1, min(nSamp, round(clickX * fs)));

            if isempty(pendingInvalidStartSamp)
                pendingInvalidStartSamp = cand;
            else
                s0 = min(pendingInvalidStartSamp, cand);
                s1 = max(pendingInvalidStartSamp, cand);
                minDurSamp = max(1, round(manualBadMissing.invalidSegmentMinDurationSec * fs));

                if (s1 - s0) >= minDurSamp
                    invalidSegmentsSamp = normalize_invalid_segments_samp([invalidSegmentsSamp; s0 s1], nSamp);
                end

                pendingInvalidStartSamp = [];
            end
        else
            cand = snap_click_to_rpeak(ecgData, fs, clickX, manualBadMissing.addBeatSearchWindowSec, guiPolarity);
            if isnan(cand) || cand < 1 || cand > nSamp
                return;
            end

            if any(abs(double(rSamp(:)) - cand) <= round(0.03 * fs))
                idxExist = find(abs(double(rSamp(:)) - cand) <= round(0.03 * fs), 1, 'first');
                badMask(idxExist) = false;
            elseif ~any(abs(double(addedRSamp(:)) - cand) <= round(0.03 * fs))
                oldBadVals = rSamp(badMask);
                addedRSamp(end + 1, 1) = cand; %#ok<AGROW>
                addedRSamp = unique(double(addedRSamp(:)));
                rSamp = unique([rSamp; cand]);
                badMask = ismember(double(rSamp(:)), double(oldBadVals(:)));
            end
        end

        renderView();
    end

    function saveCurrentMarkings()
        allRSamp = unique(double(rSamp(:)));
        badRSamp = unique(double(rSamp(badMask)));
        goodRSamp = setdiff(allRSamp, badRSamp, 'stable');
        badLatencySec = badRSamp / fs;
        addedLatencySec = addedRSamp / fs;
        invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp, nSamp);
        invalidIntervalsSamp = invalidSegmentsSamp;
        invalidSegmentLatencySec = invalidSegmentsSamp / fs;
        invalidIntervalLatencySec = invalidSegmentLatencySec;
        sourceSetFile = setFile;
        ecgChannelIndex = ecgIdx;
        detectedRSamp = allRSamp;
        badDetectedIndex = find(ismember(allRSamp, badRSamp));
        forcePolarity = char(guiPolarity);

        if exist(char(badMatFile), 'file')
            Sold = load(char(badMatFile));
            if isfield(Sold, 'created')
                created = Sold.created;
            else
                created = datetime('now');
            end
        else
            created = datetime('now');
        end

        lastModified = datetime('now');

        save(char(badMatFile), 'sourceSetFile', 'ecgChannelIndex', 'detectedRSamp', 'allRSamp', 'goodRSamp', 'badDetectedIndex', 'badRSamp', 'badLatencySec', 'addedRSamp', 'addedLatencySec', 'invalidSegmentsSamp', 'invalidIntervalsSamp', 'invalidSegmentLatencySec', 'invalidIntervalLatencySec', 'forcePolarity', 'created', 'lastModified');

        fprintf('Saved manual beat file: %s\n', char(badMatFile));
    end

    function saveAndNext(~, ~)
        saveCurrentMarkings();
        action = 'next';

        if ishghandle(fh)
            uiresume(fh);
            delete(fh);
        end
    end

    function exitGui(~, ~)
        action = 'exit';

        if ishghandle(fh)
            uiresume(fh);
            delete(fh);
        end
    end

end

function samp = snap_click_to_rpeak(ecgData, fs, clickSec, searchWindowSec, forcePolarity)

samp = NaN;

if isempty(ecgData) || ~isfinite(clickSec)
    return;
end

nSamp = numel(ecgData);
c = round(clickSec * fs);

if c < 1 || c > nSamp
    return;
end

halfWin = max(1, round(searchWindowSec * fs / 2));
s0 = max(1, c - halfWin);
s1 = min(nSamp, c + halfWin);
seg = double(ecgData(s0:s1));

if isempty(seg) || all(~isfinite(seg))
    return;
end

[pkVal, pkRel] = max(seg);
[trVal, trRel] = min(seg);
pol = lower(string(forcePolarity));

if pol == "negative"
    samp = s0 + trRel - 1;
elseif pol == "positive"
    samp = s0 + pkRel - 1;
elseif abs(pkVal) >= abs(trVal)
    samp = s0 + pkRel - 1;
else
    samp = s0 + trRel - 1;
end

end

function export_rest_channel_waveform_support(Trest, hep, outDir)

supportFile = fullfile(outDir, 'Rest_RLocked_ChannelWaveforms.mat');
diagFile = fullfile(outDir, 'Rest_RLocked_ChannelWaveforms_Diagnostics.csv');
WaveCh = table();
DiagCh = table();
ChannelOrder = strings(0, 1);
ChannelLocs = struct([]);
tGridSec = (hep.tmin: 0.004: hep.tmax)';
timeMs = 1000 * tGridSec;

if isempty(Trest)
    if support_file_has_nonempty_wave_table(supportFile)
        fprintf('Rest channel waveform support: no input rows; keeping existing non-empty support file: %s\n', supportFile);
    else
        save(supportFile, 'WaveCh', 'DiagCh', 'ChannelOrder', 'ChannelLocs', 'tGridSec', 'timeMs');
        writetable(DiagCh, diagFile);
    end
    return;
end

rowList = {};
diagList = {};
rowCount = 0;
diagCount = 0;

for i = 1: height(Trest)
    subject = string(Trest.Subject(i));
    stageLabel = "";

    if ismember('ClinicalStage', Trest.Properties.VariableNames)
        stageLabel = string(Trest.ClinicalStage(i));
    elseif ismember('Group', Trest.Properties.VariableNames)
        stageLabel = four_group_label_from_raw_group(Trest.Group(i));
    end

    restFile = "";

    if ismember('RestFile', Trest.Properties.VariableNames)
        restFile = string(Trest.RestFile(i));
    end

    if (strlength(restFile) == 0 || ~exist(restFile, 'file')) && ismember('SubjectDir', Trest.Properties.VariableNames)
        subjectDir = string(Trest.SubjectDir(i));

        if strlength(subjectDir) > 0 && exist(subjectDir, 'dir')
            restFile = first_existing_file({fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.mat', subject))});

            if strlength(restFile) == 0
                restFile = first_existing_file({fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', subject))});
            end

            if strlength(restFile) == 0
                restFile = find_first_file(subjectDir, '*rest_processed.set');
            end

            if strlength(restFile) == 0
                restFile = find_first_file(subjectDir, '*rest_processed.mat');
            end
        end
    end

    skipReason = "";

    if strlength(restFile) == 0 || ~exist(restFile, 'file')
        skipReason = "missing_rest_file";
    else
        EEG = load_eeg_file(restFile);

        if isempty(EEG)
            skipReason = "could_not_load_rest_file";
        else
            ch = identify_channels(EEG, {}, true);
            [EEG, ~] = apply_rest_analysis_lowpass_filter(EEG, ch.eegIdx, hep);

            if isempty(ch.eegIdx)
                skipReason = "missing_scalp_eeg_channels";
            else
                labels = strings(numel(ch.eegIdx), 1);

                for c = 1: numel(ch.eegIdx)
                    labels(c, 1) = string(EEG.chanlocs(ch.eegIdx(c)).labels);
                end

                if isempty(ChannelOrder)
                    ChannelOrder = labels;
                else
                    ChannelOrder = union(ChannelOrder, labels, 'stable');
                end

                if isempty(ChannelLocs)
                    try
                        ChannelLocs = EEG.chanlocs(ch.eegIdx);
                    catch
                        ChannelLocs = struct([]);
                    end
                end

                [goodRSamp, statusAnn, ann] = get_good_rest_rpeaks_from_manual_sidecar(restFile, EEG);

                if strlength(statusAnn) > 0
                    skipReason = statusAnn;
                else
                    includedAnyChannel = false;

                    for c = 1: numel(ch.eegIdx)
                        chIdx = ch.eegIdx(c);
                        chLabel = string(EEG.chanlocs(chIdx).labels);
                        [hepMat, ~, tVecSec, epochQC] = extract_rest_hep_single_channel_epochs_with_qc(EEG, goodRSamp, chIdx, hep, ann.invalidSegmentsSamp);
                        channelStatus = "no_epochs_after_qc";
                        nBeats = 0;
                        ampRejectedFrac = epochQC.ampRejectedFrac;
                        outlierExcludedFrac = NaN;

                        if ~isempty(hepMat)
                            fs = EEG.srate;
                            hepIdx = round((hep.hepWin - hep.tmin) * fs) + 1;
                            hepIdx = max(1, min(size(hepMat, 2), hepIdx));
                            meanAmpPerEpoch = mean(hepMat(:, hepIdx(1): hepIdx(2)), 2, 'omitnan');
                            [keepOutlierMask, outlierInfo] = apply_rest_hep_beat_outlier_qc(meanAmpPerEpoch, hep);
                            hepMat = hepMat(keepOutlierMask, :);
                            nBeats = size(hepMat, 1);

                            if outlierInfo.nInput > 0
                                outlierExcludedFrac = outlierInfo.nExcluded / outlierInfo.nInput;
                            end

                            if nBeats >= hep.minEpochs
                                subjWave = mean(hepMat, 1, 'omitnan')';
                                waveInterp = interp1(double(tVecSec(:)), double(subjWave(:)), double(tGridSec(:)), 'linear', NaN);
                                rowCount = rowCount + 1;
                                rowList{rowCount, 1} = table(subject, string(stageLabel), chLabel, nBeats, {waveInterp(:)'}, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'NBeats', 'Waveform_uV'});
                                channelStatus = "included";
                                includedAnyChannel = true;
                            else
                                channelStatus = "too_few_hep_epochs_after_qc";
                            end
                        end

                        diagCount = diagCount + 1;
                        diagList{diagCount, 1} = table(subject, string(stageLabel), chLabel, string(channelStatus), nBeats, epochQC.nInput, epochQC.nEdgeRejected, epochQC.nInvalidSegmentRejected, epochQC.nAmpRejected, ampRejectedFrac, outlierExcludedFrac, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'Status', 'NBeatsIncluded', 'NInput', 'NEdgeRejected', 'NInvalidSegmentRejected', 'NAmpRejected', 'AmpRejectedFrac', 'OutlierExcludedFrac'});
                    end

                    if includedAnyChannel
                        skipReason = "included";
                    else
                        skipReason = "no_channels_included";
                    end
                end
            end
        end
    end

    if skipReason ~= "included" && ~isempty(ChannelOrder)
        diagCount = diagCount + 1;
        diagList{diagCount, 1} = table(subject, string(stageLabel), "ALL", string(skipReason), 0, 0, 0, 0, 0, NaN, NaN, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'Status', 'NBeatsIncluded', 'NInput', 'NEdgeRejected', 'NInvalidSegmentRejected', 'NAmpRejected', 'AmpRejectedFrac', 'OutlierExcludedFrac'});
    end
end

if rowCount > 0
    WaveCh = vertcat(rowList{1: rowCount});
end

if diagCount > 0
    DiagCh = vertcat(diagList{1: diagCount});
end

if isempty(WaveCh) && support_file_has_nonempty_wave_table(supportFile)
    fprintf('Channel waveform support: generated 0 waveforms; keeping existing non-empty support file: %s\n', supportFile);
else
    save(supportFile, 'WaveCh', 'DiagCh', 'ChannelOrder', 'ChannelLocs', 'tGridSec', 'timeMs');
    writetable(DiagCh, diagFile);
end

if ~isempty(WaveCh)
    export_rest_channel_waveform_csvs(WaveCh, ChannelOrder, timeMs, outDir, hep);
end

fprintf('Rest channel waveform support: included %d subject-channel waveforms. Saved %s\n', rowCount, supportFile);

end

function export_rest_channel_waveform_csvs(WaveCh, ChannelOrder, timeMs, outDir, hep, filePrefix)

if nargin < 6 || strlength(string(filePrefix)) == 0
    filePrefix = 'Rest_RLocked_ChannelWaveforms';
end

if isempty(WaveCh) || ~ismember('Waveform_uV', WaveCh.Properties.VariableNames)
    return;
end

hepWinMs = [100 200];

if nargin >= 5 && isstruct(hep) && isfield(hep, 'hepWin') && numel(hep.hepWin) == 2
    hepWinMs = 1000 * double(hep.hepWin(:))';
end

hepWinMs = sort(hepWinMs);
export_rest_channel_waveform_long_csv(WaveCh, timeMs, outDir, filePrefix);
export_rest_channel_waveform_endpoint_subject_csv(WaveCh, timeMs, hepWinMs, outDir, filePrefix);

Tgroup = table();
rowIdx = 0;
stages = unique(string(WaveCh.ClinicalStage), 'stable');
channels = ChannelOrder(:);
channels = channels(strlength(channels) > 0);

for c = 1: numel(channels)
    for s = 1: numel(stages)
        idx = string(WaveCh.Channel) == channels(c) & string(WaveCh.ClinicalStage) == stages(s);

        if ~any(idx)
            continue;
        end

        subjRows = find(idx);
        Y = nan(numel(subjRows), numel(timeMs));

        for r = 1: numel(subjRows)
            y = double(WaveCh.Waveform_uV{subjRows(r)}(:))';
            n = min(numel(y), numel(timeMs));
            Y(r, 1: n) = y(1: n);
        end

        for t = 1: numel(timeMs)
            rowIdx = rowIdx + 1;
            vals = Y(:, t);
            Tgroup.Channel(rowIdx, 1) = channels(c);
            Tgroup.ClinicalStage(rowIdx, 1) = stages(s);
            Tgroup.TimeMs(rowIdx, 1) = double(timeMs(t));
            nFinite = sum(~isnan(vals));
            Tgroup.N(rowIdx, 1) = nFinite;
            Tgroup.Mean_uV(rowIdx, 1) = mean(vals, 'omitnan');
            Tgroup.SD_uV(rowIdx, 1) = std(vals, 0, 'omitnan');
            Tgroup.SE_uV(rowIdx, 1) = se_halfwidth_vector(vals);
            Tgroup.SEM_uV(rowIdx, 1) = Tgroup.SE_uV(rowIdx, 1);
        end
    end
end

if ~isempty(Tgroup)
    writetable(Tgroup, fullfile(outDir, [char(filePrefix) '_GroupSummary.csv']));
end

end

function export_rest_channel_waveform_long_csv(WaveCh, timeMs, outDir, filePrefix)

nTime = numel(timeMs);
nRowsAllocated = height(WaveCh) * nTime;
Subject = strings(nRowsAllocated, 1);
ClinicalStage = strings(nRowsAllocated, 1);
Channel = strings(nRowsAllocated, 1);
NBeats = nan(nRowsAllocated, 1);
TimeMs = nan(nRowsAllocated, 1);
Waveform_uV = nan(nRowsAllocated, 1);
rowPtr = 0;

for r = 1: height(WaveCh)
    y = double(WaveCh.Waveform_uV{r}(:));
    n = min(numel(y), nTime);

    if n == 0
        continue;
    end

    idx = (rowPtr + 1): (rowPtr + n);
    Subject(idx, 1) = string(WaveCh.Subject(r));
    ClinicalStage(idx, 1) = string(WaveCh.ClinicalStage(r));
    Channel(idx, 1) = string(WaveCh.Channel(r));
    NBeats(idx, 1) = double(WaveCh.NBeats(r));
    TimeMs(idx, 1) = double(timeMs(1: n));
    Waveform_uV(idx, 1) = y(1: n);
    rowPtr = rowPtr + n;
end

if rowPtr == 0
    return;
end

Subject = Subject(1: rowPtr);
ClinicalStage = ClinicalStage(1: rowPtr);
Channel = Channel(1: rowPtr);
NBeats = NBeats(1: rowPtr);
TimeMs = TimeMs(1: rowPtr);
Waveform_uV = Waveform_uV(1: rowPtr);
Tlong = table(Subject, ClinicalStage, Channel, NBeats, TimeMs, Waveform_uV);
writetable(Tlong, fullfile(outDir, [char(filePrefix) '_Long.csv']));

end

function export_rest_channel_waveform_endpoint_subject_csv(WaveCh, timeMs, hepWinMs, outDir, filePrefix)

nRows = height(WaveCh);
Subject = strings(nRows, 1);
ClinicalStage = strings(nRows, 1);
Channel = strings(nRows, 1);
NBeats = nan(nRows, 1);
RLockedWindowStartMs = repmat(double(hepWinMs(1)), nRows, 1);
RLockedWindowEndMs = repmat(double(hepWinMs(2)), nRows, 1);
RLockedWindowBoundaryConvention = repmat("start_inclusive_end_exclusive_ms", nRows, 1);
WindowNTimepoints = nan(nRows, 1);
RLockedWindowMean_uV = nan(nRows, 1);
RLockedTimeWindowMean_uV = nan(nRows, 1);
RLockedWindowMaxAbs_uV = nan(nRows, 1);
FullWaveformMaxAbs_uV = nan(nRows, 1);
TimeOfFullWaveformMaxAbsMs = nan(nRows, 1);

winMask = time_window_mask_ms(double(timeMs(:))', hepWinMs);
winMask = winMask(:);

for r = 1: nRows
    Subject(r, 1) = string(WaveCh.Subject(r));
    ClinicalStage(r, 1) = string(WaveCh.ClinicalStage(r));
    Channel(r, 1) = string(WaveCh.Channel(r));
    NBeats(r, 1) = double(WaveCh.NBeats(r));
    y = double(WaveCh.Waveform_uV{r}(:));
    yAligned = nan(numel(timeMs), 1);
    n = min(numel(y), numel(timeMs));

    if n > 0
        yAligned(1: n) = y(1: n);
    end

    endpointVals = yAligned(winMask);
    finiteEndpoint = endpointVals(isfinite(endpointVals));
    WindowNTimepoints(r, 1) = numel(finiteEndpoint);

    if ~isempty(finiteEndpoint)
        RLockedWindowMean_uV(r, 1) = mean(finiteEndpoint, 'omitnan');
        RLockedTimeWindowMean_uV(r, 1) = RLockedWindowMean_uV(r, 1);
        RLockedWindowMaxAbs_uV(r, 1) = max(abs(finiteEndpoint), [], 'omitnan');
    end

    finiteFull = yAligned(isfinite(yAligned));

    if ~isempty(finiteFull)
        [FullWaveformMaxAbs_uV(r, 1), maxIdx] = max(abs(yAligned), [], 'omitnan');
        finiteIdx = find(isfinite(yAligned));

        if ~isempty(finiteIdx) && maxIdx >= 1 && maxIdx <= numel(yAligned) && isfinite(yAligned(maxIdx))
            TimeOfFullWaveformMaxAbsMs(r, 1) = double(timeMs(maxIdx));
        elseif ~isempty(finiteIdx)
            [~, localIdx] = max(abs(yAligned(finiteIdx)));
            TimeOfFullWaveformMaxAbsMs(r, 1) = double(timeMs(finiteIdx(localIdx)));
        end
    end
end

Tendpoint = table(Subject, ClinicalStage, Channel, NBeats, RLockedWindowStartMs, RLockedWindowEndMs, RLockedWindowBoundaryConvention, WindowNTimepoints, RLockedWindowMean_uV, RLockedTimeWindowMean_uV, RLockedWindowMaxAbs_uV, FullWaveformMaxAbs_uV, TimeOfFullWaveformMaxAbsMs);
writetable(Tendpoint, fullfile(outDir, [char(filePrefix) '_EndpointBySubject.csv']));

end

function [hepMat, keptRSamp, tVecSec, epochQC] = extract_rest_hep_single_channel_epochs_with_qc(EEG, rSamp, chIdx, hep, invalidSegmentsSamp)

if nargin < 5
    invalidSegmentsSamp = [];
end

hepMat = [];
keptRSamp = [];
fs = EEG.srate;
tminS = round(hep.tmin * fs);
tmaxS = round(hep.tmax * fs);
tVecSec = (tminS: tmaxS) / fs;
rSamp = double(rSamp(:));
invalidSegmentsSamp = normalize_invalid_segments_samp(invalidSegmentsSamp, EEG.pnts);

nInput = numel(rSamp);
epochQC = struct('nInput', nInput, 'nEdgeRejected', nInput, 'nInvalidSegmentRejected', 0, 'nAmpRejected', 0, 'ampRejectedFrac', NaN);

if isempty(rSamp) || isempty(chIdx)
    return;
end

baseIdx = round((hep.baseWin - hep.tmin) * fs) + 1;
hepIdx = round((hep.hepWin - hep.tmin) * fs) + 1;
baseIdx = max(1, min(numel(tVecSec), baseIdx));
hepIdx = max(1, min(numel(tVecSec), hepIdx));
keepEdge = (rSamp + tminS) > 1;
keepEdge = keepEdge & (rSamp + tmaxS) <= EEG.pnts;
edgeRSamp = rSamp(keepEdge);
epochQC.nEdgeRejected = nInput - numel(edgeRSamp);

if isempty(edgeRSamp)
    return;
end

invalidEpochMask = intervals_overlap_invalid_segments(edgeRSamp + tminS, edgeRSamp + tmaxS, invalidSegmentsSamp);
epochQC.nInvalidSegmentRejected = sum(invalidEpochMask);
epochRSamp = edgeRSamp(~invalidEpochMask);

if isempty(epochRSamp)
    return;
end

epochAbsThr = get_hep_field_default(hep, 'epochAbsMax_uV', Inf);
baseAbsThr = get_hep_field_default(hep, 'baseAbsMax_uV', Inf);
hepWinAbsThr = get_hep_field_default(hep, 'hepWinAbsMax_uV', Inf);
heps = nan(numel(epochRSamp), numel(tVecSec));
keepAmp = false(numel(epochRSamp), 1);

for i = 1: numel(epochRSamp)
    seg = double(EEG.data(chIdx, (epochRSamp(i) + tminS): (epochRSamp(i) + tmaxS)));
    b = mean(seg(baseIdx(1): baseIdx(2)), 'omitnan');
    seg = seg - b;
    epochMaxAbs = finite_max_abs(seg);
    baseMaxAbs = finite_max_abs(seg(baseIdx(1): baseIdx(2)));
    hepWinMaxAbs = finite_max_abs(seg(hepIdx(1): hepIdx(2)));
    rejectAmp = any(~isfinite(seg(:))) || epochMaxAbs > epochAbsThr || baseMaxAbs > baseAbsThr || hepWinMaxAbs > hepWinAbsThr;

    if ~rejectAmp
        heps(i, :) = seg(:)';
        keepAmp(i) = true;
    end
end

hepMat = heps(keepAmp, :);
keptRSamp = epochRSamp(keepAmp);
epochQC.nAmpRejected = sum(~keepAmp);

if numel(epochRSamp) > 0
    epochQC.ampRejectedFrac = epochQC.nAmpRejected / numel(epochRSamp);
end

end

function export_pseudo_event_channel_waveform_support(Trest, hep, outDir)

supportFile = fullfile(outDir, 'Rest_PseudoEvent_ChannelWaveforms.mat');
diagFile = fullfile(outDir, 'Rest_PseudoEvent_ChannelWaveforms_Diagnostics.csv');
WaveCh = table();
DiagCh = table();
ChannelOrder = strings(0, 1);
ChannelLocs = struct([]);
tGridSec = (hep.tmin: 0.004: hep.tmax)';
timeMs = 1000 * tGridSec;

if isempty(Trest)
    save(supportFile, 'WaveCh', 'DiagCh', 'ChannelOrder', 'ChannelLocs', 'tGridSec', 'timeMs');
    writetable(DiagCh, diagFile);
    return;
end

rowList = {};
diagList = {};
rowCount = 0;
diagCount = 0;

for i = 1:height(Trest)
    subject = string(Trest.Subject(i));
    stageLabel = "";

    if ismember('ClinicalStage', Trest.Properties.VariableNames)
        stageLabel = string(Trest.ClinicalStage(i));
    elseif ismember('Group', Trest.Properties.VariableNames)
        stageLabel = four_group_label_from_raw_group(Trest.Group(i));
    end

    restFile = "";

    if ismember('RestFile', Trest.Properties.VariableNames)
        restFile = string(Trest.RestFile(i));
    end

    if (strlength(restFile) == 0 || ~exist(restFile, 'file')) && ismember('SubjectDir', Trest.Properties.VariableNames)
        subjectDir = string(Trest.SubjectDir(i));

        if strlength(subjectDir) > 0 && exist(subjectDir, 'dir')
            restFile = first_existing_file({fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', sprintf('%s_rest_processed.mat', subject))});

            if strlength(restFile) == 0
                restFile = first_existing_file({fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.set', subject)), fullfile(subjectDir, 'Processed', 'Rest', sprintf('%s_rest_processed.mat', subject))});
            end

            if strlength(restFile) == 0
                restFile = find_first_file(subjectDir, '*rest_processed.set');
            end

            if strlength(restFile) == 0
                restFile = find_first_file(subjectDir, '*rest_processed.mat');
            end
        end
    end

    skipReason = "";

    if strlength(restFile) == 0 || ~exist(restFile, 'file')
        skipReason = "missing_rest_file";
    else
        EEG = load_eeg_file(restFile);

        if isempty(EEG)
            skipReason = "could_not_load_rest_file";
        else
            ch = identify_channels(EEG, {}, true);
            [EEG, ~] = apply_rest_analysis_lowpass_filter(EEG, ch.eegIdx, hep);

            if isempty(ch.eegIdx)
                skipReason = "missing_scalp_eeg_channels";
            else
                labels = strings(numel(ch.eegIdx), 1);

                for c = 1:numel(ch.eegIdx)
                    labels(c, 1) = string(EEG.chanlocs(ch.eegIdx(c)).labels);
                end

                if isempty(ChannelOrder)
                    ChannelOrder = labels;
                else
                    ChannelOrder = union(ChannelOrder, labels, 'stable');
                end

                if isempty(ChannelLocs)
                    try
                        ChannelLocs = EEG.chanlocs(ch.eegIdx);
                    catch
                        ChannelLocs = struct([]);
                    end
                end

                [goodRSamp, statusAnn, ann] = get_good_rest_rpeaks_from_manual_sidecar(restFile, EEG);

                if strlength(statusAnn) > 0
                    skipReason = statusAnn;
                else
                    pseudoSeed = pseudo_subject_seed(subject, hep.pseudo.randomSeed);
                    pseudoSamp = make_pseudo_event_samples(goodRSamp, EEG.srate, EEG.pnts, ann.invalidSegmentsSamp, hep, hep.pseudo, pseudoSeed);

                    if isempty(pseudoSamp)
                        skipReason = "no_valid_pseudo_events";
                    else
                        includedAnyChannel = false;

                        for c = 1:numel(ch.eegIdx)
                            chIdx = ch.eegIdx(c);
                            chLabel = string(EEG.chanlocs(chIdx).labels);
                            [eventMat, ~, tVecSec, epochQC] = extract_rest_hep_single_channel_epochs_with_qc(EEG, pseudoSamp, chIdx, hep, ann.invalidSegmentsSamp);
                            channelStatus = "no_epochs_after_qc";
                            nBeats = 0;
                            ampRejectedFrac = epochQC.ampRejectedFrac;
                            outlierExcludedFrac = NaN;

                            if ~isempty(eventMat)
                                fs = EEG.srate;
                                winIdx = round((hep.hepWin - hep.tmin) * fs) + 1;
                                winIdx = max(1, min(size(eventMat, 2), winIdx));
                                meanAmpPerEpoch = mean(eventMat(:, winIdx(1):winIdx(2)), 2, 'omitnan');
                                [keepOutlierMask, outlierInfo] = apply_rest_hep_beat_outlier_qc(meanAmpPerEpoch, hep);
                                eventMat = eventMat(keepOutlierMask, :);
                                nBeats = size(eventMat, 1);

                                if outlierInfo.nInput > 0
                                    outlierExcludedFrac = outlierInfo.nExcluded / outlierInfo.nInput;
                                end

                                if nBeats >= hep.minEpochs
                                    subjWave = mean(eventMat, 1, 'omitnan')';
                                    waveInterp = interp1(double(tVecSec(:)), double(subjWave(:)), double(tGridSec(:)), 'linear', NaN);
                                    rowCount = rowCount + 1;
                                    rowList{rowCount, 1} = table(subject, string(stageLabel), chLabel, nBeats, {waveInterp(:)'}, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'NBeats', 'Waveform_uV'});
                                    channelStatus = "included";
                                    includedAnyChannel = true;
                                else
                                    channelStatus = "too_few_pseudo_epochs_after_qc";
                                end
                            end

                            diagCount = diagCount + 1;
                            diagList{diagCount, 1} = table(subject, string(stageLabel), chLabel, string(channelStatus), nBeats, epochQC.nInput, epochQC.nEdgeRejected, epochQC.nInvalidSegmentRejected, epochQC.nAmpRejected, ampRejectedFrac, outlierExcludedFrac, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'Status', 'NBeatsIncluded', 'NInput', 'NEdgeRejected', 'NInvalidSegmentRejected', 'NAmpRejected', 'AmpRejectedFrac', 'OutlierExcludedFrac'});
                        end

                        if includedAnyChannel
                            skipReason = "included";
                        else
                            skipReason = "no_channels_included";
                        end
                    end
                end
            end
        end
    end

    if skipReason ~= "included" && ~isempty(ChannelOrder)
        diagCount = diagCount + 1;
        diagList{diagCount, 1} = table(subject, string(stageLabel), "ALL", string(skipReason), 0, 0, 0, 0, 0, NaN, NaN, 'VariableNames', {'Subject', 'ClinicalStage', 'Channel', 'Status', 'NBeatsIncluded', 'NInput', 'NEdgeRejected', 'NInvalidSegmentRejected', 'NAmpRejected', 'AmpRejectedFrac', 'OutlierExcludedFrac'});
    end
end

if rowCount > 0
    WaveCh = vertcat(rowList{1 :rowCount});
end

if diagCount > 0
    DiagCh = vertcat(diagList{1: diagCount});
end

save(supportFile, 'WaveCh', 'DiagCh', 'ChannelOrder', 'ChannelLocs', 'tGridSec', 'timeMs');
writetable(DiagCh, diagFile);

if ~isempty(WaveCh)
    export_rest_channel_waveform_csvs(WaveCh, ChannelOrder, timeMs, outDir, hep, 'Rest_PseudoEvent_ChannelWaveforms');
end

fprintf('Pseudo-event waveform support: included %d subject-channel waveforms. Saved %s\n', rowCount, supportFile);

end

function seed = pseudo_subject_seed(subject, baseSeed)

chars = char(string(subject));
seed = double(baseSeed);

for i = 1: numel(chars)
    seed = mod(seed * 33 + double(chars(i)), 2147483647);
end

if seed < 1
    seed = double(baseSeed) + 1;
end

end

function pseudoSamp = make_pseudo_event_samples(realRSamp, fs, nSamp, invalidSegmentsSamp, hep, pseudo, seed)

pseudoSamp = [];
realRSamp = sort(unique(double(realRSamp(:)), 'stable'));

if numel(realRSamp) < 2
    return;
end

rng(seed, 'twister');
tminS = round(hep.tmin * fs);
tmaxS = round(hep.tmax * fs);
edgeLo = max(1, 1 - tminS);
edgeHi = min(nSamp, nSamp - tmaxS);
analysisStartSec = double(hep.hepWin(1));
analysisEndSec = double(hep.hepWin(2));
minEndpointStartAfterRealRSec = get_pseudo_field_default(pseudo, 'minEndpointStartAfterRealRSec', 0.200);
minEndpointEndBeforeNextRSec = get_pseudo_field_default(pseudo, 'minEndpointEndBeforeNextRSec', 0.200);
maxAttempts = max(10, round(get_pseudo_field_default(pseudo, 'maxAttemptsPerInterval', 100)));
anchorLowerOffsetSamp = round((minEndpointStartAfterRealRSec - analysisStartSec) * fs);
anchorUpperOffsetFromNextSamp = round((minEndpointEndBeforeNextRSec + analysisEndSec) * fs);
candidates = nan(numel(realRSamp) - 1, 1);

for i = 1: numel(realRSamp) - 1
    currentR = realRSamp(i);
    nextR = realRSamp(i + 1);
    lower = round(currentR + anchorLowerOffsetSamp);
    upper = round(nextR - anchorUpperOffsetFromNextSamp);
    lower = max(lower, edgeLo);
    upper = min(upper, edgeHi);

    if upper < lower
        continue;
    end

    for attempt = 1: maxAttempts
        cand = lower + round(rand * max(0, upper - lower));

        if is_valid_rr_adaptive_pseudo_event_sample(cand, currentR, nextR, fs, nSamp, invalidSegmentsSamp, hep, tminS, tmaxS, edgeLo, edgeHi, minEndpointStartAfterRealRSec, minEndpointEndBeforeNextRSec)
            candidates(i, 1) = cand;
            break;
        end
    end
end

pseudoSamp = sort(unique(candidates(isfinite(candidates)), 'stable'));

end

function tf = is_valid_rr_adaptive_pseudo_event_sample(cand, currentR, nextR, fs, nSamp, invalidSegmentsSamp, hep, tminS, tmaxS, edgeLo, edgeHi, minEndpointStartAfterRealRSec, minEndpointEndBeforeNextRSec)

tf = false;

if ~isfinite(cand)
    return;
end

cand = round(cand);

if cand < edgeLo || cand > edgeHi || cand < 1 || cand > nSamp
    return;
end

analysisStartSamp = round(hep.hepWin(1) * fs);
analysisEndSamp = round(hep.hepWin(2) * fs);
endpointStart = cand + analysisStartSamp;
endpointEnd = cand + analysisEndSamp;

if endpointStart < currentR + round(minEndpointStartAfterRealRSec * fs)
    return;
end

if endpointEnd > nextR - round(minEndpointEndBeforeNextRSec * fs)
    return;
end

segStart = cand + tminS;
segEnd = cand + tmaxS;

if segStart < 1 || segEnd > nSamp
    return;
end

if intervals_overlap_invalid_segments(segStart, segEnd, invalidSegmentsSamp)
    return;
end

tf = true;

end

function value = get_pseudo_field_default(pseudo, fieldName, defaultValue)

value = defaultValue;

if isstruct(pseudo) && isfield(pseudo, fieldName)
    candidate = pseudo.(fieldName);

    if isnumeric(candidate) && isscalar(candidate) && isfinite(candidate)
        value = double(candidate);
    end
end

end

function tf = support_file_has_nonempty_wave_table(supportFile)

tf = false;

if exist(supportFile, 'file') ~= 2
    return;
end

try
    S = load(supportFile);
catch
    return;
end

if isfield(S, 'WaveCh') && istable(S.WaveCh) && ~isempty(S.WaveCh)
    tf = true;
    return;
end

if isfield(S, 'Wave') && istable(S.Wave) && ~isempty(S.Wave)
    tf = true;
    return;
end

end

function outDirs = get_analysis_output_dirs(resultsDir)

% Metric-collection output layout.
% Generated metrics are written directly to resultsDir.
% QC artifacts from metric collection are written to a dedicated QC sub folder.

outDirs = struct();
outDirs.Root = resultsDir;
outDirs.SubjectLevel = resultsDir;
outDirs.Long = resultsDir;
outDirs.QC = fullfile(resultsDir, 'QC');
outDirs.Models = resultsDir;
outDirs.Paper = resultsDir;
outDirs.PaperTables = resultsDir;
outDirs.PaperFigures = resultsDir;
outDirs.Tables = resultsDir;
outDirs.Figures = resultsDir;

end

function outDirs = ensure_analysis_output_dirs(resultsDir)

outDirs = get_analysis_output_dirs(resultsDir);
fn = fieldnames(outDirs);

createdDirs = strings(0, 1);

for i = 1: numel(fn)
    thisName = fn{i};
    thisDir = string(outDirs.(thisName));

    if strlength(thisDir) == 0 || ismissing(thisDir)
        continue
    end

    if any(createdDirs == thisDir)
        continue
    end

    if exist(char(thisDir), 'dir') ~= 7
        mkdir(char(thisDir));
    end

    createdDirs(end + 1, 1) = thisDir;
end

end

function x = table_value_or_nan(T, varName, i)

x = NaN;

if isempty(T) || width(T) == 0 || ~ismember(varName, T.Properties.VariableNames) || i > height(T)
    return;
end

v = T.(varName)(i);

if isnumeric(v) || islogical(v)
    x = double(v);
elseif iscell(v) && isscalar(v) && isnumeric(v{1}) && isscalar(v{1})
    x = double(v{1});
end

end

function T = struct_array_to_table(S, template)

if isempty(S)
    T = struct2table(template);
    T(1, :) = [];
else
    T = struct2table(S);
end

end

function label = pathless_file_label(filePath)

label = "";

if strlength(string(filePath)) == 0
    return;
end

[~, n, e] = fileparts(char(filePath));
label = string([n e]);

end

function [keepMask, info] = apply_rest_hep_beat_outlier_qc(hepVals, hep)

hepVals = double(hepVals(:));
keepMask = true(size(hepVals));
info = struct('nInput', numel(hepVals), 'nFiniteHEP', 0, 'nExcluded', 0, 'center_uV', NaN, 'mad_uV', NaN, 'thresholdMAD', NaN);

if isempty(hepVals)
    return;
end

finiteMask = isfinite(hepVals);
info.nFiniteHEP = sum(finiteMask);
madThreshold = get_hep_field_default(hep, 'beatOutlierMAD', 0);
info.thresholdMAD = madThreshold;

if madThreshold <= 0
    keepMask(~finiteMask) = false;
    info.nExcluded = sum(~keepMask);
    return;
end

minFinite = get_hep_field_default(hep, 'minFiniteHEPForOutlierFilter', 10);

if info.nFiniteHEP < minFinite
    keepMask(~finiteMask) = false;
    info.nExcluded = sum(~keepMask);
    return;
end

centerVal = median(hepVals(finiteMask), 'omitnan');
madVal = mad(hepVals(finiteMask), 1);
info.center_uV = centerVal;
info.mad_uV = madVal;

if ~isfinite(madVal) || madVal <= 0
    keepMask(~finiteMask) = false;
    info.nExcluded = sum(~keepMask);
    return;
end

keepMask(~finiteMask) = false;
keepMask(finiteMask) = abs(hepVals(finiteMask) - centerVal) <= (madThreshold * madVal);
info.nExcluded = sum(~keepMask);

end

function se = se_halfwidth_vector(vals)

vals = double(vals(:));
vals = vals(isfinite(vals));

if numel(vals) < 2
    se = NaN;
else
    se = std(vals, 0, 'omitnan') / sqrt(numel(vals));
end

end

function T = make_paper_facing_table(T, removeLogCigs)

if nargin < 2
    removeLogCigs = true;
end

if isempty(T)
    return;
end

if removeLogCigs && ismember('LogCigsPerDay', T.Properties.VariableNames)
    T(:, {'LogCigsPerDay'}) = [];
end

T.Properties.VariableNames = replace_old_hep_labels_in_varnames(T.Properties.VariableNames);

for v = 1:numel(T.Properties.VariableNames)
    vn = T.Properties.VariableNames{v};
    x = T.(vn);

    if isstring(x)
        y = replace_old_hep_labels_in_strings(x);
        if removeLogCigs
            y = remove_logcigs_from_strings(y);
        end
        T.(vn) = y;
    elseif iscellstr(x)
        y = replace_old_hep_labels_in_strings(string(x));
        if removeLogCigs
            y = remove_logcigs_from_strings(y);
        end
        T.(vn) = cellstr(y);
    elseif iscell(x)
        try
            isTextCell = cellfun(@(c) ischar(c) || (isstring(c) && isscalar(c)), x);
            if all(isTextCell(:))
                y = replace_old_hep_labels_in_strings(string(x));
                if removeLogCigs
                    y = remove_logcigs_from_strings(y);
                end
                T.(vn) = cellstr(y);
            end
        catch
        end
    elseif iscategorical(x)
        cats = categories(x);
        newCatStrings = replace_old_hep_labels_in_strings(string(cats));
        if removeLogCigs
            newCatStrings = remove_logcigs_from_strings(newCatStrings);
        end
        newCats = cellstr(newCatStrings);
        if ~isequal(cats(:), newCats(:))
            T.(vn) = renamecats(x, cats, newCats);
        end
    end
end

end

function x = remove_logcigs_from_strings(x)

x = string(x);
x = strrep(x, " + LogCigsPerDay", "");
x = strrep(x, "+ LogCigsPerDay", "");
x = strrep(x, "LogCigsPerDay + ", "");
x = strrep(x, "LogCigsPerDay+", "");
x = strrep(x, "|LogCigsPerDay", "");
x = strrep(x, "LogCigsPerDay|", "");
x = strrep(x, "LogCigsPerDay", "");
x = strrep(x, "||", "|");
x = strrep(x, " +  + ", " + ");
x = strrep(x, " ~  + ", " ~ ");
x = strtrim(x);

end

function namesOut = replace_old_hep_labels_in_varnames(namesIn)

namesOut = namesIn;
for i = 1:numel(namesOut)
    s = string(namesOut{i});
    s = strrep(s, "HEP100to200FieldScore_LOSO_uV", "RLocked100to200FieldScore_LOSO_uV");
    s = strrep(s, "HEP100to200_GFP_uV", "RLocked100to200_GFP_uV");
    s = strrep(s, "HEP100to200_CFA_MapCorr", "RLocked100to200_CFA_MapCorr");
    s = strrep(s, "HEP100to200", "RLocked100to200");
    s = strrep(s, "PrimaryHEP", "PrimaryRLocked");
    s = strrep(s, "HEPWindowMean_uV", "RLockedWindowMean_uV");
    s = strrep(s, "HEPWindowMean", "RLockedWindowMean");
    s = strrep(s, "nFiniteHEP", "nFiniteRLocked");
    s = strrep(s, "minFiniteHEP", "minFiniteRLocked");
    s = strrep(s, "HEP", "RLocked");
    s = matlab.lang.makeValidName(char(s));
    namesOut{i} = char(s);
end

namesOut = matlab.lang.makeUniqueStrings(namesOut, {}, namelengthmax);

end

function x = replace_old_hep_labels_in_strings(x)

x = string(x);
oldNew = [
    "HEP100to200FieldScore_LOSO_uV", "RLocked100to200FieldScore_LOSO_uV";
    "HEP100to200_GFP_uV", "RLocked100to200_GFP_uV";
    "HEP100to200_CFA_MapCorr", "RLocked100to200_CFA_MapCorr";
    "PrimaryHEP", "PrimaryRLocked";
    "HEPWindowMean_uV", "RLockedWindowMean_uV";
    "HEPWindowMean", "RLockedWindowMean";
    "HEP100to200", "RLocked100to200";
    "primary HEP", "primary R-locked field";
    "Primary HEP", "Primary R-locked field";
    "HEP", "R-locked field";
    "hep", "r_locked_field"
    ];

for r = 1:size(oldNew, 1)
    x = strrep(x, oldNew(r, 1), oldNew(r, 2));
end

end

function export_all_tables_docx(cfg, Tsub, Tdiag, Tendpoints, Primary100Rows, secondaryRows, BDRows, PseudoRows, TemplateReliability, Cluster)

fprintf('Generating All_Tables.docx...\n');
docxPath = alltables_docx_output_path(cfg);
[docxDir, ~, ~] = fileparts(docxPath);
ensure_dir(docxDir);
preprocFile = alltables_find_preprocessing_qc_file(cfg);
T1 = alltables_build_table1(Tsub);
TS1 = alltables_build_table_s1(Tsub);
[TS2, TS2source] = alltables_build_table_s2(Tsub, Tdiag, Tendpoints, preprocFile, cfg);
TS3 = alltables_build_table_s3(Primary100Rows);
TS4 = alltables_build_table_s4(secondaryRows);
TS5 = alltables_build_table_s5(Cluster);
TS6 = alltables_build_table_s6(BDRows);
TS7 = alltables_build_table_s7(Primary100Rows, PseudoRows);
TS8 = alltables_build_table_s8(TemplateReliability);
writetable(TS2, fullfile(cfg.tblDir, 'Table_S2_ECG_EEG_QC_Balance.csv'));
writetable(TS2source, fullfile(cfg.tblDir, 'Table_S2_SubjectLevel_SourceData.csv'));
word = [];
doc = [];
try
    word = actxserver('Word.Application');
    word.Visible = false;
    doc = word.Documents.Add;
    doc.PageSetup.Orientation = 1;
        word = actxserver('Word.Application');
    word.Visible = false;
    doc = word.Documents.Add;
    doc.PageSetup.Orientation = 1;
marginPoints = 36;
doc.PageSetup.TopMargin = marginPoints;
doc.PageSetup.BottomMargin = marginPoints;
doc.PageSetup.LeftMargin = marginPoints;
doc.PageSetup.RightMargin = marginPoints;  
    selection = word.Selection;
    selection.Font.Name = 'Times New Roman';
    selection.Font.Size = 11;
    alltables_word_heading(selection, 'All manuscript tables', 16, true);
    alltables_word_paragraph(selection, sprintf('Generated by Rest_RLocked_Field_Analysis.m on %s.', char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'))), 10, false);
    alltables_word_paragraph(selection, 'This document collates Table 1 and Supplementary Tables S1-S8 from the generated analysis outputs.', 10, false);
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table 1. Demographic and clinical characteristics of the analytic sample.', T1, 'Values are presented as mean +/- SD unless otherwise indicated. Sex and BD subtype are presented as counts. MADRS, YMRS, and GAF scores were available for BD participants only and are shown as N/A for healthy controls and unaffected siblings. Abbreviations: BD, bipolar disorder; HC, healthy controls; M, male; F, female; MADRS, Montgomery-Asberg Depression Rating Scale; YMRS, Young Mania Rating Scale; GAF, Global Assessment of Functioning; N/A, not applicable.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S1. Medication categories by subject.', TS1, 'For each BD participant and mood-state group, the number of medications taken from each category is indicated in parentheses. Abbreviations: AD, antidepressants; AP, antipsychotics; MS, mood stabilizers; ANX, anxiolytics; Other, other medications; BD, bipolar disorder.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S2. ECG, beat-retention, R-locked waveform quality, preprocessing, and peri-R cardiac-field diagnostics by clinical group.', TS2, 'Values are median [interquartile range] unless otherwise indicated. Enhanced QC flag is shown as n (%). Omnibus p values are descriptive Kruskal-Wallis tests across the four clinical groups and were not used for primary inference. Standardized mean differences are shown for the two contrasts most relevant to the primary result. Channel-level R-locked waveform diagnostics were first aggregated within subject, so the participant is the unit of analysis. CFA, cardiac-field activity/topography; RMSSD, root mean square of successive RR-interval differences; SMD, standardized mean difference.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S3. Primary clinical-group model and planned contrasts for the 100-200 ms R-locked distributed-field score.', TS3, 'The dependent variable was the leave-one-subject-out, group-blind, CFA-orthogonalized 100-200 ms R-locked distributed-field score. The primary model included clinical group, age, and sex. Planned-contrast p values were Holm-corrected across the five primary contrasts. Abbreviations: BD, bipolar disorder; CFA, cardiac-field activity/topography; HC, healthy controls; LOSO, leave-one-subject-out; Adj, adjusted; Perm, permutation.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S4. Secondary post-R endpoints and adjacent-window sensitivity analyses.', TS4, 'Secondary analyses tested whether clinical-group effects were present in adjacent or related post-R endpoints. Models included clinical group, age, and sex. Holm correction was applied separately across the three secondary omnibus tests and across the adjacent-window planned contrasts. Abbreviations: BD, bipolar disorder; CFA, cardiac-field activity/topography; GFP, global field power; HC, healthy controls; Perm, permutation.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S5. Exploratory channel x time cluster-permutation localization of the depressed BD versus healthy-control contrast.', TS5, 'The exploratory mass-univariate analysis tested the depressed BD versus healthy-control contrast across channels and time points from 100 to 400 ms post-R, adjusted for age and sex. Only clusters with p_FWER < 0.10 are shown. Abbreviations: FWER, family-wise error rate.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S6. Exploratory BD-only clinical associations with the primary 100-200 ms R-locked distributed-field score.', TS6, 'Exploratory analyses tested associations between the primary 100-200 ms field score and clinical variables within BD participants. False-discovery-rate correction was applied across the exploratory BD-only associations. Abbreviations: BD, bipolar disorder; FDR, false discovery rate; GAF, Global Assessment of Functioning; MADRS, Montgomery-Asberg Depression Rating Scale; YMRS, Young Mania Rating Scale; Perm, permutation.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S7. Robustness and specificity analyses for the primary 100-200 ms R-locked distributed-field score.', TS7, 'Sensitivity models tested whether the primary clinical-group effect persisted after adjustment for peri-R CFA score, mean heart rate, lnRMSSD, and cigarettes per day. The smoking-adjusted model was post hoc. The pseudo-event negative-control analysis tested whether the clinical-group pattern was reproduced across Monte Carlo realizations of RR-adaptive pseudo-event placements. Abbreviations: BD, bipolar disorder; CFA, cardiac-field activity/topography; HC, healthy controls; HR, heart rate; LOSO, leave-one-subject-out; RMSSD, root mean square of successive RR-interval differences; Adj, adjusted; Perm, permutation.');
    alltables_word_page_break(selection);
    alltables_word_add_table(doc, selection, 'Table S8. Template-reliability diagnostics for the primary 100-200 ms R-locked topographic template.', TS8, 'Reliability diagnostics evaluated stability of the group-blind, CFA-orthogonalized 100-200 ms template used to compute the primary field score. Bootstrap and split-half analyses used 2,000 iterations. Abbreviations: CFA, cardiac-field activity/topography; CI, confidence interval; LOSO, leave-one-subject-out.');
    doc.SaveAs2(docxPath);
    doc.Close(false);
    word.Quit;
catch ME
    if ~isempty(doc)
        try
            doc.Close(false);
        catch
        end
    end
    if ~isempty(word)
        try
            word.Quit;
        catch
        end
    end
    rethrow(ME);
end
fprintf('All manuscript tables DOCX saved: %s\n', docxPath);

end

function docxPath = alltables_docx_output_path(cfg)

if isfield(cfg, 'allTables') && isfield(cfg.allTables, 'outputFileOverride') && strlength(string(cfg.allTables.outputFileOverride)) > 0
    docxPath = char(cfg.allTables.outputFileOverride);
else
    docxPath = fullfile(char(cfg.projectRoot), char(cfg.allTables.fileName));
end

end

function preprocFile = alltables_find_preprocessing_qc_file(cfg)

candidateFiles = strings(0, 1);
candidateFiles(end + 1, 1) = string(fullfile(cfg.analysisRoot, 'Preprocessing_QC', 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv'));
candidateFiles(end + 1, 1) = string(fullfile(cfg.projectRoot, 'Analysis', 'Preprocessing_QC', 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv'));
candidateFiles(end + 1, 1) = string(fullfile(cfg.tblDir, 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv'));
candidateFiles(end + 1, 1) = string(fullfile(cfg.inputDir, 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv'));
candidateFiles(end + 1, 1) = string(fullfile(pwd, 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv'));
preprocFile = '';
for i = 1: numel(candidateFiles)
    if exist(char(candidateFiles(i)), 'file') == 2
        preprocFile = char(candidateFiles(i));
        return;
    end
end
warning('Preprocessing QC file was not found. Table S2 noisy-channel and ICA-component rows will be unavailable.');

end

function T = alltables_build_table1(Tsub)

stages = ["BD_Depressed" "BD_Euthymic" "Siblings" "HC"];
headers = ["Characteristic" "Depressed BD" "Euthymic BD" "Siblings" "HC"];
rows = strings(8, numel(headers));
rows(:, 1) = ["n"; "Age, years"; "Sex, M/F"; "BD subtype, I/II"; "Daily cigarettes"; "MADRS"; "YMRS"; "GAF"];
for g = 1: numel(stages)
    mask = string(Tsub.ClinicalStage) == stages(g);
    rows(1, g + 1) = string(sum(mask));
    rows(2, g + 1) = alltables_mean_sd_text(alltables_get_numeric(Tsub, 'Age', mask), 1);
    rows(3, g + 1) = alltables_sex_mf_text(Tsub, mask);
    rows(4, g + 1) = alltables_subtype_text(Tsub, mask, stages(g));
    rows(5, g + 1) = alltables_mean_sd_text(alltables_get_numeric(Tsub, 'CigsPerDay', mask), 1);
    rows(6, g + 1) = alltables_mean_sd_text_bd_only(Tsub, 'MADRS', mask, stages(g), 1);
    rows(7, g + 1) = alltables_mean_sd_text_bd_only(Tsub, 'YMRS', mask, stages(g), 1);
    rows(8, g + 1) = alltables_mean_sd_text_bd_only(Tsub, 'GAF', mask, stages(g), 1);
end
T = array2table(rows, 'VariableNames', matlab.lang.makeValidName(headers));
T.Properties.VariableDescriptions = cellstr(headers);

end

function T = alltables_build_table_s1(Tsub)

medVars = {'AD', 'AP', 'MS', 'ANX', 'Other'};
dep = Tsub(string(Tsub.ClinicalStage) == "BD_Depressed", :);
euth = Tsub(string(Tsub.ClinicalStage) == "BD_Euthymic", :);
nRows = max(height(dep), height(euth));
ParticipantNumber = strings(nRows, 1);
DepressedBD = strings(nRows, 1);
EuthymicBD = strings(nRows, 1);
for i = 1: nRows
    ParticipantNumber(i) = string(i);
    if i <= height(dep)
        DepressedBD(i) = alltables_med_string(dep, i, medVars);
    else
        DepressedBD(i) = "";
    end
    if i <= height(euth)
        EuthymicBD(i) = alltables_med_string(euth, i, medVars);
    else
        EuthymicBD(i) = "";
    end
end
T = table(ParticipantNumber, DepressedBD, EuthymicBD);
T.Properties.VariableDescriptions = {'Participant # (within subgroup)', 'Depressed BD', 'Euthymic BD'};

end

function [T, S] = alltables_build_table_s2(Tsub, Tdiag, Tendpoints, preprocFile, cfg)

subjects = string(Tsub.Subject);
S = table();
S.Subject = subjects(:);
S.ClinicalStage = string(Tsub.ClinicalStage(:));
S.RecordingDurationSec = alltables_get_numeric(Tsub, 'Rest_DurationSec', true(height(Tsub), 1));
S.RPeaksBeforeManualBadExclusion_N = alltables_get_numeric(Tsub, 'Rest_Rpeaks_AllMarked_N', true(height(Tsub), 1));
S.AcceptedRPeaksAfterManualQC_N = alltables_get_numeric(Tsub, 'Rest_Rpeaks_N', true(height(Tsub), 1));
S.ManualBadRPeaks_Percent = 100 * alltables_get_numeric(Tsub, 'Rest_ManualBadPeakFrac', true(height(Tsub), 1));
S.ManualAddedRPeaks_Percent = 100 * alltables_get_numeric(Tsub, 'Rest_ManualAddedPeakFrac', true(height(Tsub), 1));
invalidSec = alltables_get_numeric(Tsub, 'Rest_ManualInvalidSegment_TotalSec', true(height(Tsub), 1));
durSec = alltables_get_numeric(Tsub, 'Rest_DurationSec', true(height(Tsub), 1));
S.InvalidECGDuration_Percent = 100 * invalidSec ./ durSec;
S.MeanHeartRate_BPM = alltables_get_numeric(Tsub, 'Rest_MeanHR_BPM', true(height(Tsub), 1));
S.lnRMSSD = alltables_get_numeric(Tsub, 'Rest_lnRMSSD', true(height(Tsub), 1));
S.MeanChannelRLockedEpochsIncluded_N = alltables_subject_aggregate(Tdiag, subjects, 'NBeatsIncluded', 'mean');
S.MinChannelRLockedEpochsIncluded_N = alltables_subject_aggregate(Tdiag, subjects, 'NBeatsIncluded', 'min');
S.MeanChannelAmplitudeRejection_Percent = 100 * alltables_subject_aggregate(Tdiag, subjects, 'AmpRejectedFrac', 'mean');
S.MaxChannelAmplitudeRejection_Percent = 100 * alltables_subject_aggregate(Tdiag, subjects, 'AmpRejectedFrac', 'max');
S.MeanChannelRobustOutlierExclusion_Percent = 100 * alltables_subject_aggregate(Tdiag, subjects, 'OutlierExcludedFrac', 'mean');
S.MaxFullWaveformAbs_uV = alltables_subject_aggregate(Tendpoints, subjects, 'FullWaveformMaxAbs_uV', 'max');
S.EnhancedQCFlag = alltables_get_numeric(Tsub, 'QC_EnhancedExclusionFlag', true(height(Tsub), 1));
S.PeriRCFAScore_uV = alltables_get_numeric(Tsub, 'CFAScore_LOSO_uV', true(height(Tsub), 1));
S.PeriRCFAGFP_uV = alltables_get_numeric(Tsub, 'CFA_GFP_uV', true(height(Tsub), 1));
S.NoisyInterpolatedChannels_N = nan(height(S), 1);
S.RemovedICAComponents_N = nan(height(S), 1);
if strlength(string(preprocFile)) > 0 && exist(preprocFile, 'file') == 2
    Tpre = readtable(preprocFile, 'TextType', 'string');
    if ismember('Subject', Tpre.Properties.VariableNames)
        Tpre.Subject = string(Tpre.Subject);
        for i = 1: height(S)
            idx = find(Tpre.Subject == S.Subject(i), 1, 'first');
            if ~isempty(idx)
                if ismember('NoisyChannelsRemoved', Tpre.Properties.VariableNames)
                    valsNoisy = to_double_column(Tpre.NoisyChannelsRemoved);
                    S.NoisyInterpolatedChannels_N(i) = valsNoisy(idx);
                end
                if ismember('ICAComponentsRemoved', Tpre.Properties.VariableNames)
                    valsICA = to_double_column(Tpre.ICAComponentsRemoved);
                    S.RemovedICAComponents_N(i) = valsICA(idx);
                end
            end
        end
    end
end
varNames = ["RecordingDurationSec"; "RPeaksBeforeManualBadExclusion_N"; "AcceptedRPeaksAfterManualQC_N"; "ManualBadRPeaks_Percent"; "ManualAddedRPeaks_Percent"; "InvalidECGDuration_Percent"; "MeanHeartRate_BPM"; "lnRMSSD"; "MeanChannelRLockedEpochsIncluded_N"; "MinChannelRLockedEpochsIncluded_N"; "MeanChannelAmplitudeRejection_Percent"; "MaxChannelAmplitudeRejection_Percent"; "MeanChannelRobustOutlierExclusion_Percent"; "MaxFullWaveformAbs_uV"; "NoisyInterpolatedChannels_N"; "RemovedICAComponents_N"; "EnhancedQCFlag"; "PeriRCFAScore_uV"; "PeriRCFAGFP_uV"];
labels = ["Recording duration retained, s"; "R peaks before manual bad-peak exclusion, N"; "Accepted R peaks after manual QC, N"; "Manually bad R peaks, %"; "Manually added R peaks, %"; "Invalid ECG duration, % of retained recording"; "Mean heart rate, bpm"; "lnRMSSD"; "R-locked epochs included per channel, mean N"; "Minimum channel R-locked epochs included, N"; "Mean channel amplitude-rejection fraction, %"; "Maximum channel amplitude-rejection fraction, %"; "Mean channel robust-outlier exclusion fraction, %"; "Maximum full-waveform absolute amplitude, uV"; "Noisy/interpolated channels, N"; "Removed ICA components, N"; "Enhanced QC flag, n (%)"; "Peri-R CFA score, uV"; "Peri-R CFA GFP, uV"];
why = ["Ensures groups contributed comparable rest data"; "Basic ECG/beat yield before manual bad-beat exclusion"; "Determines reliability of subject-level R-locked averages"; "Tests whether one group required more manual bad-beat rejection"; "Tests whether one group required more missed-beat correction"; "Detects differential ECG-quality loss"; "Relevant because post-R timing and autonomic state may differ"; "Relevant autonomic covariate already used in sensitivity analysis"; "Indexes R-locked waveform averaging reliability"; "Detects channel-specific poor beat retention"; "Tests whether one group had noisier R-locked EEG epochs"; "Detects channel-specific amplitude-rejection burden"; "Tests whether robust within-subject outlier exclusion differed by group"; "Detects unusually large retained waveform amplitudes"; "Systematic preprocessing-quality summary"; "Systematic preprocessing-quality summary"; "Compact rule-based QC audit"; "Directly relevant to cardiac-field contamination"; "Raw peri-R field-magnitude complement to CFA score"];
digits = repmat(2, numel(varNames), 1);
displayType = [repmat("median", 16, 1); "binary"; "median"; "median"];
T = table();
T.Variable = labels;
T.WhyItMatters = why;
T.HC = strings(numel(varNames), 1);
T.Siblings = strings(numel(varNames), 1);
T.EuthymicBD = strings(numel(varNames), 1);
T.DepressedBD = strings(numel(varNames), 1);
T.OmnibusP = strings(numel(varNames), 1);
T.SMD_DepressedBD_vs_HC = strings(numel(varNames), 1);
T.SMD_DepressedBD_vs_EuthymicBD = strings(numel(varNames), 1);
stageOrder = ["HC" "Siblings" "BD_Euthymic" "BD_Depressed"];
for r = 1: numel(varNames)
    x = double(S.(varNames(r)));
    for g = 1: numel(stageOrder)
        xg = x(S.ClinicalStage == stageOrder(g));
        if displayType(r) == "binary"
            txt = alltables_binary_group_text(xg);
        else
            txt = alltables_median_iqr_text(xg, digits(r));
        end
        if stageOrder(g) == "HC"
            T.HC(r) = txt;
        elseif stageOrder(g) == "Siblings"
            T.Siblings(r) = txt;
        elseif stageOrder(g) == "BD_Euthymic"
            T.EuthymicBD(r) = txt;
        elseif stageOrder(g) == "BD_Depressed"
            T.DepressedBD(r) = txt;
        end
    end
    T.OmnibusP(r) = alltables_kw_p_text(x, S.ClinicalStage);
    T.SMD_DepressedBD_vs_HC(r) = alltables_smd_text(x(S.ClinicalStage == "BD_Depressed"), x(S.ClinicalStage == "HC"));
    T.SMD_DepressedBD_vs_EuthymicBD(r) = alltables_smd_text(x(S.ClinicalStage == "BD_Depressed"), x(S.ClinicalStage == "BD_Euthymic"));
end
T.Properties.VariableDescriptions = {'Variable', 'Why it matters', 'HC', 'Siblings', 'Euthymic BD', 'Depressed BD', 'Omnibus p', 'SMD: Depressed BD vs HC', 'SMD: Depressed BD vs Euthymic BD'};

end

function T = alltables_build_table_s3(Primary100Rows)

if isempty(Primary100Rows)
    T = table();
    return;
end
mask = ismember(string(Primary100Rows.AnalysisTier), ["PrimaryClinicalStageOmnibus" "PrimaryPlannedContrast" "SupportiveOrdinalTrend"]);
R = Primary100Rows(mask, :);
Analysis = strings(height(R), 1);
Test = strings(height(R), 1);
Estimate = strings(height(R), 1);
CI95 = strings(height(R), 1);
Statistic = strings(height(R), 1);
df = strings(height(R), 1);
PermP = strings(height(R), 1);
AdjP = strings(height(R), 1);
for i = 1: height(R)
    tier = string(R.AnalysisTier(i));
    if tier == "PrimaryClinicalStageOmnibus"
        Analysis(i) = "Primary omnibus";
        Test(i) = "Clinical-group omnibus";
    elseif tier == "PrimaryPlannedContrast"
        Analysis(i) = "Planned contrast";
        Test(i) = alltables_contrast_label(R, i);
    else
        Analysis(i) = "Supportive trend";
        Test(i) = "Ordinal group gradient";
    end
    if isfinite(double(R.Estimate(i)))
        Estimate(i) = alltables_num(double(R.Estimate(i)), 3);
        CI95(i) = alltables_ci_text(double(R.CI95_Low(i)), double(R.CI95_High(i)), 3);
    end
    Statistic(i) = alltables_stat_text(R, i);
    df(i) = alltables_num(double(R.DF(i)), 0);
    PermP(i) = alltables_p_text(double(R.PermutationP(i)));
    AdjP(i) = alltables_p_text(double(R.HolmP(i)));
end
T = table(Analysis, Test, Estimate, CI95, Statistic, df, PermP, AdjP);
T.Properties.VariableDescriptions = {'Analysis', 'Test', 'Estimate', '95% CI', 'Statistic', 'df', 'Perm. p', 'Adj. p'};

end

function T = alltables_build_table_s4(secondaryRows)

if isempty(secondaryRows)
    T = table();
    return;
end
R = secondaryRows;
Analysis = strings(height(R), 1);
Endpoint = strings(height(R), 1);
Test = strings(height(R), 1);
Estimate = strings(height(R), 1);
CI95 = strings(height(R), 1);
Statistic = strings(height(R), 1);
PermP = strings(height(R), 1);
HolmP = strings(height(R), 1);
for i = 1: height(R)
    if string(R.AnalysisTier(i)) == "Secondary"
        Analysis(i) = "Secondary omnibus";
        Test(i) = "Clinical-group omnibus";
    else
        Analysis(i) = "Adjacent-window contrast";
        Test(i) = alltables_contrast_label(R, i);
    end
    Endpoint(i) = alltables_endpoint_label(string(R.Endpoint(i)));
    if isfinite(double(R.Estimate(i)))
        Estimate(i) = alltables_num(double(R.Estimate(i)), 3);
        CI95(i) = alltables_ci_text(double(R.CI95_Low(i)), double(R.CI95_High(i)), 3);
    end
    Statistic(i) = alltables_stat_text(R, i);
    PermP(i) = alltables_p_text(double(R.PermutationP(i)));
    HolmP(i) = alltables_p_text(double(R.HolmP(i)));
end
T = table(Analysis, Endpoint, Test, Estimate, CI95, Statistic, PermP, HolmP);
T.Properties.VariableDescriptions = {'Analysis', 'Endpoint', 'Test', 'Estimate', '95% CI', 'Statistic', 'Perm. p', 'Holm p'};

end

function T = alltables_build_table_s5(Cluster)

if ~isstruct(Cluster) || ~isfield(Cluster, 'Table') || isempty(Cluster.Table)
    T = table();
    return;
end
R = Cluster.Table;
if ismember('ClusterP_FWER', R.Properties.VariableNames)
    keep = double(R.ClusterP_FWER) < 0.10;
    R = R(keep, :);
end
ClusterID = strings(height(R), 1);
Sign = strings(height(R), 1);
Mass = strings(height(R), 1);
Size = strings(height(R), 1);
TimeWindowMs = strings(height(R), 1);
PeakT = strings(height(R), 1);
PeakChannel = strings(height(R), 1);
Channels = strings(height(R), 1);
pFWER = strings(height(R), 1);
for i = 1: height(R)
    ClusterID(i) = alltables_num(double(R.ClusterID(i)), 0);
    if double(R.Sign(i)) < 0
        Sign(i) = "Negative";
    else
        Sign(i) = "Positive";
    end
    Mass(i) = alltables_num(double(R.Mass(i)), 2);
    Size(i) = alltables_num(double(R.Size(i)), 0);
    TimeWindowMs(i) = alltables_num(double(R.StartMs(i)), 0) + "-" + alltables_num(double(R.EndMs(i)), 0);
    PeakT(i) = alltables_num(double(R.PeakT(i)), 3);
    PeakChannel(i) = string(R.PeakChannel(i));
    Channels(i) = strrep(string(R.Channels(i)), "|", ", ");
    pFWER(i) = alltables_p_text(double(R.ClusterP_FWER(i)));
end
T = table(ClusterID, Sign, Mass, Size, TimeWindowMs, PeakT, PeakChannel, Channels, pFWER);
T.Properties.VariableDescriptions = {'Cluster ID', 'Sign', 'Mass', 'Size', 'Time window (ms)', 'Peak t', 'Peak channel', 'Channels', 'p_FWER'};

end

function T = alltables_build_table_s6(BDRows)

if isempty(BDRows)
    T = table();
    return;
end
R = BDRows;
Predictor = strings(height(R), 1);
Covariates = strings(height(R), 1);
Estimate = strings(height(R), 1);
CI95 = strings(height(R), 1);
Statistic = strings(height(R), 1);
PermP = strings(height(R), 1);
FDRq = strings(height(R), 1);
for i = 1: height(R)
    Predictor(i) = alltables_predictor_label(string(R.Predictor(i)));
    Covariates(i) = alltables_covariate_label(string(R.CovariatesIncluded(i)));
    Estimate(i) = alltables_num(double(R.Estimate(i)), 3);
    CI95(i) = alltables_ci_text(double(R.CI95_Low(i)), double(R.CI95_High(i)), 3);
    Statistic(i) = alltables_stat_text(R, i);
    PermP(i) = alltables_p_text(double(R.PermutationP(i)));
    FDRq(i) = alltables_p_text(double(R.FDR_BH_Q(i)));
end
T = table(Predictor, Covariates, Estimate, CI95, Statistic, PermP, FDRq);
T.Properties.VariableDescriptions = {'Predictor', 'Covariates', 'Estimate', '95% CI', 'Statistic', 'Perm. p', 'FDR q'};

end

function T = alltables_build_table_s7(Primary100Rows, PseudoRows)

R1 = table();
if ~isempty(Primary100Rows)
    keep = ismember(string(Primary100Rows.AnalysisTier), ["PrimarySensitivity" "PostHocSensitivity"]);
    R1 = Primary100Rows(keep, :);
end
R2 = table();
if ~isempty(PseudoRows)
    R2 = PseudoRows;
end
R = append_rows(R1, R2);
if isempty(R)
    T = table();
    return;
end
Analysis = strings(height(R), 1);
TestContrast = strings(height(R), 1);
Estimate = strings(height(R), 1);
CI95 = strings(height(R), 1);
Statistic = strings(height(R), 1);
PermP = strings(height(R), 1);
AdjP = strings(height(R), 1);
for i = 1: height(R)
    Analysis(i) = alltables_sensitivity_label(R, i);
    if string(R.Contrast(i)) == "ClinicalStageOmnibus"
        TestContrast(i) = "Clinical-group omnibus";
    else
        TestContrast(i) = alltables_contrast_label(R, i);
    end

    isMCSummary = false;

    if ismember('IsMonteCarloSummary', R.Properties.VariableNames)
        isMCSummary = logical(R.IsMonteCarloSummary(i));
    end

    if isMCSummary
        Estimate(i) = alltables_mc_interval_text(R, i, 'MC_EstimateMedian', 'MC_EstimateCI95_Low', 'MC_EstimateCI95_High', 3);
        CI95(i) = "MC 2.5-97.5% interval";
        Statistic(i) = alltables_mc_interval_text(R, i, 'MC_StatisticMedian', 'MC_StatisticCI95_Low', 'MC_StatisticCI95_High', 2);
        PermP(i) = alltables_mc_p_text(R, i, 'MC_PermP_Median', 'MC_PermP_CI95_Low', 'MC_PermP_CI95_High', 'MC_PermP_Lt_0_05_Percent');
        AdjP(i) = alltables_mc_p_text(R, i, 'MC_HolmP_Median', 'MC_HolmP_CI95_Low', 'MC_HolmP_CI95_High', 'MC_HolmP_Lt_0_05_Percent');
    else
        if isfinite(double(R.Estimate(i)))
            Estimate(i) = alltables_num(double(R.Estimate(i)), 3);
            CI95(i) = alltables_ci_text(double(R.CI95_Low(i)), double(R.CI95_High(i)), 3);
        end
        Statistic(i) = alltables_stat_text(R, i);
        PermP(i) = alltables_p_text(double(R.PermutationP(i)));
        AdjP(i) = alltables_p_text(double(R.HolmP(i)));
    end
end
T = table(Analysis, TestContrast, Estimate, CI95, Statistic, PermP, AdjP);
T.Properties.VariableDescriptions = {'Analysis', 'Test / contrast', 'Estimate', '95% CI', 'Statistic', 'Perm. p', 'Adj. p'};

end


function txt = alltables_mc_interval_text(R, i, medianName, lowName, highName, ndigits)

txt = "";

if ~ismember(medianName, R.Properties.VariableNames) || ~ismember(lowName, R.Properties.VariableNames) || ~ismember(highName, R.Properties.VariableNames)
    return;
end

mid = double(R.(medianName)(i));
lo = double(R.(lowName)(i));
hi = double(R.(highName)(i));

if ~isfinite(mid)
    return;
end

if isfinite(lo) && isfinite(hi)
    txt = sprintf('%s [%s, %s]', alltables_num(mid, ndigits), alltables_num(lo, ndigits), alltables_num(hi, ndigits));
else
    txt = alltables_num(mid, ndigits);
end

end

function txt = alltables_mc_p_text(R, i, medianName, lowName, highName, percentName)

txt = "";

if ~ismember(medianName, R.Properties.VariableNames)
    return;
end

mid = double(R.(medianName)(i));

if ~isfinite(mid)
    return;
end

if ismember(lowName, R.Properties.VariableNames) && ismember(highName, R.Properties.VariableNames)
    lo = double(R.(lowName)(i));
    hi = double(R.(highName)(i));
else
    lo = NaN;
    hi = NaN;
end

if isfinite(lo) && isfinite(hi)
    txt = sprintf('median %s [%s, %s]', alltables_p_text(mid), alltables_p_text(lo), alltables_p_text(hi));
else
    txt = sprintf('median %s', alltables_p_text(mid));
end

if ismember(percentName, R.Properties.VariableNames)
    pct = double(R.(percentName)(i));

    if isfinite(pct)
        txt = sprintf('%s; <0.05 in %.1f%%', txt, pct);
    end
end

end

function T = alltables_build_table_s8(TemplateReliability)

if ~isstruct(TemplateReliability) || ~isfield(TemplateReliability, 'Summary') || isempty(TemplateReliability.Summary)
    T = table();
    return;
end
R = TemplateReliability.Summary;
ReliabilityMetric = strings(height(R), 1);
Value = strings(height(R), 1);
for i = 1: height(R)
    ReliabilityMetric(i) = alltables_reliability_label(string(R.Metric(i)));
    Value(i) = alltables_num(double(R.Value(i)), 3);
end
T = table(ReliabilityMetric, Value);
T.Properties.VariableDescriptions = {'Reliability metric', 'Value'};

end

function alltables_word_heading(selection, txt, fontSize, isBold)

selection.Font.Name = 'Times New Roman';
selection.Font.Size = fontSize;
selection.Font.Bold = double(isBold);
selection.TypeText(char(txt));
selection.TypeParagraph;
selection.Font.Bold = 0;
selection.Font.Size = 10;

end

function alltables_word_paragraph(selection, txt, fontSize, isItalic)

selection.Font.Name = 'Times New Roman';
selection.Font.Size = fontSize;
selection.Font.Italic = double(isItalic);
selection.TypeText(char(txt));
selection.TypeParagraph;
selection.Font.Italic = 0;

end

function alltables_word_page_break(selection)

selection.InsertBreak(7);

end

function alltables_word_add_table(doc, selection, caption, T, noteText)

alltables_word_heading(selection, caption, 11, true);
if isempty(T) || height(T) == 0 || width(T) == 0
    alltables_word_paragraph(selection, 'Table unavailable.', 9, true);
    return;
end
headers = alltables_table_headers(T);
nRows = height(T) + 1;
nCols = width(T);
range = selection.Range;
tbl = doc.Tables.Add(range, nRows, nCols);
tbl.Borders.Enable = 1;
tbl.Range.Font.Name = 'Times New Roman';
tbl.Range.Font.Size = 7;
tbl.Rows.Item(1).Range.Font.Bold = 1;
for c = 1: nCols
    tbl.Cell(1, c).Range.Text = char(headers(c));
end
for r = 1: height(T)
    for c = 1: nCols
        tbl.Cell(r + 1, c).Range.Text = char(alltables_cell_text(T{r, c}));
    end
end
tbl.AutoFitBehavior(2);
selection.SetRange(tbl.Range.End, tbl.Range.End);
selection.TypeParagraph;
alltables_word_paragraph(selection, noteText, 8, false);
selection.TypeParagraph;

end

function headers = alltables_table_headers(T)

if ~isempty(T.Properties.VariableDescriptions) && numel(T.Properties.VariableDescriptions) == width(T)
    headers = string(T.Properties.VariableDescriptions);
else
    headers = string(T.Properties.VariableNames);
end
headers = strrep(headers, '_', ' ');

end

function txt = alltables_cell_text(x)

if iscell(x)
    if isempty(x)
        txt = "";
    else
        txt = alltables_cell_text(x{1});
    end
elseif isstring(x)
    txt = x;
elseif ischar(x)
    txt = string(x);
elseif isnumeric(x)
    if isempty(x) || ~isfinite(x(1))
        txt = "";
    else
        txt = string(x(1));
    end
elseif iscategorical(x)
    txt = string(x);
elseif islogical(x)
    txt = string(x);
else
    txt = string(x);
end
if ismissing(txt)
    txt = "";
end

end

function x = alltables_get_numeric(T, varName, mask)

if isempty(T) || ~ismember(varName, T.Properties.VariableNames)
    x = nan(sum(mask), 1);
    return;
end
vals = to_double_column(T.(varName));
x = vals(mask);

end

function txt = alltables_mean_sd_text(x, digits)

x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    txt = "N/A";
else
    txt = sprintf(['%.', num2str(digits), 'f %s %.', num2str(digits), 'f'], mean(x, 'omitnan'), '+/-', std(x, 0, 'omitnan'));
end

end

function txt = alltables_mean_sd_text_bd_only(T, varName, mask, stageName, digits)

if ~ismember(stageName, ["BD_Depressed" "BD_Euthymic"])
    txt = "N/A";
    return;
end
txt = alltables_mean_sd_text(alltables_get_numeric(T, varName, mask), digits);

end

function txt = alltables_sex_mf_text(Tsub, mask)

x = alltables_get_numeric(Tsub, 'Sex', mask);
m = sum(x == 1 & isfinite(x));
f = sum(x == 0 & isfinite(x));
txt = sprintf('%d/%d', m, f);

end

function txt = alltables_subtype_text(Tsub, mask, stageName)

if ~ismember(stageName, ["BD_Depressed" "BD_Euthymic"])
    txt = "N/A";
    return;
end
if ~ismember('Subtype', Tsub.Properties.VariableNames)
    txt = "N/A";
    return;
end
subtype = string(Tsub.Subtype(mask));
nI = sum(strcmpi(subtype, "I"));
nII = sum(strcmpi(subtype, "II"));
txt = sprintf('%d/%d', nI, nII);

end

function txt = alltables_med_string(T, rowIdx, medVars)

txtParts = strings(1, numel(medVars));
for m = 1: numel(medVars)
    if ismember(medVars{m}, T.Properties.VariableNames)
        vals = to_double_column(T.(medVars{m}));
        val = vals(rowIdx);
    else
        val = NaN;
    end
    if ~isfinite(val)
        val = 0;
    end
    txtParts(m) = sprintf('%s(%d)', medVars{m}, round(val));
end
txt = strjoin(txtParts, ', ');

end

function vals = alltables_subject_aggregate(T, subjects, varName, modeName)

vals = nan(numel(subjects), 1);
if isempty(T) || ~istable(T) || ~ismember('Subject', T.Properties.VariableNames) || ~ismember(varName, T.Properties.VariableNames)
    return;
end
subj = string(T.Subject);
xAll = to_double_column(T.(varName));
for i = 1: numel(subjects)
    x = xAll(subj == subjects(i) & isfinite(xAll));
    if isempty(x)
        continue;
    end
    if strcmpi(modeName, 'max')
        vals(i) = max(x);
    elseif strcmpi(modeName, 'min')
        vals(i) = min(x);
    else
        vals(i) = mean(x, 'omitnan');
    end
end

end

function txt = alltables_median_iqr_text(x, digits)

x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    txt = "N/A";
else
    medVal = median(x, 'omitnan');
    q1 = prctile(x, 25);
    q3 = prctile(x, 75);
    fmt = ['%.', num2str(digits), 'f [%.', num2str(digits), 'f, %.', num2str(digits), 'f]'];
    txt = sprintf(fmt, medVal, q1, q3);
end

end

function txt = alltables_binary_group_text(x)

x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    txt = "N/A";
else
    n = sum(x > 0);
    pct = 100 * n / numel(x);
    txt = sprintf('%d/%d (%.2f%%)', n, numel(x), pct);
end

end

function txt = alltables_kw_p_text(x, groups)

x = double(x(:));
groups = string(groups(:));
ok = isfinite(x) & strlength(groups) > 0;
if sum(ok) < 4 || numel(unique(groups(ok))) < 2
    txt = "";
    return;
end
try
    p = kruskalwallis(x(ok), categorical(groups(ok)), 'off');
    txt = alltables_p_text(p);
catch
    txt = "";
end

end

function txt = alltables_smd_text(x1, x0)

x1 = double(x1(:));
x0 = double(x0(:));
x1 = x1(isfinite(x1));
x0 = x0(isfinite(x0));
if numel(x1) < 2 || numel(x0) < 2
    txt = "";
    return;
end
s1 = var(x1, 0, 'omitnan');
s0 = var(x0, 0, 'omitnan');
sp = sqrt(((numel(x1) - 1) * s1 + (numel(x0) - 1) * s0) / max(numel(x1) + numel(x0) - 2, 1));
if ~isfinite(sp) || sp <= eps
    txt = "";
else
    txt = alltables_num((mean(x1, 'omitnan') - mean(x0, 'omitnan')) / sp, 2);
end

end

function txt = alltables_num(x, digits)

if isempty(x) || ~isfinite(x)
    txt = "";
else
    txt = string(sprintf(['%.', num2str(digits), 'f'], x));
end

end

function txt = alltables_p_text(p)

if isempty(p) || ~isfinite(p)
    txt = "";
elseif p < 0.001
    txt = "<0.001";
else
    txt = string(sprintf('%.3f', p));
end

end

function txt = alltables_ci_text(lo, hi, digits)

if ~isfinite(lo) || ~isfinite(hi)
    txt = "";
else
    txt = "[" + alltables_num(lo, digits) + ", " + alltables_num(hi, digits) + "]";
end

end

function txt = alltables_stat_text(R, i)

val = double(R.T(i));
if ~isfinite(val)
    txt = "";
    return;
end
if string(R.Contrast(i)) == "ClinicalStageOmnibus"
    txt = "F = " + alltables_num(val, 2);
else
    txt = "t = " + alltables_num(val, 2);
end

end

function txt = alltables_contrast_label(R, i)

if ismember('ContrastLabel', R.Properties.VariableNames)
    label = string(R.ContrastLabel(i));
else
    label = "";
end
if ~ismissing(label) && strlength(label) > 0
    txt = label;
else
    txt = string(R.Contrast(i));
end
txt = strrep(txt, "BD Depressed", "Depressed BD");
txt = strrep(txt, "BD Euthymic", "Euthymic BD");
txt = strrep(txt, "BD_Depressed", "Depressed BD");
txt = strrep(txt, "BD_Euthymic", "Euthymic BD");
txt = strrep(txt, "_vs_", " - ");
txt = strrep(txt, "_", " ");

end

function txt = alltables_endpoint_label(endpointName)

if endpointName == "EarlyFieldScore_LOSO_uV"
    txt = "200-300 ms field score";
elseif endpointName == "LateFieldScore_LOSO_uV"
    txt = "300-400 ms field score";
elseif endpointName == "EarlyGFP_200to300_uV"
    txt = "200-300 ms GFP";
else
    txt = endpointName;
end

end

function txt = alltables_predictor_label(pred)

if pred == "MedBurden"
    txt = "Medication burden";
else
    txt = pred;
end

end

function txt = alltables_covariate_label(covs)

txt = strrep(covs, "|", ", ");
txt = strrep(txt, "BDMoodState_Depressed", "BD mood state");

end

function txt = alltables_sensitivity_label(R, i)

rule = "";
if ismember('QCSensitivityRule', R.Properties.VariableNames)
    rule = string(R.QCSensitivityRule(i));
end
family = "";
if ismember('Family', R.Properties.VariableNames)
    family = string(R.Family(i));
end
if rule == "CFA_adjustment"
    txt = "CFA-adjusted primary model";
elseif rule == "MeanHR_adjustment"
    txt = "Mean-HR-adjusted primary model";
elseif rule == "lnRMSSD_adjustment"
    txt = "lnRMSSD-adjusted primary model";
elseif rule == "CigsPerDay_adjustment"
    txt = "Smoking-adjusted primary model";
elseif string(R.AnalysisTier(i)) == "PseudoEventMonteCarloSummary"
    txt = "Pseudo-event Monte Carlo control";
elseif startsWith(family, "PseudoEvent") || string(R.AnalysisTier(i)) == "PseudoEventControl"
    txt = "Pseudo-event control";
else
    txt = string(R.AnalysisTier(i));
end

end

function txt = alltables_reliability_label(metric)

keys = ["LOSO_weight_corr_with_pooled_mean"; "LOSO_weight_corr_with_pooled_sd"; "LOSO_weight_corr_with_pooled_min"; "Bootstrap_weight_corr_with_pooled_mean"; "Bootstrap_weight_corr_with_pooled_sd"; "Bootstrap_weight_corr_with_pooled_CI95_low"; "Bootstrap_weight_corr_with_pooled_CI95_high"; "SplitHalf_weight_corr_between_halves_mean"; "SplitHalf_weight_corr_between_halves_sd"; "SplitHalf_weight_corr_between_halves_CI95_low"; "SplitHalf_weight_corr_between_halves_CI95_high"; "SplitHalf_halfA_corr_with_pooled_mean"; "SplitHalf_halfB_corr_with_pooled_mean"];
vals = ["LOSO weight correlation with pooled template, mean"; "LOSO weight correlation with pooled template, SD"; "LOSO weight correlation with pooled template, minimum"; "Bootstrap weight correlation with pooled template, mean"; "Bootstrap weight correlation with pooled template, SD"; "Bootstrap weight correlation with pooled template, 95% interval lower bound"; "Bootstrap weight correlation with pooled template, 95% interval upper bound"; "Split-half weight correlation between halves, mean"; "Split-half weight correlation between halves, SD"; "Split-half weight correlation between halves, 95% interval lower bound"; "Split-half weight correlation between halves, 95% interval upper bound"; "Split-half template A correlation with pooled template, mean"; "Split-half template B correlation with pooled template, mean"];
idx = find(keys == metric, 1, 'first');
if isempty(idx)
    txt = strrep(metric, "_", " ");
else
    txt = vals(idx);
end

end
