# Reproducibility notes

## Analysis overview

The main script performs the following operations:

1. Loads resting R-locked channel waveform outputs and resting metrics.
2. Builds subject x channel x time arrays.
3. Computes window-averaged scalp maps for peri-R CFA, 100-200 ms, 200-300 ms, and 300-400 ms windows.
4. Constructs group-blind topographic templates.
5. Computes leave-one-subject-out field scores orthogonalized to the peri-R CFA template.
6. Runs the primary clinical-stage omnibus and planned contrasts with age and sex adjustment.
7. Runs sensitivity analyses for peri-R CFA, mean heart rate, lnRMSSD, and smoking.
8. Runs pseudo-event negative-control models.
9. Runs exploratory channel x time cluster localization.
10. Generates paper figures and supplementary figures.

## Primary endpoint

The primary endpoint is:

```text
RLocked100to200FieldScore_LOSO_uV
```

It is a leave-one-subject-out, group-blind, CFA-orthogonalized 100-200 ms field score. The sign is oriented so that the healthy-control group mean is positive.

## Primary model

```text
RLocked100to200FieldScore_LOSO_uV ~ ClinicalStage + Age + Sex
```

ClinicalStage levels:

```text
HC, Siblings, BD_Euthymic, BD_Depressed
```

Primary planned contrasts:

```text
BD_Depressed - HC
BD_Depressed - BD_Euthymic
BD_Depressed - Siblings
Siblings - HC
BD_Euthymic - HC
```

Permutation inference uses Freedman-Lane permutation. Planned contrasts are Holm-corrected.
