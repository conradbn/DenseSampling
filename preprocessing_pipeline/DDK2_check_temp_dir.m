function DDK2_check_temp_dir(temp_dir)
% First verify that temp_dir is specified correctly
if ~strcmp(temp_dir,'/media/sf_afni_tmp') &&...
   ~strcmp(temp_dir,'/Users/nbl_imac2/Desktop/sf_afni_tmp') &&...
   ~strcmp(temp_dir,'/Users/nbl_imac/Desktop/sf_afni_tmp')
    error('*** YOUR temp_dir SETTING DOES NOT SEEM CORRECT - It should be (MACHINE)/sf_afni_tmp - OTHERWISE BAD THINGS CAN HAPPEN ***');
end 
% Clear temp_dir of data
unix('rm -rf /media/sf_afni_tmp/*'); % Hard coded to avoid any badness from rm command
unix('rm -rf /Users/nbl_imac2/Desktop/sf_afni_tmp/*');
unix('rm -rf /Users/nbl_imac/Desktop/sf_afni_tmp/*');