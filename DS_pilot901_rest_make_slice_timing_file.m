
%% Make slice timing file for multiband development scans
% Price_241319.23.01.15-54-58.WIP_fMRI_mb3_229iso.01.nii
% Price_241319.25.01.16-06-00.WIP_fMRI_mb4_229iso.01.nii

% These scans used the default slice order (odds/evens)

% TR = 1.9383;
% mb_factor = 3;
% nslices = 54;

TR = .9638;
mb_factor = 4;
nslices = 52;

block = nslices/mb_factor;
slice_order = [1:2:block,2:2:block];
slice_order = repmat(slice_order,1,mb_factor);


[~,I] = sort(slice_order);
slice_order_TR = ([1:nslices]-1) .* (TR/nslices);
slice_order_TR_sort = slice_order_TR(I);

% Set output filename
out = ['slice_order_AFNI_oddsevens_mb' num2str(mb_factor) '_' num2str(TR) 'TR_' num2str(nslices) 'slices.txt'];
dlmwrite(out,slice_order_TR_sort,'delimiter',' ');