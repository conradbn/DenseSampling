function out = DDK2_run_exemplar_GLM(subj,year,temp_dir,orig_dir,onsets_dir,exemplars,afni_proc_cmd)
%% Run exemplar-level GLM on unsmoothed data for Representational Similarity Analysis (RSA)

%% First create the scaled/unsmoothed version of each run
results_dir = [temp_dir '/' subj '_' year '.results'];
cd(results_dir);
runs = dir('pb04.*.r*.volreg+tlrc.HEAD');
for run = 1:numel(runs)
    data = runs(run).name;
    split = strsplit(data,'.');
    data_scale = ['pb04b.' split{2} '.' split{3} '.volreg_scale'];
    mean = ['rm.mean_' num2str(run) '+tlrc.HEAD'];
    % Run the scaling process
    unix(['3dTstat -prefix ' mean ' ' data]);
    unix(['3dcalc -a ' data ' -b ' mean ...
          ' -expr "min(200, a/b*100)*step(a)*step(b)"'...
          ' -prefix ' data_scale]);
end
% Remove temporary mean files and gzip the final BRIK files
unix('rm -rf rm.mean*');

%% Create original 3dDeconvole command
% This step produces the 3dDeconvolve command which we will further modify
% below
cd(orig_dir)
add_flags = [' -write_3dD_script 3dDeconvolve.' subj '_' year '.condition_level.txt '...
             ' -write_3dD_prefix condition_level_ -execute']; 
afni_proc_cmd2 = [afni_proc_cmd add_flags];
unix(afni_proc_cmd2);

%% Edit afni_proc and create new 3dDeconvolve command
% Set new stimulus onset filenames
onsets_txt = '-regress_stim_times ';
stim_labels = '-regress_stim_labels ';
for ii = 1:numel(exemplars)
    onsets_txt = [onsets_txt onsets_dir '/*_' exemplars{ii} '.txt ']; 
    stim_labels = [stim_labels exemplars{ii} ' '];
end
onsets_txt = [onsets_txt ' '...
              onsets_dir '/*Error.txt '...
              onsets_dir '/*Omission.txt '];
stim_labels = [stim_labels ' error omiss '];

% Insert new stimulus onset filenames
start_expr = '-regress_stim_times';
start = regexp(afni_proc_cmd2,start_expr);
stop_expr = '-regress_basis';
stop = regexp(afni_proc_cmd2,stop_expr);
afni_proc_cmd2(start:stop-1) = [];
afni_proc_cmd2 = [afni_proc_cmd2 ' ' onsets_txt stim_labels];

% Remove contrast specifications
start_expr = '-num_glt';
start = regexp(afni_proc_cmd2,start_expr);
stop_expr = '-regress_reml_exec';
stop = regexp(afni_proc_cmd2,stop_expr);
afni_proc_cmd2(start:stop-1) = [];

% Run the new afni_proc command
afni_proc_cmd2 = strrep(afni_proc_cmd2,'condition_level','exemplar_level');
unix(afni_proc_cmd2);

% Edit the new command to use the new unsmoothed/scaled input data
decon = fileread(['3dDeconvolve.' subj '_' year '.exemplar_level.txt']);
decon = strrep(decon,'pb06.$subj.r*.scale+tlrc.HEAD','pb04b.$subj.r*.volreg_scale+tlrc.HEAD');
decon = strrep(decon,'stimuli/',[onsets_dir '/']);

% Write new command
dlmwrite(['3dDeconvolve.' subj '_' year '.exemplar_level.txt'],decon,'delimiter','');

%% Run new command
cd(results_dir)
unix(['tcsh -xef ' orig_dir '/3dDeconvolve.' subj '_' year '.exemplar_level.txt']);

% Display any large pairwise correlations from the X-matrix
unix('1d_tool.py -show_cormat_warnings -infile exemplar_level_X.xmat.1D 2>&1 | tee exemplar_level_out.cormat_warn.txt')

% Execute the 3dREMLfit script, written by 3dDeconvolve
unix(['tcsh -x exemplar_level_stats.REML_cmd -GOFORIT -Rwherr exemplar_level_errts.' subj '_' year '_REMLwh']);


