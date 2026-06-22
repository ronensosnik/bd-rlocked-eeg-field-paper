# Data dictionary

## Key analysis variables

| Variable | Meaning |
|---|---|
| `Subject` | De-identified internal subject label. Review before public release. |
| `ClinicalStage` | Four-level clinical group: HC, Siblings, BD_Euthymic, BD_Depressed. |
| `Age` | Age in years. |
| `Sex` | Sex coding used in the analysis; see project documentation before reuse. |
| `RLocked100to200FieldScore_LOSO_uV` | Primary leave-one-subject-out 100-200 ms R-locked distributed-field score. |
| `CFAScore_LOSO_uV` | Peri-R cardiac-field/topography score from the -25 to +25 ms window. |
| `EarlyFieldScore_LOSO_uV` | CFA-orthogonalized 200-300 ms distributed-field score. |
| `LateFieldScore_LOSO_uV` | CFA-orthogonalized 300-400 ms distributed-field score. |
| `Rest_MeanHR_BPM` | Mean resting heart rate in beats/min. |
| `Rest_lnRMSSD` | Natural-log RMSSD heart-rate variability metric. |
| `MADRS` | Montgomery-Asberg Depression Rating Scale score. |
| `YMRS` | Young Mania Rating Scale score. |
| `GAF` | Global Assessment of Functioning score. |
| `MedBurden` | Medication burden summary used in exploratory BD-only models. |
| `PermutationP` | Freedman-Lane permutation p value. |
| `HolmP` | Holm-adjusted p value for the relevant contrast family. |
| `FDR_BH_Q` | Benjamini-Hochberg FDR q value for exploratory families. |

## Window definitions

| Window | Definition |
|---|---|
| Peri-R CFA | -25 to +25 ms relative to R peak |
| Primary field | 100 to 200 ms post-R |
| Adjacent early field | 200 to 300 ms post-R |
| Later post-R field | 300 to 400 ms post-R |

All predefined window averages use start-inclusive, end-exclusive boundaries.
