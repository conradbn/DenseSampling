function DS_preprocess_pipeline_template(subj,year,process_dir,temp_dir)
%% NSF DDK2 Project - Single Subject Process Pipeline Template
% This script strings together the subprocesses needed to preprocess
% subject data

%% Start process timer and write command window output to text file
tic
diary_fname = [process_dir '/' subj '_' year '_command_window_output_' datestr(now,'mm-dd-yyyy-HHMM') '.txt'];
diary(diary_fname); diary on;

%% Make sure temp_dir is correctly specified and clear
DDK2_check_temp_dir(temp_dir);

%% Get image file names
[raw_data_files] = DS_get_filenames(subj,year,process_dir); 

%% Process folder creation and data copy
[orig_dir,proc_dir,onsets_dir,raw_data_files] = DDK2_process_folder_setup(process_dir,subj,year,raw_data_files);

%% Extract trial onset times and create txt files for AFNI
[conditions,exemplars] = DDK2_onset_file_creation(subj,year,orig_dir,onsets_dir,raw_data_files); %#ok<*ASGLU>

%% Run afni_proc.py command to generate process script
[afni_proc_cmd] = DDK2_generate_proc_script(subj,year,orig_dir,raw_data_files,proc_dir,onsets_dir,temp_dir);

%% Run processing script
DDK2_run_proc_script(orig_dir);

%% Run additional exemplar-level GLM
DDK2_run_exemplar_GLM(subj,year,temp_dir,orig_dir,onsets_dir,exemplars,afni_proc_cmd);

%% Perform post-processing operations
% Includes mean TSNR calculation, masking of stats files, compression of
% BRIK files, and moving results to the server
DDK2_post_proc(subj,year,temp_dir,proc_dir,orig_dir);

%% Save final workspace
save([process_dir '/' subj '_' year '_proc_workspace']);

%% Turn off command window output writing
toc
diary off;
