%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Summarize noisy-channel removal and ICA-component rejection
% ==========================================================
%
% This script scans resting EEG preprocessing outputs and computes:
% 1. Number of noisy channels removed before ICA.
% 2. Number of ICA components removed before final analysis file.
% 3. Overall percentages, ranges, and group medians for Methods reporting.
%
% Expected files per subject:
% Subject_X_rest_processed_unclean_Not_interpolated_Not_referenced.set
% Subject_X_rest_processed.set
%
% The unclean file is assumed to contain data after 0.5-40 Hz filtering,
% noisy-channel removal, and ICA, before bad ICA-component subtraction,
% interpolation, and average re-reference.
%
% The final file is assumed to contain data after ICA-component subtraction,
% interpolation to the original montage, and average reference.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all force; clc;

%% =========
%  User settings
%  ==========

cfg = struct();

cfg.projectRootOverride = "";
cfg.baseDirOverride = "";
cfg.outputDirOverride = "";

cfg.groups = {'BP_I_Depressed', 'BP_II_Depressed', 'BP_I_Euthymic', 'BP_II_Euthymic', 'Siblings', 'HC'};
cfg.processedFolderName = 'Processed';
cfg.restFolderName = "";

cfg.initialChannelCount = 65;
cfg.uncleanSuffix = '_rest_processed_unclean_Not_interpolated_Not_referenced.set';
cfg.finalSuffix = '_rest_processed.set';
cfg.icaRejectionSidecarSuffix = '_rest_ICARejection.mat';
cfg.parseICARejectionFromHistory = true;
cfg.assumeNoPopSubcompMeansZero = true;

cfg.writeOutputs = true;

thisFile = mfilename('fullpath');

if strlength(string(thisFile)) > 0
    scriptDir = string(fileparts(thisFile));
else
    scriptDir = string(pwd);
end

cfg.projectRoot = infer_project_root(scriptDir, cfg.projectRootOverride);

if strlength(string(cfg.baseDirOverride)) > 0
    cfg.baseDir = char(cfg.baseDirOverride);
else
    cfg.baseDir = char(fullfile(cfg.projectRoot, 'Data'));
end

if strlength(string(cfg.outputDirOverride)) > 0
    cfg.outputDir = char(cfg.outputDirOverride);
else
    cfg.outputDir = char(fullfile(cfg.projectRoot, 'Analysis', 'Preprocessing_QC'));
end

ensure_dir(cfg.outputDir);

if exist('pop_loadset', 'file') ~= 2
    error('EEGLAB pop_loadset was not found on the MATLAB path. Add EEGLAB before running this script.');
end

fprintf('\nPreprocessing summary scan started.\n');
fprintf('Data root: %s\n', cfg.baseDir);
fprintf('Output directory: %s\n', cfg.outputDir);
fprintf('Initial channel count assumed: %d\n', cfg.initialChannelCount);

%% ==========
%  Scan subjects
%  ===========

Rows = table();

for g = 1: numel(cfg.groups)
    rawGroup = string(cfg.groups{g});
    groupDir = fullfile(cfg.baseDir, char(rawGroup));

    if exist(groupDir, 'dir') ~= 7
        warning('Group directory not found: %s', groupDir);
        continue;
    end

    subjDirs = dir(fullfile(groupDir, 'Subject_*'));
    subjDirs = subjDirs([subjDirs.isdir]);

    for s = 1: numel(subjDirs)
        subject = string(subjDirs(s).name);
        subjDir = fullfile(groupDir, char(subject));

        if strlength(string(cfg.restFolderName)) > 0
            restDir = fullfile(subjDir, cfg.processedFolderName, cfg.restFolderName);
        else
            restDir = fullfile(subjDir, cfg.processedFolderName);
        end

        uncleanFile = fullfile(restDir, char(subject + string(cfg.uncleanSuffix)));
        finalFile = fullfile(restDir, char(subject + string(cfg.finalSuffix)));
        icaRejectionFile = fullfile(restDir, char(subject + string(cfg.icaRejectionSidecarSuffix)));

        row = init_subject_row();
        row.RawGroup = rawGroup;
        row.ClinicalStage = raw_group_to_clinical_stage(rawGroup);
        row.Subject = subject;
        row.UncleanFile = string(uncleanFile);
        row.FinalFile = string(finalFile);
        row.ICARejectionFile = string(icaRejectionFile);

        if exist(uncleanFile, 'file') ~= 2
            row.Status = "MissingUncleanFile";
            Rows = append_rows(Rows, row);
            continue;
        end

        if exist(finalFile, 'file') ~= 2
            row.Status = "MissingFinalFile";
            Rows = append_rows(Rows, row);
            continue;
        end

        try
            EEGunclean = load_set_header(uncleanFile);
            EEGfinal = load_set_header(finalFile);

            row.UncleanNChannels = double(EEGunclean.nbchan);
            row.FinalNChannels = double(EEGfinal.nbchan);
            row.NoisyChannelsRemoved = cfg.initialChannelCount - row.UncleanNChannels;

            if row.NoisyChannelsRemoved < 0
                row.Warning = "UncleanFileHasMoreChannelsThanInitialCount";
                row.NoisyChannelsRemoved = NaN;
            end

            row.UncleanChannelLabels = strjoin(channel_labels_from_eeg(EEGunclean), "|");
            row.FinalChannelLabels = strjoin(channel_labels_from_eeg(EEGfinal), "|");
            row.RemovedChannelLabels = strjoin(setdiff(channel_labels_from_eeg(EEGfinal), channel_labels_from_eeg(EEGunclean), 'stable'), "|");

            row.UncleanNICAComponents = get_n_ica_components(EEGunclean);
            row.FinalNICAComponents = get_n_ica_components(EEGfinal);
            row.UncleanRejectFlaggedComponents = get_n_reject_flagged_components(EEGunclean);
            row.FinalRejectFlaggedComponents = get_n_reject_flagged_components(EEGfinal);

            methodWarning = "";
            [explicitCount, explicitIndices, explicitMethod] = get_explicit_ica_removal_count(EEGfinal, EEGunclean, icaRejectionFile, cfg);
            row.ExplicitICAComponentsRemoved = explicitCount;
            row.ExplicitICAComponentIndices = explicitIndices;

            if isfinite(explicitCount)
                row.ICAComponentsRemoved = explicitCount;
                row.ICAComponentsRemovedMethod = explicitMethod;
            else
                [zeroCount, zeroMethod, zeroWarning] = infer_zero_ica_removal_from_absent_pop_subcomp(EEGfinal, EEGunclean, row.UncleanNICAComponents, cfg);

                if isfinite(zeroCount)
                    row.ICAComponentsRemoved = zeroCount;
                    row.ICAComponentsRemovedMethod = zeroMethod;
                    methodWarning = zeroWarning;
                else
                    [row.ICAComponentsRemoved, row.ICAComponentsRemovedMethod, methodWarning] = estimate_removed_components(row.UncleanNICAComponents, row.FinalNICAComponents, row.UncleanRejectFlaggedComponents, row.FinalRejectFlaggedComponents);
                end
            end

            if strlength(methodWarning) > 0
                if strlength(row.Warning) > 0
                    row.Warning = row.Warning + "; " + methodWarning;
                else
                    row.Warning = methodWarning;
                end
            end

            row.Status = "OK";
        catch ME
            row.Status = "LoadOrParseFailed";
            row.Warning = string(ME.message);
        end

        Rows = append_rows(Rows, row);
    end
end

Rows = sortrows(Rows, {'ClinicalStage', 'Subject'});

%% ========
%  Summaries
%  =========

ok = string(Rows.Status) == "OK";
Tok = Rows(ok, :);

Summary = table();

Summary = append_rows(Summary, summarize_metric(Tok, "All", "All", "NoisyChannelsRemoved", "Noisy channels removed"));
Summary = append_rows(Summary, summarize_metric(Tok, "All", "All", "ICAComponentsRemoved", "ICA components removed"));

stageOrder = ["BD_Depressed", "BD_Euthymic", "HC", "Siblings"];

for i = 1: numel(stageOrder)
    st = stageOrder(i);
    Tstage = Tok(string(Tok.ClinicalStage) == st, :);
    Summary = append_rows(Summary, summarize_metric(Tstage, "ClinicalStage", st, "NoisyChannelsRemoved", "Noisy channels removed"));
    Summary = append_rows(Summary, summarize_metric(Tstage, "ClinicalStage", st, "ICAComponentsRemoved", "ICA components removed"));
end

rawGroups = unique(string(Tok.RawGroup), 'stable');

for i = 1: numel(rawGroups)
    rg = rawGroups(i);
    Traw = Tok(string(Tok.RawGroup) == rg, :);
    Summary = append_rows(Summary, summarize_metric(Traw, "RawGroup", rg, "NoisyChannelsRemoved", "Noisy channels removed"));
    Summary = append_rows(Summary, summarize_metric(Traw, "RawGroup", rg, "ICAComponentsRemoved", "ICA components removed"));
end

textBlock = build_manuscript_text(Tok);

%% ====
%  Export
%  =====

if cfg.writeOutputs
    subjectOut = fullfile(cfg.outputDir, 'Table_Preprocessing_NoisyChannels_ICAComponents_BySubject.csv');
    summaryOut = fullfile(cfg.outputDir, 'Table_Preprocessing_NoisyChannels_ICAComponents_Summary.csv');
    textOut = fullfile(cfg.outputDir, 'Manuscript_Preprocessing_NoisyChannels_ICAComponents_Text.txt');

    writetable(Rows, subjectOut);
    writetable(Summary, summaryOut);

    fid = fopen(textOut, 'w');
    if fid > 0
        fprintf(fid, '%s\n', textBlock);
        fclose(fid);
    end

    fprintf('\nExported subject table:\n%s\n', subjectOut);
    fprintf('Exported summary table:\n%s\n', summaryOut);
    fprintf('Exported manuscript text:\n%s\n', textOut);
end

fprintf('\nManuscript-ready text:\n\n%s\n', textBlock);

fprintf('\nDone.\n');

%% ==========
%  Local functions
%  ===========

function projectRoot = infer_project_root(scriptDir, projectRootOverride)

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

function ensure_dir(p)

if exist(p, 'dir') ~= 7
    mkdir(p);
end

end

function row = init_subject_row()

row = table();
row.RawGroup = strings(1, 1);
row.ClinicalStage = strings(1, 1);
row.Subject = strings(1, 1);
row.Status = strings(1, 1);
row.Warning = strings(1, 1);
row.UncleanFile = strings(1, 1);
row.FinalFile = strings(1, 1);
row.ICARejectionFile = strings(1, 1);
row.UncleanNChannels = NaN;
row.FinalNChannels = NaN;
row.NoisyChannelsRemoved = NaN;
row.RemovedChannelLabels = strings(1, 1);
row.UncleanChannelLabels = strings(1, 1);
row.FinalChannelLabels = strings(1, 1);
row.UncleanNICAComponents = NaN;
row.FinalNICAComponents = NaN;
row.ICAComponentsRemoved = NaN;
row.ICAComponentsRemovedMethod = strings(1, 1);
row.ExplicitICAComponentsRemoved = NaN;
row.ExplicitICAComponentIndices = strings(1, 1);
row.UncleanRejectFlaggedComponents = NaN;
row.FinalRejectFlaggedComponents = NaN;

end

function stage = raw_group_to_clinical_stage(rawGroup)

g = string(rawGroup);

if g == "HC"
    stage = "HC";
elseif g == "Siblings"
    stage = "Siblings";
elseif contains(g, "Depressed")
    stage = "BD_Depressed";
elseif contains(g, "Euthymic")
    stage = "BD_Euthymic";
else
    stage = "Unknown";
end

end

function EEG = load_set_header(setFile)

[p, n, e] = fileparts(setFile);
fname = [n e];

try
    EEG = pop_loadset('filename', fname, 'filepath', p, 'loadmode', 'info');
catch
    EEG = pop_loadset('filename', fname, 'filepath', p);
end

end

function labels = channel_labels_from_eeg(EEG)

labels = strings(0, 1);

if isempty(EEG) || ~isfield(EEG, 'chanlocs') || isempty(EEG.chanlocs)
    return;
end

labels = strings(numel(EEG.chanlocs), 1);

for i = 1: numel(EEG.chanlocs)
    if isfield(EEG.chanlocs(i), 'labels') && ~isempty(EEG.chanlocs(i).labels)
        labels(i) = string(EEG.chanlocs(i).labels);
    else
        labels(i) = "";
    end
end

labels = labels(strlength(labels) > 0);

end

function nComp = get_n_ica_components(EEG)

nComp = NaN;

if isempty(EEG)
    return;
end

if isfield(EEG, 'icaweights') && ~isempty(EEG.icaweights)
    nComp = size(EEG.icaweights, 1);
    return;
end

if isfield(EEG, 'icawinv') && ~isempty(EEG.icawinv)
    nComp = size(EEG.icawinv, 2);
    return;
end

if isfield(EEG, 'icaact') && ~isempty(EEG.icaact)
    nComp = size(EEG.icaact, 1);
    return;
end

end

function nFlagged = get_n_reject_flagged_components(EEG)

nFlagged = NaN;

if isempty(EEG) || ~isfield(EEG, 'reject') || isempty(EEG.reject)
    return;
end

candidateFields = {'gcompreject', 'rejmanual', 'rejkurt', 'rejskew', 'rejfreq', 'rejconst', 'rejthresh'};

for f = 1: numel(candidateFields)
    fn = candidateFields{f};

    if isfield(EEG.reject, fn)
        x = EEG.reject.(fn);

        if ~isempty(x)
            x = double(x(:));
            n = sum(x > 0 & isfinite(x));

            if isfinite(n)
                if isnan(nFlagged)
                    nFlagged = n;
                else
                    nFlagged = max(nFlagged, n);
                end
            end
        end
    end
end

end

function [nRemoved, method, warningText] = estimate_removed_components(nBefore, nAfter, nFlagBefore, nFlagAfter)

nRemoved = NaN;
method = "";
warningText = "";

if isfinite(nBefore) && isfinite(nAfter)
    d = nBefore - nAfter;

    if d >= 0
        nRemoved = d;
        method = "ComponentCountDifference";

        if d == 0
            if isfinite(nFlagBefore) && nFlagBefore > 0
                nRemoved = nFlagBefore;
                method = "UncleanRejectFlagsBecauseCountDifferenceWasZero";
                warningText = "ICA removal inferred from unclean reject flags because component-count difference was zero";
            elseif isfinite(nFlagAfter) && nFlagAfter > 0
                nRemoved = nFlagAfter;
                method = "FinalRejectFlagsBecauseCountDifferenceWasZero";
                warningText = "ICA removal inferred from final reject flags because component-count difference was zero";
            end
        end

        return;
    end

    warningText = "Final file has more ICA components than unclean file; component removal could not be inferred from component counts";
end

if isfinite(nFlagAfter) && nFlagAfter > 0
    nRemoved = nFlagAfter;
    method = "FinalRejectFlags";
    return;
end

if isfinite(nFlagBefore) && nFlagBefore > 0
    nRemoved = nFlagBefore;
    method = "UncleanRejectFlags";
    return;
end

method = "Unavailable";
warningText = "ICA component removal unavailable: no explicit removal count, no usable final ICA component count, and no positive ICA rejection flags";

if isfinite(nFlagBefore) && nFlagBefore == 0
    warningText = warningText + "; unclean-file reject flags were zero and were not treated as evidence of zero removed components";
end

end

function [nRemoved, indicesText, method] = get_explicit_ica_removal_count(EEGfinal, EEGunclean, sidecarFile, cfg)

nRemoved = NaN;
indicesText = "";
method = "";

[nRemoved, indicesText] = count_removed_ics_from_sidecar(sidecarFile);

if isfinite(nRemoved)
    method = "ICARejectionSidecar";
    return;
end

[nRemoved, indicesText] = count_removed_ics_from_eeg_explicit(EEGfinal);

if isfinite(nRemoved)
    method = "FinalExplicitICARejectionMetadata";
    return;
end

[nRemoved, indicesText] = count_removed_ics_from_eeg_explicit(EEGunclean);

if isfinite(nRemoved)
    method = "UncleanExplicitICARejectionMetadata";
    return;
end

if isfield(cfg, 'parseICARejectionFromHistory') && cfg.parseICARejectionFromHistory
    [nRemoved, indicesText] = count_removed_ics_from_history(EEGfinal);

    if isfinite(nRemoved)
        method = "FinalHistoryPopSubcomp";
        return;
    end

    [nRemoved, indicesText] = count_removed_ics_from_history(EEGunclean);

    if isfinite(nRemoved)
        method = "UncleanHistoryPopSubcomp";
        return;
    end
end

end

function [nRemoved, indicesText] = count_removed_ics_from_sidecar(sidecarFile)

nRemoved = NaN;
indicesText = "";

if exist(sidecarFile, 'file') ~= 2
    return;
end

try
    S = load(sidecarFile);
catch
    return;
end

names = fieldnames(S);

for i = 1: numel(names)
    value = S.(names{i});
    [nRemoved, indicesText] = count_removed_ics_from_value(value);

    if isfinite(nRemoved)
        return;
    end
end

end

function [nRemoved, indicesText] = count_removed_ics_from_eeg_explicit(EEG)

nRemoved = NaN;
indicesText = "";

if isempty(EEG)
    return;
end

if isfield(EEG, 'etc') && ~isempty(EEG.etc)
    [nRemoved, indicesText] = count_removed_ics_from_value(EEG.etc);

    if isfinite(nRemoved)
        return;
    end
end

if isfield(EEG, 'reject') && ~isempty(EEG.reject)
    candidateFields = {'gcompreject', 'rejmanual', 'rejkurt', 'rejskew', 'rejfreq', 'rejconst', 'rejthresh'};

    for f = 1: numel(candidateFields)
        fn = candidateFields{f};

        if isfield(EEG.reject, fn)
            x = EEG.reject.(fn);
            x = double(x(:));
            idx = find(x > 0 & isfinite(x));

            if ~isempty(idx)
                nRemoved = numel(idx);
                indicesText = join_component_indices(idx);
                return;
            end
        end
    end
end

end

function [nRemoved, indicesText] = count_removed_ics_from_value(value)

nRemoved = NaN;
indicesText = "";

if isempty(value)
    return;
end

if isnumeric(value) || islogical(value)
    x = double(value(:));
    x = x(isfinite(x));

    if isempty(x)
        return;
    end

    if islogical(value) || all(ismember(unique(x), [0 1])) && numel(x) > 1
        idx = find(x > 0);
        nRemoved = numel(idx);
        indicesText = join_component_indices(idx);
    elseif numel(x) == 1
        nRemoved = x(1);
        indicesText = "";
    else
        idx = unique(round(x(:)))';
        idx = idx(isfinite(idx) & idx > 0);
        nRemoved = numel(idx);
        indicesText = join_component_indices(idx);
    end

    return;
end

if istable(value)
    variableNames = string(value.Properties.VariableNames);
    candidateNames = ["BadComponents", "badComponents", "BadICs", "badICs", "RejectedComponents", "rejectedComponents", "RemovedComponents", "removedComponents", "componentsToRemove", "compsToRemove", "ICsToRemove", "ManualICs", "manualICs", "NRemovedICAComponents", "nRemovedICAComponents", "ICAComponentsRemoved"];

    for c = 1: numel(candidateNames)
        idx = find(variableNames == candidateNames(c), 1, 'first');

        if ~isempty(idx)
            [nRemoved, indicesText] = count_removed_ics_from_value(value.(variableNames(idx)));

            if isfinite(nRemoved)
                return;
            end
        end
    end

    return;
end

if isstruct(value)
    candidateNames = {'NRemovedICAComponents', 'nRemovedICAComponents', 'ICAComponentsRemoved', 'icaComponentsRemoved', 'removedICAComponents', 'RemovedICAComponents', 'removedICs', 'RemovedICs', 'badICs', 'BadICs', 'RejectedICAComponents', 'rejectedICAComponents', 'RejectedComponents', 'rejectedComponents', 'componentsToRemove', 'compsToRemove', 'ICsToRemove', 'ManualICs', 'manualICs'};

    for c = 1: numel(candidateNames)
        fn = candidateNames{c};

        if isfield(value, fn)
            [nRemoved, indicesText] = count_removed_ics_from_value(value.(fn));

            if isfinite(nRemoved)
                return;
            end
        end
    end
end

end

function [nRemoved, indicesText] = count_removed_ics_from_history(EEG)

nRemoved = NaN;
indicesText = "";

if isempty(EEG) || ~isfield(EEG, 'history') || isempty(EEG.history)
    return;
end

historyText = char(string(EEG.history));
tokens = regexp(historyText, 'pop_subcomp\s*\([^,]+,\s*\[([^\]]*)\]', 'tokens');

if isempty(tokens)
    return;
end

lastToken = tokens{end}{1};
nums = regexp(lastToken, '[-+]?\d+', 'match');

if isempty(nums)
    return;
end

idx = str2double(nums(:));
idx = idx(isfinite(idx) & idx > 0);
idx = unique(round(idx(:)))';
nRemoved = numel(idx);
indicesText = join_component_indices(idx);

end

function [nRemoved, method, warningText] = infer_zero_ica_removal_from_absent_pop_subcomp(EEGfinal, EEGunclean, nUncleanICAComponents, cfg)

nRemoved = NaN;
method = "";
warningText = "";

if ~isfield(cfg, 'assumeNoPopSubcompMeansZero') || ~cfg.assumeNoPopSubcompMeansZero
    return;
end

if ~isfinite(nUncleanICAComponents) || nUncleanICAComponents <= 0
    return;
end

[finalHasHistory, finalHasPopSubcomp, finalHasPostICAEvidence] = inspect_ica_history_for_zero_removal(EEGfinal);
[uncleanHasHistory, uncleanHasPopSubcomp, uncleanHasPostICAEvidence] = inspect_ica_history_for_zero_removal(EEGunclean);

if finalHasPopSubcomp || uncleanHasPopSubcomp
    return;
end

if finalHasHistory && finalHasPostICAEvidence
    nRemoved = 0;
    method = "FinalHistoryNoPopSubcompAssumedZero";
    warningText = "No pop_subcomp command was found in final-file history despite post-ICA processing evidence; ICA components removed set to zero";
    return;
end

if uncleanHasHistory && uncleanHasPostICAEvidence
    nRemoved = 0;
    method = "UncleanHistoryNoPopSubcompAssumedZero";
    warningText = "No pop_subcomp command was found in unclean-file history despite ICA evidence; ICA components removed set to zero";
    return;
end

end

function [hasHistory, hasPopSubcomp, hasPostICAEvidence] = inspect_ica_history_for_zero_removal(EEG)

hasHistory = false;
hasPopSubcomp = false;
hasPostICAEvidence = false;

if isempty(EEG) || ~isfield(EEG, 'history') || isempty(EEG.history)
    return;
end

hasHistory = true;
historyText = char(string(EEG.history));
hasPopSubcomp = ~isempty(regexp(historyText, 'pop_subcomp\s*\(', 'once'));
hasPostICAEvidence = contains(historyText, 'pop_runica') || contains(historyText, 'icaweights') || contains(historyText, 'pop_interp') || contains(historyText, 'pop_reref') || contains(historyText, '_rest_processed_unclean_Not_interpolated_Not_referenced.set');

end

function txt = join_component_indices(idx)

idx = double(idx(:));
idx = idx(isfinite(idx) & idx > 0);

if isempty(idx)
    txt = "";
else
    txt = strjoin(string(idx(:)'), "|");
end

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

function S = summarize_metric(T, groupVariable, groupLevel, metricName, metricLabel)

S = table();
S.GroupVariable = string(groupVariable);
S.GroupLevel = string(groupLevel);
S.Metric = string(metricName);
S.MetricLabel = string(metricLabel);

if isempty(T) || height(T) == 0 || ~ismember(metricName, T.Properties.VariableNames)
    S.NSubjects = 0;
    S.NFinite = 0;
    S.NWithValueAboveZero = NaN;
    S.PercentWithValueAboveZero = NaN;
    S.Mean = NaN;
    S.SD = NaN;
    S.Median = NaN;
    S.Min = NaN;
    S.Max = NaN;
    return;
end

x = double(T.(metricName));
xf = x(isfinite(x));

S.NSubjects = height(T);
S.NFinite = numel(xf);

if isempty(xf)
    S.NWithValueAboveZero = NaN;
    S.PercentWithValueAboveZero = NaN;
    S.Mean = NaN;
    S.SD = NaN;
    S.Median = NaN;
    S.Min = NaN;
    S.Max = NaN;
    return;
end

S.NWithValueAboveZero = sum(xf > 0);
S.PercentWithValueAboveZero = 100 * sum(xf > 0) / numel(xf);
S.Mean = mean(xf, 'omitnan');
S.SD = std(xf, 0, 'omitnan');
S.Median = median(xf, 'omitnan');
S.Min = min(xf);
S.Max = max(xf);

end

function textBlock = build_manuscript_text(Tok)

if isempty(Tok) || height(Tok) == 0
    textBlock = "No successfully loaded subjects were available.";
    return;
end

noisy = double(Tok.NoisyChannelsRemoved);
ica = double(Tok.ICAComponentsRemoved);

pctNoisy = percent_positive(noisy);
pctICA = percent_positive(ica);

rangeNoisy = range_text(noisy);
rangeICA = range_text(ica);

medNoisyDep = group_median(Tok, "BD_Depressed", "NoisyChannelsRemoved");
medNoisyEuth = group_median(Tok, "BD_Euthymic", "NoisyChannelsRemoved");
medNoisyHC = group_median(Tok, "HC", "NoisyChannelsRemoved");
medNoisySib = group_median(Tok, "Siblings", "NoisyChannelsRemoved");

medICADep = group_median(Tok, "BD_Depressed", "ICAComponentsRemoved");
medICAEuth = group_median(Tok, "BD_Euthymic", "ICAComponentsRemoved");
medICAHC = group_median(Tok, "HC", "ICAComponentsRemoved");
medICASib = group_median(Tok, "Siblings", "ICAComponentsRemoved");

textBlock = "";
textBlock = textBlock + sprintf('Noisy channels were removed on visual inspection in %.1f%% of datasets; the number of removed channels ranged from %s across subjects, with group medians of %s in depressed BD, %s in euthymic BD, %s in HC, and %s in siblings.\n', pctNoisy, rangeNoisy, format_num(medNoisyDep), format_num(medNoisyEuth), format_num(medNoisyHC), format_num(medNoisySib));
textBlock = textBlock + sprintf('ICA components reflecting ocular activity, muscle activity, movement, or clear cardiac-field artifact were removed in %.1f%% of datasets; the number of removed components ranged from %s across subjects, with group medians of %s in depressed BD, %s in euthymic BD, %s in HC, and %s in siblings.', pctICA, rangeICA, format_num(medICADep), format_num(medICAEuth), format_num(medICAHC), format_num(medICASib));

end

function p = percent_positive(x)

x = double(x(:));
x = x(isfinite(x));

if isempty(x)
    p = NaN;
else
    p = 100 * sum(x > 0) / numel(x);
end

end

function txt = range_text(x)

x = double(x(:));
x = x(isfinite(x));

if isempty(x)
    txt = "N/A";
else
    txt = sprintf('%s-%s', format_num(min(x)), format_num(max(x)));
end

end

function m = group_median(T, stage, metricName)

mask = string(T.ClinicalStage) == string(stage);
x = double(T.(metricName));
x = x(mask & isfinite(x));

if isempty(x)
    m = NaN;
else
    m = median(x, 'omitnan');
end

end

function s = format_num(x)

if ~isfinite(x)
    s = "N/A";
    return;
end

if abs(x - round(x)) < 1e-9
    s = string(sprintf('%d', round(x)));
else
    s = string(sprintf('%.1f', x));
end

end
