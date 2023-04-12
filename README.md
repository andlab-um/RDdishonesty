# Reward and self-consistency: Dissecting the role of social brain and cognitive control in moral decisions <img src="https://github.com/andlab-um/RDdishonesty/blob/main/demo.png" align="right" width="461px">

[![GitHub repo size](https://img.shields.io/github/repo-size/andlab-um/IMQ?color=brightgreend&logo=github)](https://github.com/andlab-um/IMQ)
[![Twitter URL](https://img.shields.io/twitter/url?label=%40ANDlab3&style=social&url=https%3A%2F%2Ftwitter.com%ANDlab3)](https://twitter.com/ANDlab3)
[![Twitter URL](https://img.shields.io/twitter/url?label=%40xuxinyi_julia&style=social&url=https%3A%2F%2Ftwitter.com%2Fxuxinyi_julia)](https://twitter.com/xuxinyi_julia)


___

## Highlights
- The behavioral results can be best fitted by a multi-attribute time-dependent drift diffusion model (tDDM), in which self-interest and self-consistency had different onset timings and drift rates.
- Univariate analysis on the fMRI data showed significant activations in regions related to cognitive control and reward in the dishonesty condition.
- The drift rates of reward and the related brain regions were correlated to the respective ROIs, which was further confirmed through fMRI functional connectivity analysis.

___

## Structure

**This repository contains:**
```
root
├── README.md
├── demo.png
├── dishonesty_behav
│   ├── 1.behavior_vis.R
│   ├── 2.behavior_brain.R
│   ├── 3.ddmComparison.R
│   ├── 4.MTanalysis.R
│   └── behav_ddm
│       ├── fitDDMs
│       │   ├── latDDM_Rcpp.cpp
│       │   ├── mDDM_Rcpp.cpp
│       │   ├── sDDM_Rcpp.cpp
│       │   └── tDDM_Rcpp.cpp
│       ├── fitting_code
│       │   ├── latDDM.R
│       │   ├── mDDM.R
│       │   ├── sDDM.R
│       │   └── tDDM.R
│       └── parameter_recovery
│           ├── fitSimulatedData
│           │   ├── fit_latDDM_tSims.R
│           │   ├── fit_mDDM_tSims.R
│           │   ├── fit_sDDM_tSims.R
│           │   ├── fit_tDDM_tSims.R
│           │   ├── results_latDDM_tSims
│           │   │   ├── simFits_latFit_tSim.RData
│           │   │   └── simFits_latFit_tSim.csv
│           │   ├── results_mDDM_tSims
│           │   │   ├── simFits_mFit_tSim.RData
│           │   │   └── simFits_mFit_tSim.csv
│           │   ├── results_sDDM_tSims
│           │   │   ├── simFits_sFit_tSim.RData
│           │   │   └── simFits_sFit_tSim.csv
│           │   └── results_tDDM_tSims
│           │       ├── simFits_tFit_tSim.RData
│           │       └── simFits_tFit_tSim.csv
│           ├── simDDMs
│           │   ├── simulate_mDDM_lrt_Rcpp.cpp
│           │   └── simulate_tDDM_lrt_Rcpp.cpp
│           └── simulateRT
│               ├── simulate_mDDM.R
│               └── simulate_tDDM.R
└── dishonesty_fMRI
    ├── 1.GLM
    │   ├── firstLevel.m
    │   └── secondLevel.m
    ├── 2.ROIextraction
    │   ├── 1.meanbeta.ipynb
    │   └── 2.meanbeta_vis.R
    ├── 3.time_courses
    │   ├── Functions
    │   │   ├── ci95plotmulticoloffalpha.m
    │   │   ├── concatenate.m
    │   │   ├── fill_around_line.m
    │   │   ├── fill_around_line_multicol.m
    │   │   ├── fillsteplotcol.m
    │   │   ├── steplotmulticoloffalpha.m
    │   │   └── violaPoints.m
    │   ├── mask_reslice.m
    │   ├── remove_confounds.m
    │   ├── time_course_beta_2attributes.m
    │   ├── time_course_beta_liexattributes.m
    │   └── upsample_fmri.m
    ├── 4.RSA
    │   ├── 1.ISRSA-prepdata.ipynb
    │   ├── 2.run_ISRSA.ipynb
    │   ├── 2.run_ISRSA_questionnaire.ipynb
    │   ├── 3.plot_results.ipynb
    │   └── 3.plot_results_ques.ipynb
    └── fc_RDM.Rmd


```

___

## Data

- The behavior data for the experiment are in `beha_data.csv`
- All fMRI data with descriptions of the variables is put in openfmri

