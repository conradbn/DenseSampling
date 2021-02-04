function DDK2_post_proc(subj,year,temp_dir,proc_dir,orig_dir)
%% Perform several post afni_proc operations
%% Move output text files to results directory
cd(orig_dir)
sid = [subj '_' year];
unix(['mv *' sid ' ' temp_dir '/' sid '.results']);
unix(['mv 3dDeconvolve.' sid '* ' temp_dir '/' sid '.results']);

%% Create TSNR text files
cd([temp_dir '/' sid '.results']);
unix('3dmaskave -quiet -mask full_mask*.HEAD TSNR.vreg*.HEAD > TSNR.vreg.mean.txt');

%% Create masked stats files
unix(['3dcalc -prefix stats.' sid '_REML_mask+tlrc'...
      ' -a stats.' sid '_REML+tlrc.HEAD'...
      ' -b mask_epi_anat.' sid '+tlrc.HEAD -expr "a*b"']);
unix(['3dcalc -prefix stats.' sid '_mask+tlrc'...
      ' -a stats.' sid '+tlrc.HEAD'...
      ' -b mask_epi_anat.' sid '+tlrc.HEAD -expr "a*b"']);
  
unix(['3dcalc -prefix exemplar_level_stats.' sid '_REML_mask+tlrc'...
      ' -a exemplar_level_stats.' sid '_REML+tlrc.HEAD'...
      ' -b mask_epi_anat.' sid '+tlrc.HEAD -expr "a*b"']);
unix(['3dcalc -prefix exemplar_level_stats.' sid '_mask+tlrc'...
      ' -a exemplar_level_stats.' sid '+tlrc.HEAD'...
      ' -b mask_epi_anat.' sid '+tlrc.HEAD -expr "a*b"']);


%% Compress all BRIK files
disp('**** Compressing all BRIK files to save space... ****');
unix('pigz *.BRIK')

%% Move output from temporary directory
disp('**** Moving results to server... ****');
%unix(['mv ' temp_dir '/' sid '.results ' proc_dir '/']);
unix(['rsync -a --info=progress2 --remove-source-files ' temp_dir '/' sid '.results/ ' proc_dir]);