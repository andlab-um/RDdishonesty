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
 ├── dishonesty_beha               
 │    ├── OT_questionnaire data.xlsx  # behavior data  
 │    └── fmri_data_link.md          
 ├── code                
 │    ├── R
 │    │    ├── PCAcode.r
 │    │    ├── analysis.r
 │    │    ├── data.csv
 │    │    ├── pca.csv
 │    │    └── pp.r
 │    └── Python
 │    │    ├── pca.py
 │    │    ├── questionnaier.py
 │    │    ├── roi_signal_change_aal.py
 │    │    └── tsne.py
 ├──  models            
 │    ├── MATLAB
 │    │    ├── TDTmvpa.m
 │    │    ├── mvpaR_main.m
 │    │    └── parsave.m
 │    ├── Python
 │    │    ├── mvpaR.py
 │    │    ├── mvpa_perm_all_cond.py
 │    │    ├── mvpa_perm_all_cond_neurosynth.py
 │    │    ├── rsa_roi.py
 │    │    └── images
 │    │        ├── OT_masked_accuracies.nii
 │    │        ├── OT_p_adjusted.nii
 │    │        ├── OT_p_unadjusted.nii
 │    │        ├── PL_masked_accuracies.nii
 │    │        ├── PL_p_adjusted.nii
 │    │        ├── PL_p_unadjusted.nii
 │    │        ├── diff_masked_accuracies.nii
 │    │        ├── diff_p_adjusted.nii
 │    │        └── diff_p_unadjusted.nii
 │    └── README.md
 ├──  MVPA_plots         
 │    ├── Wholebrain
 │    │    ├── niis
 │    │         ├── OT_masked_accuracies.nii
 │    │         ├── OT_p_adjusted.nii
 │    │         ├── OT_p_unadjusted.nii
 │    │         ├── PL_masked_accuracies.nii
 │    │         ├── PL_p_adjusted.nii
 │    │         ├── PL_p_unadjusted.nii
 │    │         ├── diff_masked_accuracies.nii
 │    │         ├── diff_p_adjusted.nii
 │    │         └── diff_p_unadjusted.nii
 │    │    ├── OT_lh_caud.jpg
 │    │    ├── OT_lh_lat.jpg
 │    │    ├── OT_lh_med.jpg
 │    │    ├── OT_lh_ros.jpg
 │    │    ├── OT_rh_caud.jpg
 │    │    ├── OT_rh_lat.jpg
 │    │    ├── OT_rh_med.jpg
 │    │    ├── OT_rh_ros.jpg
 │    │    ├── PL_lh_caud.jpg
 │    │    ├── PL_lh_lat.jpg
 │    │    ├── PL_lh_med.jpg
 │    │    ├── PL_lh_ros.jpg
 │    │    ├── PL_rh_caud.jpg
 │    │    ├── PL_rh_lat.jpg
 │    │    ├── PL_rh_med.jpg
 │    │    ├── PL_rh_ros.jpg
 │    │    ├── diff_lh_caud.jpg
 │    │    ├── diff_lh_lat.jpg
 │    │    ├── diff_lh_med.jpg
 │    │    ├── diff_lh_ros.jpg
 │    │    ├── diff_rh_caud.jpg
 │    │    ├── diff_rh_lat.jpg
 │    │    ├── diff_rh_med.jpg
 │    │    └── diff_rh_ros.jpg
 │    └── Neurosynth
 │    │    ├── niis
 │    │         ├── OT_masked_accuracies.nii
 │    │         ├── OT_p_adjusted.nii
 │    │         ├── OT_p_unadjusted.nii
 │    │         ├── PL_masked_accuracies.nii
 │    │         ├── PL_p_adjusted.nii
 │    │         ├── PL_p_unadjusted.nii
 │    │         ├── diff_masked_accuracies.nii
 │    │         ├── diff_p_adjusted.nii
 │    │         └── diff_p_unadjusted.nii
 │    │    ├── diff_lh_caud.jpg
 │    │    ├── diff_lh_lat.jpg
 │    │    ├── diff_lh_med.jpg
 │    │    ├── diff_lh_ros.jpg
 │    │    ├── diff_rh_caud.jpg
 │    │    ├── diff_rh_lat.jpg
 │    │    ├── diff_rh_med.jpg
 │    │    └── diff_rh_ros.jpg
 └── README.md
```
**Note 1**: Before running the codes, change the directories to the path of corresponding locations. <br />
**Note 2**: All fMRI data with descriptions of the variables is put in openfmri. <br />

___

## Data

- The behavior data for the experiment are in `beha_data.csv`
- All fMRI data with descriptions of the variables is put in openfmri

