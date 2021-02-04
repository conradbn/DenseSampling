%% Set variables
purge;
subj = 'sub-DS901';
year = 'ses-1';
process_dir = '/Volumes/NBL_Projects/DenseSampling/Processed_Data';
temp_dir = '/Users/nbl_imac2/Desktop/sf_afni_tmp';
% % Run process
DDK2_preprocess_pipeline_template(subj,year,process_dir,temp_dir);